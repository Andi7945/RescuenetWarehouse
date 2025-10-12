# Cross-Project Export/Import Fix

**For Claude Code Subagent Implementation**

---

## Problem Statement

The export/import scripts have three critical issues preventing production → testing data migration:

1. **Storage domain mismatch**: firebase-init.js uses `.appspot.com` but export script uses `.firebasestorage.app`
2. **Import SDK bug**: Import script incorrectly uses Firebase Admin SDK for intermediate GCS bucket access
3. **Missing cross-project permissions**: No setup script or documentation for granting cross-project bucket access

**Current State:** Scripts may work within single project, but fail for cross-project migrations (prod → testing).

**Goal:** Enable reliable data migration from production to testing via intermediate GCS bucket.

---

## Solution Overview

**Architecture:**
```
Production Firebase → Intermediate GCS Bucket → Testing Firebase
(rescuenet-7733b)    (rescuenet-migrations)     (rescuenet-testing)
```

**Key Changes:**
1. Fix storage domain to use `.firebasestorage.app` consistently
2. Fix import script to use GCS Storage SDK for intermediate bucket
3. Add setup script for cross-project bucket permissions
4. Add documentation for cross-project workflows

**Principles Applied:**
- **KISS**: Minimal code changes, fix root causes only
- **SRP**: Each script does one thing (export, import, setup)
- **Modularity**: Reusable functions, pure where possible
- **No over-testing**: Manual testing sufficient for infrastructure scripts

---

## Implementation Tasks

Execute these tasks sequentially using subagents:

### Task 1: Fix Storage Domain Consistency
**Agent:** general-purpose
**File:** `scripts/lib/firebase-init.js`

**Problem:** Line 54 uses old `.appspot.com` domain, causing bucket mismatch.

**Solution:** Update to `.firebasestorage.app` to match export script.

**Changes:**
```javascript
// OLD (line 54):
storageBucket: `${projectId}.appspot.com`

// NEW:
storageBucket: `${projectId}.firebasestorage.app`
```

**Why:** Firebase migrated to new domain. Export already uses it, this aligns init.

**Validation:**
- Read the file
- Locate line 54 with `.appspot.com`
- Replace with `.firebasestorage.app`
- Verify change applied

**No testing needed:** This is a straightforward domain update.

---

### Task 2: Fix Import Script Bucket Access
**Agent:** general-purpose
**File:** `scripts/import-firebase.js`

**Problem:** Lines 48-52 incorrectly use Firebase Admin SDK for intermediate bucket access.

**Current Code (lines 48-52):**
```javascript
// Step 2: Initialize source Firebase (to access GCS bucket)
console.log(chalk.white('\nStep 2: Connecting to GCS bucket...'));
const sourceFirebase = await initFirebaseReadOnly(options.project);
const sourceBucket = sourceFirebase.storageBucket.bucket(bucketName);
console.log(chalk.green(`✓ Connected to bucket: ${bucketName}`));
```

**Issues:**
1. Variable name `sourceFirebase` is misleading (it's actually target project)
2. Uses Firebase Admin SDK for non-Firebase bucket access
3. Doesn't use GCS Storage SDK directly

**Solution:** Use GCS Storage SDK directly like export script does.

**New Code:**
```javascript
// Step 2: Connect to GCS bucket using Storage SDK
console.log(chalk.white('\nStep 2: Connecting to GCS bucket...'));
const { Storage } = require('@google-cloud/storage');
const path = require('path');
const { getServiceAccountPath } = require('./lib/firebase-init');

const serviceAccountPath = getServiceAccountPath(options.project);
const storage = new Storage({ keyFilename: path.resolve(serviceAccountPath) });
const sourceBucket = storage.bucket(bucketName);
console.log(chalk.green(`✓ Connected to bucket: ${bucketName}`));
```

**Additional Changes:**

1. **Add imports at top of file (after line 14):**
```javascript
const { Storage } = require('@google-cloud/storage');
const path = require('path');
```

2. **Update import statement (line 16):**
```javascript
// OLD:
const { initFirebaseReadOnly } = require('./lib/firebase-init');

// NEW:
const { initFirebaseReadOnly, getServiceAccountPath } = require('./lib/firebase-init');
```

3. **Update comment and variable naming:**
   - Remove misleading `sourceFirebase` variable
   - Clarify that source bucket is the intermediate GCS bucket
   - Target Firebase initialized later (line 110)

**Step-by-Step Implementation:**

1. **Update imports (lines 14-16):**
   - Add `Storage` from `@google-cloud/storage`
   - Add `path` require
   - Add `getServiceAccountPath` to firebase-init import

2. **Replace Step 2 section (lines 48-52):**
   - Remove Firebase Admin SDK initialization
   - Add GCS Storage SDK initialization
   - Keep console.log messages for user feedback

**Validation:**
- Import script should initialize GCS Storage SDK
- Should use target project's service account credentials
- Should NOT use Firebase Admin SDK for intermediate bucket

**Testing:**
```bash
# Dry run to verify script doesn't crash
npm run import -- \
  --source gs://rescuenet-migrations/exports/test/manifest.json \
  --project rescuenet-testing
```

Expected: Script should parse bucket name and initialize GCS client without errors.

---

### Task 3: Create Cross-Project Permissions Setup Script
**Agent:** general-purpose
**File:** `scripts/setup-cross-project-access.sh` (new file)

**Purpose:** Grant service account from one project access to GCS bucket in another project.

**Use Case:** Allow production service account to write to testing's migration bucket.

**Script Design:**

```bash
#!/bin/bash
#
# Setup Cross-Project GCS Bucket Access
#
# Grants a service account from one Firebase project access to a GCS bucket
# in another Firebase project. Required for cross-project data migration.
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Owner or Editor role on the project containing the bucket
# - Service accounts already created in both projects
#
# Usage:
#   ./setup-cross-project-access.sh <bucket-name> <source-project-id> <access-level>
#
# Example:
#   ./setup-cross-project-access.sh rescuenet-migrations rescuenet-7733b admin
#   ./setup-cross-project-access.sh rescuenet-testing-backups rescuenet-testing viewer
#
# Access Levels:
#   admin   - Full read/write access (roles/storage.objectAdmin)
#   creator - Create and read access (roles/storage.objectCreator)
#   viewer  - Read-only access (roles/storage.objectViewer)
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVICE_ACCOUNT_NAME="firebase-export-tool"

# =============================================================================
# Functions
# =============================================================================

print_usage() {
  echo "Usage: $0 <bucket-name> <source-project-id> <access-level>"
  echo ""
  echo "Arguments:"
  echo "  bucket-name       GCS bucket name (e.g., rescuenet-migrations)"
  echo "  source-project-id Project ID of service account to grant access (e.g., rescuenet-7733b)"
  echo "  access-level      Access level: admin, creator, or viewer"
  echo ""
  echo "Access Levels:"
  echo "  admin   - Full read/write/delete access (roles/storage.objectAdmin)"
  echo "  creator - Create and read access (roles/storage.objectCreator)"
  echo "  viewer  - Read-only access (roles/storage.objectViewer)"
  echo ""
  echo "Examples:"
  echo "  # Allow production to write to testing's migration bucket"
  echo "  $0 rescuenet-migrations rescuenet-7733b admin"
  echo ""
  echo "  # Allow testing to read from production's backup bucket"
  echo "  $0 rescuenet-production-backups rescuenet-testing viewer"
}

print_header() {
  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}→${NC} $1"
}

# Pure function: Maps access level to IAM role
get_role_for_access_level() {
  local access_level=$1

  case "${access_level}" in
    admin)
      echo "roles/storage.objectAdmin"
      ;;
    creator)
      echo "roles/storage.objectCreator"
      ;;
    viewer)
      echo "roles/storage.objectViewer"
      ;;
    *)
      echo ""
      ;;
  esac
}

# Pure function: Gets description for access level
get_access_description() {
  local access_level=$1

  case "${access_level}" in
    admin)
      echo "Full read/write/delete access"
      ;;
    creator)
      echo "Create and read access"
      ;;
    viewer)
      echo "Read-only access"
      ;;
    *)
      echo "Unknown"
      ;;
  esac
}

check_prerequisites() {
  print_header "Checking Prerequisites"

  # Check if gcloud is installed
  if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed"
    echo ""
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
  fi
  print_success "gcloud CLI installed"

  # Check if authenticated
  if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    print_error "Not authenticated with gcloud"
    echo ""
    echo "Run: gcloud auth login"
    exit 1
  fi
  print_success "gcloud authenticated"

  echo ""
}

verify_bucket_exists() {
  local bucket_name=$1

  print_header "Verifying Bucket"
  print_info "Bucket: gs://${bucket_name}"

  # Check if bucket exists
  if ! gcloud storage buckets describe "gs://${bucket_name}" &> /dev/null; then
    print_error "Bucket does not exist: gs://${bucket_name}"
    echo ""
    echo "Create it first by running:"
    echo "  ./setup-gcs-bucket.sh <project-id> ${bucket_name}"
    exit 1
  fi

  print_success "Bucket exists"

  # Get bucket project
  local bucket_project=$(gcloud storage buckets describe "gs://${bucket_name}" \
    --format="value(metadata.projectNumber)" 2>/dev/null || echo "unknown")

  print_info "Bucket project: ${bucket_project}"
  echo ""
}

verify_service_account() {
  local source_project_id=$1
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${source_project_id}.iam.gserviceaccount.com"

  print_header "Verifying Service Account"
  print_info "Service account: ${service_account_email}"

  # Check if service account exists
  if ! gcloud iam service-accounts describe "${service_account_email}" \
    --project="${source_project_id}" &> /dev/null; then
    print_error "Service account does not exist: ${service_account_email}"
    echo ""
    echo "Create it first by running:"
    echo "  ./setup-service-accounts.sh ${source_project_id} ${source_project_id}.json"
    exit 1
  fi

  print_success "Service account exists"
  echo ""
}

grant_bucket_access() {
  local bucket_name=$1
  local source_project_id=$2
  local access_level=$3
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${source_project_id}.iam.gserviceaccount.com"

  # Get IAM role for access level
  local role=$(get_role_for_access_level "${access_level}")
  local description=$(get_access_description "${access_level}")

  print_header "Granting Access"
  print_info "Bucket: gs://${bucket_name}"
  print_info "Service Account: ${service_account_email}"
  print_info "Access Level: ${access_level} (${description})"
  print_info "IAM Role: ${role}"
  echo ""

  # Grant access
  print_info "Granting permissions..."
  gcloud storage buckets add-iam-policy-binding "gs://${bucket_name}" \
    --member="serviceAccount:${service_account_email}" \
    --role="${role}" \
    --quiet

  print_success "Permissions granted"
  echo ""
}

verify_access() {
  local bucket_name=$1
  local source_project_id=$2
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${source_project_id}.iam.gserviceaccount.com"

  print_header "Verifying Access"

  # Get bucket IAM policy
  print_info "Checking IAM policy..."
  local has_access=$(gcloud storage buckets get-iam-policy "gs://${bucket_name}" \
    --format="value(bindings.members)" 2>/dev/null | \
    grep -c "serviceAccount:${service_account_email}" || echo "0")

  if [ "${has_access}" -gt 0 ]; then
    print_success "Service account has access to bucket"
  else
    print_warning "Could not verify access (may take a few seconds to propagate)"
  fi

  echo ""
}

print_summary() {
  local bucket_name=$1
  local source_project_id=$2
  local access_level=$3
  local service_account_email="${SERVICE_ACCOUNT_NAME}@${source_project_id}.iam.gserviceaccount.com"
  local description=$(get_access_description "${access_level}")

  print_header "Setup Complete"

  echo "Bucket: gs://${bucket_name}"
  echo "Service Account: ${service_account_email}"
  echo "Access Level: ${access_level} (${description})"
  echo ""

  print_success "Cross-project access configured!"
  echo ""

  # Provide usage examples based on access level
  case "${access_level}" in
    admin|creator)
      echo "You can now export to this bucket:"
      echo "  cd .."
      echo "  npm run export -- \\"
      echo "    --project ${source_project_id} \\"
      echo "    --bucket ${bucket_name}"
      echo ""
      ;;
    viewer)
      echo "You can now import from this bucket:"
      echo "  cd .."
      echo "  npm run import -- \\"
      echo "    --source gs://${bucket_name}/exports/path/manifest.json \\"
      echo "    --project ${source_project_id}"
      echo ""
      ;;
  esac
}

# =============================================================================
# Main Script
# =============================================================================

main() {
  # Parse arguments
  if [ $# -ne 3 ]; then
    print_error "Invalid number of arguments"
    echo ""
    print_usage
    exit 1
  fi

  local bucket_name=$1
  local source_project_id=$2
  local access_level=$3

  # Validate arguments
  if [ -z "${bucket_name}" ]; then
    print_error "Bucket name cannot be empty"
    exit 1
  fi

  if [ -z "${source_project_id}" ]; then
    print_error "Source project ID cannot be empty"
    exit 1
  fi

  # Validate access level
  local role=$(get_role_for_access_level "${access_level}")
  if [ -z "${role}" ]; then
    print_error "Invalid access level: ${access_level}"
    echo ""
    echo "Valid access levels: admin, creator, viewer"
    exit 1
  fi

  # Run setup steps
  check_prerequisites
  verify_bucket_exists "${bucket_name}"
  verify_service_account "${source_project_id}"
  grant_bucket_access "${bucket_name}" "${source_project_id}" "${access_level}"
  verify_access "${bucket_name}" "${source_project_id}"
  print_summary "${bucket_name}" "${source_project_id}" "${access_level}"
}

# Change to scripts directory if not already there
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

# Run main function
main "$@"
```

**Key Features:**
- **Pure functions**: `get_role_for_access_level()` and `get_access_description()` are pure
- **Single responsibility**: Each function does one thing
- **Reusable**: Can grant any access level to any service account
- **Safe**: Validates bucket and service account exist before granting
- **User-friendly**: Clear output and usage examples

**Make Executable:**
```bash
chmod +x scripts/setup-cross-project-access.sh
```

**Testing:**
```bash
# Test with dry-run equivalent (just verify, don't grant)
cd scripts
./setup-cross-project-access.sh rescuenet-migrations rescuenet-7733b admin
```

---

### Task 4: Create End-to-End Workflow Documentation
**Agent:** general-purpose
**File:** `scripts/README-cross-project.md` (new file)

**Purpose:** Document the complete workflow for cross-project data migration.

**Content:**

```markdown
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
```

---

### Task 5: Update Main Export README
**Agent:** general-purpose
**File:** `scripts/README-export.md`

**Changes:** Add reference to cross-project documentation.

**Location:** After line 647 (in "Related Documentation" section)

**Add:**
```markdown
- **Cross-Project Migration**: See [README-cross-project.md](README-cross-project.md) for production → testing workflows
```

---

### Task 6: Update Main Import README
**Agent:** general-purpose
**File:** `scripts/README-import.md`

**Changes:** Add reference to cross-project documentation.

**Location:** After line 752 (in "Related Documentation" section)

**Add:**
```markdown
- **Cross-Project Migration**: See [README-cross-project.md](README-cross-project.md) for production → testing workflows
```

---

### Task 7: Integration Testing
**Agent:** general-purpose

**Purpose:** Manually verify the complete workflow works end-to-end.

**Test Plan:**

#### Test 1: Storage Domain Fix Verification
```bash
cd scripts

# Check firebase-init.js has correct domain
grep "firebasestorage.app" lib/firebase-init.js
# Should find: storageBucket: `${projectId}.firebasestorage.app`

# Verify export still works
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-testing-backups \
  --dry-run
```

**Expected:** Dry run succeeds, shows correct storage bucket domain.

#### Test 2: Import GCS SDK Fix Verification
```bash
cd scripts

# Check import script has GCS Storage SDK import
grep "@google-cloud/storage" import-firebase.js
# Should find: const { Storage } = require('@google-cloud/storage');

# Verify import initializes correctly
npm run import -- \
  --source gs://rescuenet-migrations/exports/test/manifest.json \
  --project rescuenet-testing

# Note: Will fail if manifest doesn't exist, but that's OK
# We're just verifying it initializes GCS SDK without errors
```

**Expected:** Script initializes, shows error about manifest not found (expected), but no SDK errors.

#### Test 3: Cross-Project Access Script
```bash
cd scripts

# Verify script is executable
ls -la setup-cross-project-access.sh
# Should show: -rwxr-xr-x

# Test with --help (if implemented) or invalid args
./setup-cross-project-access.sh
# Should show usage information

# Dry-run equivalentL verify without granting
./setup-cross-project-access.sh rescuenet-migrations rescuenet-testing admin
# Should verify bucket and service account exist, then grant access
```

**Expected:** Script runs, validates inputs, shows clear output.

#### Test 4: End-to-End Cross-Project Migration
```bash
cd scripts

# 1. Setup cross-project access (if not already done)
./setup-cross-project-access.sh rescuenet-migrations rescuenet-7733b admin

# 2. Export testing to migration bucket (small dataset)
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-migrations \
  --output test-migration-$(date +%Y-%m-%d) \
  --collections container_types \
  --skip-storage

# 3. Import back to testing from migration bucket
npm run import -- \
  --source gs://rescuenet-migrations/exports/test-migration-$(date +%Y-%m-%d)/manifest.json \
  --project rescuenet-testing \
  --collections container_types \
  --skip-storage \
  --execute

# 4. Verify in Firebase Console
# Check that container_types collection has data
```

**Expected:**
- Export succeeds, writes to migration bucket
- Import succeeds, reads from migration bucket
- Data appears in Firebase Console

#### Test 5: Documentation Verification
```bash
cd scripts

# Check all new docs exist
ls -la README-cross-project.md
ls -la setup-cross-project-access.sh

# Check updated docs reference new guide
grep "README-cross-project.md" README-export.md
grep "README-cross-project.md" README-import.md
```

**Expected:** All files exist, cross-references are present.

---

## Success Criteria

✅ Storage domain is consistent (`.firebasestorage.app`)
✅ Import uses GCS Storage SDK for intermediate bucket
✅ Cross-project access script works
✅ Documentation is comprehensive and accurate
✅ End-to-end test succeeds (export → bucket → import)
✅ No breaking changes to existing functionality

---

## Rollback Plan

If issues arise:

1. **Revert code changes:**
   ```bash
   git checkout scripts/lib/firebase-init.js
   git checkout scripts/import-firebase.js
   ```

2. **Remove new files:**
   ```bash
   rm scripts/setup-cross-project-access.sh
   rm scripts/README-cross-project.md
   ```

3. **Revert documentation updates:**
   ```bash
   git checkout scripts/README-export.md
   git checkout scripts/README-import.md
   ```

4. **Manual workaround:**
   - Export to bucket in same project as source
   - Import from bucket in same project as target
   - Manually copy data between buckets if needed

---

## Files Modified/Created

**Modified (3 files):**
1. `scripts/lib/firebase-init.js` - Storage domain fix (1 line)
2. `scripts/import-firebase.js` - GCS SDK fix (5 lines changed)
3. `scripts/README-export.md` - Add cross-reference (1 line)
4. `scripts/README-import.md` - Add cross-reference (1 line)

**Created (2 files):**
1. `scripts/setup-cross-project-access.sh` - New setup script (~275 lines)
2. `scripts/README-cross-project.md` - New documentation (~450 lines)

**Total Complexity:** Low-Medium
**Risk Level:** Low (changes are additive, don't break existing functionality)
**Testing Effort:** 30-45 minutes manual testing

---

## Implementation Order

Execute tasks in this exact order:

1. **Task 1** - Fix storage domain (5 min)
2. **Task 2** - Fix import GCS SDK (10 min)
3. **Task 3** - Create cross-project access script (15 min)
4. **Task 4** - Create cross-project documentation (20 min)
5. **Task 5** - Update export README (2 min)
6. **Task 6** - Update import README (2 min)
7. **Task 7** - Integration testing (30 min)

**Total Estimated Time:** 90 minutes

---

## Subagent Execution Instructions

**For Claude Code main session:**

To execute this plan, launch subagents for each task:

```bash
# Task 1: Fix storage domain
Use general-purpose agent to:
1. Read scripts/lib/firebase-init.js
2. Find line 54 with `.appspot.com`
3. Replace with `.firebasestorage.app`
4. Verify change applied

# Task 2: Fix import GCS SDK
Use general-purpose agent to:
1. Read scripts/import-firebase.js
2. Update imports (lines 14-16)
3. Replace Step 2 section (lines 48-52)
4. Test with dry-run command

# Task 3: Create cross-project access script
Use general-purpose agent to:
1. Create scripts/setup-cross-project-access.sh with provided content
2. Make executable: chmod +x
3. Test script runs and shows usage

# Task 4: Create cross-project documentation
Use general-purpose agent to:
1. Create scripts/README-cross-project.md with provided content
2. Verify markdown formatting
3. Check all code examples are valid

# Task 5-6: Update READMEs
Use general-purpose agent to:
1. Add cross-reference to README-export.md
2. Add cross-reference to README-import.md
3. Verify links work

# Task 7: Integration testing
Use general-purpose agent to:
1. Execute test plan step by step
2. Report any failures
3. Verify all success criteria met
```

**Monitoring Progress:**

Check completion of each task before moving to next. If any task fails, investigate and fix before proceeding.

---

## Post-Implementation

After successful implementation:

1. **Commit changes:**
   ```bash
   git add scripts/
   git commit -m "Fix cross-project export/import functionality

   - Fix storage domain mismatch (.appspot.com → .firebasestorage.app)
   - Fix import to use GCS Storage SDK for intermediate bucket
   - Add cross-project access setup script
   - Add comprehensive cross-project migration documentation
   - Update main READMEs with cross-references

   Enables reliable production → testing data migration via intermediate bucket."
   ```

2. **Test on production:**
   - Do NOT test on actual production yet
   - Use testing → testing migration first
   - Then testing → staging if separate staging exists

3. **Update team:**
   - Notify team of new cross-project capabilities
   - Share README-cross-project.md documentation
   - Schedule training session if needed

4. **Monitor first real migration:**
   - Be present for first prod → testing migration
   - Verify data integrity in target
   - Document any issues encountered

---

## Future Enhancements (Out of Scope)

These are NOT part of this implementation but could be considered later:

- **Automated bucket setup in setup script** - Detect if bucket doesn't exist and offer to create it
- **Progress bars for large migrations** - Show percentage complete during export/import
- **Differential exports** - Only export changed documents since last export
- **Compression** - Compress large exports to reduce storage costs
- **Parallel collection import** - Import multiple collections concurrently
- **Web UI dashboard** - Visual interface for managing migrations
- **Migration validation** - Automated data integrity checks post-import

---

## Notes

**Why This Approach:**

1. **Minimal Changes:** Only fix what's broken, don't refactor unnecessarily
2. **Backward Compatible:** Existing single-project workflows still work
3. **Well-Documented:** Comprehensive docs prevent future confusion
4. **Safe:** Multiple validation steps, dry-run mode, confirmations
5. **Testable:** Manual testing sufficient for infrastructure tools

**Design Decisions:**

1. **Intermediate Bucket Location:** Recommend target project for easier management
2. **Service Account Reuse:** Use existing export tool SA, don't create new ones
3. **Pure Functions in Shell:** `get_role_for_access_level()` is pure for testability
4. **GCS Storage SDK:** Direct SDK usage more reliable than Firebase Admin SDK wrapper
5. **Comprehensive Docs:** Better over-documented than under-documented for infrastructure

**Maintenance:**

This is infrastructure code - changes should be rare. Main maintenance tasks:
- Update docs if Firebase changes domains again
- Add new access levels if needed
- Update troubleshooting section based on real issues encountered
