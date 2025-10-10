# GitHub Actions Workflows

## deploy-multi-tenant.yml

Multi-tenant deployment workflow for deploying RescuenetWarehouse to Firebase Hosting.

### Features

- **Automatic deployments**: Triggered by pushes to `develop` (staging) or `main` (production)
- **Manual deployments**: Workflow dispatch allows deploying specific org/environment combinations
- **Matrix strategy**: Scalable to multiple organizations
- **Environment determination**: Automatically selects correct environment based on branch
- **Deployment summaries**: Provides detailed output in GitHub Actions UI

### Triggers

#### 1. Automatic Branch-Based Deployment

**Push to `develop` branch:**
- Deploys all organizations to their staging environments
- No manual intervention required

**Push to `main` branch:**
- Deploys all organizations to their production environments
- Use with caution - production deploys should be carefully reviewed

#### 2. Manual Workflow Dispatch

Navigate to Actions > Deploy Multi-Tenant > Run workflow

**Inputs:**
- **org**: Select specific organization or "all" to deploy all orgs
- **environment**: Choose "staging" or "production"

**Use cases:**
- Deploy specific org without affecting others
- Deploy to production outside of main branch merge
- Re-deploy after configuration changes

### Matrix Strategy

The workflow uses GitHub Actions matrix strategy to support multiple organizations:

```yaml
strategy:
  matrix:
    org: [rescuenet]  # Add more orgs here
```

**To add new organization:**
1. Add org ID to the matrix array
2. Ensure corresponding `.firebaserc_<org>_<env>` files exist
3. Commit changes

**Example with multiple orgs:**
```yaml
strategy:
  matrix:
    org: [rescuenet, acme, example]
```

### Workflow Steps

#### 1. Checkout Code
Uses `actions/checkout@v3` to clone repository

#### 2. Setup Flutter
- Installs Flutter 3.32.4 (stable channel)
- Configures Flutter environment

#### 3. Get Dependencies
Runs `flutter pub get` to install all dependencies

#### 4. Determine Environment
Logic to select correct environment:
- **Manual dispatch**: Uses user-selected environment
- **Main branch**: Production environment
- **Other branches**: Staging environment (default)

Outputs stored as `steps.env.outputs.env` and `steps.env.outputs.org`

#### 5. Build Application
Builds Flutter web app with organization-specific configuration:
- Uses `--dart-define=ORG=<org>` and `--dart-define=ENV=<env>`
- Builds with `--release` and `--web-renderer canvaskit`
- Outputs to `build/web_<org>_<env>/`

#### 6. Setup Firebase CLI
Installs Firebase CLI tools via npm

#### 7. Deploy to Firebase
- Copies org-specific build to `build/web/`
- Switches to correct Firebase project using `.firebaserc_<org>_<env>`
- Deploys to Firebase Hosting using `FIREBASE_TOKEN` secret
- Uses `--non-interactive` flag for automated deployment

#### 8. Deployment Summary
Creates GitHub Actions summary with:
- Organization deployed
- Environment (staging/production)
- Branch name
- Commit SHA
- Trigger type

### Required Secrets

#### FIREBASE_TOKEN

Firebase CI token for automated deployments.

**To generate:**
```bash
firebase login:ci
```

Copy the generated token and add to GitHub repository:
1. Go to repository Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Name: `FIREBASE_TOKEN`
4. Value: Paste token from `firebase login:ci`
5. Click "Add secret"

**Token permissions:**
The token must have deploy permissions for all Firebase projects used by the workflow:
- `rescuenet-7733b` (production)
- `rescuenet-staging` (staging)
- Any additional org projects

**Security notes:**
- Never commit the token to the repository
- Rotate token periodically
- Use separate tokens for different environments if needed

### Environment Determination Logic

```bash
if workflow_dispatch:
  use user-selected environment and org
elif branch == main:
  environment = production
  org = matrix.org
else:
  environment = staging
  org = matrix.org
```

### Build Output Structure

```
build/
├── web_rescuenet_staging/
│   ├── index.html
│   ├── main.dart.js
│   └── ...
├── web_rescuenet_production/
│   ├── index.html
│   ├── main.dart.js
│   └── ...
└── web/  # Temporary copy for deployment
```

### Firebase RC File Switching

The workflow switches between Firebase projects using RC files:

```bash
# Copies org/env-specific RC file to .firebaserc
cp .firebaserc_rescuenet_staging .firebaserc
```

**Required RC files:**
- `.firebaserc_rescuenet_staging`
- `.firebaserc_rescuenet_production`
- `.firebaserc_<neworg>_staging` (for each new org)
- `.firebaserc_<neworg>_production` (for each new org)

### Validation

Before running the workflow, ensure:

1. **Firebase RC files exist** for each org/environment combination
2. **Firebase projects are created** and configured
3. **FIREBASE_TOKEN secret** is set in GitHub
4. **Flutter version** matches project requirements (currently 3.32.4)
5. **Config files** exist in `lib/config/` for each org

### Troubleshooting

#### Build fails with "Unknown organization"

**Problem:** Organization not found in `org_registry.dart`

**Solution:**
- Verify org is added to `lib/config/org_registry.dart`
- Run `dart run build_runner build` locally
- Commit generated files

#### Deploy fails with "Firebase RC file not found"

**Problem:** Missing `.firebaserc_<org>_<env>` file

**Solution:**
- Create RC file with correct Firebase project ID
- Commit file to repository
- Re-run workflow

#### Firebase token invalid

**Problem:** `FIREBASE_TOKEN` secret is expired or invalid

**Solution:**
- Run `firebase login:ci` to generate new token
- Update GitHub secret
- Re-run workflow

#### Wrong Firebase project deployed

**Problem:** Build deployed to incorrect Firebase project

**Solution:**
- Verify `.firebaserc_<org>_<env>` contains correct project ID
- Check workflow logs for RC file copy step
- Ensure correct branch triggered workflow

#### Matrix not deploying all orgs

**Problem:** Only one org deploying instead of all

**Solution:**
- Check matrix strategy includes all org IDs
- Verify workflow_dispatch input isn't set to specific org
- Use "all" option in manual dispatch or check matrix array

### Best Practices

1. **Test in staging first**: Always deploy to staging before production
2. **Review PR before merge**: Ensure code changes are reviewed before auto-deploy
3. **Monitor deployments**: Check GitHub Actions logs and Firebase console
4. **Use feature branches**: Develop on feature branches, merge to develop for staging
5. **Protect main branch**: Enable branch protection rules to prevent accidental production deploys
6. **Semantic versioning**: Tag releases when deploying to production
7. **Rollback plan**: Keep previous builds for quick rollback if needed

### Future Enhancements

Potential improvements for future iterations:

1. **Deployment approvals**: Require manual approval for production deploys
2. **Slack notifications**: Post deployment status to team channel
3. **Health checks**: Verify app loads after deployment
4. **Rollback capability**: Automatically rollback on deployment failure
5. **Performance monitoring**: Track build times and deployment duration
6. **Artifact storage**: Archive builds for rollback capability
7. **Environment-specific secrets**: Different tokens per environment
8. **Deployment scheduling**: Schedule off-hours deployments

### Related Files

- **Workflow**: `.github/workflows/deploy-multi-tenant.yml`
- **Build scripts**: `scripts/build_org.sh`, `scripts/deploy_org.sh` (Phase 3)
- **Config**: `lib/config/org_registry.dart`
- **Firebase RC files**: `.firebaserc_*`
- **Plan**: `plans/2025-10-10-multi-tenant-build-time-config.md`
