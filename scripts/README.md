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
