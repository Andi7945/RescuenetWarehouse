# Local Filesystem Export/Import Guide

This guide explains how to use local filesystem export/import instead of Google Cloud Storage buckets for Firebase data backups.

## Overview

The export/import scripts now support two modes:
- **GCS Mode** (original): Export/import data to/from Google Cloud Storage buckets
- **Local Mode** (new): Export/import data to/from local filesystem

## When to Use Local Backups

### ✅ Good use cases:
- Quick backups before making changes to your data
- Local development and testing workflows
- Transferring data via secure/offline channels
- Avoiding GCS storage costs for temporary backups
- CI/CD build artifacts (store exports as test fixtures)
- Air-gapped environments without cloud access

### ❌ Not recommended for:
- Production disaster recovery (use GCS for reliability)
- Long-term archival storage (use GCS)
- Automated scheduled backups (use GCS)
- Team collaboration on shared backups (use GCS)

## Quick Start

### Export to Local Directory

```bash
# Basic export
node export-firebase.js \
  --project my-project \
  --local-output ./backups/my-backup

# With timestamped directory
node export-firebase.js \
  --project rescuenet-staging \
  --local-output ./backups/$(date +%Y-%m-%d-%H%M%S)

# Skip storage files (faster for Firestore-only backups)
node export-firebase.js \
  --project my-project \
  --local-output ./backups/firestore-only \
  --skip-storage
```

### Import from Local Directory

```bash
# Basic import (dry-run first)
node import-firebase.js \
  --local-input ./backups/my-backup \
  --project my-target-project

# Execute the import
node import-firebase.js \
  --local-input ./backups/my-backup \
  --project my-target-project \
  --execute

# Import specific collections only
node import-firebase.js \
  --local-input ./backups/my-backup \
  --project my-project \
  --collections items,containers \
  --execute
```

## Local Backup Structure

After export, you'll have the following structure:

```
./backups/my-backup/
├── manifest.json                    # Export metadata (version, timestamp, collections)
├── firestore/
│   ├── items.json                  # Each collection as a separate JSON file
│   ├── containers.json
│   ├── assignments.json
│   ├── work_log.json
│   ├── current_locations.json
│   ├── module_destinations.json
│   └── container_types.json
└── storage/                         # Firebase Storage files (preserves structure)
    ├── item_images/
    │   └── image123.jpg
    └── documents/
        └── label.pdf
```

## Usage Examples

### Cross-Project Data Transfer (Local)

Transfer data from staging to production using local filesystem:

```bash
# Step 1: Export from staging
node export-firebase.js \
  --project rescuenet-staging \
  --local-output ./transfer/staging-data

# Step 2: Import to production
node import-firebase.js \
  --local-input ./transfer/staging-data \
  --project rescuenet-production \
  --execute
```

**Benefits over GCS approach:**
- No GCS bucket setup required
- No cross-project bucket permissions needed
- Simpler for one-time transfers
- No storage costs

### Daily Development Backup

Create a backup before making risky changes:

```bash
# Quick backup with timestamp
node export-firebase.js \
  --project rescuenet-staging \
  --local-output ./backups/before-migration-$(date +%Y%m%d) \
  --skip-storage  # Faster if you only need Firestore data

# Make your risky changes...

# Restore if needed
node import-firebase.js \
  --local-input ./backups/before-migration-20251012 \
  --project rescuenet-staging \
  --execute
```

### Backup Specific Collections

```bash
# Export only certain collections
node export-firebase.js \
  --project my-project \
  --local-output ./backups/items-only \
  --collections items,containers \
  --skip-storage
```

## Tips & Best Practices

### Directory Organization

Use timestamped directories for easy management:

```bash
# Create timestamped backup
BACKUP_DIR="./backups/$(date +%Y-%m-%d-%H%M%S)"
node export-firebase.js \
  --project my-project \
  --local-output "$BACKUP_DIR"
```

### Storage Management

Keep backups outside your git repository:

```bash
# Add to .gitignore
echo "backups/" >> .gitignore
echo "exports/" >> .gitignore
```

### Compression

Compress large backups to save disk space:

```bash
# Export and compress
node export-firebase.js \
  --project my-project \
  --local-output ./backups/my-backup

tar -czf my-backup.tar.gz ./backups/my-backup/

# Extract and import
tar -xzf my-backup.tar.gz
node import-firebase.js \
  --local-input ./backups/my-backup \
  --project my-project \
  --execute
```

### Testing Imports

Always test imports on staging before production:

```bash
# 1. Dry-run (shows what will happen, no changes)
node import-firebase.js \
  --local-input ./backups/prod-backup \
  --project rescuenet-staging

# 2. Execute on staging
node import-firebase.js \
  --local-input ./backups/prod-backup \
  --project rescuenet-staging \
  --execute

# 3. Verify data looks correct

# 4. Then import to production if all looks good
```

## Comparing GCS vs Local Mode

| Feature | GCS Mode | Local Mode |
|---------|----------|------------|
| **Setup** | Requires GCS bucket + permissions | Just a local directory |
| **Speed** | Network dependent | Fast (local I/O) |
| **Cost** | GCS storage + egress fees | Free (local disk) |
| **Durability** | High (cloud replicated) | Low (single disk) |
| **Sharing** | Easy (cloud accessible) | Manual (file transfer) |
| **Automation** | Great for CI/CD | Good for dev workflows |
| **Best for** | Production backups | Development, testing |

## Switching from GCS to Local

Existing GCS workflows remain unchanged. Simply swap the CLI flag:

**Before (GCS):**
```bash
node export-firebase.js \
  --project my-project \
  --bucket my-backup-bucket
```

**After (Local):**
```bash
node export-firebase.js \
  --project my-project \
  --local-output ./backups/latest
```

## Troubleshooting

### "Permission denied" error

Ensure the parent directory exists and is writable:

```bash
mkdir -p ./backups
chmod 755 ./backups
node export-firebase.js --project my-project --local-output ./backups/my-backup
```

### "Disk space full" error

Free up disk space or use a different directory:

```bash
# Check available space
df -h .

# Use a different directory with more space
node export-firebase.js \
  --project my-project \
  --local-output /Volumes/ExternalDrive/backups/my-backup
```

### "Incomplete export" on import

Re-run the export (it's safe to overwrite):

```bash
# Export again to the same directory
node export-firebase.js \
  --project my-project \
  --local-output ./backups/my-backup

# Then import
node import-firebase.js \
  --local-input ./backups/my-backup \
  --project my-project \
  --execute
```

### "Directory not found" on import

Verify the directory exists and contains a manifest.json:

```bash
# Check directory structure
ls -la ./backups/my-backup/
# Should see: manifest.json, firestore/, storage/

# If manifest.json is missing, the export was incomplete
```

## Advanced Use Cases

### Automated Testing with Fixtures

Use local exports as test fixtures in CI/CD:

```bash
# Create test fixture once
node export-firebase.js \
  --project test-project \
  --local-output ./test/fixtures/baseline-data \
  --skip-storage

# In CI/CD pipeline, import fixture before each test run
node import-firebase.js \
  --local-input ./test/fixtures/baseline-data \
  --project ci-test-project-${BUILD_ID} \
  --execute --yes
```

### Incremental Backups (Manual)

Since full backups can be large, you can manually create incremental backups:

```bash
# Full backup
node export-firebase.js \
  --project my-project \
  --local-output ./backups/full-$(date +%Y%m%d)

# Later, backup specific collections that changed
node export-firebase.js \
  --project my-project \
  --local-output ./backups/incremental-$(date +%Y%m%d) \
  --collections items,work_log \
  --skip-storage
```

## Security Considerations

### Sensitive Data

Local backups contain all your Firebase data in plain JSON:

- ⚠️  **Never commit backups to git** (especially public repos)
- ⚠️  **Encrypt sensitive backups** if storing long-term
- ⚠️  **Use secure channels** when transferring between machines

### Encryption Example

```bash
# Export and encrypt
node export-firebase.js \
  --project my-project \
  --local-output ./backups/sensitive-data

# Encrypt with GPG
tar -czf - ./backups/sensitive-data | \
  gpg --symmetric --cipher-algo AES256 > backup-encrypted.tar.gz.gpg

# Decrypt and import
gpg --decrypt backup-encrypted.tar.gz.gpg | \
  tar -xzf -

node import-firebase.js \
  --local-input ./backups/sensitive-data \
  --project my-project \
  --execute
```

## See Also

- [README.md](./README.md) - Main documentation
- [README-export.md](./README-export.md) - Detailed export guide
- [README-import.md](./README-import.md) - Detailed import guide
- [README-cross-project.md](./README-cross-project.md) - Cross-project transfers
- [SERVICE_ACCOUNTS.md](./SERVICE_ACCOUNTS.md) - Service account setup
