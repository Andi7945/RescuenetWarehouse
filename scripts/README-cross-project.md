# Cross-Project Data Migration Guide

## Overview

This guide explains how to migrate data between different Firebase projects (e.g., production → testing) using the export/import tools.

**Architecture:**
```
Source Project    →    Intermediate Bucket    →    Target Project
(rescuenet-7733b)      (rescuenet-migrations)      (rescuenet-testing)
     Export                 GCS Storage                  Import
```

**Key Concept:** The intermediate GCS bucket acts as a "transfer station" that both projects can access.

---

## Prerequisites

1. **Both projects have service accounts created:**
   ```bash
   cd scripts
   ./setup-service-accounts.sh rescuenet-7733b rescuenet-production.json
   ./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json
   ```

2. **Intermediate bucket exists:**
   ```bash
   # Create in target project (testing) for easier management
   ./setup-gcs-bucket.sh rescuenet-testing rescuenet-migrations
   ```

3. **Cross-project access granted:**
   ```bash
   # Allow source project (production) to write to target project's bucket
   ./setup-cross-project-access.sh rescuenet-migrations rescuenet-7733b admin
   ```

---

## Complete Workflow: Production → Testing

### Step 1: Setup (One-Time)

```bash
cd scripts

# 1. Create service accounts (if not already done)
./setup-all-service-accounts.sh

# 2. Create migration bucket in testing project
./setup-gcs-bucket.sh rescuenet-testing rescuenet-migrations

# 3. Grant production service account access to migration bucket
./setup-cross-project-access.sh rescuenet-migrations rescuenet-7733b admin

# Done! You can now migrate data.
```

**Verify Setup:**
```bash
# List buckets
gcloud storage buckets list --project=rescuenet-testing

# Check bucket permissions
gcloud storage buckets get-iam-policy gs://rescuenet-migrations
# Should see firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com with objectAdmin role
```

---

### Step 2: Export Production Data

```bash
cd scripts

# Export all data from production to migration bucket
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-migrations \
  --output prod-to-testing-$(date +%Y-%m-%d)
```

**Output:**
```
=== Firebase Export Tool ===
Project: rescuenet-7733b
Target: gs://rescuenet-migrations/exports/prod-to-testing-2025-10-11

Initializing Firebase...
✓ Firebase initialized

Initializing GCS Storage SDK...
✓ GCS Storage SDK initialized

Exporting Firestore collections...
✓ Exported 7 collections

Exporting Storage files...
✓ Copied 150 files (52428800 bytes)

Creating manifest...
✓ Manifest created

Writing data to GCS...
  ✓ manifest.json
  ✓ firestore/items.json (342 documents)
  ✓ firestore/containers.json (28 documents)
  ...

=== Export Complete ===
Location: gs://rescuenet-migrations/exports/prod-to-testing-2025-10-11
Total time: 45s
```

**Verify Export:**
```bash
# List exported files
gcloud storage ls gs://rescuenet-migrations/exports/prod-to-testing-2025-10-11/

# Check manifest
gcloud storage cat gs://rescuenet-migrations/exports/prod-to-testing-2025-10-11/manifest.json
```

---

### Step 3: Import to Testing

```bash
cd scripts

# IMPORTANT: Dry run first to preview
npm run import -- \
  --source gs://rescuenet-migrations/exports/prod-to-testing-2025-10-11/manifest.json \
  --project rescuenet-testing

# Review the manifest carefully, then execute
npm run import -- \
  --source gs://rescuenet-migrations/exports/prod-to-testing-2025-10-11/manifest.json \
  --project rescuenet-testing \
  --execute
```

**Interactive Confirmation:**
```
⚠️  DESTRUCTIVE OPERATION ⚠️
This operation will REPLACE existing data in the target project.
All existing data in imported collections will be DELETED.

Target Project: rescuenet-testing

=== Export Manifest ===
Export Version: 1.0
Export Timestamp: 2025-10-11T14:23:45.123Z
Source Project: rescuenet-7733b

Collections:
  items: 342 documents
  containers: 28 documents
  assignments: 1205 documents
  work_log: 567 documents

Storage Files:
  Total files: 150
  Total size: 50.00 MB

? Do you understand this will DELETE and REPLACE data? (y/N) y

To proceed, type the EXACT target project name:
Expected: rescuenet-testing
? Project name: rescuenet-testing

✓ Confirmed. Proceeding with import...

Importing collections to Firestore...
✓ Cleared collection 'items' (342 documents deleted)
✓ Imported 342 documents to 'items'
...

Importing storage files...
✓ Copied 150 files

=== Import Complete ===
Firestore Collections: 7 imported
Documents: 2142 total
Storage files: 150 copied
```

**Verify Import:**
```bash
# Check Firebase Console
open https://console.firebase.google.com/project/rescuenet-testing/firestore

# Or use gcloud
gcloud firestore databases describe --project=rescuenet-testing
```

---

## Common Scenarios

### Scenario 1: Regular Staging Refresh

Refresh testing environment with production data weekly:

```bash
#!/bin/bash
# refresh-staging-from-prod.sh

cd scripts

# Export production
echo "Exporting production data..."
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-migrations \
  --output staging-refresh-$(date +%Y-%m-%d)

# Import to testing
echo "Importing to testing..."
npm run import -- \
  --source gs://rescuenet-migrations/exports/staging-refresh-$(date +%Y-%m-%d)/manifest.json \
  --project rescuenet-testing \
  --execute

echo "Staging refreshed!"
```

### Scenario 2: Selective Collection Migration

Migrate only specific collections:

```bash
# Export only items and containers from production
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-migrations \
  --collections items,containers \
  --skip-storage

# Import only those collections
npm run import -- \
  --source gs://rescuenet-migrations/exports/path/manifest.json \
  --project rescuenet-testing \
  --collections items,containers \
  --skip-storage \
  --execute
```

### Scenario 3: Testing → Production (Reverse Migration)

**⚠️ WARNING: Rare and dangerous! Requires careful planning.**

Setup:
```bash
# Grant testing SA access to production's bucket (read-only recommended)
./setup-cross-project-access.sh rescuenet-production-backups rescuenet-testing viewer

# Or create a separate bucket for this purpose
./setup-gcs-bucket.sh rescuenet-7733b rescuenet-testing-to-prod
./setup-cross-project-access.sh rescuenet-testing-to-prod rescuenet-testing admin
```

Migration:
```bash
# Export from testing
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-testing-to-prod \
  --output testing-to-prod-$(date +%Y-%m-%d)

# DANGER: Importing to production
# Only do this with:
# - Technical lead approval
# - Complete backup of production
# - Scheduled maintenance window
# - Team standing by to verify

npm run import -- \
  --source gs://rescuenet-testing-to-prod/exports/testing-to-prod-2025-10-11/manifest.json \
  --project rescuenet-7733b \
  --execute
```

---

## Permission Matrix

| Scenario | Bucket Location | Source SA Access | Target SA Access |
|----------|----------------|------------------|------------------|
| Prod → Testing | Testing project | Admin (write) | Auto (same project) |
| Testing → Prod | Production project | Auto (same project) | Admin (write) |
| Prod → Testing (separate) | Neutral bucket | Admin | Admin |

**Auto Access:** Service account automatically has access when bucket is in the same project.

**Manual Grant Required:** When bucket is in different project, use `setup-cross-project-access.sh`.

---

## Troubleshooting

### Error: Permission Denied on Bucket

**Error:**
```
Error: Permission denied: firebase-export-tool@rescuenet-7733b.iam.gserviceaccount.com
does not have storage.objects.create access to gs://rescuenet-migrations
```

**Solution:**
```bash
# Grant cross-project access
./setup-cross-project-access.sh rescuenet-migrations rescuenet-7733b admin

# Verify
gcloud storage buckets get-iam-policy gs://rescuenet-migrations | \
  grep firebase-export-tool@rescuenet-7733b
```

### Error: Bucket Not Found

**Error:**
```
Error: Bucket not found: gs://rescuenet-migrations
```

**Solution:**
```bash
# Create the bucket first
./setup-gcs-bucket.sh rescuenet-testing rescuenet-migrations

# Verify
gcloud storage buckets describe gs://rescuenet-migrations
```

### Error: Service Account Not Found

**Error:**
```
Error: Service account file not found: /path/to/secrets/rescuenet-testing.json
```

**Solution:**
```bash
# Create service account
./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json

# Verify
ls -la secrets/rescuenet-*.json
```

### Import Shows 0 Collections

**Possible Causes:**
1. Manifest path is wrong
2. Export didn't complete
3. Collections array is empty in manifest

**Debug:**
```bash
# Check manifest exists
gcloud storage cat gs://bucket/exports/path/manifest.json

# Check manifest structure
gcloud storage cat gs://bucket/exports/path/manifest.json | jq .

# List all files in export
gcloud storage ls gs://bucket/exports/path/
```

---

## Best Practices

### Security

1. **Principle of Least Privilege:**
   - Grant only required access level (viewer vs creator vs admin)
   - Review bucket IAM policies regularly
   - Rotate service account keys annually

2. **Separate Buckets for Different Purposes:**
   - `rescuenet-production-backups` - Production backups only
   - `rescuenet-migrations` - Cross-project data migration
   - `rescuenet-testing-backups` - Testing backups only

3. **Audit Trail:**
   - Name exports with dates and purpose
   - Document why each migration was performed
   - Keep exports for 30-90 days for rollback

### Performance

1. **Off-Peak Migrations:**
   - Export production during low-traffic periods
   - Import to testing can be done anytime

2. **Incremental Updates:**
   - For large datasets, consider selective collection export
   - Use `--collections` flag to migrate only changed data

3. **Cleanup:**
   - Delete old exports after 90 days
   - Set up GCS lifecycle policy:
   ```bash
   gcloud storage buckets update gs://rescuenet-migrations \
     --lifecycle-file=lifecycle.json
   ```

   `lifecycle.json`:
   ```json
   {
     "lifecycle": {
       "rule": [{
         "action": {"type": "Delete"},
         "condition": {"age": 90}
       }]
     }
   }
   ```

### Testing

1. **Always Dry Run First:**
   ```bash
   npm run import -- --source=... --project=... # No --execute
   ```

2. **Verify Manifest:**
   - Check export timestamp (should be recent)
   - Check source project (should be correct)
   - Check document counts (should match expectations)

3. **Post-Import Verification:**
   - Check Firebase Console for document counts
   - Test critical app functionality
   - Verify user access still works

---

## Automation Examples

### GitHub Actions Workflow

```yaml
name: Refresh Staging from Production

on:
  schedule:
    - cron: '0 2 * * 0'  # Every Sunday at 2 AM
  workflow_dispatch:  # Manual trigger

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: |
          cd scripts
          npm install

      - name: Setup gcloud
        uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}

      - name: Export production
        run: |
          cd scripts
          npm run export -- \
            --project rescuenet-7733b \
            --bucket rescuenet-migrations \
            --output staging-refresh-$(date +%Y-%m-%d)

      - name: Import to testing
        run: |
          cd scripts
          npm run import -- \
            --source gs://rescuenet-migrations/exports/staging-refresh-$(date +%Y-%m-%d)/manifest.json \
            --project rescuenet-testing \
            --yes \
            --execute

      - name: Notify team
        if: always()
        run: |
          echo "Staging refresh completed"
          # Add Slack/email notification here
```

### Cron Job

```bash
# /etc/cron.d/staging-refresh
# Refresh staging every Sunday at 2 AM
0 2 * * 0 cd /path/to/RescuenetWarehouse/scripts && ./refresh-staging-from-prod.sh >> /var/log/staging-refresh.log 2>&1
```

---

## Related Documentation

- **Export Tool**: See [README-export.md](README-export.md)
- **Import Tool**: See [README-import.md](README-import.md)
- **Service Account Setup**: See [README-export.md#service-account-setup](README-export.md#service-account-setup)
- **GCS Bucket Setup**: See [README-export.md#gcs-bucket-setup](README-export.md#gcs-bucket-setup)
- **Multi-Tenant Config**: See [../CLAUDE.md](../CLAUDE.md)

---

## Support

**Common Questions:**

Q: Can I migrate from testing to production?
A: Yes, but requires careful planning, approval, and production backup. See "Scenario 3" above.

Q: How long does migration take?
A: Depends on data size. Typical: 1-2 minutes for export, 2-3 minutes for import.

Q: Can I migrate between different organizations?
A: Yes! Use the same cross-project setup, just with different project IDs.

Q: What happens to existing data in target project?
A: It's DELETED before import. Always backup target before importing.

Q: Can I cancel import after starting?
A: Press Ctrl+C before confirmation prompts. After confirmation, import cannot be cancelled.

**Need Help?**

1. Check Troubleshooting section above
2. Verify prerequisites are met
3. Check Firebase Console for errors
4. Review script output carefully
5. Test on staging before production
