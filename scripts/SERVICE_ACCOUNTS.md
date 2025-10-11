# Service Account Creation Guide

Quick reference for creating Firebase export tool service accounts.

## TL;DR - Quick Setup

```bash
cd scripts
./setup-all-service-accounts.sh
```

This creates service accounts for both `rescuenet-testing` and `rescuenet-7733b` with proper permissions.

---

## Why Script > Console?

### Advantages of Scripted Setup
- ✅ **Reproducible** - Identical setup every time
- ✅ **Version Controlled** - Documents exact permissions in git
- ✅ **Fast** - 30 seconds vs 5 minutes manual clicking
- ✅ **Auditable** - Clear record of what was created
- ✅ **Team-Friendly** - New team members run one command
- ✅ **Multi-Org Ready** - Easy to scale to new organizations
- ✅ **Error-Proof** - No chance of forgetting a permission
- ✅ **Consistent** - Same configuration across all environments

### Only Downside
- ⚠️ Requires `gcloud` CLI installed and authenticated
- ⚠️ Requires Owner/Editor IAM role on projects

But if you're doing Firebase/GCP development, you already have this.

---

## Scripts Available

### 1. Setup All Environments
**File:** `setup-all-service-accounts.sh`

Sets up both testing and production at once:
```bash
./setup-all-service-accounts.sh
```

### 2. Setup Individual Project
**File:** `setup-service-accounts.sh`

For granular control:
```bash
./setup-service-accounts.sh <project-id> <key-filename>

# Examples:
./setup-service-accounts.sh rescuenet-testing rescuenet-testing.json
./setup-service-accounts.sh rescuenet-7733b rescuenet-production.json
```

---

## What the Script Does

1. **Validates Prerequisites**
   - Checks `gcloud` is installed
   - Verifies authentication
   - Creates `secrets/` directory if needed

2. **Creates Service Account**
   - Name: `firebase-export-tool`
   - Description: "Read-only service account for Firebase data export tool"
   - Checks if already exists (safe to re-run)

3. **Grants Permissions** (minimal read-only access)
   - `roles/datastore.user` - Read Firestore collections
   - `roles/storage.objectViewer` - Read Firebase Storage files
   - `roles/storage.objectCreator` - Write to GCS backup bucket

4. **Creates & Downloads Key**
   - Generates JSON key file
   - Saves to `secrets/<filename>`
   - Sets file permissions to 600 (owner read/write only)
   - Prompts before overwriting existing keys

5. **Provides Testing Instructions**
   - Shows dry-run command to test immediately

---

## Prerequisites

### Required
- **gcloud CLI**: [Install guide](https://cloud.google.com/sdk/docs/install)
- **Authentication**: Run `gcloud auth login`
- **Project Access**: Owner or Editor role on Firebase projects

### Verify Prerequisites
```bash
# Check gcloud is installed
gcloud --version

# Check authentication
gcloud auth list

# Check project access
gcloud projects list
```

---

## Manual Setup (If You Prefer Console)

If you don't have `gcloud` or prefer clicking:

1. **Google Cloud Console** → https://console.cloud.google.com/
2. Select project (e.g., `rescuenet-testing`)
3. **IAM & Admin** → **Service Accounts**
4. **+ CREATE SERVICE ACCOUNT**
   - Name: `firebase-export-tool`
   - Description: "Read-only service account for Firebase data export tool"
5. **Grant these 3 roles:**
   - Cloud Datastore User
   - Storage Object Viewer
   - Storage Object Creator
6. **Done** (skip user access)
7. Find service account → **⋮** → **Manage keys**
8. **ADD KEY** → **Create new key** → **JSON**
9. Download → Move to `scripts/secrets/rescuenet-testing.json`

Repeat for production (`rescuenet-7733b` → `rescuenet-production.json`)

---

## Troubleshooting

### gcloud not found
```bash
# macOS
brew install google-cloud-sdk

# Or download from:
# https://cloud.google.com/sdk/docs/install
```

### Not authenticated
```bash
gcloud auth login
```

### Permission denied creating service account
```bash
# Check your role on the project
gcloud projects get-iam-policy rescuenet-testing \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:$(gcloud config get-value account)"

# You need: roles/owner or roles/editor
```

### Service account already exists
The script will detect this and ask if you want to update permissions. Safe to say "yes".

### Key file already exists
The script will ask before overwriting. Backup old key if needed:
```bash
cp secrets/rescuenet-testing.json secrets/rescuenet-testing.json.backup
```

---

## Testing After Setup

```bash
cd scripts

# Test with dry-run (doesn't export, just shows plan)
npm run export -- \
  --project rescuenet-testing \
  --bucket rescuenet-migrations \
  --dry-run
```

Expected output:
```
=== DRY RUN MODE ===
Export Plan:
  Project: rescuenet-testing
  Target Bucket: rescuenet-migrations
  Output Path: exports/2025-10-11-rescuenet-testing
  Collections: all
  Skip Storage: no

No data will be exported in dry-run mode.
```

---

## Security Best Practices

✅ **Minimal Permissions** - Read-only for Firebase, write-only for backups
✅ **File Permissions** - Script sets 600 (owner only)
✅ **Gitignored** - `secrets/` directory never committed
✅ **Rotate Keys** - Regenerate periodically
✅ **Audit Access** - Monitor in Cloud Console IAM logs

---

## Adding New Projects

When adding a new organization:

```bash
# 1. Run setup script
./setup-service-accounts.sh new-org-production new-org-production.json

# 2. Update firebase-init.js mapping (or script does it automatically)
# 3. Test with dry-run
npm run export -- --project new-org-production --bucket new-org-backups --dry-run
```

---

## Related Documentation

- **Export Tool Usage**: See [README-export.md](README-export.md)
- **Multi-Org Setup**: See [ONBOARDING_ORG.md](../ONBOARDING_ORG.md)
- **Google Cloud IAM**: [Official Docs](https://cloud.google.com/iam/docs/service-accounts)

---

## Quick Reference

| Task | Command |
|------|---------|
| Setup all environments | `./setup-all-service-accounts.sh` |
| Setup single project | `./setup-service-accounts.sh <project> <filename>` |
| Test setup | `npm run export -- --project <id> --bucket <name> --dry-run` |
| List service accounts | `gcloud iam service-accounts list --project <project>` |
| View permissions | `gcloud projects get-iam-policy <project>` |
| Delete service account | `gcloud iam service-accounts delete <email>` |

---

**Bottom Line:** Use the scripts. They're faster, safer, and more maintainable than manual console clicking.
