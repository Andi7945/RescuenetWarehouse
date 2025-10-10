# GitHub Actions Quick Start Guide

## First-Time Setup

### 1. Generate Firebase Token

```bash
firebase login:ci
```

Copy the token that is displayed.

### 2. Add Token to GitHub

1. Go to your repository on GitHub
2. Click **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Name: `FIREBASE_TOKEN`
5. Value: Paste the token from step 1
6. Click **Add secret**

### 3. Verify Prerequisites

Ensure these files exist:
- ✅ `.firebaserc_rescuenet_staging`
- ✅ `.firebaserc_rescuenet_production`
- ✅ `lib/config/org_registry.dart` with rescuenet configuration
- ✅ `lib/config/firebase_options_rescuenet_staging.dart`
- ✅ `lib/config/firebase_options_rescuenet_production.dart`

### 4. Test Manual Deployment

1. Go to **Actions** tab in GitHub
2. Select **Deploy Multi-Tenant**
3. Click **Run workflow**
4. Select:
   - Branch: `develop` or your current branch
   - Organization: `rescuenet`
   - Environment: `staging`
5. Click **Run workflow**
6. Monitor the deployment in real-time

### 5. Verify Deployment

After workflow completes:
- Open the staging Firebase project console
- Check that hosting has the new deployment
- Visit the staging URL to verify the app loads

---

## Daily Usage

### Deploy to Staging (Automatic)

```bash
# Create and push to develop branch
git checkout develop
git pull origin develop
git merge your-feature-branch
git push origin develop
```

The workflow automatically deploys to staging for all organizations.

### Deploy to Production (Automatic)

```bash
# Create and push to main branch (BE CAREFUL!)
git checkout main
git pull origin main
git merge develop
git push origin main
```

The workflow automatically deploys to production for all organizations.

**⚠️ WARNING:** Production deploys are automatic when pushing to main. Always:
- Test thoroughly in staging first
- Have code reviewed via pull request
- Use branch protection rules on main branch

### Deploy Manually (Any Environment)

Use this when you need more control:

1. Go to **Actions** > **Deploy Multi-Tenant**
2. Click **Run workflow**
3. Choose branch, org, and environment
4. Click **Run workflow**

**Common scenarios:**
- Deploy hotfix directly to production
- Re-deploy after configuration change
- Deploy specific org without affecting others

---

## Monitoring Deployments

### View Running Deployment

1. Go to **Actions** tab
2. Click on the workflow run (in progress or completed)
3. Click on the **deploy** job
4. Expand steps to view detailed logs

### Deployment Summary

At the bottom of each workflow run, you'll see:
- Organization deployed
- Environment (staging/production)
- Branch name
- Commit SHA
- How it was triggered

### Check Deployment Status

**In GitHub:**
- Green checkmark = successful deployment
- Red X = failed deployment
- Yellow circle = deployment in progress

**In Firebase:**
- Open Firebase Console
- Select the correct project
- Go to Hosting
- Check deployment history

---

## Troubleshooting

### "Firebase RC file not found"

**Problem:** Workflow can't find `.firebaserc_<org>_<env>`

**Fix:**
```bash
# Create the missing file
cat > .firebaserc_rescuenet_staging << EOF
{
  "projects": {
    "default": "rescuenet-staging"
  }
}
EOF

git add .firebaserc_rescuenet_staging
git commit -m "Add Firebase RC file for staging"
git push
```

### "Unknown organization"

**Problem:** Org not configured in `org_registry.dart`

**Fix:**
- Ensure organization is added to `lib/config/org_registry.dart`
- Run `dart run build_runner build` locally
- Commit generated files
- Push changes

### "FIREBASE_TOKEN secret not set"

**Problem:** GitHub Actions can't access Firebase token

**Fix:**
- Follow step 1-2 in "First-Time Setup" above
- Ensure secret name is exactly `FIREBASE_TOKEN` (case-sensitive)
- Re-run the workflow

### "Permission denied" during Firebase deploy

**Problem:** Firebase token doesn't have deploy permissions

**Fix:**
- Regenerate token: `firebase login:ci`
- Update GitHub secret with new token
- Ensure you're logged in to correct Google account with deploy permissions

### Build fails

**Problem:** Flutter build step fails

**Common causes:**
- Missing dependencies: Run `flutter pub get` locally
- Compilation errors: Check code compiles locally
- Missing files: Ensure all required config files exist

**Fix:**
- Check workflow logs for specific error
- Fix the issue locally
- Push the fix
- Re-run workflow

---

## Adding a New Organization

### 1. Update Workflow Matrix

Edit `.github/workflows/deploy-multi-tenant.yml`:

```yaml
strategy:
  matrix:
    org: [rescuenet, neworg]  # Add neworg here
```

### 2. Update Workflow Dispatch Options

In the same file:

```yaml
workflow_dispatch:
  inputs:
    org:
      options:
        - rescuenet
        - neworg  # Add here
        - all
```

### 3. Create Firebase RC Files

```bash
# Staging
cat > .firebaserc_neworg_staging << EOF
{
  "projects": {
    "default": "neworg-staging"
  }
}
EOF

# Production
cat > .firebaserc_neworg_production << EOF
{
  "projects": {
    "default": "neworg-production"
  }
}
EOF
```

### 4. Commit and Push

```bash
git add .github/workflows/deploy-multi-tenant.yml
git add .firebaserc_neworg_*
git commit -m "Add neworg to CI/CD pipeline"
git push
```

### 5. Test

- Manually trigger workflow with `neworg` and `staging`
- Verify deployment succeeds
- Check app loads at staging URL

---

## Best Practices

### Branch Workflow

```
feature branches → develop → staging (auto-deploy)
                      ↓
                    main → production (auto-deploy)
```

### Before Merging to Develop

- ✅ Code compiles locally
- ✅ Tests pass (if applicable)
- ✅ Code reviewed (via PR)
- ✅ Build succeeds locally with dart-defines

### Before Merging to Main

- ✅ Fully tested in staging
- ✅ All stakeholders approve
- ✅ Release notes prepared
- ✅ Rollback plan ready

### Deployment Timing

- **Staging:** Deploy anytime during business hours
- **Production:**
  - Avoid Fridays and end-of-day
  - Plan for monitoring time after deploy
  - Have team available for quick fixes

### Monitoring After Deploy

1. Check workflow completes successfully
2. Visit deployed URL
3. Test critical user flows
4. Check Firebase Console for errors
5. Monitor for ~15 minutes post-deploy

---

## Advanced Usage

### Deploy All Organizations

Use workflow_dispatch with `org: all`:
1. Actions > Deploy Multi-Tenant > Run workflow
2. Select `all` for organization
3. All orgs in matrix deploy in sequence

### Emergency Rollback

If deployment breaks production:

1. Revert the problematic commit locally
2. Push to main (triggers auto-deploy)
3. Or manually deploy previous good commit:
   - Actions > Deploy Multi-Tenant
   - Select previous commit's branch/tag
   - Deploy to production

### Deploy from Feature Branch

Useful for testing:

1. Actions > Deploy Multi-Tenant
2. Select your feature branch
3. Choose `staging` environment
4. Test without merging to develop

---

## Security Checklist

- ✅ `FIREBASE_TOKEN` stored as GitHub secret (never in code)
- ✅ Branch protection rules enabled on `main`
- ✅ Required reviewers configured for PRs to main
- ✅ Firebase token rotated periodically
- ✅ Deploy permissions limited to authorized users
- ✅ Audit logs reviewed regularly

---

## Support

### Documentation

- **Full documentation:** `.github/workflows/README.md`
- **Implementation plan:** `plans/2025-10-10-multi-tenant-build-time-config.md`
- **Implementation summary:** `plans/phase-4.1-implementation-summary.md`

### Common Commands

```bash
# Generate new Firebase token
firebase login:ci

# List Firebase projects
firebase projects:list

# View local Firebase configuration
cat .firebaserc

# Test build locally
flutter build web --dart-define=ORG=rescuenet --dart-define=ENV=staging

# View GitHub Actions logs
gh run list --workflow=deploy-multi-tenant.yml
gh run view <run-id> --log
```

### Getting Help

1. Check workflow logs in GitHub Actions
2. Review troubleshooting section above
3. Consult full documentation in README.md
4. Check Firebase Console for deploy status
5. Review implementation summary for technical details

---

## Quick Reference

| Action | Command/Steps |
|--------|---------------|
| Setup token | `firebase login:ci` → Add to GitHub secrets |
| Deploy staging | Push to `develop` branch |
| Deploy production | Push to `main` branch (careful!) |
| Manual deploy | Actions > Deploy Multi-Tenant > Run workflow |
| View logs | Actions > Click workflow run |
| Add org | Update matrix in workflow YAML + create RC files |
| Rollback | Deploy previous commit manually |

---

**Last Updated:** 2025-10-10
**Workflow Version:** 1.0
**Flutter Version:** 3.32.4
