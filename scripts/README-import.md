# Firebase Data Import Tool

## ⚠️ Safety Features

**CRITICAL: This tool performs DESTRUCTIVE operations that REPLACE existing data.**

Built-in protections:

- **Dry-run by default**: No changes without `--execute` flag
- **Triple confirmation required**: Understand → Type project name → Production extra check
- **Production protection**: Additional warnings and confirmation for production projects
- **Mandatory user approval**: Cannot bypass without explicit `--yes` flag (dangerous)
- **Manifest preview**: See exactly what will be imported before proceeding
- **Graceful cancellation**: Ctrl+C any time to safely abort

**NEVER run import without understanding what will be replaced.**

---

## Overview

A Node.js command-line tool for importing Firebase data from timestamped backups stored in Google Cloud Storage.

**Key Features:**
- **Imports Firestore collections**: Restores all or selected collections from JSON exports
- **Imports Storage files**: Restores files to Firebase Storage
- **Destructive by design**: DELETES existing data before import
- **Safety confirmations**: Triple-check before any writes
- **Dry-run mode**: Preview import plan before executing (default)
- **Selective import**: Import specific collections or skip storage

**What it does:**
- Reads export manifest from GCS
- Validates export structure and completeness
- Clears target collections (destructive)
- Restores documents with preserved IDs and timestamps
- Copies storage files to target bucket

**What it does NOT do:**
- Does not merge data (always replaces)
- Does not preserve document creation timestamps as system fields
- Does not skip existing documents (always overwrites)

---

## Prerequisites

**Before using the import tool:**

1. **Completed export**: You must have a successful export in GCS
   - See [README-export.md](README-export.md) for export instructions
   - Verify manifest.json exists and is valid

2. **Service account keys**: Required for target Firebase project
   - See export tool documentation for setup instructions
   - Same service account can be used (already has write permissions)

3. **Explicit decision**: You must consciously decide to replace data
   - Verify you have a recent backup
   - Confirm target project is correct
   - Understand data will be deleted

4. **Testing first**: ALWAYS test on staging before production
   - Create a test export
   - Import to staging environment
   - Verify functionality before production import

---

## Setup

If you've completed the export tool setup, you're already done! The import tool uses the same dependencies and service accounts.

### Quick Setup Check

```bash
cd scripts

# Verify dependencies installed
npm list firebase-admin prompts chalk

# Verify service account keys exist
ls secrets/rescuenet-*.json

# Should see:
# secrets/rescuenet-production.json
# secrets/rescuenet-testing.json
```

If missing, see [README-export.md](README-export.md) for complete setup instructions.

---

## Usage

### Basic Import Command

```bash
cd scripts
npm run import -- \
  --source gs://rescuenet-testing-backups/exports/2025-10-11-rescuenet-testing \
  --project rescuenet-testing \
  --execute
```

**Important**: Without `--execute`, this runs in dry-run mode (no changes).

### Command-Line Options

```bash
npm run import -- [options]
```

**Required Options:**
- `--source <uri>` - GCS path to export (e.g., `gs://bucket/exports/2025-10-11-project`)
- `--project <id>` - Target Firebase project ID (where data will be imported)

**Optional Options:**
- `--execute` - Actually perform import (default: dry-run only)
- `--yes` - Skip confirmation prompts (DANGEROUS - see warning below)
- `--skip-storage` - Import Firestore only, skip Storage files
- `--skip-clear` - Don't clear collections before import (may cause conflicts)
- `--collections <list>` - Import specific collections only (comma-separated)

### Examples

**1. Dry run (safe, no changes):**
```bash
npm run import -- \
  --source gs://rescuenet-testing-backups/exports/2025-10-11-rescuenet-testing \
  --project rescuenet-testing
```

Output:
```
=== DRY RUN MODE ===
Import Plan:
  Source: gs://rescuenet-testing-backups/exports/2025-10-11-rescuenet-testing
  Target Project: rescuenet-testing
  Collections: all
  Skip Storage: no
  Clear Before Import: yes

=== Export Manifest ===
Export Version: 1.0
Export Timestamp: 2025-10-11T10:30:00.123Z
Source Project: rescuenet-7733b

Collections:
  items: 342 documents
  containers: 28 documents
  assignments: 1205 documents
  work_log: 567 documents

Storage Files:
  Total files: 150
  Total size: 50.00 MB

No data will be imported in dry-run mode.
Add --execute flag to perform actual import.
```

**2. Full import with confirmation (recommended):**
```bash
npm run import -- \
  --source gs://rescuenet-production-backups/exports/2025-10-10-rescuenet-7733b \
  --project rescuenet-testing \
  --execute
```

You'll see:
```
⚠️  DESTRUCTIVE OPERATION ⚠️
This operation will REPLACE existing data in the target project.
All existing data in imported collections will be DELETED.

Target Project: rescuenet-testing

[Manifest preview shown]

? Do you understand this will DELETE and REPLACE data? (y/N)
> y

To proceed, type the EXACT target project name:
Expected: rescuenet-testing
? Project name: rescuenet-testing

✓ Confirmed. Proceeding with import...

Importing collections...
✓ Cleared collection 'items' (342 documents deleted)
✓ Imported 342 documents to 'items'
✓ Cleared collection 'containers' (28 documents deleted)
✓ Imported 28 documents to 'containers'
...

Importing storage files...
✓ Copied 150 files (50.00 MB)

=== Import Complete ===
Collections: 5 imported
Documents: 2142 total
Storage files: 150 copied
Duration: 45 seconds
```

**3. Import specific collections only:**
```bash
npm run import -- \
  --source gs://rescuenet-testing-backups/exports/2025-10-11-rescuenet-testing \
  --project rescuenet-testing \
  --collections items,containers \
  --execute
```

**4. Skip storage files:**
```bash
npm run import -- \
  --source gs://rescuenet-testing-backups/exports/2025-10-11-rescuenet-testing \
  --project rescuenet-testing \
  --skip-storage \
  --execute
```

**5. Skip confirmation (automated scripts only - DANGEROUS):**
```bash
npm run import -- \
  --source gs://rescuenet-testing-backups/exports/2025-10-11-rescuenet-testing \
  --project rescuenet-testing \
  --yes \
  --execute
```

⚠️ **WARNING about `--yes` flag:**
- Bypasses ALL safety confirmations
- Should ONLY be used in automated scripts
- Requires thorough testing beforehand
- NOT recommended for production
- Easy to make costly mistakes

**6. Direct node invocation (without npm):**
```bash
node import-firebase.js \
  --source gs://bucket/exports/path \
  --project rescuenet-testing \
  --execute
```

---

## What Gets Replaced

**Understanding the destructive nature:**

When you import data, the tool:

1. **Clears entire collections** (unless `--skip-clear`)
   - Every document in the target collection is DELETED
   - No way to undo except from backup
   - Irreversible operation

2. **Replaces with export data**
   - Documents restored with their original IDs
   - Timestamps converted from ISO strings
   - Nested objects and arrays preserved

3. **Overwrites storage files**
   - Files copied to original paths
   - Existing files with same path are replaced
   - No versioning or conflict resolution

**What is NOT preserved:**
- Document creation timestamps (system field)
- Document update timestamps (system field)
- Storage file metadata (except content-type)
- Any data not in the export

**Example impact:**
```
Before import:
  items: 342 documents
  containers: 28 documents

After import (from export with 300 items, 25 containers):
  items: 300 documents (42 documents lost!)
  containers: 25 documents (3 documents lost!)
```

**Always verify:**
- Export is complete and recent
- Export document counts match expectations
- You have a backup of target project

---

## Confirmation Flow Example

When you run an import with `--execute`, you'll see:

```
⚠️  DESTRUCTIVE OPERATION ⚠️
This operation will REPLACE existing data in the target project.
All existing data in imported collections will be DELETED.

Target Project: rescuenet-testing

=== Export Manifest ===
Export Version: 1.0
Export Timestamp: 2025-10-11T10:30:00.123Z
Source Project: rescuenet-7733b

Collections:
  items: 342 documents
  containers: 28 documents

You must confirm that you understand this is a destructive operation.
? Do you understand this will DELETE and REPLACE data? (y/N)
```

Type `y` and press Enter:

```
To proceed, type the EXACT target project name:
Expected: rescuenet-testing
? Project name: _
```

Type the project name exactly (case-sensitive):

```
? Project name: rescuenet-testing

✓ Confirmed. Proceeding with import...
```

**For production projects** (e.g., `rescuenet-7733b`):

```
🚨 PRODUCTION PROJECT DETECTED 🚨
You are about to modify a PRODUCTION environment!

[... manifest and first two confirmations ...]

🚨 FINAL PRODUCTION WARNING 🚨
This is your last chance to cancel.
Are you ABSOLUTELY SURE you want to modify production?
? Proceed with PRODUCTION import? (y/N)
```

**Cancel any time:**
- Press Ctrl+C to abort
- Answer "no" to any prompt
- Type wrong project name
- All result in safe cancellation

---

## Common Workflows

### Refresh Staging from Production

Copy current production data to staging for testing:

```bash
#!/bin/bash
# refresh-staging.sh

cd /path/to/RescuenetWarehouse/scripts

# Step 1: Export production (read-only, safe)
echo "Exporting production data..."
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-migrations \
  --output staging-refresh-2025-10-11

# Step 2: Import to staging (destructive, requires confirmation)
echo "Importing to staging..."
npm run import -- \
  --source gs://rescuenet-migrations/exports/staging-refresh-2025-10-11 \
  --project rescuenet-testing \
  --execute

echo "Staging refreshed from production!"
```

**Verify after import:**
- Check Firebase Console for document counts
- Test critical app flows
- Verify user access still works

### Restore from Backup

If production has issues, restore from a previous backup:

```bash
# Step 1: Verify backup exists
gsutil ls gs://rescuenet-production-backups/exports/

# Step 2: Dry run to verify backup
npm run import -- \
  --source gs://rescuenet-production-backups/exports/2025-10-10-rescuenet-7733b \
  --project rescuenet-7733b

# Step 3: Check manifest carefully
# Verify timestamp, document counts, source project

# Step 4: Create safety backup of current state (optional but recommended)
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-production-backups \
  --output backups/before-restore-2025-10-11

# Step 5: Restore from backup (with confirmations)
npm run import -- \
  --source gs://rescuenet-production-backups/exports/2025-10-10-rescuenet-7733b \
  --project rescuenet-7733b \
  --execute

# Step 6: Verify restoration
# - Check Firebase Console
# - Test critical app functionality
# - Verify user access
```

### Selective Collection Recovery

Restore only specific collections (e.g., after accidental deletion):

```bash
# Restore only 'items' collection from yesterday's backup
npm run import -- \
  --source gs://rescuenet-production-backups/exports/2025-10-10-rescuenet-7733b \
  --project rescuenet-7733b \
  --collections items \
  --execute
```

### Migrate to New Organization

When onboarding a new organization:

```bash
# Step 1: Export from template organization
npm run export -- \
  --project rescuenet-testing \
  --bucket migration-templates \
  --output templates/initial-setup

# Step 2: Import to new organization's staging
npm run import -- \
  --source gs://migration-templates/exports/templates/initial-setup \
  --project neworg-staging \
  --execute

# Step 3: Verify and customize for new org
# Step 4: Import to new organization's production (when ready)
```

---

## Safety Checklist

**Before importing to production, verify:**

- [ ] Export is recent (< 7 days old, ideally < 24 hours)
- [ ] Manifest shows expected document counts
- [ ] Source project matches expectations
- [ ] Target project ID is correct (check spelling!)
- [ ] You have a current backup of target project
- [ ] Tested import on staging environment first
- [ ] Confirmed staging works after test import
- [ ] Scheduled import during low-traffic period
- [ ] Team is aware of maintenance window
- [ ] Rollback plan is documented and tested
- [ ] Someone is available to verify after import

**Production import pre-flight:**

```bash
# 1. Verify current state
firebase use rescuenet-7733b
firebase firestore:indexes:list

# 2. Create safety backup
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-production-backups

# 3. Dry run import
npm run import -- \
  --source gs://bucket/exports/path \
  --project rescuenet-7733b

# 4. Review manifest carefully

# 5. Execute with confirmations
npm run import -- \
  --source gs://bucket/exports/path \
  --project rescuenet-7733b \
  --execute

# 6. Verify immediately
# - Check Firebase Console
# - Test critical user flows
# - Monitor error logs
```

---

## Troubleshooting

### Service Account Permission Denied

**Error:**
```
Error: Permission denied: Missing or insufficient permissions
```

**Solution:**

The service account needs WRITE permissions:
- **Cloud Datastore User** (or Owner) - For Firestore writes
- **Storage Object Admin** - For Storage writes

Grant in Firebase Console → Project Settings → Service Accounts → Permissions

Or re-run setup script:
```bash
./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json
```

### Manifest Not Found

**Error:**
```
Error: Manifest not found at gs://bucket/exports/path/manifest.json
```

**Solutions:**
1. Verify GCS path is correct:
   ```bash
   gsutil ls gs://bucket/exports/
   ```
2. Check path format (should NOT end with `/manifest.json`)
3. Verify export completed successfully
4. Check service account has read access to bucket

### Invalid Manifest Structure

**Error:**
```
Error: Invalid manifest: Missing required field 'collections'
```

**Causes:**
- Corrupted export
- Incomplete export
- Export created by different tool version

**Solution:**
- Re-export from source project
- Verify export process completed without errors
- Check manifest.json manually for structure

### Collection File Not Found

**Error:**
```
Error: Collection file not found: gs://bucket/exports/path/firestore/items.json
```

**Causes:**
- Incomplete export
- Missing collection in export
- File deleted from GCS

**Solution:**
- Run export again
- Verify all collection files exist:
  ```bash
  gsutil ls gs://bucket/exports/path/firestore/
  ```
- Use `--collections` to skip missing collections

### Import Fails Midway

**Error:**
```
Error importing collection items: Quota exceeded
```

**Causes:**
- Firestore quota exceeded
- Large collections
- Network timeout

**Solutions:**
1. **Check quotas** in Firebase Console → Usage
2. **Import collections separately**:
   ```bash
   npm run import -- --source=... --project=... --collections items --execute
   npm run import -- --source=... --project=... --collections containers --execute
   ```
3. **Reduce batch size** (requires code modification)
4. **Retry import** - Tool is designed to be re-runnable

### Storage Copy Errors

**Error:**
```
Storage import completed with errors: 5 files failed
```

**Solution:**

Check which files failed and why. Common causes:
- Files deleted between export and import
- File size limits exceeded
- Storage quota exceeded
- Corrupted files

Files that succeeded are still copied. Failed files can be:
- Manually copied using `gsutil`
- Re-exported and imported
- Skipped if not critical

### Wrong Project Imported

**DISASTER SCENARIO:**
You accidentally imported staging data to production!

**Immediate actions:**
1. **Don't panic** - Breathe
2. **Check if backup exists**:
   ```bash
   gsutil ls gs://rescuenet-production-backups/exports/ | tail -5
   ```
3. **Restore from backup** (see "Restore from Backup" workflow above)
4. **If no backup:** Contact team, assess damage, restore from:
   - Previous automated backup
   - Manual export if available
   - Reconstruct from other sources

**Prevention:**
- Always dry-run first
- Always read confirmation prompts carefully
- Use descriptive export names
- Never use `--yes` flag for production

---

## Production Import Policy

**Requirements before importing to production:**

1. **Approval Required**:
   - Technical lead approval
   - Documented reason for import
   - Change request if applicable

2. **Testing Required**:
   - Import tested on staging
   - Staging verification completed
   - Critical flows tested post-import

3. **Documentation Required**:
   - Rollback plan documented
   - Team notification sent
   - Maintenance window scheduled

4. **Timing Requirements**:
   - Low-traffic period preferred
   - Team member available for monitoring
   - Support team aware

5. **Backup Required**:
   - Current production backup created
   - Backup verified and accessible
   - Backup less than 1 hour old

**Production import checklist:**
- [ ] Approval received
- [ ] Tested on staging
- [ ] Backup created and verified
- [ ] Team notified
- [ ] Maintenance window scheduled
- [ ] Rollback plan ready
- [ ] Monitor ready to verify

---

## Next Steps After Import

**Immediately after import:**

1. **Verify document counts** in Firebase Console:
   - Go to Firestore Database
   - Check each collection matches manifest
   - Spot-check document contents

2. **Test critical user flows**:
   - User authentication
   - Data loading and display
   - Write operations (create, update, delete)
   - File uploads and downloads

3. **Check for errors**:
   - Firebase Console → Functions → Logs
   - Application error monitoring
   - User reports

4. **Verify storage files**:
   - Check Firebase Console → Storage
   - Test file downloads in app
   - Verify file counts

5. **Monitor performance**:
   - Response times
   - Database queries
   - User experience

**Within 24 hours:**

1. **Create new backup** of post-import state
2. **Document what was imported** (date, source, reason)
3. **Review any issues** encountered
4. **Update runbook** if needed

**If issues detected:**

1. **Assess severity**:
   - Critical: Restore from backup immediately
   - Major: Schedule rollback during next maintenance window
   - Minor: Fix forward or schedule restoration

2. **Communicate with team**:
   - Report issues found
   - Document remediation steps
   - Update change request

3. **Execute rollback if needed**:
   - Follow "Restore from Backup" workflow
   - Verify restoration
   - Document lessons learned

---

## Related Documentation

- **Export Tool**: See [README-export.md](README-export.md) for creating backups
- **Cross-Project Migration**: See [README-cross-project.md](README-cross-project.md) for production → testing workflows
- **Multi-Tenant Setup**: See [../CLAUDE.md](../CLAUDE.md) for organization configuration
- **Service Accounts**: See [SERVICE_ACCOUNTS.md](SERVICE_ACCOUNTS.md) for detailed setup
- **Firebase Admin SDK**: [Official Documentation](https://firebase.google.com/docs/admin/setup)

---

## Support

For issues or questions:

1. **Read this documentation** carefully - most questions are answered here
2. **Check Troubleshooting section** for common errors
3. **Verify prerequisites** are correctly set up
4. **Review confirmation prompts** - they contain important information
5. **Test on staging first** before production imports

**Remember:**
- Import is destructive by design
- Always dry-run first
- Always verify backups exist
- Never skip confirmations for production
- When in doubt, ask before executing

**Common mistakes:**
- Forgetting `--execute` flag (dry-run only)
- Wrong project ID in `--project` option
- Skipping dry-run step
- Not verifying manifest before confirming
- Using `--yes` flag without thorough testing
- Importing old exports (>7 days)
- Not having a backup before production import
