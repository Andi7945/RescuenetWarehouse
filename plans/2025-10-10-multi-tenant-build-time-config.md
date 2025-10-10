# Multi-Tenant Build-Time Configuration Implementation Plan

**Date:** 2025-10-10
**Goal:** Enable build-time multi-tenancy with per-org staging and production Firebase projects
**Approach:** Pure functions, minimal refactoring, KISS principle

---

## Overview

This plan implements build-time organization selection with separate Firebase projects for:
- Each org's **production** environment
- Each org's **staging** environment

**Key Design Principles:**
- Pure functions for configuration lookup (no DI, no services)
- Freezed for immutable config models
- Build flags (`--dart-define`) for org and environment selection
- Zero changes to existing repositories (they use Firebase.instance which we initialize)
- No runtime overhead - everything resolved at build time

---

## Phase 1: Foundation - Config System

### Step 1.1: Create Organization Config Model

**File:** `lib/config/org_config.dart`

**Actions:**
1. Create Freezed model with fields:
   - `id: String` (org identifier, e.g., 'rescuenet')
   - `name: String` (display name, e.g., 'RescueNet')
   - `logoAssetPath: String?` (optional, path to org logo in assets)
   - `primaryColor: Color?` (optional, org brand color)
   - `productionFirebase: FirebaseOptions`
   - `stagingFirebase: FirebaseOptions`
   - `features: Map<String, dynamic>` (optional, default empty map for future feature flags)

2. Add json_serializable if needed for future config file loading (optional for now)

3. Generate code: `dart run build_runner build`

**Expected output:** `lib/config/org_config.dart` + generated files

**Validation:** Model compiles without errors

---

### Step 1.2: Prepare Firebase Options Files

**Current state:** `lib/firebase_options.dart` (rescuenet production)

**Actions:**
1. Create staging Firebase project: `rescuenet-staging` (manual Firebase Console step)
2. Run FlutterFire CLI for staging:
   ```bash
   flutterfire configure --project=rescuenet-staging --out=lib/config/firebase_options_rescuenet_staging.dart
   ```
3. Rename existing file:
   ```bash
   mv lib/firebase_options.dart lib/config/firebase_options_rescuenet_production.dart
   ```
4. Update class names in renamed files to avoid conflicts:
   - Production: `class RescuenetProductionFirebaseOptions`
   - Staging: `class RescuenetStagingFirebaseOptions`

**Expected files:**
- `lib/config/firebase_options_rescuenet_production.dart`
- `lib/config/firebase_options_rescuenet_staging.dart`

**Validation:** Both files compile independently

---

### Step 1.3: Create Organization Registry

**File:** `lib/config/org_registry.dart`

**Actions:**
1. Import Firebase options files with aliases:
   ```dart
   import 'firebase_options_rescuenet_production.dart' as rescuenet_prod;
   import 'firebase_options_rescuenet_staging.dart' as rescuenet_staging;
   ```

2. Create private map of org configs:
   ```dart
   final Map<String, OrgConfig> _orgConfigs = {
     'rescuenet': OrgConfig(
       id: 'rescuenet',
       name: 'RescueNet',
       productionFirebase: rescuenet_prod.RescuenetProductionFirebaseOptions.currentPlatform,
       stagingFirebase: rescuenet_staging.RescuenetStagingFirebaseOptions.currentPlatform,
       features: {},
     ),
   };
   ```

3. Create pure getter functions:
   ```dart
   /// Get organization config by ID. Throws if org not found.
   OrgConfig getOrgConfig(String orgId) {
     final config = _orgConfigs[orgId];
     if (config == null) {
       throw ArgumentError('Unknown organization: $orgId. Available: ${_orgConfigs.keys.join(", ")}');
     }
     return config;
   }

   /// Get Firebase options for specific org and environment.
   FirebaseOptions getFirebaseOptions(String orgId, String environment) {
     final config = getOrgConfig(orgId);
     switch (environment.toLowerCase()) {
       case 'production':
       case 'prod':
         return config.productionFirebase;
       case 'staging':
       case 'stage':
         return config.stagingFirebase;
       default:
         throw ArgumentError('Invalid environment: $environment. Use "production" or "staging".');
     }
   }

   /// Get all available organization IDs.
   List<String> getAvailableOrgs() => _orgConfigs.keys.toList();
   ```

**Expected output:** Pure functions, no classes, no state

**Validation:**
- `getOrgConfig('rescuenet')` returns config
- `getOrgConfig('invalid')` throws ArgumentError
- `getFirebaseOptions('rescuenet', 'staging')` returns staging options

---

## Phase 2: Application Integration

### Step 2.1: Update Main.dart Firebase Initialization

**File:** `lib/main.dart`

**Actions:**
1. Add build-time constants at top of file:
   ```dart
   import 'config/org_registry.dart';

   // Read from --dart-define flags
   const String kOrgId = String.fromEnvironment('ORG', defaultValue: 'rescuenet');
   const String kEnvironment = String.fromEnvironment('ENV', defaultValue: 'staging');
   ```

2. Update Firebase initialization in `main()`:
   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // Get Firebase options for selected org and environment
     final firebaseOptions = getFirebaseOptions(kOrgId, kEnvironment);

     print('🚀 Initializing Firebase for $kOrgId ($kEnvironment)');
     await Firebase.initializeApp(options: firebaseOptions);

     runApp(river.ProviderScope(child: MyApp()));
   }
   ```

3. Remove old firebase_options import if present

**Expected behavior:**
- App initializes with correct Firebase project based on build flags
- Logs show which org/env is running

**Validation:**
```bash
# Test staging
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging

# Test production (BE CAREFUL)
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=production
```

---

### Step 2.2: Add Current Org Provider (for UI)

**File:** `lib/config/org_provider.dart`

**Required for org-specific branding (logos, names, colors)**

**Actions:**
1. Create Riverpod provider:
   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'org_config.dart';
   import 'org_registry.dart';
   import '../main.dart' show kOrgId, kEnvironment;

   part 'org_provider.g.dart';

   @riverpod
   OrgConfig currentOrg(CurrentOrgRef ref) {
     return getOrgConfig(kOrgId);
   }

   @riverpod
   String currentEnvironment(CurrentEnvironmentRef ref) {
     return kEnvironment;
   }
   ```

2. Generate: `dart run build_runner build`

3. Use in UI for branding:
   ```dart
   final org = ref.watch(currentOrgProvider);

   // Show org name
   Text('Welcome to ${org.name}');

   // Show org logo if available
   if (org.logoAssetPath != null) {
     Image.asset(org.logoAssetPath!);
   }

   // Use org color if available
   final color = org.primaryColor ?? theme.primaryColor;
   ```

---

## Phase 3: Build and Deploy Automation

### Step 3.1: Create Build Script

**File:** `scripts/build_org.sh`

**Actions:**
1. Create executable script:
   ```bash
   #!/bin/bash
   set -e  # Exit on error

   # Parse arguments
   ORG=${1:-}
   ENV=${2:-staging}

   # Validation
   if [ -z "$ORG" ]; then
     echo "❌ Error: Organization ID required"
     echo "Usage: ./scripts/build_org.sh <org_id> [environment]"
     echo "Example: ./scripts/build_org.sh rescuenet staging"
     exit 1
   fi

   # Validate environment
   if [[ ! "$ENV" =~ ^(staging|production)$ ]]; then
     echo "❌ Error: Invalid environment '$ENV'. Use 'staging' or 'production'."
     exit 1
   fi

   echo "🏗️  Building $ORG for $ENV environment..."

   # Build with dart-define flags
   flutter build web \
     --dart-define=ORG="$ORG" \
     --dart-define=ENV="$ENV" \
     --release \
     --web-renderer canvaskit

   # Move to environment-specific directory
   BUILD_DIR="build/web_${ORG}_${ENV}"
   rm -rf "$BUILD_DIR"
   mkdir -p "$BUILD_DIR"
   cp -r build/web/* "$BUILD_DIR/"

   echo "✅ Build complete: $BUILD_DIR"
   echo "📦 Firebase project: $ORG-$ENV (verify before deploy)"
   ```

2. Make executable: `chmod +x scripts/build_org.sh`

**Usage:**
```bash
./scripts/build_org.sh rescuenet staging
./scripts/build_org.sh rescuenet production
```

**Validation:** Run script, verify build output in correct directory

---

### Step 3.2: Create Firebase RC Files

**Files:** `.firebaserc_rescuenet_staging`, `.firebaserc_rescuenet_production`

**Actions:**
1. Create staging RC file:
   ```json
   {
     "projects": {
       "default": "rescuenet-staging"
     }
   }
   ```

2. Create production RC file:
   ```json
   {
     "projects": {
       "default": "rescuenet-7733b"
     }
   }
   ```

3. Add to `.gitignore` (keep `.firebaserc` local):
   ```
   .firebaserc
   ```

4. Commit RC template files:
   ```bash
   git add .firebaserc_rescuenet_staging .firebaserc_rescuenet_production
   ```

**Note:** `.firebaserc` is switched by deploy script

---

### Step 3.3: Update firebase.json for Multi-Build

**File:** `firebase.json`

**Actions:**
1. Update to support dynamic public directory:
   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": [
         "firebase.json",
         "**/.*",
         "**/node_modules/**"
       ],
       "frameworksBackend": {
         "region": "europe-west1"
       },
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     },
     "functions": {
       "runtime": "nodejs18",
       "source": "functions"
     }
   }
   ```

**Note:** Deploy script will copy correct build to `build/web` before deploying

---

### Step 3.4: Create Deploy Script

**File:** `scripts/deploy_org.sh`

**Actions:**
1. Create script:
   ```bash
   #!/bin/bash
   set -e

   # Parse arguments
   ORG=${1:-}
   ENV=${2:-staging}

   # Validation
   if [ -z "$ORG" ]; then
     echo "❌ Error: Organization ID required"
     echo "Usage: ./scripts/deploy_org.sh <org_id> [environment]"
     exit 1
   fi

   if [[ ! "$ENV" =~ ^(staging|production)$ ]]; then
     echo "❌ Error: Invalid environment '$ENV'"
     exit 1
   fi

   # Safety check for production
   if [ "$ENV" = "production" ]; then
     read -p "⚠️  Deploy to PRODUCTION for $ORG? (yes/no): " confirm
     if [ "$confirm" != "yes" ]; then
       echo "❌ Production deploy cancelled"
       exit 1
     fi
   fi

   BUILD_DIR="build/web_${ORG}_${ENV}"

   # Verify build exists
   if [ ! -d "$BUILD_DIR" ]; then
     echo "❌ Error: Build not found at $BUILD_DIR"
     echo "Run: ./scripts/build_org.sh $ORG $ENV"
     exit 1
   fi

   # Copy build to firebase public directory
   rm -rf build/web
   cp -r "$BUILD_DIR" build/web

   # Switch to correct Firebase project
   RC_FILE=".firebaserc_${ORG}_${ENV}"
   if [ ! -f "$RC_FILE" ]; then
     echo "❌ Error: Firebase RC file not found: $RC_FILE"
     exit 1
   fi

   cp "$RC_FILE" .firebaserc

   echo "🚀 Deploying $ORG to $ENV..."
   firebase deploy --only hosting

   echo "✅ Deploy complete!"
   echo "🌍 URL: https://$(jq -r '.projects.default' .firebaserc).web.app"
   ```

2. Make executable: `chmod +x scripts/deploy_org.sh`

**Usage:**
```bash
./scripts/deploy_org.sh rescuenet staging
./scripts/deploy_org.sh rescuenet production  # Requires confirmation
```

**Validation:** Deploy to staging, verify app loads

---

### Step 3.5: Create Combined Build+Deploy Script

**File:** `scripts/release_org.sh`

**Actions:**
```bash
#!/bin/bash
set -e

ORG=${1:-}
ENV=${2:-staging}

if [ -z "$ORG" ]; then
  echo "Usage: ./scripts/release_org.sh <org_id> [environment]"
  exit 1
fi

echo "🔄 Building and deploying $ORG to $ENV..."

./scripts/build_org.sh "$ORG" "$ENV"
./scripts/deploy_org.sh "$ORG" "$ENV"

echo "🎉 Release complete!"
```

Make executable: `chmod +x scripts/release_org.sh`

**Usage:** `./scripts/release_org.sh rescuenet staging`

---

## Phase 4: CI/CD Integration

### Step 4.1: Create GitHub Actions Workflow

**File:** `.github/workflows/deploy-multi-tenant.yml`

**Actions:**
```yaml
name: Deploy Multi-Tenant

on:
  push:
    branches:
      - develop    # Auto-deploy to staging
      - main       # Auto-deploy to production
  workflow_dispatch:
    inputs:
      org:
        description: 'Organization to deploy'
        required: true
        type: choice
        options:
          - rescuenet
          - all
      environment:
        description: 'Environment'
        required: true
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        org: [rescuenet]  # Add more orgs here as needed

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.4'
          channel: 'stable'

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Determine environment
        id: env
        run: |
          if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
            echo "env=${{ github.event.inputs.environment }}" >> $GITHUB_OUTPUT
          elif [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
            echo "env=production" >> $GITHUB_OUTPUT
          else
            echo "env=staging" >> $GITHUB_OUTPUT
          fi

      - name: Build ${{ matrix.org }}
        run: ./scripts/build_org.sh ${{ matrix.org }} ${{ steps.env.outputs.env }}

      - name: Setup Firebase CLI
        run: npm install -g firebase-tools

      - name: Deploy ${{ matrix.org }}
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        run: |
          BUILD_DIR="build/web_${{ matrix.org }}_${{ steps.env.outputs.env }}"
          rm -rf build/web
          cp -r "$BUILD_DIR" build/web

          cp .firebaserc_${{ matrix.org }}_${{ steps.env.outputs.env }} .firebaserc

          firebase deploy --only hosting --token "$FIREBASE_TOKEN" --non-interactive

      - name: Deployment summary
        run: |
          echo "### Deployment Complete 🚀" >> $GITHUB_STEP_SUMMARY
          echo "- **Org:** ${{ matrix.org }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Environment:** ${{ steps.env.outputs.env }}" >> $GITHUB_STEP_SUMMARY
          echo "- **Branch:** ${{ github.ref_name }}" >> $GITHUB_STEP_SUMMARY
```

**Setup required:**
1. Generate Firebase token: `firebase login:ci`
2. Add to GitHub secrets: `FIREBASE_TOKEN`

**Behavior:**
- Push to `develop` → Auto-deploy all orgs to staging
- Push to `main` → Auto-deploy all orgs to production
- Manual trigger → Deploy specific org to specific environment

---

### Step 4.2: E2E Testing Strategy

**SKIP:** Playwright tests do not perform well with Flutter Web (Canvas-based rendering, not classical HTML DOM).

**Alternative testing approaches:**
1. **Manual staging testing** - Use staging environments for manual QA before production
2. **Flutter integration tests** - Run Flutter's own integration test framework
3. **API testing** - Test Firebase/Firestore operations independently
4. **Unit tests** - Test business logic in isolation

**Note:** If E2E tests are needed in the future, consider:
- Using Flutter integration tests instead of Playwright
- Testing the backend/API layer directly
- Manual QA processes for UI verification

---

## Phase 5: Documentation and Validation

### Step 5.1: Update CLAUDE.md

**File:** `CLAUDE.md`

**Actions:**
Add new section:

```markdown
## Multi-Tenant Configuration

The app supports multiple organizations with separate Firebase projects per environment.

### Architecture
- **Build-time selection** via `--dart-define=ORG=<org_id> --dart-define=ENV=<environment>`
- **Pure function config** in `lib/config/org_registry.dart`
- **Per-org staging and production** Firebase projects

### Available Organizations
- `rescuenet` (default)

### Build Commands
```bash
# Build for staging (default)
flutter build web --dart-define=ORG=rescuenet --dart-define=ENV=staging

# Build for production
flutter build web --dart-define=ORG=rescuenet --dart-define=ENV=production
```

### Deployment Scripts
```bash
# Build only
./scripts/build_org.sh rescuenet staging

# Deploy only (requires prior build)
./scripts/deploy_org.sh rescuenet staging

# Build + Deploy
./scripts/release_org.sh rescuenet staging
```

### Adding New Organization
1. Create Firebase projects: `<org_id>-staging` and `<org_id>-production`
2. Generate Firebase options:
   ```bash
   flutterfire configure --project=<org_id>-staging --out=lib/config/firebase_options_<org_id>_staging.dart
   flutterfire configure --project=<org_id>-production --out=lib/config/firebase_options_<org_id>_production.dart
   ```
3. Add to `lib/config/org_registry.dart`
4. Create `.firebaserc_<org_id>_staging` and `.firebaserc_<org_id>_production`
5. Update CI/CD matrix in `.github/workflows/deploy-multi-tenant.yml`
```

---

### Step 5.2: Create Onboarding Documentation

**File:** `ONBOARDING_ORG.md`

**Actions:**
Create comprehensive guide for onboarding new organizations:

```markdown
# Onboarding New Organizations

This guide walks through adding a new organization to the RescuenetWarehouse multi-tenant system.

## Overview

Each organization has:
- **Two Firebase projects**: `<org_id>-staging` and `<org_id>-production`
- **Configuration entry**: In `lib/config/org_registry.dart`
- **Firebase RC files**: `.firebaserc_<org_id>_staging` and `.firebaserc_<org_id>_production`
- **Optional branding**: Logo, name, primary color

**Time estimate:** ~30 minutes per organization

---

## Prerequisites

Before starting, ensure you have:
- [ ] Firebase CLI installed: `npm install -g firebase-tools`
- [ ] FlutterFire CLI installed: `dart pub global activate flutterfire_cli`
- [ ] Firebase project creation permissions
- [ ] Organization details: name, logo (optional), brand color (optional)
- [ ] Access to repository to commit changes

---

## Step-by-Step Process

### Step 1: Create Firebase Projects

**1.1 Create Staging Project**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Project name: `<org_id>-staging` (e.g., `acme-staging`)
4. Disable Google Analytics (optional for staging)
5. Click "Create Project"

**1.2 Create Production Project**

1. Repeat process for production
2. Project name: `<org_id>-production` (e.g., `acme-production`)
3. Enable Google Analytics if needed
4. Click "Create Project"

**1.3 Configure Firebase Services**

For **both** projects, enable:
- [ ] **Authentication** → Email/Password provider
- [ ] **Firestore Database** → Start in production mode (set rules later)
- [ ] **Storage** → Start in production mode
- [ ] **Hosting** → Enable (will configure later)

**Security Rules:**
Copy Firestore security rules from existing project (rescuenet-production) to both new projects.

---

### Step 2: Generate Firebase Configuration Files

**2.1 Authenticate Firebase CLI**

```bash
firebase login
```

**2.2 Generate Staging Config**

```bash
flutterfire configure \
  --project=<org_id>-staging \
  --out=lib/config/firebase_options_<org_id>_staging.dart \
  --platforms=web,ios,android,macos
```

When prompted:
- Select the staging Firebase project
- Confirm platforms

**2.3 Generate Production Config**

```bash
flutterfire configure \
  --project=<org_id>-production \
  --out=lib/config/firebase_options_<org_id>_production.dart \
  --platforms=web,ios,android,macos
```

**2.4 Update Class Names**

Edit generated files to avoid naming conflicts:

**`lib/config/firebase_options_<org_id>_staging.dart`:**
```dart
// Change class name from DefaultFirebaseOptions to:
class <OrgId>StagingFirebaseOptions {
  static FirebaseOptions get currentPlatform { ... }
  // ... rest of file
}
```

**`lib/config/firebase_options_<org_id>_production.dart`:**
```dart
// Change class name from DefaultFirebaseOptions to:
class <OrgId>ProductionFirebaseOptions {
  static FirebaseOptions get currentPlatform { ... }
  // ... rest of file
}
```

Example: For "acme", classes would be `AcmeStagingFirebaseOptions` and `AcmeProductionFirebaseOptions`.

---

### Step 3: Add Organization to Registry

**3.1 Prepare Assets (if using logo)**

If the organization has a custom logo:
1. Add logo to `assets/images/<org_id>_logo.png`
2. Update `pubspec.yaml` to include new asset (if not already covered by wildcard)

**3.2 Update org_registry.dart**

Edit `lib/config/org_registry.dart`:

1. **Import Firebase options:**
   ```dart
   import 'firebase_options_<org_id>_staging.dart' as <org_id>_staging;
   import 'firebase_options_<org_id>_production.dart' as <org_id>_prod;
   ```

2. **Add to _orgConfigs map:**
   ```dart
   final Map<String, OrgConfig> _orgConfigs = {
     'rescuenet': OrgConfig(...),

     // Add new org
     '<org_id>': OrgConfig(
       id: '<org_id>',
       name: '<Organization Display Name>',
       logoAssetPath: 'assets/images/<org_id>_logo.png', // Optional
       primaryColor: const Color(0xFF<HEX_COLOR>), // Optional
       productionFirebase: <org_id>_prod.<OrgId>ProductionFirebaseOptions.currentPlatform,
       stagingFirebase: <org_id>_staging.<OrgId>StagingFirebaseOptions.currentPlatform,
       features: {},
     ),
   };
   ```

3. **Run code generation:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

### Step 4: Create Firebase RC Files

**4.1 Create Staging RC File**

Create `.firebaserc_<org_id>_staging`:
```json
{
  "projects": {
    "default": "<org_id>-staging"
  }
}
```

**4.2 Create Production RC File**

Create `.firebaserc_<org_id>_production`:
```json
{
  "projects": {
    "default": "<org_id>-production"
  }
}
```

**4.3 Verify .gitignore**

Ensure `.firebaserc` is in `.gitignore` (but NOT the `_<org>_<env>` files):
```
.firebaserc
```

---

### Step 5: Update CI/CD

**5.1 Update GitHub Actions**

Edit `.github/workflows/deploy-multi-tenant.yml`:

Find the matrix strategy and add new org:
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        org: [rescuenet, <org_id>]  # Add new org here
```

**5.2 Update Manual Workflow Options**

In the same file, add to workflow_dispatch options:
```yaml
workflow_dispatch:
  inputs:
    org:
      description: 'Organization to deploy'
      required: true
      type: choice
      options:
        - rescuenet
        - <org_id>  # Add here
        - all
```

---

### Step 6: Test the Configuration

**6.1 Build Test**

Build for staging to verify configuration:
```bash
./scripts/build_org.sh <org_id> staging
```

Expected output:
- ✅ Build succeeds
- ✅ Output in `build/web_<org_id>_staging/`
- ✅ No compilation errors

**6.2 Local Test**

Run locally with the new org:
```bash
flutter run -d chrome \
  --dart-define=ORG=<org_id> \
  --dart-define=ENV=staging
```

Verify:
- [ ] App loads without errors
- [ ] Correct org name displays (if using UI provider)
- [ ] Correct logo displays (if configured)
- [ ] Firebase initializes correctly (check console logs)

**6.3 Deploy to Staging**

Deploy to staging Firebase project:
```bash
./scripts/deploy_org.sh <org_id> staging
```

When prompted, confirm deployment.

**6.4 Verify Staging Deployment**

1. Open staging URL: `https://<org_id>-staging.web.app`
2. Verify:
   - [ ] App loads
   - [ ] Can create account
   - [ ] Can log in
   - [ ] Can create test data
   - [ ] Data is isolated from other orgs

---

### Step 7: Production Deployment

**⚠️ Only after thorough staging testing**

**7.1 Build for Production**

```bash
./scripts/build_org.sh <org_id> production
```

**7.2 Deploy to Production**

```bash
./scripts/deploy_org.sh <org_id> production
```

Will prompt for confirmation. Type `yes` to proceed.

**7.3 Verify Production**

1. Open production URL: `https://<org_id>-production.web.app`
2. Perform smoke tests:
   - [ ] App loads
   - [ ] Login works
   - [ ] Core features work

---

### Step 8: Documentation

**8.1 Update CLAUDE.md**

Add new org to the "Available Organizations" list in `CLAUDE.md`:
```markdown
### Available Organizations
- `rescuenet` (default)
- `<org_id>`
```

**8.2 Commit Changes**

```bash
git add lib/config/
git add .firebaserc_<org_id>_staging .firebaserc_<org_id>_production
git add .github/workflows/deploy-multi-tenant.yml
git add assets/images/<org_id>_logo.png  # If applicable
git add CLAUDE.md

git commit -m "Add <org_name> organization

- Add Firebase configurations for staging and production
- Update org registry with branding
- Configure CI/CD for automated deploys"

git push origin <branch>
```

---

## Troubleshooting

### Build Fails with "Unknown organization"

**Issue:** `ArgumentError: Unknown organization: <org_id>`

**Fix:**
- Verify org is added to `_orgConfigs` map in `org_registry.dart`
- Run `dart run build_runner build` to regenerate code

### Firebase Initialization Error

**Issue:** Firebase fails to initialize or shows wrong project

**Fix:**
- Check class names in generated files match registry imports
- Verify Firebase options were generated for correct projects
- Check build flags: `--dart-define=ORG=<org_id> --dart-define=ENV=<env>`

### Deploy to Wrong Project

**Issue:** Deployed to wrong Firebase project

**Fix:**
- Verify `.firebaserc_<org>_<env>` files have correct project IDs
- Check deploy script copied correct RC file
- Use `firebase projects:list` to verify project exists

### Logo Not Showing

**Issue:** Org logo doesn't display

**Fix:**
- Verify asset path in `org_registry.dart` matches file location
- Check `pubspec.yaml` includes asset in `assets:` section
- Run `flutter clean` and rebuild

### CI/CD Not Deploying New Org

**Issue:** GitHub Actions doesn't deploy new org

**Fix:**
- Verify org is in workflow matrix
- Check `FIREBASE_TOKEN` secret has permissions for new projects
- Manually trigger workflow with workflow_dispatch to test

---

## Checklist Summary

Before considering onboarding complete:

**Firebase Setup:**
- [ ] Staging project created and configured
- [ ] Production project created and configured
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created with security rules
- [ ] Storage enabled with security rules
- [ ] Hosting enabled

**Code Configuration:**
- [ ] Firebase options files generated for both environments
- [ ] Class names updated to avoid conflicts
- [ ] Organization added to `org_registry.dart`
- [ ] Assets added (logo, if applicable)
- [ ] Code generation completed successfully

**Deployment Configuration:**
- [ ] Firebase RC files created for both environments
- [ ] CI/CD updated with new org in matrix
- [ ] Build script tested locally
- [ ] Deploy script tested to staging

**Testing:**
- [ ] Local build succeeds
- [ ] Staging deployment succeeds
- [ ] Staging app loads and functions correctly
- [ ] Data isolation verified
- [ ] Production deployment succeeds
- [ ] Production app verified

**Documentation:**
- [ ] CLAUDE.md updated
- [ ] Changes committed to repository
- [ ] Team notified of new org

---

## Quick Reference

**Build commands:**
```bash
./scripts/build_org.sh <org_id> staging
./scripts/build_org.sh <org_id> production
```

**Deploy commands:**
```bash
./scripts/deploy_org.sh <org_id> staging
./scripts/deploy_org.sh <org_id> production
```

**Combined (build + deploy):**
```bash
./scripts/release_org.sh <org_id> staging
./scripts/release_org.sh <org_id> production
```

**URLs:**
- Staging: `https://<org_id>-staging.web.app`
- Production: `https://<org_id>-production.web.app`
```

---

### Step 5.3: Create README for Scripts

**File:** `scripts/README.md`

**Actions:**
```markdown
# Build and Deploy Scripts

## Overview
Scripts for building and deploying multi-tenant Flutter app to Firebase.

## Prerequisites
- Flutter 3.32.4+
- Firebase CLI installed and authenticated
- Correct `.firebaserc_<org>_<env>` files

## Scripts

### build_org.sh
Builds the app for a specific org and environment.

**Usage:**
```bash
./scripts/build_org.sh <org_id> [environment]
```

**Examples:**
```bash
./scripts/build_org.sh rescuenet staging
./scripts/build_org.sh rescuenet production
```

**Output:** `build/web_<org>_<env>/`

---

### deploy_org.sh
Deploys pre-built app to Firebase.

**Usage:**
```bash
./scripts/deploy_org.sh <org_id> [environment]
```

**Safety:** Production deploys require manual confirmation.

---

### release_org.sh
Combined build and deploy.

**Usage:**
```bash
./scripts/release_org.sh <org_id> [environment]
```

**Example:**
```bash
./scripts/release_org.sh rescuenet staging
```

---

## Environment Variables

Scripts read from `--dart-define`:
- `ORG`: Organization ID (e.g., 'rescuenet')
- `ENV`: Environment ('staging' or 'production')

---

## CI/CD

GitHub Actions workflow: `.github/workflows/deploy-multi-tenant.yml`

**Triggers:**
- Push to `develop` → Deploy all orgs to staging
- Push to `main` → Deploy all orgs to production
- Manual workflow dispatch → Deploy specific org/env

**Required Secret:**
- `FIREBASE_TOKEN` - Get via `firebase login:ci`
```

---

### Step 5.4: Validation Checklist

**Manual testing checklist:**

1. **Build validation:**
   - [ ] `./scripts/build_org.sh rescuenet staging` succeeds
   - [ ] `./scripts/build_org.sh rescuenet production` succeeds
   - [ ] Build output exists in `build/web_rescuenet_staging/`
   - [ ] Invalid org ID fails with clear error
   - [ ] Invalid environment fails with clear error

2. **Configuration validation:**
   - [ ] `getOrgConfig('rescuenet')` returns correct config
   - [ ] `getOrgConfig('invalid')` throws ArgumentError
   - [ ] `getFirebaseOptions('rescuenet', 'staging')` returns staging options
   - [ ] `getFirebaseOptions('rescuenet', 'production')` returns production options

3. **Deployment validation:**
   - [ ] Deploy to staging succeeds
   - [ ] App loads on staging URL
   - [ ] Login works on staging
   - [ ] Data is isolated from production
   - [ ] Production deploy requires confirmation
   - [ ] Production app still works (no regression)

4. **CI/CD validation:**
   - [ ] Push to develop triggers staging deploy
   - [ ] Manual workflow dispatch works
   - [ ] Deployment summary shows in GitHub Actions

5. **Documentation validation:**
   - [ ] CLAUDE.md contains multi-tenant section
   - [ ] scripts/README.md exists and is accurate
   - [ ] ONBOARDING_ORG.md exists and is comprehensive
   - [ ] Process for adding new org is documented

---

## Phase 6: Future Enhancements (Not in initial implementation)

### 6.1: Add Second Organization
When ready to onboard second org (e.g., ACME):
1. Repeat Step 1.2 for ACME staging and production
2. Add ACME to `org_registry.dart`
3. Create ACME firebase RC files
4. Update CI/CD matrix to include ACME

### 6.2: Feature Flags per Org
If orgs need different features:
1. Use `OrgConfig.features` map
2. Add Riverpod provider for feature checks
3. Conditionally show/hide UI based on features

### 6.3: Org-Specific Branding
**IMPLEMENTED in initial version** - OrgConfig already includes:
- `logoAssetPath` for custom logos
- `primaryColor` for brand colors
- `currentOrgProvider` available for UI

### 6.4: Environment Banner
Add visual indicator for staging:
```dart
if (kEnvironment == 'staging') {
  Banner(
    message: 'STAGING',
    location: BannerLocation.topEnd,
    child: child,
  );
}
```

---

## Implementation Order for Subagents

**Suggested task breakdown:**

1. **Agent 1: Config Foundation**
   - Implement Steps 1.1, 1.2, 1.3
   - Output: Config system with pure functions
   - Validation: Unit tests for config functions

2. **Agent 2: App Integration**
   - Implement Steps 2.1, 2.2
   - Output: App initializes with correct Firebase, org provider for branding
   - Validation: Manual testing with different build flags, verify branding works

3. **Agent 3: Build Automation**
   - Implement Steps 3.1, 3.2, 3.3, 3.4, 3.5
   - Output: Working build and deploy scripts
   - Validation: Successful staging deployment

4. **Agent 4: CI/CD**
   - Implement Step 4.1 (skip 4.2 - Playwright doesn't work well with Flutter Web)
   - Output: GitHub Actions workflow for automated deploys
   - Validation: Successful automated deploy

5. **Agent 5: Documentation**
   - Implement Steps 5.1, 5.2 (ONBOARDING_ORG.md), 5.3 (scripts/README.md), 5.4 (validation)
   - Output: Updated docs, onboarding guide, scripts readme, validation checklist
   - Validation: Another developer can follow docs to add new org

---

## Risk Mitigation

**Risks and mitigations:**

1. **Breaking production:**
   - Mitigation: Default to staging in build scripts
   - Mitigation: Manual confirmation required for production
   - Mitigation: Test staging thoroughly before production

2. **Firebase project mixup:**
   - Mitigation: Clear naming convention (`<org>-staging`, `<org>-production`)
   - Mitigation: Logging shows which project is used
   - Mitigation: Separate RC files prevent accidental deploys

3. **Build flag forgotten:**
   - Mitigation: Defaults to safe values (rescuenet, staging)
   - Mitigation: Scripts enforce correct flags
   - Mitigation: CI/CD always uses correct flags

4. **Data leakage between orgs:**
   - Mitigation: Complete Firebase project isolation
   - Mitigation: No shared resources
   - Mitigation: Firestore security rules per project

---

## Success Criteria

Implementation is complete when:
- ✅ RescueNet has separate staging and production Firebase projects
- ✅ App can be built for either environment via build flags
- ✅ Scripts automate build and deploy process
- ✅ CI/CD deploys develop → staging, main → production
- ✅ Documentation enables adding new orgs
- ✅ Zero changes to existing business logic or repositories
- ✅ Production still works (no regression)
- ✅ Team can test features in staging before production

---

## Estimated Timeline

- Phase 1: 1.5 hours (config system + Firebase setup)
- Phase 2: 1 hour (app integration + org provider for branding)
- Phase 3: 1.5 hours (scripts)
- Phase 4: 0.5 hours (CI/CD - skip E2E tests)
- Phase 5: 1.5 hours (docs + onboarding guide + validation)
- **Total: ~6 hours**

With multiple agents in parallel: **~3.5 hours wall-clock time**

---

## Notes for Implementation

- **Don't over-engineer:** Stick to pure functions, no DI framework
- **Test in staging first:** Every change should be validated in staging
- **Keep it reversible:** Original setup can be restored by reverting commits
- **Document as you go:** Update docs immediately after each change
- **Use safe defaults:** Always default to staging to prevent production accidents
