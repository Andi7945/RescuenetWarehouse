# Fix Web Safety Datasheet Upload - Platform Compatibility

**Created:** 2025-10-24
**Status:** Ready for Implementation
**Complexity:** Low
**Estimated Time:** 30-45 minutes

## Problem Statement

Safety datasheet uploads crash on web with `Unsupported operation: Platform._pathSeparator` error. The code in `lib/ui/item_edit_page/item_edit_page_signs_single_documents.dart` uses `dart:io` APIs that don't exist on web platforms.

**Root Cause:**
- Uses `Platform.pathSeparator` (web-incompatible)
- Uses `File(path)` from `dart:io` (web-incompatible)
- Assumes `platformFile.path` is non-null (null on web)
- Unnecessarily parses path to extract filename instead of using `platformFile.name`

**Existing Pattern:**
The codebase already has correct patterns in `lib/ui/rescue_pickable_image.dart` that properly handle both web and native platforms using `kIsWeb` checks.

## Architecture Principles

- **SRP**: Keep file picking UI logic separate from upload logic (already separated via `firebase_utils.dart`)
- **KISS**: Use simple platform branching with `kIsWeb` (don't over-engineer with conditional imports)
- **Modularity**: Leverage existing `uploadData()` and `uploadFile()` functions
- **Pure Functions**: Extract filename handling to pure function for testability
- **No Over-Testing**: This is UI glue code; manual testing is sufficient

## Implementation Plan

### Step 1: Read and Understand Current Code

**Task:** Read the buggy file and existing patterns

**Files to read:**
- `lib/ui/item_edit_page/item_edit_page_signs_single_documents.dart` (the buggy file)
- `lib/ui/rescue_pickable_image.dart` (lines 99-115 - the correct pattern)
- `lib/services/firebase_utils.dart` (verify uploadData/uploadFile signatures)

**Analysis points:**
- Identify the `_addNew()` method (lines 41-53)
- Understand the current flow: pick file → extract filename → create File → upload
- Confirm that `uploadData(destination, bytes, mimeType)` and `uploadFile(destination, file)` exist
- Note the UUID generation and FirebaseDocument creation pattern

### Step 2: Fix the Upload Logic

**Task:** Modify `_addNew()` method to support both web and native platforms

**File:** `lib/ui/item_edit_page/item_edit_page_signs_single_documents.dart`

**Changes:**

1. **Add import** (after existing imports):
   ```dart
   import 'package:flutter/foundation.dart' show kIsWeb;
   ```

2. **Replace the entire `_addNew()` method** (lines 41-53) with:
   ```dart
   void _addNew([String? prevId]) async {
     var id = prevId ?? uuid.v4();
     var result = await FilePicker.platform.pickFiles(
       type: FileType.custom,
       allowedExtensions: ['pdf'],
     );

     if (result == null) return;

     var platformFile = result.files.single;
     var name = platformFile.name;
     var destination = "safety_datasheets/$name";

     try {
       if (kIsWeb) {
         // Web: Use bytes
         var bytes = platformFile.bytes;
         if (bytes == null) {
           // Handle error - show snackbar or dialog
           return;
         }
         await uploadData(destination, bytes, 'application/pdf');
       } else {
         // Native: Use file path
         var path = platformFile.path;
         if (path == null) {
           // Handle error - show snackbar or dialog
           return;
         }
         var file = File(path);
         await uploadFile(destination, file);
       }

       _changePaths(
         id,
         FirebaseDocument(id: id, url: destination, name: name),
       );
     } catch (e) {
       // Handle upload error - show snackbar or dialog
       debugPrint('Failed to upload safety datasheet: $e');
     }
   }
   ```

**Key improvements:**
- ✅ Uses `kIsWeb` to branch between web and native
- ✅ Gets filename from `platformFile.name` (cross-platform, no path parsing)
- ✅ Adds file type filter (PDF only) for better UX
- ✅ Uses `platformFile.bytes` on web (available)
- ✅ Uses `platformFile.path` on native (available)
- ✅ Adds null checks for safety
- ✅ Adds try-catch for upload errors
- ✅ No `Platform.pathSeparator` - not needed!

### Step 3: Verify Imports

**Task:** Ensure all necessary imports are present

**File:** `lib/ui/item_edit_page/item_edit_page_signs_single_documents.dart`

**Required imports:**
```dart
import 'dart:io';  // Keep for native File usage
import 'package:flutter/foundation.dart' show kIsWeb;  // Add this
import 'package:file_picker/file_picker.dart';  // Should exist
// ... other existing imports
```

**Note:** We keep `import 'dart:io'` because it's conditionally used only on native platforms via the `kIsWeb` check.

### Step 4: Manual Testing

**Task:** Test on both web and native platforms

**Web Testing (Primary):**
1. Run app in Chrome: `flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging`
2. Navigate to item edit page
3. Attempt to upload a safety datasheet PDF
4. **Expected:** File uploads successfully without crash
5. **Verify:** File appears in Firebase Storage at `safety_datasheets/filename.pdf`
6. **Verify:** Document reference saved in Firestore

**Native Testing (Regression):**
1. Run app on mobile/desktop: `flutter run -d <device>`
2. Navigate to item edit page
3. Attempt to upload a safety datasheet PDF
4. **Expected:** File uploads successfully (same as before)
5. **Verify:** No regressions in native behavior

**Edge Cases:**
- ❌ User cancels file picker → Should do nothing
- ❌ User picks non-PDF file → Should be prevented by file type filter
- ❌ Network error during upload → Should handle gracefully (try-catch)

### Step 5: Code Review Checklist

**Task:** Self-review before completion

**Checklist:**
- [ ] No `Platform.pathSeparator` usage remains
- [ ] Both `kIsWeb` branches are covered
- [ ] No `dart:io` APIs called on web branch
- [ ] Null checks for `bytes` (web) and `path` (native)
- [ ] Error handling with try-catch
- [ ] File type restricted to PDF
- [ ] Filename extracted from `platformFile.name` (not path parsing)
- [ ] Existing `uploadData()` and `uploadFile()` functions reused
- [ ] No new dependencies added
- [ ] UUID and FirebaseDocument logic preserved

### Step 6: Documentation Update (Optional)

**Task:** Update CLAUDE.md if needed

**File:** `CLAUDE.md`

**Change:** Add to "Common Patterns" section (if it doesn't exist, skip this step):

```markdown
### File Upload Pattern

When uploading files via FilePicker, always use platform-specific handling:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

var platformFile = result.files.single;
var name = platformFile.name;  // Cross-platform filename

if (kIsWeb) {
  var bytes = platformFile.bytes!;
  await uploadData(destination, bytes, mimeType);
} else {
  var file = File(platformFile.path!);
  await uploadFile(destination, file);
}
```

**Never use:**
- `Platform.pathSeparator` (not available on web)
- Path parsing to extract filename (use `platformFile.name`)
- `File()` from `dart:io` on web
```

**Note:** Only add this if you think it adds value. The pattern is already demonstrated in `rescue_pickable_image.dart`.

## Testing Strategy

**Manual Testing Only** - This is UI glue code with no complex business logic.

**Why no unit tests:**
- File picker interaction requires platform plugins (hard to mock)
- Upload functions are tested via Firebase integration
- Filename extraction is trivial (single property access)
- Platform branching is simple conditional logic
- ROI on unit tests is low for this change

**Testing focus:**
- ✅ Manual smoke testing on web (primary)
- ✅ Manual regression testing on mobile/desktop
- ✅ Edge case handling (cancel, errors)

## Success Criteria

- [ ] Safety datasheet upload works on web without crash
- [ ] Safety datasheet upload still works on native platforms
- [ ] File uploads to correct Firebase Storage path
- [ ] Firestore document reference created correctly
- [ ] No console errors or warnings
- [ ] Code follows existing patterns in `rescue_pickable_image.dart`

## Rollback Plan

If issues arise:
1. Revert the single file change to `item_edit_page_signs_single_documents.dart`
2. Git command: `git checkout HEAD -- lib/ui/item_edit_page/item_edit_page_signs_single_documents.dart`

## Implementation Notes for Claude Code

**Execution approach:**
- This is a straightforward fix - no need for subagents
- Single file modification with clear before/after
- Use Edit tool to replace the `_addNew()` method
- Test manually on web to verify fix

**Time estimate:**
- Code changes: 10 minutes
- Testing on web: 10 minutes
- Testing on native: 10 minutes
- Code review: 5 minutes
- **Total: ~35 minutes**

**Complexity: LOW** - Following established patterns, minimal logic changes.

---

## References

- **Correct Pattern:** `lib/ui/rescue_pickable_image.dart:99-115`
- **Upload Functions:** `lib/services/firebase_utils.dart`
- **FilePicker Docs:** https://pub.dev/packages/file_picker
- **Flutter Web Limitations:** https://docs.flutter.dev/platform-integration/web/faq#what-dart-libraries-are-available-for-web
