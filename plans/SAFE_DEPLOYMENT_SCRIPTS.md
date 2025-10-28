# Safe Deployment Scripts Implementation Plan

## Problem Statement

Current deployment scripts don't verify that the compiled JavaScript bundle contains the correct Firebase configuration. This led to a production incident where a build configured for `humedica-e767c` was deployed to `rescuenet-7733b`, causing authorization failures.

## Solution Overview

Add verification layers to build and deployment scripts that:
1. Verify the compiled bundle contains the expected Firebase project ID
2. Create manifest files to track build metadata
3. Prevent deploying builds that don't match the requested org/env
4. Maintain an audit log of all deployments

## Architecture Principles

- **SRP**: Separate verification, extraction, and logging into focused functions
- **KISS**: Use simple bash functions and standard tools (grep, jq)
- **Modularity**: Shared functions in a library file
- **Pure functions**: Stateless extraction and validation where possible
- **Fast startup mindset**: Don't over-engineer, ship working solution quickly

## Implementation Phases

### Phase 1: Verification Library (Core Foundation)

**File**: `scripts/lib/verify_build.sh`

**Purpose**: Pure/simple functions for extraction and verification

**Functions to implement**:

```bash
# Extract Firebase project ID from compiled JavaScript bundle
# Pure function: input (file path) -> output (project ID or empty)
extract_project_id_from_bundle() {
  local bundle_path="$1"
  # Extract projectId from Firebase config in JavaScript
  # Pattern: look for Firebase config object with projectId
  grep -oE '"[a-z0-9-]+","[a-z0-9-]+\.firebaseapp\.com"' "$bundle_path" | \
    grep -oE '[a-z0-9-]+' | head -1
}

# Get expected project ID for org/env combination
# Pure function: input (org, env) -> output (expected project ID)
get_expected_project_id() {
  local org="$1"
  local env="$2"

  case "$org/$env" in
    rescuenet/production) echo "rescuenet-7733b" ;;
    rescuenet/staging) echo "rescuenet-testing" ;;
    humedica/production) echo "humedica-e767c" ;;
    humedica/staging) echo "humedica-e767c" ;;  # Uses same project
    *) echo "" ;;
  esac
}

# Verify bundle contains expected project ID
# Returns: 0 (success) or 1 (failure)
verify_bundle_project_id() {
  local bundle_path="$1"
  local expected_id="$2"

  local actual_id=$(extract_project_id_from_bundle "$bundle_path")

  if [ -z "$actual_id" ]; then
    echo "❌ Error: Could not extract project ID from bundle"
    return 1
  fi

  if [ "$actual_id" != "$expected_id" ]; then
    echo "❌ PROJECT ID MISMATCH!"
    echo "   Expected: $expected_id"
    echo "   Found:    $actual_id"
    return 1
  fi

  echo "✅ Project ID verified: $actual_id"
  return 0
}

# Create build manifest JSON
create_build_manifest() {
  local org="$1"
  local env="$2"
  local project_id="$3"
  local output_file="$4"

  local git_commit=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  cat > "$output_file" <<EOF
{
  "org": "$org",
  "env": "$env",
  "project_id": "$project_id",
  "timestamp": "$timestamp",
  "git_commit": "$git_commit",
  "verified": true
}
EOF
}

# Verify manifest matches requested deployment
verify_manifest_matches() {
  local manifest_path="$1"
  local requested_org="$2"
  local requested_env="$3"

  if [ ! -f "$manifest_path" ]; then
    echo "❌ Error: Build manifest not found at $manifest_path"
    return 1
  fi

  local manifest_org=$(jq -r '.org' "$manifest_path")
  local manifest_env=$(jq -r '.env' "$manifest_path")
  local manifest_verified=$(jq -r '.verified' "$manifest_path")

  if [ "$manifest_org" != "$requested_org" ] || [ "$manifest_env" != "$requested_env" ]; then
    echo "❌ MANIFEST MISMATCH!"
    echo "   Requested: $requested_org/$requested_env"
    echo "   Manifest:  $manifest_org/$manifest_env"
    return 1
  fi

  if [ "$manifest_verified" != "true" ]; then
    echo "❌ Error: Build was not verified"
    return 1
  fi

  echo "✅ Manifest verified"
  return 0
}

# Check build age and warn if stale
check_build_age() {
  local manifest_path="$1"
  local max_age_hours=${2:-24}

  if [ ! -f "$manifest_path" ]; then
    return 1
  fi

  local build_timestamp=$(jq -r '.timestamp' "$manifest_path")
  local build_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$build_timestamp" "+%s" 2>/dev/null || echo "0")
  local now_epoch=$(date "+%s")
  local age_hours=$(( (now_epoch - build_epoch) / 3600 ))

  if [ $age_hours -gt $max_age_hours ]; then
    echo "⚠️  Warning: Build is $age_hours hours old (threshold: $max_age_hours hours)"
    return 1
  fi

  return 0
}
```

**Testing checklist**:
- [ ] Can extract project ID from rescuenet production bundle
- [ ] Can extract project ID from humedica production bundle
- [ ] Returns empty string for invalid bundle
- [ ] `get_expected_project_id` returns correct IDs for all org/env combos
- [ ] Verification succeeds when IDs match
- [ ] Verification fails when IDs don't match
- [ ] Manifest creation includes all required fields
- [ ] Manifest verification catches mismatches

---

### Phase 2: Enhanced Build Script

**File**: `scripts/build_org.sh`

**Enhancements**:
1. Clean `build/web` before building (prevent contamination)
2. Add `--web-renderer canvaskit` flag
3. Verify compiled bundle after build
4. Create build manifest
5. Fail fast if verification fails

**Updated script structure**:

```bash
#!/bin/bash
set -e

# Source verification library
source "$(dirname "$0")/lib/verify_build.sh"

# Parse arguments
ORG=${1:-}
ENV=${2:-staging}

# Validation (existing)
if [ -z "$ORG" ]; then
  echo "❌ Error: Organization ID required"
  echo "Usage: ./scripts/build_org.sh <org_id> [environment]"
  echo "Example: ./scripts/build_org.sh rescuenet staging"
  exit 1
fi

if [[ ! "$ENV" =~ ^(staging|production)$ ]]; then
  echo "❌ Error: Invalid environment '$ENV'. Use 'staging' or 'production'."
  exit 1
fi

echo "🏗️  Building $ORG for $ENV environment..."

# NEW: Get expected project ID
EXPECTED_PROJECT_ID=$(get_expected_project_id "$ORG" "$ENV")
if [ -z "$EXPECTED_PROJECT_ID" ]; then
  echo "❌ Error: Unknown org/env combination: $ORG/$ENV"
  exit 1
fi

echo "📋 Target Firebase project: $EXPECTED_PROJECT_ID"

# NEW: Clean build directory to prevent contamination
echo "🧹 Cleaning build directory..."
rm -rf build/web

# Build with dart-define flags (ADD canvaskit)
flutter build web \
  --dart-define=ORG="$ORG" \
  --dart-define=ENV="$ENV" \
  --release \
  --web-renderer canvaskit

# NEW: Verify the build contains correct Firebase config
echo "🔍 Verifying build configuration..."
if ! verify_bundle_project_id "build/web/main.dart.js" "$EXPECTED_PROJECT_ID"; then
  echo ""
  echo "❌ BUILD VERIFICATION FAILED!"
  echo "The compiled bundle does not contain the expected Firebase project ID."
  echo "This build is NOT safe to deploy."
  exit 1
fi

# NEW: Create build manifest
MANIFEST_PATH="build/web/.build-manifest.json"
create_build_manifest "$ORG" "$ENV" "$EXPECTED_PROJECT_ID" "$MANIFEST_PATH"
echo "📝 Build manifest created: $MANIFEST_PATH"

# Move to environment-specific directory
BUILD_DIR="build/web_${ORG}_${ENV}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r build/web/* "$BUILD_DIR/"

echo ""
echo "✅ Build complete and verified!"
echo "📦 Build directory: $BUILD_DIR"
echo "🎯 Firebase project: $EXPECTED_PROJECT_ID"
echo "🔒 Manifest: $(cat "$BUILD_DIR/.build-manifest.json")"
```

**Testing checklist**:
- [ ] Build succeeds for rescuenet/staging
- [ ] Build succeeds for rescuenet/production
- [ ] Build succeeds for humedica/production
- [ ] Manifest file is created in build directory
- [ ] Verification passes for correct builds
- [ ] Script fails if project ID extraction fails

---

### Phase 3: Enhanced Deploy Script

**File**: `scripts/deploy_org.sh`

**Enhancements**:
1. Verify build manifest exists and matches
2. Re-verify bundle project ID before deploy
3. Check build age
4. Enhanced confirmation prompt with full summary
5. For production, require typing exact project ID

**Updated script structure**:

```bash
#!/bin/bash
set -e

# Source verification library
source "$(dirname "$0")/lib/verify_build.sh"

# Parse arguments
ORG=${1:-}
ENV=${2:-staging}

# Validation (existing)
if [ -z "$ORG" ]; then
  echo "❌ Error: Organization ID required"
  echo "Usage: ./scripts/deploy_org.sh <org_id> [environment]"
  exit 1
fi

if [[ ! "$ENV" =~ ^(staging|production)$ ]]; then
  echo "❌ Error: Invalid environment '$ENV'"
  exit 1
fi

BUILD_DIR="build/web_${ORG}_${ENV}"

# Verify build exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Error: Build not found at $BUILD_DIR"
  echo "Run: ./scripts/build_org.sh $ORG $ENV"
  exit 1
fi

# NEW: Verify manifest exists and matches
echo "🔍 Verifying build manifest..."
MANIFEST_PATH="$BUILD_DIR/.build-manifest.json"
if ! verify_manifest_matches "$MANIFEST_PATH" "$ORG" "$ENV"; then
  echo ""
  echo "❌ DEPLOYMENT BLOCKED!"
  echo "Build manifest does not match requested deployment."
  exit 1
fi

# NEW: Re-verify bundle project ID
EXPECTED_PROJECT_ID=$(get_expected_project_id "$ORG" "$ENV")
echo "🔍 Re-verifying bundle configuration..."
if ! verify_bundle_project_id "$BUILD_DIR/main.dart.js" "$EXPECTED_PROJECT_ID"; then
  echo ""
  echo "❌ DEPLOYMENT BLOCKED!"
  echo "Bundle verification failed. Build may be corrupted."
  exit 1
fi

# NEW: Check build age
if ! check_build_age "$MANIFEST_PATH" 48; then
  read -p "Continue with stale build? (yes/no): " continue_stale
  if [ "$continue_stale" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 1
  fi
fi

# Switch to correct Firebase project
RC_FILE=".firebaserc_${ORG}_${ENV}"
if [ ! -f "$RC_FILE" ]; then
  echo "❌ Error: Firebase RC file not found: $RC_FILE"
  exit 1
fi

cp "$RC_FILE" .firebaserc

# Extract project ID from .firebaserc
PROJECT_ID=$(jq -r '.projects.default' .firebaserc)

# Verify .firebaserc matches expected
if [ "$PROJECT_ID" != "$EXPECTED_PROJECT_ID" ]; then
  echo "❌ Error: .firebaserc contains wrong project ID"
  echo "   Expected: $EXPECTED_PROJECT_ID"
  echo "   Found:    $PROJECT_ID"
  exit 1
fi

# NEW: Show comprehensive deployment summary
BUILD_INFO=$(cat "$MANIFEST_PATH")
BUILD_TIMESTAMP=$(echo "$BUILD_INFO" | jq -r '.timestamp')
GIT_COMMIT=$(echo "$BUILD_INFO" | jq -r '.git_commit')

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  DEPLOYMENT SUMMARY"
echo "═══════════════════════════════════════════════════════"
echo "  Organization:      $ORG"
echo "  Environment:       $ENV"
echo "  Firebase Project:  $PROJECT_ID"
echo "  Build Timestamp:   $BUILD_TIMESTAMP"
echo "  Git Commit:        $GIT_COMMIT"
echo "  Target URL:        https://$PROJECT_ID.web.app"
echo "═══════════════════════════════════════════════════════"
echo ""

# Enhanced confirmation for production
if [ "$ENV" = "production" ]; then
  echo "⚠️  PRODUCTION DEPLOYMENT"
  echo "To confirm, type the exact Firebase project ID: $PROJECT_ID"
  read -p "> " typed_id
  if [ "$typed_id" != "$PROJECT_ID" ]; then
    echo "❌ Production deploy cancelled (project ID mismatch)"
    exit 1
  fi
else
  read -p "Deploy to staging? (yes/no): " confirm
  if [ "$confirm" != "yes" ]; then
    echo "❌ Deployment cancelled"
    exit 1
  fi
fi

# Copy build to firebase public directory
rm -rf build/web
cp -r "$BUILD_DIR" build/web

# Clear Firebase CLI cache
rm -rf .firebase/

echo "🚀 Deploying $ORG to $ENV (project: $PROJECT_ID)..."
firebase deploy --only hosting --project "$PROJECT_ID"

echo ""
echo "✅ Deploy complete!"
echo "🌍 URL: https://$PROJECT_ID.web.app"

# NEW: Log deployment
./scripts/lib/log_deployment.sh "$ORG" "$ENV" "$PROJECT_ID" "$GIT_COMMIT"
```

**Testing checklist**:
- [ ] Deploy succeeds when manifest matches
- [ ] Deploy blocks when manifest doesn't match
- [ ] Deploy blocks when bundle verification fails
- [ ] Warns about stale builds (>48 hours)
- [ ] Production requires typing exact project ID
- [ ] Staging only requires "yes"
- [ ] Deployment is logged to audit file

---

### Phase 4: Deployment Audit Log

**File**: `scripts/lib/log_deployment.sh`

**Purpose**: Simple append-only audit log

```bash
#!/bin/bash

ORG="$1"
ENV="$2"
PROJECT_ID="$3"
GIT_COMMIT="$4"

LOG_FILE="deployments.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
USER=$(whoami)

# Create log entry
LOG_ENTRY="$TIMESTAMP | $USER | $ORG | $ENV | $PROJECT_ID | $GIT_COMMIT"

# Append to log file
echo "$LOG_ENTRY" >> "$LOG_FILE"

echo "📝 Deployment logged to $LOG_FILE"
```

**Log file format** (`deployments.log`):
```
# Deployment Audit Log
# Format: TIMESTAMP | USER | ORG | ENV | PROJECT_ID | GIT_COMMIT
2025-10-28T10:30:00Z | michandtke | rescuenet | production | rescuenet-7733b | 26399d0
2025-10-28T11:45:00Z | michandtke | rescuenet | staging | rescuenet-testing | 56fd1d9
```

**File**: `deployments.log` (create with header)

```
# Deployment Audit Log
# Format: TIMESTAMP | USER | ORG | ENV | PROJECT_ID | GIT_COMMIT
```

**Add to `.gitignore`**: NO - we want this tracked in git for history

---

### Phase 5: Update Documentation

**File**: `CLAUDE.md` - Update deployment section

Add after existing deployment commands:

```markdown
### Deployment Safety Features

All deployment scripts include automatic verification:
- ✅ Compiled bundle contains correct Firebase project ID
- ✅ Build manifest tracks org, env, timestamp, git commit
- ✅ Deployment blocked if manifest doesn't match
- ✅ Stale builds (>48h) generate warnings
- ✅ Production deploys require typing exact project ID
- ✅ All deployments logged to `deployments.log`

**Verification Process:**
1. Build script verifies compiled JavaScript contains correct project ID
2. Creates `.build-manifest.json` with metadata
3. Deploy script re-verifies manifest and bundle before deployment
4. Logs deployment to audit trail

**If verification fails:**
- Build will abort with clear error message
- Shows expected vs actual project ID
- Build directory will not be created
- Deployment will be blocked

**Audit Log:**
All deployments are logged to `deployments.log` (tracked in git) with:
- Timestamp, user, org, environment, project ID, git commit
```

---

### Phase 6: Testing & Validation

**Manual testing scenarios**:

1. **Happy path - correct build/deploy**
   ```bash
   ./scripts/build_org.sh rescuenet production
   # Should succeed with verification

   ./scripts/deploy_org.sh rescuenet production
   # Should require typing "rescuenet-7733b"
   # Should succeed and log deployment
   ```

2. **Catch mismatched deployment (the original bug)**
   ```bash
   ./scripts/build_org.sh humedica production
   # Should succeed with humedica-e767c

   ./scripts/deploy_org.sh rescuenet production
   # Should BLOCK with manifest mismatch error
   ```

3. **Catch stale build**
   ```bash
   # Build something
   ./scripts/build_org.sh rescuenet staging

   # Manually edit manifest timestamp to be 3 days old
   # Then try to deploy
   ./scripts/deploy_org.sh rescuenet staging
   # Should warn about stale build
   ```

4. **Release script (combined build+deploy)**
   ```bash
   ./scripts/release_org.sh rescuenet staging
   # Should build, verify, deploy successfully
   ```

---

## Implementation Checklist

### Phase 1: Verification Library
- [ ] Create `scripts/lib/` directory
- [ ] Create `scripts/lib/verify_build.sh`
- [ ] Implement `extract_project_id_from_bundle()`
- [ ] Implement `get_expected_project_id()`
- [ ] Implement `verify_bundle_project_id()`
- [ ] Implement `create_build_manifest()`
- [ ] Implement `verify_manifest_matches()`
- [ ] Implement `check_build_age()`
- [ ] Make script executable: `chmod +x scripts/lib/verify_build.sh`
- [ ] Test extraction with existing build (if available)

### Phase 2: Enhanced Build Script
- [ ] Update `scripts/build_org.sh` to source verification library
- [ ] Add build directory cleaning
- [ ] Add `--web-renderer canvaskit` flag
- [ ] Add project ID verification after build
- [ ] Add manifest creation
- [ ] Add verification failure handling
- [ ] Test with rescuenet/staging
- [ ] Test with rescuenet/production

### Phase 3: Enhanced Deploy Script
- [ ] Update `scripts/deploy_org.sh` to source verification library
- [ ] Add manifest verification
- [ ] Add bundle re-verification
- [ ] Add build age check
- [ ] Add deployment summary display
- [ ] Enhance production confirmation (type project ID)
- [ ] Add deployment logging call
- [ ] Test staging deployment
- [ ] Test production deployment (dry-run)

### Phase 4: Audit Log
- [ ] Create `scripts/lib/log_deployment.sh`
- [ ] Make script executable: `chmod +x scripts/lib/log_deployment.sh`
- [ ] Create `deployments.log` with header
- [ ] Verify log is NOT in `.gitignore`
- [ ] Test log entry creation

### Phase 5: Documentation
- [ ] Update `CLAUDE.md` deployment section
- [ ] Add safety features explanation
- [ ] Add troubleshooting section

### Phase 6: Validation
- [ ] Test happy path (correct build/deploy)
- [ ] Test mismatched deployment (should block)
- [ ] Test stale build warning
- [ ] Test release script (build+deploy)
- [ ] Verify audit log entries
- [ ] Commit changes

---

## Success Criteria

✅ **Prevention**: Cannot deploy a build with wrong Firebase config
✅ **Verification**: Multiple layers verify correctness at build and deploy time
✅ **Visibility**: Clear error messages explain what's wrong
✅ **Auditability**: All deployments logged with metadata
✅ **Simplicity**: No over-engineering, uses standard bash and jq
✅ **Speed**: Fast to implement, fast to execute

---

## Rollout Plan

1. Implement and test in development
2. Test with staging deployments first
3. Verify all checks work as expected
4. Use for production deployments
5. Update team documentation

---

## Future Enhancements (Not in Scope)

- Post-deployment verification (fetch deployed bundle)
- Slack/email notifications for production deploys
- Integration with GitHub Actions
- Deployment metrics and analytics

---

## Notes for Claude Code Execution

This plan can be executed by subagents with these commands:

**Phase 1:**
```
Create verification library with pure functions for project ID extraction and validation
```

**Phase 2:**
```
Enhance build_org.sh script to verify compiled bundle and create manifest
```

**Phase 3:**
```
Enhance deploy_org.sh script with pre-deployment verification and audit logging
```

Each phase is independent and can be tested before moving to the next.
