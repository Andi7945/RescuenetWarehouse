# Fix Safety Datasheet Download Type Error

## Problem Summary

When printing containers with safety datasheets on web, a type error occurs:
```
TypeError: Instance of 'ClientException': type 'ClientException' is not a subtype of type 'JavaScriptObject'
```

**Root Cause:** FlutterFire bug in `_flutterfire_internals.dart:94` where `_testException()` unsafely casts all exceptions to `JSError` without type checking. When `getData()` internally uses `http.readBytes()` and it fails (CORS/network/auth), the `ClientException` hits this buggy cast.

**Impact:** Users cannot download safety datasheets on web platform.

## Solution Overview

Bypass the buggy `getData()` code path by:
1. Using `getDownloadURL()` to get authenticated Firebase Storage URL
2. Fetching the file directly with `http.get()` (outside the guard() wrapper)
3. Properly catching and handling errors according to Firebase best practices

This follows the official Firebase error handling pattern and avoids the FlutterFire internal bug.

## Implementation Plan

### Step 1: Add http package dependency

**File:** `pubspec.yaml`

**Action:** Verify `http` package is in dependencies. If not, add it:
```yaml
dependencies:
  http: ^1.2.0  # Or latest version
```

**Verification:** Run `flutter pub get`

### Step 2: Update SafetyDatasheetService imports

**File:** `lib/features/printing/services/safety_datasheet_service.dart`

**Action:** Add http import at the top:
```dart
import 'package:http/http.dart' as http;
```

**Why:** We'll use `http.get()` for direct download instead of `getData()`

### Step 3: Rewrite _fetchFromStorage() method

**File:** `lib/features/printing/services/safety_datasheet_service.dart`

**Location:** Lines 106-144 (current implementation)

**Action:** Replace the entire `_fetchFromStorage()` method with:

```dart
/// Fetch PDF bytes from Firebase Storage.
///
/// Uses a two-step approach to avoid FlutterFire bug:
/// 1. Get authenticated download URL via Firebase SDK
/// 2. Fetch file directly with HTTP client (no guard() wrapper)
///
/// This bypasses the type cast bug in _flutterfire_internals while still
/// respecting Firebase authentication and security rules.
///
/// Throws [FirebaseException] with descriptive error codes:
/// - `object-not-found`: File doesn't exist
/// - `unauthorized`: Permission denied or not authenticated
/// - `download-failed`: HTTP download failed (CORS, network, etc.)
/// - `download-error`: Other errors
static Future<Uint8List> _fetchFromStorage(FirebaseDocument document) async {
  try {
    // Step 1: Get authenticated download URL from Firebase
    // This respects security rules and handles Firebase-level errors
    final ref = FirebaseStorage.instance.ref(document.url);
    final downloadUrl = await ref.getDownloadURL();

    // Step 2: Fetch the file directly with HTTP
    // This avoids the buggy getData() → http.readBytes() → guard() path
    final response = await http.get(Uri.parse(downloadUrl));

    if (response.statusCode != 200) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'download-failed',
        message: 'HTTP ${response.statusCode}: Failed to download safety datasheet from ${document.url}',
      );
    }

    return response.bodyBytes;
  } on FirebaseException {
    // Firebase exceptions (auth, not found, permissions) - already well formatted
    rethrow;
  } catch (e) {
    // Network errors, CORS issues, or other HTTP client errors
    throw FirebaseException(
      plugin: 'firebase_storage',
      code: 'download-error',
      message: 'Error downloading safety datasheet from "${document.url}": ${_formatHttpError(e)}',
    );
  }
}
```

**Why this works:**
- `getDownloadURL()` is wrapped by Firebase's guard() but only handles Firebase JS errors
- The HTTP download happens OUTSIDE guard(), so no type cast bug
- Follows official Firebase error handling pattern: `try { } on FirebaseException { }`
- Clear error messages for debugging

### Step 4: Add helper function for HTTP error formatting

**File:** `lib/features/printing/services/safety_datasheet_service.dart`

**Location:** After `_fetchFromStorage()`, replace existing `_formatErrorMessage()` with:

```dart
/// Format HTTP/network errors for better debugging.
///
/// Pure function that extracts useful information from error objects.
/// Provides actionable guidance for common failure scenarios.
static String _formatHttpError(Object error) {
  final errorStr = error.toString();

  // CORS is the most common web-specific issue
  if (errorStr.contains('CORS') ||
      errorStr.contains('Cross-Origin') ||
      errorStr.contains('XMLHttpRequest error')) {
    return 'CORS configuration issue. The file exists but browser security blocks access. '
           'Configure Firebase Storage CORS: https://firebase.google.com/docs/storage/web/download-files#cors_configuration';
  }

  // Network connectivity issues
  if (errorStr.contains('Failed to fetch') ||
      errorStr.contains('NetworkError') ||
      errorStr.contains('SocketException')) {
    return 'Network error. Check internet connection and Firebase Storage availability.';
  }

  // Timeout
  if (errorStr.contains('TimeoutException') || errorStr.contains('timed out')) {
    return 'Download timed out. The file may be too large or network is slow.';
  }

  // Return original for unknown errors
  return errorStr;
}
```

**Why:**
- Pure function (testable, reusable)
- Provides actionable guidance
- Helps with future debugging

### Step 5: Remove unused code

**File:** `lib/features/printing/services/safety_datasheet_service.dart`

**Action:** If there's an old `_formatErrorMessage()` function that's no longer used, remove it.

**Why:** Keep codebase clean (KISS principle)

### Step 6: Test the fix

**Manual Testing (no unit tests needed for startup pace):**

1. **Test successful download:**
   - Open app in Chrome with `flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging`
   - Navigate to a container with a safety datasheet
   - Click print/export safety datasheets
   - **Expected:** PDF downloads and opens successfully

2. **Test file not found error:**
   - Temporarily modify a safety datasheet path to invalid value in Firestore
   - Try to download
   - **Expected:** Clear error message about file not found

3. **Test permission error:**
   - Sign out or use account without storage permissions
   - Try to download
   - **Expected:** Clear error message about permissions/authentication

4. **Test CORS error (if it occurs):**
   - If CORS is not configured, should see actionable CORS error message
   - **Expected:** Error message with link to CORS configuration docs

### Step 7: Hot reload and verify

**Action:**
1. Save all changes
2. Let Flutter hot reload (or press 'r' in terminal)
3. Test the print functionality

**Success criteria:**
- No more type cast errors
- Clear error messages if download fails
- Successful PDF download when file exists and is accessible

## Technical Notes

### Why This Approach?

1. **Avoids FlutterFire bug:** By not using `getData()`, we bypass the buggy `guardWebExceptions()` wrapper
2. **Follows Firebase best practices:** Uses `try/on FirebaseException` pattern from official docs
3. **Better error handling:** Separates Firebase errors (auth, not found) from HTTP errors (CORS, network)
4. **KISS principle:** Simple two-step process, no complex error transformation
5. **SRP:** Error formatting is separate pure function
6. **Modularity:** Can reuse this pattern for other Firebase Storage downloads

### Why No Unit Tests?

- Startup pace: Manual testing is sufficient
- Integration with Firebase is better tested manually
- Pure function (`_formatHttpError`) is trivial string matching
- Hot reload makes iteration fast

### Alternative Solutions Considered

1. **Try-catch around getData():** Doesn't work because guard() is inside the Future chain
2. **Fix FlutterFire directly:** Outside our control, would require upstream PR
3. **Use getDownloadURL() with signed URLs:** Same as our solution (what we chose)

### If CORS Issues Persist

After implementing this fix, if CORS errors still occur, configure Firebase Storage CORS:

```bash
# Create cors.json:
[
  {
    "origin": ["*"],
    "method": ["GET"],
    "maxAgeSeconds": 3600
  }
]

# Apply to Firebase Storage bucket:
gsutil cors set cors.json gs://rescuenet-staging.appspot.com
```

## Rollback Plan

If this causes issues:
1. Revert changes to `safety_datasheet_service.dart`
2. Original implementation is in git history
3. No database changes required

## Future Improvements (Post-Launch)

- Consider reporting the type cast bug to FlutterFire team
- Add retry logic for transient network failures
- Add progress indicators for large file downloads
- Cache downloaded datasheets to avoid re-downloading

## Related Files

- `lib/features/printing/services/safety_datasheet_service.dart` - Main changes
- `lib/features/printing/ui/export_actions.dart` - Calls this service (no changes needed)
- Firebase Storage security rules - May need CORS configuration
