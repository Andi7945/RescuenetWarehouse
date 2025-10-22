# Fix Deployment Workflows - Priority 1 Critical Issues

**Date:** 2025-10-22
**Goal:** Fix critical deployment configuration bugs and standardize multi-tenant deployment
**Priority:** P0 - Critical Production Bug
**Approach:** KISS, SRP, minimal changes, startup velocity

---

## Executive Summary

**Critical Issue Identified:**
The legacy workflow (`firebase-hosting-merge.yml`) builds the app without proper `--dart-define` flags, causing an environment mismatch:
- Builds with **default values** (ORG=rescuenet, ENV=staging)
- Deploys to **production** Firebase project (`rescuenet-7733b`)
- Currently "works" only because staging config incorrectly points to production

**Impact:** Time bomb - if staging Firebase config is corrected, production deploys will break.

**Solution:**
1. Fix legacy workflow to build with correct flags
2. Standardize web renderer across all workflows
3. Add missing experimental flag to multi-tenant workflow
4. Align branch strategy with workflow expectations

---

## Implementation Plan

### Phase 1: Fix Legacy Workflow Configuration (CRITICAL)

**Priority:** P0 - Must fix immediately
**Estimated Time:** 15 minutes
**Risk:** Medium - touching production deployment workflow

#### Task 1.1: Update Legacy Workflow Build Step

**File:** `.github/workflows/firebase-hosting-merge.yml`

**Current State (BROKEN):**
```yaml
- run: flutter build web  # No dart-define flags!
```

**Fixed State:**
```yaml
- name: Build for production
  run: |
    flutter build web \
      --dart-define=ORG=rescuenet \
      --dart-define=ENV=production \
      --release \
      --web-renderer canvaskit
```

**Why This Fix:**
- Adds explicit `--dart-define` flags to match deployment target (production)
- Standardizes web renderer to `canvaskit` (consistent with multi-tenant workflow)
- Makes configuration explicit and auditable
- Prevents future bugs when staging config is corrected

**Validation:**
1. Check workflow syntax with GitHub Actions validator
2. Compare with multi-tenant workflow for consistency
3. Verify build flags match Firebase project being deployed to

**Automated Test:** None needed (workflow file validation)

**Rollback Plan:** Git revert if workflow fails

---

#### Task 1.2: Add Web Frameworks Experiment Flag

**File:** `.github/workflows/firebase-hosting-merge.yml`

**Current State:**
```yaml
env:
  FIREBASE_CLI_EXPERIMENTS: webframeworks
```

**Analysis:** Legacy workflow **has this flag**, multi-tenant workflow does **not**.

**Action for Legacy:** Keep as-is (no change needed)

**Note:** This flag is likely unnecessary for Flutter web (static SPA), but keeping it doesn't hurt. Will address in Phase 2 for multi-tenant workflow.

---

### Phase 2: Enhance Multi-Tenant Workflow

**Priority:** P1 - High (completes feature parity)
**Estimated Time:** 20 minutes
**Risk:** Low - workflow currently inactive (no develop/main branches)

#### Task 2.1: Add Web Frameworks Experiment Flag

**File:** `.github/workflows/deploy-multi-tenant.yml`

**Current Deploy Step (line 89-123):**
```yaml
- name: Deploy ${{ matrix.org }}
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
  run: |
    # ... deployment commands
```

**Enhanced Version:**
```yaml
- name: Deploy ${{ matrix.org }}
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
    FIREBASE_CLI_EXPERIMENTS: webframeworks
  run: |
    ORG="${{ steps.env.outputs.org }}"
    ENV="${{ steps.env.outputs.env }}"

    # Validate inputs
    if [ -z "$ORG" ] || [ "$ORG" = "all" ]; then
      ORG="${{ matrix.org }}"
    fi

    BUILD_DIR="build/web_${ORG}_${ENV}"

    # Verify build exists
    if [ ! -d "$BUILD_DIR" ]; then
      echo "Error: Build not found at $BUILD_DIR"
      exit 1
    fi

    # Copy build to firebase public directory
    rm -rf build/web
    cp -r "$BUILD_DIR" build/web

    # Switch to correct Firebase project
    RC_FILE=".firebaserc_${ORG}_${ENV}"
    if [ ! -f "$RC_FILE" ]; then
      echo "Error: Firebase RC file not found: $RC_FILE"
      exit 1
    fi

    cp "$RC_FILE" .firebaserc

    echo "Deploying $ORG to $ENV..."
    firebase deploy --only hosting --token "$FIREBASE_TOKEN" --non-interactive
```

**Why This Change:**
- Achieves feature parity with legacy workflow
- Enables `frameworksBackend` configuration in `firebase.json` (if needed)
- Low risk - flag is experimental but doesn't break existing functionality

**Validation:**
- Check workflow syntax
- Compare env vars with legacy workflow

---

#### Task 2.2: Update Branch Configuration

**File:** `.github/workflows/deploy-multi-tenant.yml`

**Current Triggers (lines 4-7):**
```yaml
on:
  push:
    branches:
      - develop    # Auto-deploy to staging
      - main       # Auto-deploy to production
```

**Problem:** These branches don't exist! Main branch is `andi`.

**Options:**

**Option A: Update to Match Current Branches (RECOMMENDED)**
```yaml
on:
  push:
    branches:
      - andi       # Auto-deploy to production (main branch)
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
```

**Option B: Create develop Branch**
```bash
git checkout -b develop andi
git push origin develop
```

Then keep workflow as-is.

**Recommended:** Option A - update workflow to use `andi` branch for now. Creating `develop`/`main` can be done later as part of branch strategy refinement.

**Updated Environment Determination (lines 45-57):**
```yaml
- name: Determine environment
  id: env
  run: |
    if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
      echo "env=${{ github.event.inputs.environment }}" >> $GITHUB_OUTPUT
      echo "org=${{ github.event.inputs.org }}" >> $GITHUB_OUTPUT
    elif [[ "${{ github.ref }}" == "refs/heads/andi" ]]; then
      echo "env=production" >> $GITHUB_OUTPUT
      echo "org=${{ matrix.org }}" >> $GITHUB_OUTPUT
    else
      echo "env=staging" >> $GITHUB_OUTPUT
      echo "org=${{ matrix.org }}" >> $GITHUB_OUTPUT
    fi
```

**Why This Change:**
- Makes workflow actually functional (currently inactive)
- Aligns with current branch structure
- Preserves manual workflow_dispatch option

**Alternative:** Don't activate multi-tenant workflow yet - keep it dormant for future use. In this case, skip this task.

**User Decision Required:** Activate multi-tenant workflow or keep dormant?

**For this plan, we'll:** Keep workflow dormant (don't change branch triggers) - user can activate later.

---

### Phase 3: Standardization and Cleanup

**Priority:** P2 - Medium (code quality improvement)
**Estimated Time:** 10 minutes
**Risk:** Very Low - documentation only

#### Task 3.1: Remove Unnecessary Firebase Config

**File:** `firebase.json`

**Current State (lines 6-8):**
```json
"frameworksBackend": {
  "region": "europe-west1"
}
```

**Analysis:**
- This config is for SSR frameworks (Next.js, Angular)
- Flutter web is a static SPA (no server-side rendering)
- Not being used effectively
- Can be safely removed

**Action:** Remove `frameworksBackend` config

**Updated firebase.json:**
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
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

**Why This Change:**
- Removes misleading configuration
- Clarifies that this is a static site
- Prevents confusion about SSR capabilities

**Risk:** Very Low - this config isn't actively used

**Rollback:** Git revert if any issues

---

#### Task 3.2: Add Workflow Documentation Header

**File:** `.github/workflows/firebase-hosting-merge.yml`

**Add at top of file:**
```yaml
# Legacy Deployment Workflow
#
# Purpose: Deploys to production on push to micha-1 branch
# Use Case: Quick production deployments during active development
#
# For standard multi-tenant deployments, see: deploy-multi-tenant.yml
#
# This file was auto-generated by the Firebase CLI and then customized.

name: Deploy to Firebase Hosting on merge
```

**Why:**
- Clarifies purpose of legacy workflow
- Prevents confusion about which workflow to use
- Documents its role in deployment strategy

---

#### Task 3.3: Update CLAUDE.md Deployment Section

**File:** `CLAUDE.md`

**Find and update the deployment section to clarify workflow usage:**

Add new subsection after existing multi-tenant documentation:

```markdown
### Deployment Workflows

**Two GitHub Actions workflows exist:**

1. **Multi-Tenant Workflow** (`.github/workflows/deploy-multi-tenant.yml`)
   - **Status:** Inactive (no matching branches)
   - **Purpose:** Automated deployments for develop→staging, main→production
   - **Usage:** Manual dispatch or push to configured branches
   - **Features:** Supports multiple orgs, environment-specific builds

2. **Legacy Workflow** (`.github/workflows/firebase-hosting-merge.yml`)
   - **Status:** Active (triggers on micha-1 branch)
   - **Purpose:** Quick production deployments during development
   - **Target:** rescuenet-7733b (production)
   - **Environment:** Production builds with proper configuration

**Current Deployment Method:**
- Production: Push to `micha-1` branch (legacy workflow)
- Staging: Manual deployment via scripts

**To Activate Multi-Tenant Workflow:**
Update branch triggers in `deploy-multi-tenant.yml` to match your branch strategy.
```

---

### Phase 4: Validation and Testing

**Priority:** P0 - Critical (verify fixes work)
**Estimated Time:** 30 minutes
**Risk:** Low - testing only

#### Task 4.1: Syntax Validation

**Commands:**
```bash
# Validate workflow YAML syntax
cd .github/workflows

# Check legacy workflow
cat firebase-hosting-merge.yml | grep -v '^#' | grep -v '^$'

# Check multi-tenant workflow
cat deploy-multi-tenant.yml | grep -v '^#' | grep -v '^$'

# Validate JSON
cd ../..
cat firebase.json | jq '.'
```

**Expected:** No syntax errors

**Validation Criteria:**
- YAML is valid (no indentation errors)
- JSON is valid (jq parses successfully)
- No duplicate keys

---

#### Task 4.2: Local Build Testing

**Test build with corrected flags:**

```bash
# Test staging build
flutter build web \
  --dart-define=ORG=rescuenet \
  --dart-define=ENV=staging \
  --release \
  --web-renderer canvaskit

echo "Staging build created"
ls -lh build/web/

# Test production build
flutter build web \
  --dart-define=ORG=rescuenet \
  --dart-define=ENV=production \
  --release \
  --web-renderer canvaskit

echo "Production build created"
ls -lh build/web/
```

**Expected Results:**
- Both builds succeed
- No compilation errors
- Build output exists in `build/web/`
- Console shows correct Firebase initialization logs

**Validation:**
1. Check build exits with code 0
2. Verify `build/web/` contains files
3. Inspect `main.dart.js` for correct Firebase config references

---

#### Task 4.3: Script Validation

**Test existing deployment scripts work with updates:**

```bash
# Test build script
./scripts/build_org.sh rescuenet staging

# Verify output
ls -lh build/web_rescuenet_staging/

# Test production build script
./scripts/build_org.sh rescuenet production

# Verify output
ls -lh build/web_rescuenet_production/
```

**Expected:** Both scripts succeed, outputs in correct directories

**Validation Criteria:**
- Scripts exit with code 0
- Environment-specific directories created
- Build artifacts present
- No error messages

---

#### Task 4.4: Workflow Dry Run Validation

**Check workflows without actually running:**

```bash
# View workflow that would trigger
git log --oneline -1
git branch --contains HEAD

# Check if workflow would run
echo "Current branch: $(git branch --show-current)"
echo "Legacy workflow triggers on: micha-1"
echo "Multi-tenant workflow triggers on: develop, main"
```

**Expected:** Understand which workflow would trigger on push

**Manual Check:**
1. Go to GitHub Actions tab
2. Check recent workflow runs
3. Verify legacy workflow configuration is visible

---

### Phase 5: Documentation Updates

**Priority:** P2 - Medium (completeness)
**Estimated Time:** 15 minutes
**Risk:** None - documentation only

#### Task 5.1: Update TODO_LIST.md

**File:** `TODO_LIST.md`

**Add new section at top:**

```markdown
# TODO List

## Completed

### ✅ Fix Critical Deployment Configuration Bug (2025-10-22)

**Issue:** Legacy workflow built for staging but deployed to production
**Fix:** Added proper `--dart-define` flags to legacy workflow
**PR/Commit:** [Link when completed]

---

## Pending

### Future: Activate Multi-Tenant Workflow

**Status:** Dormant (workflow exists but no matching branches)
**Action Required:**
1. Create `develop` and `main` branches OR
2. Update workflow triggers to use `andi` branch

**Benefit:** Automated staging/production deployments based on branch

---
```

---

#### Task 5.2: Create Deployment Runbook

**File:** `docs/DEPLOYMENT_RUNBOOK.md`

**Create new file:**

```markdown
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
```

---

## Implementation Summary for Subagent

### Execution Order

**Sequential Tasks (must run in order):**

1. **Phase 1 - CRITICAL FIX**
   - Task 1.1: Fix legacy workflow build flags ⚠️ HIGH PRIORITY
   - Validation: Syntax check, no deploy yet

2. **Phase 2 - ENHANCEMENTS**
   - Task 2.1: Add experiment flag to multi-tenant workflow
   - Task 2.2: SKIP (keep workflow dormant)

3. **Phase 3 - CLEANUP**
   - Task 3.1: Remove frameworksBackend from firebase.json
   - Task 3.2: Add workflow documentation headers
   - Task 3.3: Update CLAUDE.md

4. **Phase 4 - VALIDATION**
   - Task 4.1: Syntax validation (all files)
   - Task 4.2: Local build testing
   - Task 4.3: Script validation
   - Task 4.4: Workflow dry run check

5. **Phase 5 - DOCUMENTATION**
   - Task 5.1: Update TODO_LIST.md
   - Task 5.2: Create deployment runbook

---

## Validation Criteria

### Must Pass:
1. ✅ Legacy workflow has explicit `--dart-define` flags
2. ✅ Legacy workflow uses `--web-renderer canvaskit`
3. ✅ Both workflows have valid YAML syntax
4. ✅ Local builds succeed with both staging and production flags
5. ✅ firebase.json is valid JSON
6. ✅ Deployment scripts still work

### Nice to Have:
1. ✅ Multi-tenant workflow has experiment flag
2. ✅ Documentation updated
3. ✅ Runbook created

---

## Risk Assessment

### High Risk (Production Impact):
- **Task 1.1** - Changes active production workflow
  - **Mitigation:** Syntax validation before commit
  - **Rollback:** Git revert immediately if fails

### Medium Risk:
- **Task 3.1** - Removes firebase.json config
  - **Mitigation:** Config not actively used (Flutter web is static)
  - **Rollback:** Git revert

### Low Risk:
- All other tasks (documentation, inactive workflow changes)

---

## Success Criteria

Implementation is successful when:

1. **Critical Bug Fixed:**
   - ✅ Legacy workflow builds with production config
   - ✅ Explicit flags prevent future env mismatches

2. **Workflows Standardized:**
   - ✅ Both workflows use canvaskit renderer
   - ✅ Multi-tenant workflow has feature parity

3. **Documentation Complete:**
   - ✅ Workflows clearly documented
   - ✅ Runbook available for operations
   - ✅ CLAUDE.md updated

4. **Validation Passed:**
   - ✅ All syntax checks pass
   - ✅ Local builds work
   - ✅ Scripts still functional

---

## Estimated Timeline

- Phase 1: 15 minutes (critical fix)
- Phase 2: 20 minutes (enhancements)
- Phase 3: 10 minutes (cleanup)
- Phase 4: 30 minutes (validation)
- Phase 5: 15 minutes (documentation)

**Total:** ~90 minutes

**With subagent execution:** ~45 minutes (some tasks can parallelize)

---

## Files Modified

### Critical Changes:
- `.github/workflows/firebase-hosting-merge.yml` (fix build flags)

### Enhancement Changes:
- `.github/workflows/deploy-multi-tenant.yml` (add experiment flag)
- `firebase.json` (remove frameworksBackend)

### Documentation Changes:
- `CLAUDE.md` (update deployment section)
- `TODO_LIST.md` (track completed work)
- `docs/DEPLOYMENT_RUNBOOK.md` (new file - operational guide)

### No Changes Needed:
- `lib/main.dart` (already correct)
- `lib/config/org_registry.dart` (already correct)
- `scripts/*.sh` (already correct)
- `.firebaserc_*` files (already correct)

---

## Subagent Execution Instructions

**For a clean Claude Code session, provide this plan and execute:**

```
Read plans/FIX_DEPLOYMENT_WORKFLOWS.md

Execute in order:
1. Phase 1 (critical fixes)
2. Validate changes
3. Phase 2-3 (enhancements)
4. Phase 4 (full validation)
5. Phase 5 (documentation)

After each phase, confirm changes before proceeding.

Do not deploy to production - only fix configuration files.
```

---

## Post-Implementation

After this plan is complete:

1. **Commit changes:**
   ```bash
   git add .github/workflows/
   git add firebase.json
   git add CLAUDE.md
   git add TODO_LIST.md
   git add docs/DEPLOYMENT_RUNBOOK.md
   git commit -m "Fix critical deployment workflow configuration

   - Add explicit build flags to legacy workflow
   - Standardize web renderer to canvaskit
   - Add experiment flag to multi-tenant workflow
   - Remove unnecessary frameworksBackend config
   - Add deployment documentation and runbook"
   ```

2. **Test workflow (STAGING FIRST):**
   - Create test branch
   - Push and verify workflow runs correctly
   - Check build logs for correct flags

3. **Production validation:**
   - Monitor next production deployment
   - Verify app initializes with production Firebase
   - Confirm no regressions

4. **Future work (separate ticket):**
   - Activate multi-tenant workflow with branch strategy
   - Migrate to service accounts (see TODO_LIST.md)
   - Consider PR preview channels (if needed)

---

## Notes for Implementation

- **KISS Principle:** Minimal changes to fix critical bug
- **SRP:** Each task has single responsibility
- **Startup Velocity:** Fast, focused execution
- **No Overthinking:** Fix what's broken, standardize, document, move on
- **Safety First:** Validate before push, have rollback ready
