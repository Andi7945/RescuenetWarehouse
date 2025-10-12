# Session: Storage Permissions Investigation & Local Export/Import Planning
**Date:** 2025-10-12
**Status:** ✅ Completed - Permission issue diagnosed, local export/import planned

---

## Context

Working on Firebase export/import scripts that were failing with bucket detection errors. The export script uses `bucket.exists()` to detect which storage bucket domain exists (`.appspot.com` vs `.firebasestorage.app`), but was getting permission denied errors.

**Previous session:** `2025-10-11-export-import-fixes.md` - Initial export/import script fixes

---

## Problem: Export Script Failing with Bucket Detection Error

### Error Message
```
✗ Export failed: No Firebase Storage bucket found for project "rescuenet-7733b".
Checked:
  - rescuenet-7733b.firebasestorage.app
  - rescuenet-7733b.appspot.com

Either:
1. Firebase Storage is not enabled for this project, OR
2. The service account lacks permission to access the bucket
```

### Investigation Process

1. **Verified service account and buckets exist:**
   - Service account: `firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com`
   - Bucket `rescuenet-7733b.appspot.com` exists and contains data
   - Target bucket `rescuenet-testing-migrations` is accessible

2. **Tested bucket access with direct operations:**
   ```javascript
   // bucket.exists() - FAILED with permission denied
   // bucket.getFiles() - SUCCEEDED, listed files
   ```

3. **Checked service account permissions:**
   ```
   roles/datastore.user       - Firestore access ✅
   roles/storage.objectAdmin  - Object-level operations ✅
   roles/storage.objectCreator
   roles/storage.objectViewer
   ```

### Root Cause Analysis

**The Problem:** Permission model mismatch between code and service account

- **What the code does:** Calls `bucket.exists()` which requires `storage.buckets.get` permission
- **What the service account has:** Object-level permissions (`storage.objects.*`) but NOT bucket-level permissions (`storage.buckets.*`)
- **Why `bucket.exists()` fails:** Requires bucket-level metadata access
- **Why `bucket.getFiles()` works:** Only requires object-level permissions

**Detection Logic Flaw (scripts/lib/storage-bucket-detector.js:82-91):**
```javascript
async function checkBucketExists(storage, bucketName) {
  try {
    const [exists] = await storage.bucket(bucketName).exists();
    return exists;
  } catch (error) {
    // ❌ PROBLEM: Treats permission denied as "doesn't exist"
    return false;
  }
}
```

When checking both buckets:
- `.firebasestorage.app` - doesn't exist → returns `false` ✅
- `.appspot.com` - exists but permission denied → returns `false` ❌
- Result: Both return false → Script thinks no bucket exists → Error

**Why This Permission Model Exists:**

This is intentional security design following the **principle of least privilege**:
- ✅ Service account has object-level permissions (read/write files)
- ❌ Service account lacks bucket-level permissions (inspect/manage buckets)
- Purpose: Service account can do its job without broader bucket management access

### The Solution Attempt That Failed

Tried to grant `roles/storage.legacyBucketReader` at project level:

```bash
gcloud projects add-iam-policy-binding rescuenet-7733b \
  --member="serviceAccount:firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com" \
  --role="roles/storage.legacyBucketReader"
```

**Error:**
```
ERROR: Role roles/storage.legacyBucketReader is not supported for this resource.
```

**Why it failed:**
- Legacy roles (`legacyBucketReader`, `legacyBucketWriter`, `legacyBucketOwner`) can ONLY be applied at the **bucket level**, not project level
- They integrate with the legacy ACL system which is inherently bucket-specific
- They cannot be granted at project level by design

### Understanding GCS IAM Role Hierarchy

**Bucket-Level Permissions vs Object-Level Permissions:**

```
storage.admin ← Project-level role
    ├── storage.buckets.* ← BUCKET metadata operations (get, list, etc.)
    └── storage.objects.* ← OBJECT data operations (read, write, etc.)

storage.objectAdmin ← Project-level role
    └── storage.objects.* ← Can read/write objects
                          ← CANNOT check if bucket exists!

storage.legacyBucketReader ← BUCKET-LEVEL ONLY
    ├── storage.buckets.get
    └── storage.objects.list
```

**Current service account roles:**
- `roles/storage.objectAdmin` - Full control over objects (files)
- Does NOT include `storage.buckets.get` or `storage.buckets.list`

---

## Recommended Solutions

### Option A: Grant `roles/storage.admin` at Project Level (RECOMMENDED)

**Command:**
```bash
gcloud projects add-iam-policy-binding rescuenet-7733b \
  --member="serviceAccount:firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
```

**Why this is appropriate:**
- Export/import tools are administrative tools
- Includes all bucket and object permissions
- Standard role for backup/migration tools
- Simpler than custom roles

**Script updates needed:**
- `scripts/setup-service-accounts.sh` - Update ROLES array (line 35-38)
- `scripts/README-export.md` - Update documentation
- `scripts/SERVICE_ACCOUNTS.md` - Update role descriptions

### Option B: Create Custom Role (Principle of Least Privilege)

```bash
gcloud iam roles create FirebaseExportReader \
  --project=rescuenet-7733b \
  --title="Firebase Export Reader" \
  --permissions=storage.buckets.get,storage.buckets.list,storage.objects.get,storage.objects.list,storage.objects.create
```

**Why this might be overkill:**
- More complex to maintain
- Service account already has write permissions
- Export tools typically use admin roles

### Option C: Fix the Detection Code

Modify `storage-bucket-detector.js` to use `bucket.getFiles({ maxResults: 1 })` instead of `bucket.exists()`:

**Pros:**
- Works with current permissions
- No IAM changes needed

**Cons:**
- Slower (fetches file list vs metadata)
- More complex error handling
- Treats empty bucket same as non-existent bucket

---

## Decision: Use Option A (storage.admin)

**Rationale:**
- Export/import tools need administrative access
- Simpler and more maintainable
- Aligns with GCP best practices for backup tools
- Eliminates permission edge cases

**Next steps:**
1. Update `setup-service-accounts.sh` ROLES array
2. Update documentation
3. Run setup script or manually grant role
4. Test export script

---

## New Feature: Local Filesystem Export/Import

During this session, we also planned a major feature addition to support local filesystem export/import as an alternative to GCS buckets.

### Plan Created

**File:** `/Users/michandtke/dev/andi/RescuenetWarehouse/plans/LOCAL_FILE_EXPORT_IMPORT.md`

Comprehensive plan for adding local file support following these principles:
- **KISS** - Keep It Simple, Stupid
- **SRP** - Single Responsibility Principle
- **Modularity** - Easy to test and modify
- **Pure functions** - For business logic
- **No over-engineering** - Ship fast, iterate later

### Key Design Decisions

1. **NO storage abstraction layer**
   - Simple if/else branching at CLI level
   - Separate code paths for local vs GCS
   - Avoid premature abstraction

2. **New modules to create:**
   - `lib/local-client.js` - Local filesystem I/O (mirrors gcs-client.js)
   - `lib/manifest.js` - Pure functions for manifest handling
   - `lib/path-utils.js` - Pure path manipulation functions

3. **Modified modules:**
   - `export-firebase.js` - Add `--local-output` flag
   - `import-firebase.js` - Add `--local-input` flag
   - `lib/storage-export.js` - Add `copyStorageFilesLocal()`
   - `lib/storage-import.js` - Add `restoreStorageFilesLocal()`

### Implementation Phases

**Phase 1 (MVP - 1-2 days):**
- Export Firestore to local JSON files ✅
- Export Storage to local directory ✅
- Import Firestore from local JSON ✅
- Import Storage from local directory ✅
- Basic error handling ✅
- Unit tests for pure functions ✅

**Phase 2 (Polish - 2-3 days):**
- Parallel file operations
- Progress bars
- Dry-run mode
- Disk space validation
- Resume capability

### Use Cases

**Local mode is best for:**
- Local development/testing
- Quick backups before changes
- Avoiding GCS costs for temporary exports
- Air-gapped environments
- CI/CD test fixtures

**GCS mode is best for:**
- Production disaster recovery
- Long-term archival
- Automated scheduled backups
- Team collaboration

### CLI Examples

**Export to local:**
```bash
node export-firebase.js \
  --project rescuenet-testing \
  --local-output ./backups/2025-10-12
```

**Import from local:**
```bash
node import-firebase.js \
  --project rescuenet-testing \
  --local-input ./backups/2025-10-12
```

**Export to GCS (unchanged):**
```bash
node export-firebase.js \
  --project rescuenet-testing \
  --bucket rescuenet-testing-migrations
```

---

## Current State

### What's Working
- ✅ Export/import scripts architecturally sound
- ✅ Firestore export/import logic solid
- ✅ Storage copy logic works
- ✅ GCS target bucket writes work
- ✅ Service account has object-level permissions

### What's Blocked
- ❌ Export script fails at bucket detection step
- ❌ Missing `storage.buckets.get` permission

### What's Planned
- 📋 Comprehensive plan for local filesystem support
- 📋 Script updates to grant storage.admin role
- 📋 Documentation updates for permissions

---

## Files Modified This Session

1. **Plans Created:**
   - `plans/LOCAL_FILE_EXPORT_IMPORT.md` - Full implementation plan

2. **Investigation Files:**
   - Analyzed: `scripts/export-firebase.js`
   - Analyzed: `scripts/lib/storage-bucket-detector.js`
   - Analyzed: `scripts/lib/firebase-init.js`
   - Analyzed: `scripts/setup-service-accounts.sh`
   - Analyzed: `scripts/README-export.md`
   - Analyzed: `scripts/SERVICE_ACCOUNTS.md`

---

## Next Session Tasks

### Immediate (Fix Permissions)

1. **Update setup-service-accounts.sh:**
   ```bash
   # Change ROLES array (lines 35-38)
   ROLES=(
     "roles/datastore.user"
     "roles/storage.admin"  # Changed from storage.objectAdmin
   )
   ```

2. **Grant storage.admin to existing service accounts:**
   ```bash
   gcloud projects add-iam-policy-binding rescuenet-7733b \
     --member="serviceAccount:firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com" \
     --role="roles/storage.admin"

   gcloud projects add-iam-policy-binding rescuenet-testing \
     --member="serviceAccount:firebase-export-tool@rescuenet-testing.iam.gserviceaccount.com" \
     --role="roles/storage.admin"
   ```

3. **Test export script:**
   ```bash
   npm run export -- --project=rescuenet-7733b --bucket=rescuenet-testing-migrations
   ```

4. **Update documentation:**
   - `README-export.md` - Update required permissions
   - `SERVICE_ACCOUNTS.md` - Update role descriptions

### Future (Local Export Feature)

Follow the implementation plan in `plans/LOCAL_FILE_EXPORT_IMPORT.md`:

**Day 1:**
- Create `lib/manifest.js` with pure functions
- Create `lib/path-utils.js` with path utilities
- Create `lib/local-client.js` with filesystem I/O
- Write unit tests

**Day 2:**
- Modify `export-firebase.js` for local mode
- Modify `import-firebase.js` for local mode
- Add `copyStorageFilesLocal()` to storage-export.js
- Add `restoreStorageFilesLocal()` to storage-import.js
- Integration tests

**Day 3:**
- Documentation updates
- Manual testing
- Edge case handling

---

## Key Learnings

1. **GCS IAM is hierarchical:**
   - Legacy roles are bucket-level only
   - Modern roles work at project level
   - Object permissions ≠ bucket permissions

2. **Permission debugging:**
   - Check what operations actually work, not just what errors say
   - Test with direct API calls (getFiles vs exists)
   - Review exact permissions granted

3. **Principle of least privilege vs pragmatism:**
   - Object-only permissions seemed "safer"
   - But incomplete permissions cause hidden failures
   - For admin tools, use admin roles

4. **Error handling matters:**
   - Catching all errors and returning false hides permission issues
   - Distinguish between "doesn't exist" and "no permission"
   - Surface actionable errors to users

5. **Startup principles apply:**
   - Don't over-engineer (no storage abstraction)
   - Ship MVP fast (2-3 days for local support)
   - Use pure functions where appropriate
   - Test critical paths, not everything

---

## Commands Reference

### Check Service Account Permissions
```bash
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:EMAIL" \
  --format="table(bindings.role)"
```

### Grant Storage Admin
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:EMAIL" \
  --role="roles/storage.admin"
```

### Test Bucket Access (Node.js)
```javascript
const { Storage } = require('@google-cloud/storage');
const storage = new Storage({ keyFilename: 'path/to/key.json' });

// Test 1: bucket.exists() - requires storage.buckets.get
const [exists] = await storage.bucket('bucket-name').exists();

// Test 2: bucket.getFiles() - requires storage.objects.list
const [files] = await storage.bucket('bucket-name').getFiles({ maxResults: 5 });

// Test 3: bucket.getMetadata() - requires storage.buckets.get
const [metadata] = await storage.bucket('bucket-name').getMetadata();
```

### Export Script Commands
```bash
# GCS export
npm run export -- --project=PROJECT_ID --bucket=BUCKET_NAME

# Local export (future)
npm run export -- --project=PROJECT_ID --local-output=./backups/YYYY-MM-DD

# Dry run
npm run export -- --project=PROJECT_ID --bucket=BUCKET_NAME --dry-run
```

---

## Related Documentation

- **Previous session:** `2025-10-11-export-import-fixes.md`
- **Local export plan:** `plans/LOCAL_FILE_EXPORT_IMPORT.md`
- **Service account setup:** `scripts/SERVICE_ACCOUNTS.md`
- **Export tool docs:** `scripts/README-export.md`
- **Import tool docs:** `scripts/README-import.md`

---

## Status Summary

**Permission Issue:** ✅ Root cause identified, solution planned
**Local Export Plan:** ✅ Comprehensive plan created
**Ready to implement:** ✅ Clear next steps defined

Next session can start with either:
1. Fixing the permission issue (quick - 30 mins)
2. Implementing local export/import (feature - 2-3 days)
