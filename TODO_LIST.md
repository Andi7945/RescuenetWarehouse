# TODO List

## Completed

### ✅ Fix Critical Deployment Configuration Bug (2025-10-22)

**Issue:** Legacy workflow built for staging but deployed to production
**Fix:** Added proper `--dart-define` flags to legacy workflow
**Details:**
- Added explicit ORG=rescuenet and ENV=production flags
- Standardized web renderer to canvaskit
- Added FIREBASE_CLI_EXPERIMENTS flag to multi-tenant workflow
- Removed unnecessary frameworksBackend config
- Updated documentation

---

## Pending

### Future: Activate Multi-Tenant Workflow

**Status:** Dormant (workflow exists but no matching branches)
**Action Required:**
1. Create `develop` and `main` branches OR
2. Update workflow triggers to use `andi` branch

**Benefit:** Automated staging/production deployments based on branch

---

## Deployment Infrastructure Improvements

### Migrate to Service Account Authentication

**Priority:** Medium
**Estimated Effort:** 2-3 hours
**Status:** Pending

#### Current State
The multi-tenant workflow (`.github/workflows/deploy-multi-tenant.yml`) uses Firebase CLI token authentication (`FIREBASE_TOKEN` secret), which is:
- Deprecated by Firebase (they recommend service accounts)
- User-level access to all projects (less secure)
- Can expire periodically
- Less granular permission control

#### Target State
Migrate to service account authentication for:
- Better security (scoped to specific projects)
- No expiration issues
- Modern best practice
- Clear audit trail

#### Implementation Steps

1. **Create Service Accounts** for each Firebase project:

```bash
# For staging
gcloud iam service-accounts create github-actions-staging \
  --project=rescuenet-testing \
  --display-name="GitHub Actions Staging Deployer"

# For production
gcloud iam service-accounts create github-actions-production \
  --project=rescuenet-7733b \
  --display-name="GitHub Actions Production Deployer"
```

2. **Grant Firebase Hosting Admin permissions:**

```bash
# Staging
gcloud projects add-iam-policy-binding rescuenet-testing \
  --member="serviceAccount:github-actions-staging@rescuenet-testing.iam.gserviceaccount.com" \
  --role="roles/firebase.hostingAdmin"

# Production
gcloud projects add-iam-policy-binding rescuenet-7733b \
  --member="serviceAccount:github-actions-production@rescuenet-7733b.iam.gserviceaccount.com" \
  --role="roles/firebase.hostingAdmin"
```

3. **Download Service Account Keys:**

```bash
# Staging
gcloud iam service-accounts keys create ~/rescuenet-staging-sa-key.json \
  --iam-account=github-actions-staging@rescuenet-testing.iam.gserviceaccount.com

# Production
gcloud iam service-accounts keys create ~/rescuenet-production-sa-key.json \
  --iam-account=github-actions-production@rescuenet-7733b.iam.gserviceaccount.com
```

4. **Add to GitHub Secrets:**

```bash
# Base64 encode the keys
base64 ~/rescuenet-staging-sa-key.json
base64 ~/rescuenet-production-sa-key.json
```

Add to GitHub repository secrets:
- `FIREBASE_SERVICE_ACCOUNT_RESCUENET_STAGING`
- `FIREBASE_SERVICE_ACCOUNT_RESCUENET_PRODUCTION`

5. **Update Multi-Tenant Workflow** (`.github/workflows/deploy-multi-tenant.yml`):

Replace the manual `firebase deploy` command with the `FirebaseExtended/action-hosting-deploy` action:

```yaml
- name: Deploy ${{ matrix.org }}
  uses: FirebaseExtended/action-hosting-deploy@v0
  with:
    repoToken: '${{ secrets.GITHUB_TOKEN }}'
    firebaseServiceAccount: ${{ steps.env.outputs.env == 'staging' && secrets.FIREBASE_SERVICE_ACCOUNT_RESCUENET_STAGING || secrets.FIREBASE_SERVICE_ACCOUNT_RESCUENET_PRODUCTION }}
    projectId: ${{ steps.env.outputs.env == 'staging' && 'rescuenet-testing' || 'rescuenet-7733b' }}
    channelId: live
```

6. **Test the migration:**

```bash
# Test staging deployment
git push origin develop

# Test production deployment (if main branch exists)
git push origin main
```

7. **Cleanup:**

After confirming everything works, remove the old `FIREBASE_TOKEN` secret from GitHub.

#### Benefits
- Scoped access (staging service account can't deploy to production)
- No expiration issues
- Better audit trail
- Follows Firebase's recommended authentication method
- Leverages the full capabilities of `FirebaseExtended/action-hosting-deploy` action

#### Related Files
- `.github/workflows/deploy-multi-tenant.yml` - Needs update
- `.github/workflows/firebase-hosting-merge.yml` - Already uses service account (good example)

#### Documentation to Update
- `README.md` or `CLAUDE.md` - Update deployment authentication documentation
- Remove references to deprecated `firebase login:ci` command
