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
- Build succeeds
- Output in `build/web_<org_id>_staging/`
- No compilation errors

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

**Only after thorough staging testing**

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


## ToDo Firestore
Firestore Database:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
Storage -> Regeln:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
