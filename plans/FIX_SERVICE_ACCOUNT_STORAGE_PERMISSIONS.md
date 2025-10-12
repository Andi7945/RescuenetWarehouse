# Fix Service Account Storage Permissions

**For Claude Code Subagent Implementation**

---

## Problem Statement

The export tool fails with "bucket does not exist" error when trying to auto-detect Firebase Storage buckets.

**Root Cause:** The service account (`firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com`) has `roles/storage.objectViewer` which allows reading **objects** in a bucket, but does NOT allow checking if a **bucket exists**.

**Error:**
```
Error: No Firebase Storage bucket found for project "rescuenet-7733b".
```

**Actual Issue:**
```
firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com does not have
storage.buckets.get access to the Google Cloud Storage bucket.
```

---

## Technical Analysis

### Current Permissions (INCOMPLETE):
```yaml
Roles:
  - roles/datastore.user          # ✓ Read Firestore
  - roles/storage.objectViewer    # ✓ Read storage OBJECTS
  - roles/storage.objectCreator   # ✓ Write to GCS buckets

Missing Permissions:
  - storage.buckets.get           # ✗ Check if bucket exists
  - storage.buckets.list          # ✗ List buckets (optional but useful)
```

### Why objectViewer Is Not Enough:

**`roles/storage.objectViewer` includes:**
- `storage.objects.get` - Read individual files ✓
- `storage.objects.list` - List files in a bucket ✓
- `storage.folders.get` - Read folders ✓
- `storage.folders.list` - List folders ✓

**`roles/storage.objectViewer` does NOT include:**
- `storage.buckets.get` - Get bucket metadata ✗
- `storage.buckets.list` - List buckets ✗

### What We Need:

To check if a bucket exists using `.exists()` or `.getMetadata()`, we need **bucket-level permissions**, not just object-level permissions.

**Solution:** Add `roles/storage.legacyBucketReader` which includes:
- `storage.buckets.get` ✓
- `storage.buckets.list` ✓
- Plus all the object reading permissions we already have

---

## Solution Overview

**Strategy:** Add `roles/storage.legacyBucketReader` role to the service account setup script.

**Why legacyBucketReader:**
1. **Read-only bucket access** - Can check bucket existence, list buckets, read ACLs
2. **Minimal permissions** - No write/delete capabilities
3. **Standard GCP role** - Well-documented, widely used
4. **Includes object reading** - Superset of objectViewer for reading
5. **IAM best practice** - Least privilege for read operations

**Alternative Considered:** `roles/storage.objectAdmin`
- ❌ Too broad (includes write/delete on objects)
- ❌ Violates principle of least privilege
- ❌ Read-only export tool shouldn't have admin permissions

---

## Implementation Tasks

Execute these tasks sequentially using subagents:

### Task 1: Update Service Account Setup Script
**Agent:** general-purpose
**File:** `scripts/setup-service-accounts.sh`

**Problem:** Script grants `roles/storage.objectViewer` but this doesn't include `storage.buckets.get` permission needed for bucket existence checks.

**Solution:** Replace `roles/storage.objectViewer` with `roles/storage.legacyBucketReader`.

**Changes Required:**

#### Change: Update ROLES array (lines 35-39)

**OLD CODE:**
```bash
# Required roles for export functionality
ROLES=(
  "roles/datastore.user"        # Read Firestore collections
  "roles/storage.objectViewer"  # Read Firebase Storage files
  "roles/storage.objectCreator" # Write to GCS backup bucket
)
```

**NEW CODE:**
```bash
# Required roles for export functionality
ROLES=(
  "roles/datastore.user"           # Read Firestore collections
  "roles/storage.legacyBucketReader" # Read Firebase Storage buckets and files
  "roles/storage.objectCreator"    # Write to GCS backup bucket
)
```

**Why This Change:**
- `legacyBucketReader` is a **superset** of `objectViewer` for read operations
- Includes `storage.buckets.get` (needed for `.exists()` checks)
- Includes `storage.buckets.list` (useful for debugging)
- Still read-only, follows least-privilege principle
- Standard role used across GCP projects

**Step-by-Step:**
1. Read `scripts/setup-service-accounts.sh`
2. Locate the ROLES array (lines 35-39)
3. Replace `roles/storage.objectViewer` with `roles/storage.legacyBucketReader`
4. Update comment to reflect "buckets and files" instead of just "files"
5. Verify array syntax is correct

**Validation:**
- ROLES array has exactly 3 entries
- legacyBucketReader role is properly quoted
- Comment is updated
- No syntax errors in bash array

---

### Task 2: Update Existing Service Account Permissions
**Agent:** general-purpose
**Task Type:** Manual commands execution

**Purpose:** Update the production service account with the new role.

**Why Needed:** The setup script only runs when creating new service accounts. Existing service accounts need manual update.

**Commands to Execute:**

#### Step 1: Remove old objectViewer role
```bash
gcloud projects remove-iam-policy-binding rescuenet-7733b \
  --member="serviceAccount:firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer" \
  --quiet
```

**Expected:** Role binding removed successfully

---

#### Step 2: Add new legacyBucketReader role
```bash
gcloud projects add-iam-policy-binding rescuenet-7733b \
  --member="serviceAccount:firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com" \
  --role="roles/storage.legacyBucketReader" \
  --condition=None \
  --quiet
```

**Expected:** Role binding added successfully

---

#### Step 3: Verify updated permissions
```bash
gcloud projects get-iam-policy rescuenet-7733b \
  --flatten="bindings[].members" \
  --filter="bindings.members:firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com" \
  --format="table(bindings.role)"
```

**Expected Output:**
```
ROLE
roles/datastore.user
roles/storage.legacyBucketReader
roles/storage.objectCreator
```

---

#### Step 4: Do the same for testing project
```bash
# Remove old role
gcloud projects remove-iam-policy-binding rescuenet-testing \
  --member="serviceAccount:firebase-export-tool@rescuenet-testing.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer" \
  --quiet

# Add new role
gcloud projects add-iam-policy-binding rescuenet-testing \
  --member="serviceAccount:firebase-export-tool@rescuenet-testing.iam.gserviceaccount.com" \
  --role="roles/storage.legacyBucketReader" \
  --condition=None \
  --quiet

# Verify
gcloud projects get-iam-policy rescuenet-testing \
  --flatten="bindings[].members" \
  --filter="bindings.members:firebase-export-tool@rescuenet-testing.iam.gserviceaccount.com" \
  --format="table(bindings.role)"
```

**Expected Output:**
```
ROLE
roles/datastore.user
roles/storage.legacyBucketReader
roles/storage.objectCreator
```

---

### Task 3: Validation Testing
**Agent:** general-purpose

**Purpose:** Verify the service account can now access bucket metadata.

**Test Plan:**

#### Test 1: Verify Bucket Access with Service Account
```bash
cat > scripts/test-bucket-access.js << 'EOF'
const { Storage } = require('@google-cloud/storage');

async function test() {
  const storage = new Storage({
    keyFilename: './secrets/rescuenet-production.json'
  });

  console.log('Testing bucket access after permission update...\n');

  const bucket = storage.bucket('rescuenet-7733b.appspot.com');

  // Test bucket.exists()
  console.log('Test 1: bucket.exists()');
  try {
    const [exists] = await bucket.exists();
    console.log(`✓ Success: bucket exists = ${exists}`);
  } catch (error) {
    console.error(`✗ Failed: ${error.message}`);
    process.exit(1);
  }

  // Test bucket.getMetadata()
  console.log('\nTest 2: bucket.getMetadata()');
  try {
    const [metadata] = await bucket.getMetadata();
    console.log(`✓ Success: bucket name = ${metadata.name}`);
    console.log(`  Location: ${metadata.location}`);
  } catch (error) {
    console.error(`✗ Failed: ${error.message}`);
    process.exit(1);
  }

  console.log('\n✓ All tests passed! Service account has correct permissions.');
}

test().catch(error => {
  console.error('Test failed:', error.message);
  process.exit(1);
});
EOF

node scripts/test-bucket-access.js
rm scripts/test-bucket-access.js
```

**Expected Output:**
```
Testing bucket access after permission update...

Test 1: bucket.exists()
✓ Success: bucket exists = true

Test 2: bucket.getMetadata()
✓ Success: bucket name = rescuenet-7733b.appspot.com
  Location: EU

✓ All tests passed! Service account has correct permissions.
```

---

#### Test 2: Test Auto-Detection Function
```bash
cat > scripts/test-auto-detection.js << 'EOF'
const { Storage } = require('@google-cloud/storage');
const { detectStorageBucket } = require('./lib/storage-bucket-detector');

async function test() {
  console.log('Testing storage bucket auto-detection...\n');

  const storage = new Storage({
    keyFilename: './secrets/rescuenet-production.json'
  });

  // Test production project
  console.log('Test 1: Production project (rescuenet-7733b)');
  try {
    const bucket = await detectStorageBucket('rescuenet-7733b', storage);
    console.log(`✓ Detected: ${bucket}`);

    if (bucket === 'rescuenet-7733b.appspot.com') {
      console.log('✓ Correct bucket (legacy domain)');
    } else {
      console.error('✗ Wrong bucket detected!');
      process.exit(1);
    }
  } catch (error) {
    console.error(`✗ Detection failed: ${error.message}`);
    process.exit(1);
  }

  console.log('\n✓ Auto-detection works correctly!');
}

test().catch(error => {
  console.error('Test failed:', error.message);
  process.exit(1);
});
EOF

node scripts/test-auto-detection.js
rm scripts/test-auto-detection.js
```

**Expected Output:**
```
Testing storage bucket auto-detection...

Test 1: Production project (rescuenet-7733b)
✓ Detected: rescuenet-7733b.appspot.com
✓ Correct bucket (legacy domain)

✓ Auto-detection works correctly!
```

---

#### Test 3: Test Export with Auto-Detection
```bash
cd scripts
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-testing-migrations \
  --collections container_types \
  --skip-storage \
  --dry-run
```

**Expected:** Dry run succeeds, shows auto-detection working

---

#### Test 4: Full Export Test (With Storage)
```bash
cd scripts
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-testing-migrations \
  --collections container_types \
  --output test-permissions-fix
```

**Expected:**
```
=== Firebase Export Tool ===
Project: rescuenet-7733b
Target: gs://rescuenet-testing-migrations/exports/test-permissions-fix

Initializing Firebase...
✓ Firebase initialized

Initializing GCS Storage SDK...
✓ GCS Storage SDK initialized (source: rescuenet-7733b.appspot.com)

Exporting Firestore collections...
✓ Exported 1 collections

Exporting Storage files...
✓ Copied X files (Y bytes)

=== Export Complete ===
```

---

#### Test 5: Verify Permissions Are Minimal
```bash
# Ensure service account CANNOT write to source bucket (should fail)
cat > scripts/test-read-only.js << 'EOF'
const { Storage } = require('@google-cloud/storage');

async function test() {
  const storage = new Storage({
    keyFilename: './secrets/rescuenet-production.json'
  });

  const bucket = storage.bucket('rescuenet-7733b.appspot.com');
  const testFile = bucket.file('test-write-permission.txt');

  console.log('Verifying service account is read-only...\n');
  console.log('Test: Attempting to write to source bucket (should fail)');

  try {
    await testFile.save('test content');
    console.error('✗ SECURITY ISSUE: Service account can write to source bucket!');
    console.error('  This violates read-only principle.');
    await testFile.delete(); // Clean up
    process.exit(1);
  } catch (error) {
    if (error.code === 403) {
      console.log('✓ Correct: Write denied (read-only as expected)');
      console.log('  Service account has minimal permissions.');
    } else {
      console.error(`✗ Unexpected error: ${error.message}`);
      process.exit(1);
    }
  }
}

test().catch(error => {
  console.error('Test failed:', error.message);
  process.exit(1);
});
EOF

node scripts/test-read-only.js
rm scripts/test-read-only.js
```

**Expected Output:**
```
Verifying service account is read-only...

Test: Attempting to write to source bucket (should fail)
✓ Correct: Write denied (read-only as expected)
  Service account has minimal permissions.
```

---

## Success Criteria

✅ **Functional Requirements:**
- Service account can check if buckets exist
- Auto-detection works for both production and testing
- Export succeeds with storage files
- Import succeeds with storage files

✅ **Security Requirements:**
- Service account remains read-only for source Firebase Storage
- Service account can write to intermediate GCS buckets
- No excessive permissions granted
- Principle of least privilege maintained

✅ **Code Quality:**
- Setup script updated for future service accounts
- Existing service accounts updated manually
- Documentation reflects new permissions
- All tests pass

---

## Rollback Plan

If issues arise:

```bash
# Revert to old objectViewer role
gcloud projects remove-iam-policy-binding rescuenet-7733b \
  --member="serviceAccount:firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com" \
  --role="roles/storage.legacyBucketReader" \
  --quiet

gcloud projects add-iam-policy-binding rescuenet-7733b \
  --member="serviceAccount:firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer" \
  --condition=None \
  --quiet

# Revert script changes
git checkout scripts/setup-service-accounts.sh
```

**Manual workaround:** Use `--skip-storage` flag for exports/imports.

---

## Files Modified

**Modified (1 file):**
1. `scripts/setup-service-accounts.sh` - Update ROLES array (2 lines changed)

**No new files created** - Simple permission fix

**Total Complexity:** Very Low
**Risk Level:** Very Low (just changing IAM role)
**Testing Effort:** 15 minutes
**Implementation Time:** 15 minutes

---

## Implementation Order

Execute tasks in this exact order:

1. **Task 1** - Update service account setup script (5 min)
2. **Task 2** - Update existing service account permissions (5 min)
3. **Task 3** - Run validation tests (15 min)

**Total Estimated Time:** 25 minutes

---

## Subagent Execution Instructions

**For Claude Code main session:**

To execute this plan, launch subagents for each task:

```
Task 1: Update setup script
- Read scripts/setup-service-accounts.sh
- Locate ROLES array (lines 35-39)
- Replace objectViewer with legacyBucketReader
- Update comment
- Verify syntax

Task 2: Update existing permissions
- Remove objectViewer role from both projects
- Add legacyBucketReader role to both projects
- Verify permissions are updated
- Wait 30 seconds for IAM propagation

Task 3: Run validation tests
- Test bucket access with service account
- Test auto-detection function
- Test export with storage (dry-run)
- Test full export with storage
- Verify service account is read-only
```

**Monitoring Progress:**

Check completion of each task before moving to next. If any task fails, investigate and fix before proceeding.

---

## Post-Implementation

After successful implementation:

1. **Commit changes:**
   ```bash
   git add scripts/setup-service-accounts.sh
   git commit -m "Fix service account storage permissions

   - Replace storage.objectViewer with storage.legacyBucketReader
   - Adds storage.buckets.get permission for bucket existence checks
   - Required for auto-detection of Firebase Storage bucket domains
   - Maintains read-only access (least privilege principle)

   Fixes: 'bucket does not exist' error during export"
   ```

2. **Update documentation:**
   - Note in README that legacyBucketReader is required
   - Document why this role is needed (bucket-level read access)

3. **Test on production:**
   ```bash
   # Full export from production
   npm run export -- \
     --project rescuenet-7733b \
     --bucket rescuenet-testing-migrations

   # Import to testing
   npm run import -- \
     --source gs://rescuenet-testing-migrations/exports/[path]/manifest.json \
     --project rescuenet-testing \
     --execute
   ```

4. **Monitor IAM propagation:**
   - Permissions may take 1-2 minutes to fully propagate
   - If tests fail immediately after update, wait and retry

---

## Permission Comparison

### Before (BROKEN):
```yaml
roles/storage.objectViewer:
  - storage.objects.get       ✓ Read files
  - storage.objects.list      ✓ List files
  - storage.folders.get       ✓ Read folders
  - storage.folders.list      ✓ List folders

  Missing:
  - storage.buckets.get       ✗ Check bucket existence
  - storage.buckets.list      ✗ List buckets
```

### After (FIXED):
```yaml
roles/storage.legacyBucketReader:
  - storage.objects.get       ✓ Read files
  - storage.objects.list      ✓ List files
  - storage.folders.get       ✓ Read folders
  - storage.folders.list      ✓ List folders
  - storage.buckets.get       ✓ Check bucket existence
  - storage.buckets.list      ✓ List buckets
  - storage.buckets.getIamPolicy ✓ Read bucket ACLs

  Still read-only! No write/delete permissions.
```

---

## Security Analysis

### Read-Only Verification:

**legacyBucketReader does NOT include:**
- ❌ `storage.objects.create` - Cannot create files
- ❌ `storage.objects.delete` - Cannot delete files
- ❌ `storage.objects.update` - Cannot modify files
- ❌ `storage.buckets.create` - Cannot create buckets
- ❌ `storage.buckets.delete` - Cannot delete buckets
- ❌ `storage.buckets.update` - Cannot modify buckets

**Combined permissions:**
- ✅ **Read** from source Firebase Storage (legacyBucketReader)
- ✅ **Write** to intermediate GCS buckets (objectCreator)
- ✅ **Read** from Firestore (datastore.user)
- ❌ **No write** to source Firebase Storage ✓
- ❌ **No write** to Firestore ✓

**Security posture:** Minimal permissions for read-only export tool ✓

---

## Future Enhancements (Out of Scope)

These are NOT part of this implementation but could be considered later:

- **Custom IAM role** - Create minimal role with exact permissions needed
- **Audit logging** - Enable Cloud Audit Logs for service account actions
- **Key rotation** - Automated service account key rotation
- **Terraform/IaC** - Manage IAM permissions via infrastructure as code

---

## Notes

**Why This Approach:**

1. **Minimal change** - Only update one role in the array
2. **Standard role** - Uses well-documented GCP role
3. **Read-only** - Maintains security posture
4. **Future-proof** - New service accounts get correct permissions
5. **Quick fix** - Can be implemented in under 30 minutes

**Design Decisions:**

1. **legacyBucketReader over objectAdmin** - Least privilege principle
2. **Manual update of existing SAs** - Setup script only runs on creation
3. **Both projects updated** - Production and testing need same permissions
4. **Comprehensive testing** - Verify both functionality and security
5. **Read-only test** - Ensures we didn't grant excessive permissions

**Maintenance:**

This is a one-time fix. Once legacyBucketReader is in the setup script, all future service accounts will have correct permissions automatically.

**Why "legacy" in the name:**

The role is called "legacyBucket" because it grants the same permissions as the legacy "Bucket Reader" ACL from before IAM existed. Despite the name, it's the **current recommended role** for read-only bucket access in GCP documentation.
