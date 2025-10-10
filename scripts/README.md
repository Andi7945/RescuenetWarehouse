# Build and Deploy Scripts

This directory contains shell scripts for building and deploying the RescuenetWarehouse multi-tenant Flutter application to Firebase.

## Overview

The scripts enable automated building and deployment of organization-specific builds to separate Firebase projects for staging and production environments.

**Key features:**
- Build-time organization selection via `--dart-define` flags
- Separate staging and production environments per organization
- Safety mechanisms for production deployments
- Automated Firebase project switching
- Build output isolation per org/environment

---

## Prerequisites

Before using these scripts, ensure you have:

- **Flutter SDK**: Version 3.32.4 or higher
- **Firebase CLI**: Installed and authenticated
  ```bash
  npm install -g firebase-tools
  firebase login
  ```
- **Firebase RC Files**: Correct `.firebaserc_<org>_<env>` files for each org/environment
- **Permissions**: Write access to Firebase projects being deployed to
- **Shell**: Bash shell (macOS/Linux) or Git Bash (Windows)

---

## Scripts

### setup_firebase_project.sh

**NEW:** Automated Firebase project setup and validation script.

**Purpose:**
- Automates Firebase project configuration for new organizations
- Validates all required services are enabled
- Deploys security rules and indexes
- Tests that services are working
- Saves 2-4 hours per environment setup

**Usage:**
```bash
./scripts/setup_firebase_project.sh <project_id> <region> [options]
```

**Parameters:**
- `<project_id>` (required): Firebase project ID (e.g., `rescuenet-testing`)
- `<region>` (required): Firebase region (e.g., `europe-west1`)

**Options:**
- `--copy-from=<project>`: Copy rules and indexes from another project
- `--skip-tests`: Skip verification tests
- `--yes`: Non-interactive mode (auto-confirm prompts)
- `--verbose`: Show detailed output
- `--dry-run`: Show what would be done without making changes

**Examples:**
```bash
# Basic setup
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1

# Copy configuration from production
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --copy-from=rescuenet-7733b

# Non-interactive setup (for CI/CD)
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --yes --copy-from=rescuenet-7733b

# Preview what would be done (dry run)
./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --dry-run
```

**What it does:**

**Phase 1: Prerequisites Check**
- ✅ Validates Firebase CLI, gcloud, jq, curl installed
- ✅ Checks authentication status
- ✅ Verifies required tools are available

**Phase 2: Project Validation**
- ✅ Confirms Firebase project exists
- ✅ Checks billing status
- ✅ Gets project number for API calls

**Phase 3: Service Provisioning**
- ✅ Enables Firebase Authentication
- ✅ Enables Email/Password provider
- ✅ Creates Firestore database in correct region
- ✅ Enables Cloud Storage
- ✅ Validates Firebase Hosting

**Phase 4: Security Configuration**
- ✅ Deploys Firestore security rules
- ✅ Deploys Storage security rules
- ✅ Deploys Firestore indexes
- ✅ Configures Storage CORS for web uploads

**Phase 5: Verification Tests**
- ✅ Tests Authentication API
- ✅ Tests Firestore database access
- ✅ Tests Storage upload/download

**Phase 6: Summary Report**
- ✅ Shows status of all services
- ✅ Lists any manual steps required
- ✅ Provides next steps

**Time savings:**
- Manual setup: 2-4 hours (20+ clicks, multiple pages)
- Automated setup: 5-10 minutes
- **Saved per environment: ~3.5 hours**

**Common use cases:**

1. **Setup new staging environment:**
   ```bash
   # Copy rules from production, auto-confirm
   ./scripts/setup_firebase_project.sh acme-staging europe-west1 --copy-from=acme-production --yes
   ```

2. **Validate existing project:**
   ```bash
   # Check what needs to be fixed
   ./scripts/setup_firebase_project.sh rescuenet-testing europe-west1 --dry-run
   ```

3. **Fresh project setup:**
   ```bash
   # Interactive setup with default rules
   ./scripts/setup_firebase_project.sh neworg-staging us-central1
   ```

**Output example:**
```
========================================
  🎉 Setup Complete - Summary Report
========================================

Project: rescuenet-testing
Region:  europe-west1

Services Status:
  Authentication:       ✅
  Firestore:            ✅
  Storage:              ✅
  Hosting:              ℹ️

Security Configuration:
  Firestore Rules:      ✅
  Storage Rules:        ✅
  Firestore Indexes:    ✅
  Storage CORS:         ✅

Verification Tests:
  Auth Test:            ✅
  Firestore Test:       ✅
  Storage Test:         ✅

✅ All critical services configured and tested!

📝 Next Steps

1. Update Firebase options file:
   flutterfire configure --project=rescuenet-testing --out=lib/config/firebase_options_rescuenet_testing.dart

2. Test your app:
   flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging

3. Deploy to hosting:
   ./scripts/build_org.sh rescuenet staging
   ./scripts/deploy_org.sh rescuenet staging
```

**Troubleshooting:**

- **"Permission denied"**: Run `firebase login` and `gcloud auth login`
- **"Project not found"**: Create project first in Firebase Console
- **"Region mismatch"**: Firestore region cannot be changed after creation
- **Manual steps required**: Some operations require Firebase Console access

**Helper utilities:**

The script uses helper functions from `scripts/lib/firebase_utils.sh`:
- Color-coded output (success ✅, warning ⚠️, error ❌)
- Service status checking
- Security rules generation
- CORS configuration
- Test execution

---

### build_org.sh

Builds the Flutter web application for a specific organization and environment.

**Purpose:**
- Compiles Flutter web app with organization-specific configuration
- Uses `--dart-define` flags to inject ORG and ENV at build time
- Outputs to isolated directory: `build/web_<org>_<env>/`
- Can be run independently for testing builds without deploying

**Usage:**
```bash
./scripts/build_org.sh <org_id> [environment]
```

**Parameters:**
- `<org_id>` (required): Organization identifier (e.g., `rescuenet`)
- `[environment]` (optional): Target environment - `staging` (default) or `production`

**Examples:**
```bash
# Build for staging (default)
./scripts/build_org.sh rescuenet

# Build for staging (explicit)
./scripts/build_org.sh rescuenet staging

# Build for production
./scripts/build_org.sh rescuenet production
```

**Output:**
```
build/web_rescuenet_staging/     # Staging build
build/web_rescuenet_production/  # Production build
```

**Behavior:**
1. Validates organization ID is provided
2. Validates environment is either 'staging' or 'production'
3. Runs `flutter build web` with `--dart-define=ORG=<org> --dart-define=ENV=<env>`
4. Uses `--release` mode and `canvaskit` renderer
5. Copies output to environment-specific directory
6. Displays completion message with build location

**Error handling:**
- Missing org ID: Exits with usage instructions
- Invalid environment: Exits with error message
- Build failure: Script exits with Flutter's error code

---

### deploy_org.sh

Deploys a pre-built application to Firebase Hosting.

**Purpose:**
- Deploys existing build to correct Firebase project
- Switches Firebase RC file for correct project targeting
- Includes safety confirmation for production deployments
- Verifies build exists before attempting deploy

**Usage:**
```bash
./scripts/deploy_org.sh <org_id> [environment]
```

**Parameters:**
- `<org_id>` (required): Organization identifier
- `[environment]` (optional): Target environment - `staging` (default) or `production`

**Examples:**
```bash
# Deploy to staging
./scripts/deploy_org.sh rescuenet staging

# Deploy to production (requires confirmation)
./scripts/deploy_org.sh rescuenet production
```

**Safety Features:**
- **Production confirmation**: Requires typing "yes" to proceed with production deploys
- **Build verification**: Checks that build directory exists before deploying
- **Project switching**: Automatically switches to correct Firebase project via RC file

**Behavior:**
1. Validates parameters
2. For production: Prompts for manual confirmation
3. Verifies build exists in `build/web_<org>_<env>/`
4. Copies build to `build/web/` (Firebase public directory)
5. Switches to correct Firebase project by copying `.firebaserc_<org>_<env>` to `.firebaserc`
6. Runs `firebase deploy --only hosting`
7. Displays deployment URL

**Error handling:**
- Missing build: Exits with instructions to run build script first
- Missing RC file: Exits with error about missing Firebase configuration
- Production cancelled: Exits gracefully if user doesn't confirm
- Deploy failure: Exits with Firebase CLI error code

**Important notes:**
- Build must exist before deploying (run `build_org.sh` first)
- `.firebaserc` file is temporary and not committed to git
- Template RC files (`.firebaserc_<org>_<env>`) must exist and contain correct project IDs

---

### release_org.sh

Combined build and deploy in a single command.

**Purpose:**
- Convenience script that runs build and deploy sequentially
- Ensures fresh build before deployment
- Single command for complete release process

**Usage:**
```bash
./scripts/release_org.sh <org_id> [environment]
```

**Parameters:**
- `<org_id>` (required): Organization identifier
- `[environment]` (optional): Target environment - `staging` (default) or `production`

**Examples:**
```bash
# Build and deploy to staging
./scripts/release_org.sh rescuenet staging

# Build and deploy to production (requires confirmation)
./scripts/release_org.sh rescuenet production
```

**Behavior:**
1. Calls `./scripts/build_org.sh <org> <env>`
2. If build succeeds, calls `./scripts/deploy_org.sh <org> <env>`
3. Displays completion message

**When to use:**
- **Use `release_org.sh`** when you want to build and deploy in one go
- **Use separate scripts** when you want to build once and deploy to multiple environments

**Example workflow:**
```bash
# Build once
./scripts/build_org.sh rescuenet staging

# Deploy multiple times if needed (e.g., after testing build locally)
./scripts/deploy_org.sh rescuenet staging
```

---

## Environment Variables

### Dart Define Flags

Scripts use `--dart-define` flags to inject configuration at build time:

- **ORG**: Organization identifier (e.g., `rescuenet`)
  - Read in Dart via: `const String.fromEnvironment('ORG', defaultValue: 'rescuenet')`
  - Used to select correct Firebase project and branding

- **ENV**: Environment name (e.g., `staging` or `production`)
  - Read in Dart via: `const String.fromEnvironment('ENV', defaultValue: 'staging')`
  - Used to select staging vs production Firebase configuration

### Firebase RC Files

Each org/environment combination has a Firebase RC file:

**Format:** `.firebaserc_<org_id>_<environment>`

**Example:**
```json
{
  "projects": {
    "default": "rescuenet-staging"
  }
}
```

**Files:**
- `.firebaserc_rescuenet_staging`: Points to rescuenet-staging project
- `.firebaserc_rescuenet_production`: Points to rescuenet-7733b project

**Note:** The temporary `.firebaserc` file (no suffix) is gitignored and created during deployment.

---

## CI/CD Integration

### GitHub Actions Workflow

Automated deployments are configured in: `.github/workflows/deploy-multi-tenant.yml`

**Triggers:**

1. **Automatic on branch push:**
   - Push to `develop` → Deploy all orgs to staging
   - Push to `main` → Deploy all orgs to production

2. **Manual workflow dispatch:**
   - Select specific org and environment
   - Useful for hotfixes or testing

**Workflow steps:**
1. Checkout code
2. Setup Flutter SDK
3. Install dependencies
4. Determine environment (from branch or manual input)
5. Build app using `build_org.sh`
6. Setup Firebase CLI
7. Deploy using Firebase CLI directly (equivalent to `deploy_org.sh`)
8. Display deployment summary

**Required GitHub Secret:**
- `FIREBASE_TOKEN`: Firebase CI token for automated deployments
  - Generate via: `firebase login:ci`
  - Add to repository secrets in GitHub Settings

**Matrix strategy:**
```yaml
strategy:
  matrix:
    org: [rescuenet]  # Add new orgs here
```

This ensures all organizations are built and deployed in parallel.

### Manual Workflow Dispatch

To manually trigger deployment:

1. Go to repository → Actions tab
2. Select "Deploy Multi-Tenant" workflow
3. Click "Run workflow"
4. Select:
   - Branch to deploy from
   - Organization (or 'all')
   - Environment (staging or production)
5. Click "Run workflow"

---

## Common Workflows

### Development Workflow

```bash
# 1. Make code changes
# ... edit files ...

# 2. Test locally
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging

# 3. Build and deploy to staging for testing
./scripts/release_org.sh rescuenet staging

# 4. After testing, deploy to production
./scripts/release_org.sh rescuenet production
```

### Adding New Organization

```bash
# 1. Create Firebase projects and generate configs (see ONBOARDING_ORG.md)

# 2. Create RC files
cat > .firebaserc_neworg_staging << EOF
{
  "projects": {
    "default": "neworg-staging"
  }
}
EOF

cat > .firebaserc_neworg_production << EOF
{
  "projects": {
    "default": "neworg-production"
  }
}
EOF

# 3. Test build
./scripts/build_org.sh neworg staging

# 4. Deploy to staging
./scripts/deploy_org.sh neworg staging

# 5. After testing, deploy to production
./scripts/release_org.sh neworg production
```

### Emergency Rollback

If you need to quickly rollback a production deployment:

1. Go to Firebase Console → Hosting
2. View release history
3. Click "Rollback" on previous working version

Alternatively, redeploy a previous git commit:
```bash
git checkout <previous-commit>
./scripts/release_org.sh rescuenet production
git checkout <current-branch>
```

---

## Troubleshooting

### Script Permission Denied

**Issue:** `Permission denied` when running scripts

**Fix:**
```bash
chmod +x scripts/*.sh
```

### Firebase Project Not Found

**Issue:** `Error: Invalid project id: <project-id>`

**Fix:**
- Verify Firebase project exists: `firebase projects:list`
- Check `.firebaserc_<org>_<env>` has correct project ID
- Ensure you have access to the project

### Build Output Already Exists

**Issue:** Want to clean previous builds

**Fix:**
```bash
# Clean all builds
rm -rf build/web_*

# Clean specific build
rm -rf build/web_rescuenet_staging
```

### Wrong Firebase Project Deployed

**Issue:** Accidentally deployed to wrong project

**Fix:**
1. Verify current `.firebaserc` content
2. Check `.firebaserc_<org>_<env>` files have correct project IDs
3. Redeploy to correct project immediately

**Prevention:**
- Always use the scripts (don't run `firebase deploy` manually)
- Double-check org and environment parameters
- Use staging for testing first

### Build Fails with Unknown Organization

**Issue:** `ArgumentError: Unknown organization: <org_id>`

**Fix:**
- Verify org is registered in `lib/config/org_registry.dart`
- Check spelling of org ID (case-sensitive)
- Run `dart run build_runner build` after adding new org

---

## Script Maintenance

### Adding New Script

When adding new scripts to this directory:

1. Use `.sh` extension
2. Include shebang: `#!/bin/bash`
3. Set executable: `chmod +x scripts/newscript.sh`
4. Add error handling: `set -e` (exit on error)
5. Validate inputs at start
6. Add helpful error messages
7. Document in this README

### Modifying Existing Scripts

When updating scripts:

1. Test changes in staging first
2. Verify error handling still works
3. Update this README with any changes
4. Consider backward compatibility
5. Update CI/CD workflow if needed

---

## Additional Resources

- **Multi-tenant architecture**: See `CLAUDE.md` for architecture overview
- **Onboarding guide**: See `ONBOARDING_ORG.md` for adding new organizations
- **Firebase documentation**: [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- **Flutter build**: [Flutter Web Build Documentation](https://docs.flutter.dev/deployment/web)

---

## Questions or Issues?

If you encounter issues with these scripts:

1. Check this README's troubleshooting section
2. Review `ONBOARDING_ORG.md` for configuration issues
3. Verify prerequisites are installed
4. Check Firebase project permissions
5. Review script output for specific error messages
