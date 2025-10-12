# Storage Bucket Auto-Detection Implementation Plan

**For Claude Code Subagent Implementation**

---

## Problem Statement

Firebase Storage buckets exist with two different domain conventions:
- **Legacy (pre-2023):** `project-id.appspot.com`
- **Modern (2023+):** `project-id.firebasestorage.app`

**Current Issue:** The export/import scripts hardcode `.firebasestorage.app`, but production project (`rescuenet-7733b`) uses the legacy `.appspot.com` domain, causing "bucket does not exist" errors.

**Impact:**
- ✗ Export from production fails when copying storage files
- ✗ Import to any project using legacy domain fails on storage restore

---

## Solution Overview

Implement **automatic bucket domain detection** that:
1. Checks if modern bucket exists (`.firebasestorage.app`)
2. Falls back to legacy bucket (`.appspot.com`)
3. Throws clear error if both exist (ambiguous configuration)
4. Throws clear error if neither exists (storage not enabled)

**Architecture:**
- **Pure detection function** in a shared utility module
- **Single source of truth** used by both export and import
- **Fail-fast** with explicit error messages

---

## Implementation Tasks

Execute these tasks sequentially using subagents:

### Task 1: Create Bucket Detection Utility Module
**Agent:** general-purpose
**File:** `scripts/lib/storage-bucket-detector.js` (NEW)

**Purpose:** Pure utility function for detecting which Firebase Storage bucket domain exists.

**Implementation:**

```javascript
/**
 * Storage Bucket Domain Detector
 *
 * Detects which Firebase Storage bucket domain convention a project uses.
 * Firebase projects may use either .appspot.com (legacy) or .firebasestorage.app (modern).
 *
 * This module provides a pure detection function with clear error handling.
 */

/**
 * Detects which Firebase Storage bucket domain exists for a project
 *
 * Checks both modern (.firebasestorage.app) and legacy (.appspot.com) domains
 * to determine which bucket exists for the given project.
 *
 * @param {string} projectId - Firebase project ID
 * @param {Storage} storage - GCS Storage SDK instance
 * @returns {Promise<string>} Bucket name (e.g., "project-id.appspot.com")
 * @throws {Error} If both buckets exist (ambiguous) or neither exists
 *
 * @example
 * const storage = new Storage({ keyFilename: 'key.json' });
 * const bucketName = await detectStorageBucket('my-project', storage);
 * // Returns: "my-project.appspot.com" or "my-project.firebasestorage.app"
 */
async function detectStorageBucket(projectId, storage) {
  const modernBucket = `${projectId}.firebasestorage.app`;
  const legacyBucket = `${projectId}.appspot.com`;

  // Check both buckets in parallel for performance
  const [modernExists, legacyExists] = await Promise.all([
    checkBucketExists(storage, modernBucket),
    checkBucketExists(storage, legacyBucket)
  ]);

  // Case 1: Only modern exists
  if (modernExists && !legacyExists) {
    return modernBucket;
  }

  // Case 2: Only legacy exists
  if (legacyExists && !modernExists) {
    return legacyBucket;
  }

  // Case 3: Both exist - ambiguous configuration (likely a mistake)
  if (modernExists && legacyExists) {
    throw new Error(
      `Ambiguous storage configuration for project "${projectId}":\n` +
      `Both buckets exist:\n` +
      `  - ${modernBucket} (modern)\n` +
      `  - ${legacyBucket} (legacy)\n\n` +
      `This is likely a mistake. Please:\n` +
      `1. Determine which bucket contains your actual data\n` +
      `2. Delete the unused bucket, OR\n` +
      `3. Use --skip-storage flag to handle storage separately`
    );
  }

  // Case 4: Neither exists - storage not enabled or permissions issue
  throw new Error(
    `No Firebase Storage bucket found for project "${projectId}".\n` +
    `Checked:\n` +
    `  - ${modernBucket}\n` +
    `  - ${legacyBucket}\n\n` +
    `Either:\n` +
    `1. Firebase Storage is not enabled for this project, OR\n` +
    `2. The service account lacks permission to access the bucket\n\n` +
    `To skip storage: Use --skip-storage flag`
  );
}

/**
 * Checks if a GCS bucket exists
 *
 * Helper function that safely checks bucket existence without throwing.
 *
 * @param {Storage} storage - GCS Storage SDK instance
 * @param {string} bucketName - Bucket name to check
 * @returns {Promise<boolean>} True if bucket exists and is accessible
 */
async function checkBucketExists(storage, bucketName) {
  try {
    const [exists] = await storage.bucket(bucketName).exists();
    return exists;
  } catch (error) {
    // If we can't check (permission error, network error), assume doesn't exist
    // This is safe because we'll get a clearer error later if there's a real problem
    return false;
  }
}

module.exports = { detectStorageBucket };
```

**Validation:**
- Function is pure (no side effects except I/O)
- Clear error messages for all edge cases
- Returns quickly (parallel checks)
- Handles permission errors gracefully

**No testing needed:** Simple utility function, will be validated via integration testing.

---

### Task 2: Update Export Script to Use Auto-Detection
**Agent:** general-purpose
**File:** `scripts/export-firebase.js`

**Changes Required:**

#### Change 1: Add import for detector (line ~9)
```javascript
// After existing imports, add:
const { detectStorageBucket } = require('./lib/storage-bucket-detector');
```

#### Change 2: Replace hardcoded bucket with detection (lines 57-67)

**OLD CODE:**
```javascript
// Initialize GCS Storage SDK (used for BOTH source and target buckets)
// This ensures bucket references are compatible for cross-bucket copying
console.log('Initializing GCS Storage SDK...');
const serviceAccountPath = getServiceAccountPath(options.project);
const storage = new Storage({ keyFilename: path.resolve(serviceAccountPath) });

// Create bucket references using the SAME Storage SDK instance
// Note: Firebase Storage now uses .firebasestorage.app domain (not .appspot.com)
const sourceBucket = storage.bucket(`${options.project}.firebasestorage.app`);
const targetBucket = storage.bucket(options.bucket);
console.log('✓ GCS Storage SDK initialized\n');
```

**NEW CODE:**
```javascript
// Initialize GCS Storage SDK (used for BOTH source and target buckets)
// This ensures bucket references are compatible for cross-bucket copying
console.log('Initializing GCS Storage SDK...');
const serviceAccountPath = getServiceAccountPath(options.project);
const storage = new Storage({ keyFilename: path.resolve(serviceAccountPath) });

// Auto-detect which storage bucket domain exists (.appspot.com or .firebasestorage.app)
// This handles both legacy and modern Firebase projects
const sourceBucketName = await detectStorageBucket(options.project, storage);
const sourceBucket = storage.bucket(sourceBucketName);
const targetBucket = storage.bucket(options.bucket);

console.log(`✓ GCS Storage SDK initialized (source: ${sourceBucketName})\n`);
```

**Step-by-Step:**
1. Read export-firebase.js
2. Locate the imports section (around line 9)
3. Add detector import
4. Locate the storage initialization section (around lines 57-67)
5. Replace hardcoded bucket construction with auto-detection
6. Update success message to show detected bucket
7. Verify changes applied

**Validation:**
- Import statement added correctly
- `detectStorageBucket` called before bucket creation
- Console log shows detected bucket name
- No other changes to export logic

---

### Task 3: Update Firebase Init to Remove Hardcoded Domain
**Agent:** general-purpose
**File:** `scripts/lib/firebase-init.js`

**Problem:** Currently hardcodes `.firebasestorage.app` on line 54, but this is wrong for legacy projects.

**Solution:** Remove the `storageBucket` parameter entirely. The import script doesn't need it since we'll use GCS SDK directly.

**Changes Required:**

#### Change: Remove storageBucket parameter (line 52-55)

**OLD CODE:**
```javascript
// Initialize Firebase Admin SDK with named app
const app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: `${projectId}.firebasestorage.app`
}, projectId); // Use projectId as app name for multiple connections
```

**NEW CODE:**
```javascript
// Initialize Firebase Admin SDK with named app
// Note: We don't specify storageBucket here because we use GCS Storage SDK
// directly with auto-detection for better compatibility with legacy projects
const app = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
}, projectId); // Use projectId as app name for multiple connections
```

**IMPORTANT:** Keep the `storageBucket` return value on line 59 because import script uses it. We'll fix that next.

**Step-by-Step:**
1. Read firebase-init.js
2. Locate the app initialization (lines 52-55)
3. Remove the `storageBucket` parameter line
4. Add explanatory comment
5. Verify other code unchanged

**Validation:**
- `storageBucket` parameter removed from initializeApp config
- Return statement still includes `storageBucket` (line 59-64)
- No syntax errors

---

### Task 4: Update Import Script to Use Auto-Detection
**Agent:** general-purpose
**File:** `scripts/import-firebase.js`

**Problem:** Import uses `targetFirebase.storageBucket` from firebase-init (line 113, 160), which will now fail because we removed the storageBucket config.

**Solution:** Initialize target storage bucket using GCS SDK with auto-detection, similar to export.

**Changes Required:**

#### Change 1: Add import for detector (line ~21)
```javascript
// After existing imports, add:
const { detectStorageBucket } = require('./lib/storage-bucket-detector');
```

#### Change 2: Update Step 8 to initialize target storage (after line 114)

**OLD CODE:**
```javascript
// Step 8: Initialize target Firebase
console.log(chalk.white('\nStep 7: Initializing target Firebase...'));
const targetFirebase = await initFirebaseReadOnly(options.project);
console.log(chalk.green(`✓ Connected to project: ${options.project}`));
```

**NEW CODE:**
```javascript
// Step 8: Initialize target Firebase
console.log(chalk.white('\nStep 7: Initializing target Firebase...'));
const { db } = await initFirebaseReadOnly(options.project);
console.log(chalk.green(`✓ Connected to project: ${options.project}`));

// Initialize target storage bucket with auto-detection
console.log(chalk.white('Detecting target storage bucket...'));
const targetBucketName = await detectStorageBucket(options.project, storage);
const targetStorageBucket = storage.bucket(targetBucketName);
console.log(chalk.green(`✓ Target storage: ${targetBucketName}\n`));
```

#### Change 3: Update storage restore call (line 160)

**OLD CODE:**
```javascript
storageResults = await restoreStorageFiles(
  sourceBucket,
  storagePrefix,
  targetFirebase.storageBucket
);
```

**NEW CODE:**
```javascript
storageResults = await restoreStorageFiles(
  sourceBucket,
  storagePrefix,
  targetStorageBucket
);
```

#### Change 4: Update Firestore import call (line 146)

**OLD CODE:**
```javascript
const importResults = await importAllCollections(
  targetFirebase.db,
  collectionsData,
  clearFirst
);
```

**NEW CODE:**
```javascript
const importResults = await importAllCollections(
  db,
  collectionsData,
  clearFirst
);
```

**Step-by-Step:**
1. Read import-firebase.js
2. Add detector import at top
3. Update Step 8 to destructure only `db` from initFirebaseReadOnly
4. Add storage bucket auto-detection after Step 8
5. Update restoreStorageFiles call to use `targetStorageBucket`
6. Update importAllCollections call to use `db` instead of `targetFirebase.db`
7. Verify all changes applied

**Validation:**
- Detector imported
- Storage bucket detected after Firebase init
- All references to `targetFirebase.storageBucket` replaced
- All references to `targetFirebase.db` replaced with `db`

---

### Task 5: Clean Up Firebase Init Return Value
**Agent:** general-purpose
**File:** `scripts/lib/firebase-init.js`

**Purpose:** Remove the `storageBucket` from return value since no scripts use it anymore.

**Changes Required:**

#### Change 1: Update return statement (lines 61-65)

**OLD CODE:**
```javascript
return {
  db,
  storageBucket,
  projectId
};
```

**NEW CODE:**
```javascript
return {
  db,
  projectId
};
```

#### Change 2: Update JSDoc comment (line 32)

**OLD CODE:**
```javascript
@returns {Promise<{db: admin.firestore.Firestore, storageBucket: admin.storage.Storage, projectId: string}>}
```

**NEW CODE:**
```javascript
@returns {Promise<{db: admin.firestore.Firestore, projectId: string}>}
```

#### Change 3: Remove storageBucket variable (line 59)

**OLD CODE:**
```javascript
// Get Firestore and Storage instances
const db = app.firestore();
const storageBucket = app.storage().bucket();
```

**NEW CODE:**
```javascript
// Get Firestore instance
const db = app.firestore();
```

**Step-by-Step:**
1. Read firebase-init.js
2. Remove `storageBucket` variable declaration
3. Update return object
4. Update JSDoc return type
5. Verify function still works for Firestore

**Validation:**
- Function only returns `db` and `projectId`
- No references to `storageBucket` remain in firebase-init.js
- JSDoc is accurate

---

### Task 6: Integration Testing
**Agent:** general-purpose

**Purpose:** Verify the complete workflow works end-to-end with auto-detection.

**Test Plan:**

#### Test 1: Verify Detector Module Syntax
```bash
cd scripts
node -c lib/storage-bucket-detector.js
```

**Expected:** No syntax errors

---

#### Test 2: Verify Export Script Syntax
```bash
cd scripts
node -c export-firebase.js
```

**Expected:** No syntax errors

---

#### Test 3: Verify Import Script Syntax
```bash
cd scripts
node -c import-firebase.js
```

**Expected:** No syntax errors

---

#### Test 4: Verify Firebase Init Syntax
```bash
cd scripts
node -c lib/firebase-init.js
```

**Expected:** No syntax errors

---

#### Test 5: Test Detector Function Directly
```bash
cat > scripts/test-detector.js << 'EOF'
const { Storage } = require('@google-cloud/storage');
const { detectStorageBucket } = require('./lib/storage-bucket-detector');

async function test() {
  // Test with production project (uses legacy .appspot.com)
  const storage = new Storage({
    keyFilename: './secrets/rescuenet-production.json'
  });

  console.log('Testing bucket detection for rescuenet-7733b...');
  const bucket = await detectStorageBucket('rescuenet-7733b', storage);
  console.log('Detected bucket:', bucket);

  if (bucket === 'rescuenet-7733b.appspot.com') {
    console.log('✓ Correctly detected legacy bucket');
  } else {
    console.error('✗ Wrong bucket detected!');
    process.exit(1);
  }
}

test().catch(error => {
  console.error('Test failed:', error.message);
  process.exit(1);
});
EOF

node scripts/test-detector.js
rm scripts/test-detector.js
```

**Expected:**
- Detects `rescuenet-7733b.appspot.com`
- Prints success message

---

#### Test 6: Test Export with Auto-Detection (Dry Run)
```bash
cd scripts
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-testing-migrations \
  --dry-run
```

**Expected:**
- Shows "GCS Storage SDK initialized (source: rescuenet-7733b.appspot.com)"
- Dry run completes successfully

---

#### Test 7: Test Export with Auto-Detection (Skip Storage)
```bash
cd scripts
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-testing-migrations \
  --skip-storage
```

**Expected:**
- Exports Firestore collections successfully
- Skips storage (no bucket detection errors)
- Creates manifest in GCS bucket

---

#### Test 8: Test Export with Storage (Full Test)
```bash
cd scripts
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-testing-migrations \
  --output test-auto-detection
```

**Expected:**
- Detects correct source bucket (rescuenet-7733b.appspot.com)
- Exports Firestore collections
- Copies storage files from .appspot.com bucket
- Writes to target bucket successfully

---

#### Test 9: Test Import with Auto-Detection
```bash
cd scripts
npm run import -- \
  --source gs://rescuenet-testing-migrations/exports/test-auto-detection/manifest.json \
  --project rescuenet-testing \
  --collections container_types \
  --skip-storage
```

**Expected:**
- Connects to intermediate bucket
- Detects target storage bucket (testing project)
- Imports collection successfully (with --execute flag)

---

#### Test 10: Verify All Files Changed
```bash
cd scripts

echo "=== Files that should be modified ==="
echo "1. lib/firebase-init.js"
echo "2. export-firebase.js"
echo "3. import-firebase.js"
echo ""

echo "=== Files that should be created ==="
echo "1. lib/storage-bucket-detector.js"
echo ""

echo "=== Checking files exist ==="
ls -la lib/storage-bucket-detector.js
echo ""

echo "=== Checking detector is imported ==="
grep "storage-bucket-detector" export-firebase.js
grep "storage-bucket-detector" import-firebase.js
echo ""

echo "=== Checking detectStorageBucket is called ==="
grep "detectStorageBucket" export-firebase.js
grep "detectStorageBucket" import-firebase.js
```

**Expected:**
- All files exist
- All imports present
- All function calls present

---

## Success Criteria

✅ **Functional Requirements:**
- Export detects correct source storage bucket (legacy or modern)
- Import detects correct target storage bucket (legacy or modern)
- Clear error messages for ambiguous or missing buckets
- No hardcoded bucket domains anywhere

✅ **Code Quality:**
- Pure function for detection logic
- Single responsibility (one function does one thing)
- KISS principle (simple, no over-engineering)
- Modular design (detector is reusable)
- No over-testing (integration tests sufficient)

✅ **Compatibility:**
- Works with legacy projects (.appspot.com)
- Works with modern projects (.firebasestorage.app)
- Works with cross-project exports/imports
- Graceful error handling for edge cases

---

## Rollback Plan

If issues arise:

```bash
# Revert all changes
git checkout scripts/lib/firebase-init.js
git checkout scripts/export-firebase.js
git checkout scripts/import-firebase.js

# Remove new file
rm scripts/lib/storage-bucket-detector.js
```

**Manual workaround:** Use `--skip-storage` flag for exports/imports.

---

## Files Modified/Created

**Created (1 file):**
1. `scripts/lib/storage-bucket-detector.js` - Bucket detection utility (~80 lines)

**Modified (3 files):**
1. `scripts/lib/firebase-init.js` - Remove hardcoded domain (~5 lines changed)
2. `scripts/export-firebase.js` - Use auto-detection (~10 lines changed)
3. `scripts/import-firebase.js` - Use auto-detection (~15 lines changed)

**Total Complexity:** Low
**Risk Level:** Low (fails fast with clear errors)
**Testing Effort:** 30 minutes integration testing
**Implementation Time:** 45 minutes

---

## Implementation Order

Execute tasks in this exact order:

1. **Task 1** - Create detector utility module (15 min)
2. **Task 2** - Update export script (10 min)
3. **Task 3** - Update firebase-init (5 min)
4. **Task 4** - Update import script (10 min)
5. **Task 5** - Clean up firebase-init return value (5 min)
6. **Task 6** - Integration testing (30 min)

**Total Estimated Time:** 75 minutes

---

## Subagent Execution Instructions

**For Claude Code main session:**

To execute this plan, launch subagents for each task:

```
Task 1: Create storage bucket detector utility
- Create scripts/lib/storage-bucket-detector.js
- Implement detectStorageBucket() function
- Implement checkBucketExists() helper
- Verify syntax

Task 2: Update export script with auto-detection
- Read export-firebase.js
- Add detector import
- Replace hardcoded bucket with detection
- Update console log to show detected bucket

Task 3: Remove hardcoded domain from firebase-init
- Read firebase-init.js
- Remove storageBucket parameter from initializeApp
- Add explanatory comment
- Keep return value for now (will clean up in Task 5)

Task 4: Update import script with auto-detection
- Read import-firebase.js
- Add detector import
- Update Firebase init to only extract db
- Add storage bucket auto-detection
- Update all references to use new variables

Task 5: Clean up firebase-init return value
- Read firebase-init.js
- Remove storageBucket from return
- Update JSDoc
- Remove storageBucket variable

Task 6: Integration testing
- Run all 10 test cases
- Verify syntax
- Test detector function
- Test export dry-run
- Test export with skip-storage
- Test full export with storage
- Verify all files changed correctly
```

**Monitoring Progress:**

Check completion of each task before moving to next. If any task fails, investigate and fix before proceeding.

---

## Post-Implementation

After successful implementation:

1. **Commit changes:**
   ```bash
   git add scripts/
   git commit -m "Add automatic storage bucket domain detection

   - Create storage-bucket-detector utility for auto-detection
   - Support both legacy (.appspot.com) and modern (.firebasestorage.app) buckets
   - Update export script to auto-detect source bucket
   - Update import script to auto-detect target bucket
   - Remove hardcoded storage domain from firebase-init
   - Add clear error messages for ambiguous/missing buckets

   Fixes export/import failures with legacy Firebase projects.
   Maintains compatibility with modern projects.
   "
   ```

2. **Test on production:**
   ```bash
   # Export from production
   npm run export -- --project rescuenet-7733b --bucket rescuenet-testing-migrations

   # Import to testing
   npm run import -- \
     --source gs://rescuenet-testing-migrations/exports/[path]/manifest.json \
     --project rescuenet-testing \
     --execute
   ```

3. **Update documentation:**
   - Note in README that bucket detection is automatic
   - No manual configuration needed for storage buckets

4. **Monitor first migrations:**
   - Verify correct bucket detected
   - Check for any edge cases
   - Document any issues

---

## Future Enhancements (Out of Scope)

These are NOT part of this implementation but could be considered later:

- **Custom bucket support** - Allow --storage-bucket flag to override detection
- **Detection caching** - Cache detected bucket to avoid repeated checks
- **Bucket migration tool** - Automated copy from legacy to modern bucket
- **Better logging** - Show which bucket was checked and why

---

## Notes

**Why This Approach:**

1. **Pure function design** - Detection logic is testable and reusable
2. **Fail-fast** - Clear errors prevent silent failures
3. **KISS principle** - Simple detection, no complex heuristics
4. **Single responsibility** - Each module does one thing
5. **No over-testing** - Integration tests validate real-world usage

**Design Decisions:**

1. **Separate detector module** - Reusable by both export and import
2. **Parallel bucket checks** - Faster than sequential
3. **Throw on both-exist** - Prevents ambiguous data access
4. **Use GCS SDK directly** - More reliable than Firebase Admin SDK wrapper
5. **Remove storageBucket from firebase-init** - Not needed for Firestore-only operations

**Maintenance:**

This is infrastructure code - changes should be rare. Main maintenance:
- Add custom bucket support if needed
- Update error messages based on user feedback
- Add detection caching if performance becomes issue
