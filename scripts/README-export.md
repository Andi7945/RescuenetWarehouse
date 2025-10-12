# Firebase Data Export Tool

## Overview

A Node.js command-line tool for exporting Firebase data to Google Cloud Storage (GCS) or local filesystem.

**Key Features:**
- **Two export modes**: GCS buckets (cloud) or local filesystem (disk)
- **Read-only operation**: Cannot modify your Firebase project (safe to run)
- **Exports Firestore collections**: All or selected collections as JSON
- **Exports Storage files**: Copies all files from Firebase Storage
- **Timestamped backups**: Creates organized exports with manifest metadata
- **Idempotent**: Safe to re-run (creates new timestamped exports each time)
- **Dry-run mode**: Preview export plan before executing

**What it does NOT do:**
- Does not import/restore data (see [README-import.md](README-import.md) for import tool)
- Does not delete or modify source data
- Does not overwrite existing exports (always creates new timestamped directories)

## Export Modes

### GCS Mode (Cloud Storage)
Export to Google Cloud Storage buckets for production backups and long-term archival.

```bash
node export-firebase.js \
  --project my-project \
  --bucket my-backup-bucket
```

**Best for:**
- Production disaster recovery
- Long-term archival storage
- Automated scheduled backups
- Team collaboration on backups

### Local Mode (Filesystem)
Export to local filesystem for development, testing, and quick backups.

```bash
node export-firebase.js \
  --project my-project \
  --local-output ./backups/2025-01-15
```

**Best for:**
- Quick development backups
- Local testing workflows
- Avoiding GCS costs
- Air-gapped environments
- CI/CD test fixtures

**📖 See [README-local-backups.md](README-local-backups.md) for complete local backup guide.**

---

## Setup

### Prerequisites

**Required:**
- **Node.js**: Version 16 or higher
- **npm**: Comes with Node.js
- **Firebase Service Account Keys**: JSON key files with appropriate permissions
- **Google Cloud Storage Bucket**: GCS bucket for storing exports

**Verify installations:**
```bash
node --version   # Should be v16.0.0 or higher
npm --version    # Should be 7.0.0 or higher
```

### Installation

1. **Navigate to scripts directory:**
   ```bash
   cd scripts
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

   This installs:
   - `firebase-admin` - Firebase Admin SDK
   - `commander` - CLI argument parsing
   - `p-limit` - Concurrency control for file operations
   - `cli-progress` - Progress bars (planned feature)

### Service Account Setup

Service account keys are required to authenticate with Firebase projects.

**Location:** Place service account keys in `scripts/secrets/`

**Naming Convention:**
- Production: `scripts/secrets/rescuenet-production.json`
- Staging: `scripts/secrets/rescuenet-testing.json`

#### Automated Setup (Recommended)

Use the provided setup scripts to create service accounts with correct permissions:

**Setup both environments at once:**
```bash
cd scripts
./setup-all-service-accounts.sh
```

**Or setup individually:**
```bash
cd scripts
./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json
./setup-service-accounts.sh rescuenet-7733b rescuenet-production.json
```

The scripts will:
- ✓ Create service account with read-only permissions
- ✓ Grant required roles (Datastore User, Storage Object Viewer, Storage Object Creator)
- ✓ Generate and download JSON key file
- ✓ Save to correct location with correct filename
- ✓ Set restrictive file permissions (600)

**Prerequisites for automated setup:**
- `gcloud` CLI installed and authenticated
- Owner or Editor role on the Firebase projects

#### Manual Setup (Alternative)

If you prefer manual setup or don't have `gcloud` CLI:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (e.g., `rescuenet-testing`)
3. Navigate to: **IAM & Admin** → **Service Accounts**
4. Click **+ CREATE SERVICE ACCOUNT**
5. Name: `firebase-export-tool`
6. Grant these roles:
   - **Cloud Datastore User** (for Firestore read access)
   - **Storage Object Viewer** (for Storage read access)
   - **Storage Object Creator** (for writing to GCS backup bucket)
7. Click **Done**
8. Find the service account in the list, click **⋮** → **Manage keys**
9. Click **ADD KEY** → **Create new key** → **JSON**
10. Download and save to `scripts/secrets/` with correct naming convention

**Required Permissions:**
- Cloud Datastore User (for Firestore read access)
- Storage Object Viewer (for Storage read access)
- Storage Object Creator (for GCS backup bucket writes)

**Security Note:** The `scripts/secrets/` directory is gitignored. Never commit service account keys to version control.

**Update service account mapping:**

If adding a new project, edit `scripts/lib/firebase-init.js` and add your project to the mapping:

```javascript
const serviceAccountMap = {
  'rescuenet-7733b': 'scripts/secrets/rescuenet-production.json',
  'rescuenet-testing': 'scripts/secrets/rescuenet-testing.json',
  'your-project-id': 'scripts/secrets/your-project-name.json'
};
```

Or run the setup script for the new project:
```bash
./setup-service-accounts.sh your-project-id your-project-name.json
```

### GCS Bucket Setup

You need a Google Cloud Storage bucket to store exports.

**Create a bucket:**
```bash
# Using gcloud CLI
gsutil mb -p <project-id> -l <region> gs://<bucket-name>

# Example
gsutil mb -p rescuenet-testing -l europe-west1 gs://rescuenet-testing-backups
```

**Or use Google Cloud Console:**
1. Go to [GCS Console](https://console.cloud.google.com/storage)
2. Click "Create Bucket"
3. Name: `rescuenet-testing-backups`
4. Region: Same as your Firestore (e.g., `europe-west1`)
5. Click "Create"

**Permissions:**
The service account automatically has access to buckets in the same Firebase project. For external buckets, grant the service account "Storage Object Admin" role.

---

## Usage

### Basic Export Command

```bash
cd scripts
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-testing-backups
```

This exports:
- All Firestore collections
- All Storage files
- To `gs://rescuenet-testing-backups/exports/2025-10-11-rescuenet-testing/`

### Command-Line Options

```bash
npm run export -- [options]
```

**Required Options:**
- `--project <id>` - Firebase project ID (e.g., `rescuenet-testing`)
- `--bucket <name>` - GCS bucket name for exports (e.g., `rescuenet-testing-backups`)

**Optional Options:**
- `--output <path>` - Custom output path in bucket (default: `exports/{YYYY-MM-DD}-{projectId}`)
- `--skip-storage` - Skip Storage file export (Firestore only)
- `--collections <list>` - Export specific collections only (comma-separated)
- `--dry-run` - Show export plan without writing any data

### Examples

**1. Production export:**
```bash
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-production-backups
```

**2. Dry run (preview without exporting):**
```bash
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-testing-backups \
  --dry-run
```

Output:
```
=== DRY RUN MODE ===
Export Plan:
  Project: rescuenet-testing
  Target Bucket: rescuenet-testing-backups
  Output Path: exports/2025-10-11-rescuenet-testing
  Collections: all
  Skip Storage: no

No data will be exported in dry-run mode.
Remove --dry-run flag to perform actual export.
```

**3. Export specific collections only:**
```bash
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-testing-backups \
  --collections items,containers,assignments
```

**4. Export Firestore only (skip Storage):**
```bash
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-testing-backups \
  --skip-storage
```

**5. Custom output path:**
```bash
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-testing-backups \
  --output backups/pre-release-v2.3.0
```

**6. Direct node invocation (without npm):**
```bash
node export-firebase.js \
  --project rescuenet-testing \
  --bucket rescuenet-testing-backups
```

---

## Output Structure

Exports are organized in timestamped directories with the following structure:

```
gs://bucket-name/exports/2025-10-11-rescuenet-testing/
├── manifest.json                    # Export metadata
├── firestore/
│   ├── items.json                   # Items collection (array of documents)
│   ├── containers.json              # Containers collection
│   ├── assignments.json             # Assignments collection
│   ├── work_log.json                # Work log collection
│   ├── current_locations.json       # Current locations collection
│   ├── module_destinations.json     # Module destinations collection
│   └── container_types.json         # Container types collection
└── storage/
    └── summary.json                 # Storage copy statistics
```

**Note:** Storage files are copied with their original paths preserved within the export directory. The `storage/summary.json` file contains metadata about the copy operation (file count, bytes transferred, errors if any).

### File Formats

**Firestore Collections (*.json):**
```json
[
  {
    "id": "doc-id-123",
    "name": "Medical Kit",
    "quantity": 50,
    "createdAt": "2025-10-11T10:30:00.000Z",
    ...
  },
  ...
]
```

Each collection is an array of documents with:
- `id` field: Document ID from Firestore
- All document fields with Firestore Timestamps converted to ISO 8601 strings
- Nested objects and arrays preserved

**Storage Summary (storage/summary.json):**
```json
{
  "files": 150,
  "totalBytes": 52428800,
  "copied": 150,
  "errors": []
}
```

---

## Manifest Format

The `manifest.json` file contains metadata about the export:

```json
{
  "version": "1.0",
  "timestamp": "2025-10-11T14:23:45.123Z",
  "sourceProject": "rescuenet-testing",
  "collections": {
    "items": 342,
    "containers": 28,
    "assignments": 1205,
    "work_log": 567,
    "current_locations": 15,
    "module_destinations": 8,
    "container_types": 6
  },
  "storage": {
    "filesCopied": 150,
    "bytesTransferred": 52428800,
    "errors": 0
  }
}
```

**Fields:**
- `version` - Manifest format version (for future compatibility)
- `timestamp` - ISO 8601 timestamp when export started
- `sourceProject` - Firebase project ID that was exported
- `collections` - Object mapping collection names to document counts
- `storage` - Storage export statistics (omitted if `--skip-storage` used)

**Use cases:**
- Verify export completeness
- Compare exports over time
- Audit trail for compliance
- Input for future import tool

---

## Common Workflows

### Weekly Backup Procedure

Run this every Sunday to maintain regular backups:

```bash
#!/bin/bash
# weekly-backup.sh

cd /path/to/RescuenetWarehouse/scripts

# Backup production
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-production-backups

# Backup staging
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-testing-backups

echo "Weekly backups complete!"
```

Set up as a cron job:
```bash
# Run every Sunday at 2 AM
0 2 * * 0 /path/to/weekly-backup.sh
```

### Pre-Release Snapshot

Before deploying a major release, create a snapshot for rollback safety:

```bash
# 1. Run dry-run to verify
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-production-backups \
  --output backups/pre-release-v2.3.0 \
  --dry-run

# 2. If dry-run looks good, run actual export
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-production-backups \
  --output backups/pre-release-v2.3.0

# 3. Deploy your release
./scripts/release_org.sh rescuenet production

# 4. If issues occur, restore from backup (requires import tool - planned)
```

### Exporting for Data Analysis

Export specific collections for analysis without storage files:

```bash
# Export only items and assignments for inventory analysis
npm run export -- \
  --project rescuenet-7733b \
  --bucket rescuenet-analytics \
  --collections items,assignments \
  --skip-storage \
  --output analysis/inventory-audit-2025-10
```

Then download and analyze:
```bash
# Download exported files
gsutil -m cp -r gs://rescuenet-analytics/analysis/inventory-audit-2025-10 ./data/

# Analyze with your preferred tool
python analyze_inventory.py ./data/inventory-audit-2025-10/firestore/
```

### Migrating to New Project

When setting up a new organization or environment:

```bash
# 1. Export from source project
npm run export -- \
  --project rescuenet-7733b \
  --bucket migration-staging \
  --output migrations/to-neworg

# 2. Manual import (requires import tool - see planned features)
# This will be automated in the future import tool
```

---

## Troubleshooting

### Service Account Not Found

**Error:**
```
Service account file not found: /path/to/scripts/secrets/rescuenet-testing.json
Please ensure the service account key exists at this location.
```

**Solution:**
1. Check that the file exists: `ls scripts/secrets/`
2. Verify the filename matches the mapping in `scripts/lib/firebase-init.js`
3. Download the service account key from Firebase Console if missing
4. Place it in the correct location with correct filename

### Permission Denied Errors

**Error:**
```
Error: Permission denied: Missing or insufficient permissions
```

**Causes & Solutions:**

**Firestore Permission Denied:**
- Service account needs "Cloud Datastore User" or "Cloud Datastore Owner" role
- Grant in Firebase Console → Project Settings → Service Accounts → Permissions

**Storage Permission Denied:**
- Service account needs "Storage Object Viewer" or "Storage Admin" role
- Grant in GCS Console → Bucket → Permissions

**GCS Bucket Permission Denied:**
- For same-project buckets: Service account should have access automatically
- For cross-project buckets: Grant "Storage Object Admin" role to service account
- Verify bucket name is correct: `gsutil ls gs://bucket-name`

### GCS Bucket Doesn't Exist

**Error:**
```
Error: Bucket not found: gs://bucket-name
```

**Solution:**
```bash
# List available buckets
gsutil ls -p rescuenet-testing

# Create the bucket
gsutil mb -p rescuenet-testing -l europe-west1 gs://rescuenet-testing-backups

# Retry export
npm run export -- --project rescuenet-testing --bucket rescuenet-testing-backups
```

### Unknown Project ID

**Error:**
```
Unknown project ID: myproject. Valid project IDs are: rescuenet-7733b, rescuenet-testing
```

**Solution:**

Add your project to `scripts/lib/firebase-init.js`:

```javascript
const serviceAccountMap = {
  'rescuenet-7733b': 'scripts/secrets/rescuenet-production.json',
  'rescuenet-testing': 'scripts/secrets/rescuenet-testing.json',
  'myproject': 'scripts/secrets/myproject.json'  // Add this line
};
```

Then ensure the service account key exists at the specified path.

### Export Fails Midway

**Error:**
```
Error exporting collection items: Deadline exceeded
```

**Causes:**
- Network timeout (large collections)
- Firestore quota exceeded
- Slow connection

**Solutions:**
1. **Retry the export** - Tool is idempotent, creates new timestamped export
2. **Export specific collections** - Break into smaller batches:
   ```bash
   # Export collections separately
   npm run export -- --project rescuenet-testing --bucket bucket-name --collections items
   npm run export -- --project rescuenet-testing --bucket bucket-name --collections containers,assignments
   ```
3. **Check Firestore quotas** in Firebase Console → Usage tab
4. **Use better network connection** if possible

### Storage Copy Errors

If some files fail to copy, check the `storage/summary.json` for details:

```json
{
  "files": 100,
  "copied": 98,
  "errors": [
    {
      "file": "images/broken.jpg",
      "error": "File not found"
    }
  ]
}
```

**Common causes:**
- File deleted between listing and copying
- Permission issues on specific files
- Corrupted files in source storage

**Solution:** Review errors and manually verify/fix problematic files if needed.

---

## Safety Notes

### Read-Only Guarantee

This tool is **completely read-only**:
- Uses Firebase Admin SDK in read-only mode
- Only calls `.get()` methods on Firestore
- Only calls `.getFiles()` and `.copy()` on Storage
- Never calls `.set()`, `.update()`, `.delete()`, or any write operations

### Idempotent Operations

The tool is **safe to re-run**:
- Each export creates a new timestamped directory
- Never overwrites existing exports
- Failed exports can be safely retried
- Re-running creates a new backup, doesn't modify the old one

### Best Practices

**Always use dry-run first:**
```bash
npm run export -- --project <project> --bucket <bucket> --dry-run
```

**Production exports:**
1. Run dry-run to verify plan
2. Verify service account has read-only permissions only
3. Run export during low-traffic periods
4. Monitor Firestore quota usage
5. Verify export completeness via manifest

**Storage considerations:**
- GCS storage costs apply for exported data
- Consider lifecycle policies to auto-delete old exports
- Monitor bucket storage usage

**Security:**
- Never commit service account keys to git
- Use read-only service accounts when possible
- Restrict GCS bucket access to authorized personnel
- Regularly audit service account permissions

---

## Future Import Tool

This export tool creates the foundation for a future import tool. See [PLAN-import.md](PLAN-import.md) for the planned import functionality.

**Planned import features:**
- Restore collections from exported JSON
- Restore Storage files
- Selective import (specific collections or documents)
- Merge strategies (overwrite, skip, update)
- Dry-run mode for imports
- Validation before import

**Current workaround:**

For manual imports, you can:
1. Download exported JSON files from GCS
2. Parse and transform data as needed
3. Use Firebase Admin SDK or Firebase CLI to import:
   ```bash
   firebase firestore:import /path/to/export/firestore/
   ```

Note: Manual imports require additional scripting and careful handling of document IDs and timestamps.

---

## Related Documentation

- **Build/Deploy Scripts**: See [README.md](README.md) for Flutter build and deployment
- **Import Tool Plan**: See [PLAN-import.md](PLAN-import.md) for future import functionality
- **Cross-Project Migration**: See [README-cross-project.md](README-cross-project.md) for production → testing workflows
- **Firebase Admin SDK**: [Official Documentation](https://firebase.google.com/docs/admin/setup)
- **Google Cloud Storage**: [GCS Documentation](https://cloud.google.com/storage/docs)

---

## Support

For issues or questions:

1. Check the Troubleshooting section above
2. Review the Usage examples for your specific use case
3. Verify all prerequisites are correctly set up
4. Check Firebase and GCS console for service status
5. Review script output for specific error messages

**Common issues:**
- 90% of errors are service account permission issues
- Check that service account file exists and is valid JSON
- Verify bucket name is correct (no `gs://` prefix in `--bucket` option)
- Ensure Node.js version is 16 or higher
