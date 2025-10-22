# Deployment Runbook

## Quick Reference

### Production Deployment
```bash
# Method 1: Push to micha-1 (automatic)
git push origin micha-1

# Method 2: Manual via scripts
./scripts/release_org.sh rescuenet production
```

### Staging Deployment
```bash
./scripts/release_org.sh rescuenet staging
```

---

## Deployment Workflows

### Legacy Workflow (Active)

**Trigger:** Push to `micha-1` branch
**Target:** Production (`rescuenet-7733b`)
**Build Config:**
- ORG: rescuenet
- ENV: production
- Renderer: canvaskit

**Process:**
1. Push to micha-1
2. GitHub Actions builds with production config
3. Deploys to Firebase Hosting (production)
4. Available at: https://rescuenet-7733b.web.app

**Use When:**
- Quick production hotfixes
- Active development on micha-1 branch
- Need immediate production deployment

---

### Multi-Tenant Workflow (Inactive)

**Status:** Dormant (no matching branches)
**Potential Triggers:** Push to `develop` or `main`
**Capabilities:**
- Multi-org support
- Environment-based routing (branch → environment)
- Manual workflow dispatch

**To Activate:**
1. Create branches: `develop` and `main`
2. OR update workflow to trigger on `andi`

---

## Manual Deployment via Scripts

### Build Only
```bash
./scripts/build_org.sh <org_id> <environment>

# Examples:
./scripts/build_org.sh rescuenet staging
./scripts/build_org.sh rescuenet production
```

### Deploy Only (requires prior build)
```bash
./scripts/deploy_org.sh <org_id> <environment>

# Production deploys require confirmation:
./scripts/deploy_org.sh rescuenet production
# > ⚠️  Deploy to PRODUCTION for rescuenet? (yes/no): yes
```

### Build + Deploy Combined
```bash
./scripts/release_org.sh <org_id> <environment>

# Example:
./scripts/release_org.sh rescuenet staging
```

---

## Environment Mapping

| Environment | Firebase Project | Purpose |
|-------------|------------------|---------|
| staging | rescuenet-testing | Development, QA, testing |
| production | rescuenet-7733b | Live production environment |

---

## Build Flags

All builds require explicit flags:

```bash
--dart-define=ORG=<org_id>       # Organization identifier
--dart-define=ENV=<environment>  # Environment (staging/production)
--web-renderer canvaskit         # Consistent rendering
```

**Default Values (if flags omitted):**
- ORG: rescuenet
- ENV: staging

**⚠️ Important:** Always explicitly set flags - don't rely on defaults.

---

## Troubleshooting

### Build Deployed to Wrong Environment

**Symptom:** App connects to wrong Firebase project after deployment

**Cause:** Build flags didn't match deployment target

**Fix:**
1. Verify build command includes correct `--dart-define` flags
2. Rebuild with correct flags
3. Redeploy

### Workflow Not Triggering

**Symptom:** Push doesn't trigger GitHub Actions

**Cause:** Branch name doesn't match workflow trigger

**Fix:**
1. Check current branch: `git branch --show-current`
2. Check workflow triggers in `.github/workflows/*.yml`
3. Push to correct branch or update workflow

### Firebase Authentication Fails After Deploy

**Symptom:** Can't log in after deployment

**Cause:** Firestore rules or Authentication config mismatch

**Fix:**
1. Verify Firebase project in browser console
2. Check Firestore rules allow access
3. Verify Authentication provider is enabled

---

## Rollback Procedure

### Emergency Production Rollback

**If production deployment breaks:**

```bash
# 1. Revert to previous commit
git revert HEAD
git push origin micha-1

# 2. OR redeploy previous working build
git checkout <previous-working-commit>
flutter build web \
  --dart-define=ORG=rescuenet \
  --dart-define=ENV=production \
  --release \
  --web-renderer canvaskit
firebase deploy --only hosting --project rescuenet-7733b

# 3. Return to current state
git checkout micha-1
```

**Recovery Time:** ~5 minutes (automated workflow) or ~2 minutes (manual)

---

## Pre-Deployment Checklist

Before deploying to production:

- [ ] Changes tested in staging
- [ ] No console errors in staging
- [ ] Authentication works in staging
- [ ] Core features functional in staging
- [ ] Build flags verified: `--dart-define=ENV=production`
- [ ] Correct Firebase project targeted
- [ ] Team notified of deployment
- [ ] Rollback plan ready if needed

---

## Post-Deployment Verification

After production deployment:

1. **Immediate (0-5 min):**
   - [ ] Site loads: https://rescuenet-7733b.web.app
   - [ ] No console errors
   - [ ] Can log in
   - [ ] Home page displays correctly

2. **Smoke Test (5-15 min):**
   - [ ] Create container
   - [ ] Create item
   - [ ] Assign item to container
   - [ ] Generate PDF
   - [ ] View work log

3. **Monitor (15-60 min):**
   - [ ] Check Firebase Console for errors
   - [ ] Monitor user reports
   - [ ] Watch for authentication issues

---

## Contacts

**Deployment Issues:** [Your team's contact info]
**Firebase Admin:** [Firebase admin contact]
**Emergency:** [Emergency contact]

---

## Change Log

- **2025-10-22:** Fixed legacy workflow build configuration
- **2025-10-10:** Created multi-tenant deployment system
- **Earlier:** Initial Firebase deployment setup
