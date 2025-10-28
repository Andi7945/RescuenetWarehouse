# Single-Config Build Implementation Plan

## Problem Statement

Currently, every Flutter build contains ALL Firebase configurations (rescuenet-testing, rescuenet-7733b, humedica-e767c) regardless of which org/env is being built. This violates the Principle of Least Privilege and creates security/safety risks:

- **Security Risk**: Every build ships with API keys for all Firebase projects
- **Safety Risk**: Wrong deployment is possible (just caught by verification, not prevented)
- **The Original Bug**: Humedica build could be deployed to RescueNet because it contained RescueNet credentials

## Solution Overview

Implement build-time code generation to ensure each build contains **only** the Firebase config for its target org/env.

**Key Insight**: We already build separately for each org/env, so there's no loss of flexibility. We just need to generate the right imports before building.

## Architecture Principles

- **Security First**: Only include credentials needed for the target Firebase project
- **Physical Safety**: Make wrong deployments impossible, not just caught
- **SRP**: Generation script does one thing - create org_registry.dart from template
- **KISS**: Simple bash script with string replacement, no complex tools needed
- **Pure Functions**: Template + inputs → generated file (deterministic, testable)
- **Fast Startup**: Simple implementation, ship quickly with better security

## Benefits

**Before** (Multi-Config):
- ❌ All credentials in every build
- ❌ Wrong deployment possible (just caught)
- ⚠️ Verification checks "expected config exists"

**After** (Single-Config):
- ✅ Only needed credentials in build
- ✅ Wrong deployment IMPOSSIBLE (not just caught)
- ✅ Verification checks "ONLY expected config exists"
- ✅ Original bug would have been impossible
- ✅ Principle of Least Privilege

## Implementation Phases

### Phase 1: Template System Foundation

**Goal**: Create template and generation script

**File**: `lib/config/org_registry.dart.template`

Create template from current `org_registry.dart` with placeholders:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'org_config.dart';
// FIREBASE_IMPORTS_PLACEHOLDER

/// Registry of all available organizations in the multi-tenant system.
///
/// This file is GENERATED at build time by scripts/lib/generate_org_registry.sh
/// DO NOT EDIT - Edit org_registry.dart.template instead
///
/// Only the Firebase config for the target org/env is included for security.

/// Private map containing organization configuration
final Map<String, OrgConfig> _orgConfigs = {
  // ORG_CONFIG_PLACEHOLDER
};

/// Get organization config by ID.
///
/// Throws [ArgumentError] if the organization is not found.
OrgConfig getOrgConfig(String orgId) {
  final config = _orgConfigs[orgId];
  if (config == null) {
    throw ArgumentError(
      'Unknown organization: $orgId. Available: ${_orgConfigs.keys.join(", ")}',
    );
  }
  return config;
}

/// Get Firebase options for specific org and environment.
///
/// Throws [ArgumentError] if the organization is not found or environment is invalid.
///
/// Valid environments: 'production', 'prod', 'staging', 'stage'
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
      throw ArgumentError(
        'Invalid environment: $environment. Use "production" or "staging".',
      );
  }
}

/// Get all available organization IDs.
List<String> getAvailableOrgs() => _orgConfigs.keys.toList();
```

**File**: `scripts/lib/generate_org_registry.sh`

Pure function that generates org_registry.dart:

```bash
#!/bin/bash
# Code generation for single-config builds
# Pure function: (org, env, template) -> generated file

set -e

generate_org_registry() {
  local org="$1"
  local env="$2"
  local template_path="$3"
  local output_path="$4"

  # Validate inputs
  if [ -z "$org" ] || [ -z "$env" ]; then
    echo "❌ Error: org and env required"
    return 1
  fi

  if [ ! -f "$template_path" ]; then
    echo "❌ Error: Template not found: $template_path"
    return 1
  fi

  # Generate imports based on org/env
  local firebase_imports=""
  local org_config=""

  case "$org" in
    rescuenet)
      if [ "$env" = "production" ]; then
        firebase_imports="import 'firebase_options_rescuenet_production.dart' as rescuenet_prod;"
        org_config="  'rescuenet': OrgConfig(
    id: 'rescuenet',
    name: 'RescueNet',
    smallLogoAssetPath: 'assets/images/LogoRN.png',
    largeLogoAssetPath: 'assets/images/rn_logo_big.png',
    productionFirebase: rescuenet_prod.RescuenetProductionFirebaseOptions.currentPlatform,
    stagingFirebase: rescuenet_prod.RescuenetProductionFirebaseOptions.currentPlatform,
    features: {},
    allowedEmailDomains: ['rescuenet.net'],
    whitelistedEmails: ['Michael.Wandtke@hey.com'],
  ),"
      else
        firebase_imports="import 'firebase_options_rescuenet_testing.dart' as rescuenet_staging;"
        org_config="  'rescuenet': OrgConfig(
    id: 'rescuenet',
    name: 'RescueNet',
    smallLogoAssetPath: 'assets/images/LogoRN.png',
    largeLogoAssetPath: 'assets/images/rn_logo_big.png',
    productionFirebase: rescuenet_staging.RescuenetStagingFirebaseOptions.currentPlatform,
    stagingFirebase: rescuenet_staging.RescuenetStagingFirebaseOptions.currentPlatform,
    features: {},
    allowedEmailDomains: ['rescuenet.net'],
    whitelistedEmails: ['Michael.Wandtke@hey.com'],
  ),"
      fi
      ;;

    humedica)
      firebase_imports="import 'firebase_options_humedica_prod.dart' as humedica_prod;"
      org_config="  'humedica': OrgConfig(
    id: 'humedica',
    name: 'Humedica',
    smallLogoAssetPath: 'assets/images/humedica_logo_small.png',
    largeLogoAssetPath: 'assets/images/humedica_logo_big.png',
    productionFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
    stagingFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
    features: {},
    allowedEmailDomains: ['humedica.org', 'rescuenet.net'],
    whitelistedEmails: ['Michael.Wandtke@hey.com'],
  ),"
      ;;

    *)
      echo "❌ Error: Unknown org: $org"
      return 1
      ;;
  esac

  # Generate file from template
  cat "$template_path" | \
    sed "s|// FIREBASE_IMPORTS_PLACEHOLDER|$firebase_imports|" | \
    sed "s|  // ORG_CONFIG_PLACEHOLDER|$org_config|" \
    > "$output_path"

  echo "✅ Generated org_registry.dart for $org/$env"
  echo "   Imports: $(echo "$firebase_imports" | wc -l | tr -d ' ') Firebase config(s)"
  echo "   Output: $output_path"
}

# If called directly (not sourced), execute generation
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  if [ $# -ne 4 ]; then
    echo "Usage: $0 <org> <env> <template_path> <output_path>"
    echo "Example: $0 rescuenet production lib/config/org_registry.dart.template lib/config/org_registry.dart"
    exit 1
  fi

  generate_org_registry "$1" "$2" "$3" "$4"
fi
```

**Testing checklist**:
- [ ] Template created with correct placeholders
- [ ] Generation script is executable
- [ ] Can generate for rescuenet/production
- [ ] Can generate for rescuenet/staging
- [ ] Can generate for humedica/production
- [ ] Generated files have correct imports (only one)
- [ ] Generated files have correct org config (only one)
- [ ] Script fails gracefully for unknown org

---

### Phase 2: Integrate into Build Process

**Goal**: Generate org_registry.dart before each build

**File**: `scripts/build_org.sh`

Add generation step before Flutter build:

```bash
# After validation, before cleaning build directory:

echo "📝 Generating org_registry.dart for $ORG/$ENV..."

# Backup current org_registry.dart if it exists and isn't already generated
BACKUP_FILE="lib/config/org_registry.dart.backup"
if [ -f "lib/config/org_registry.dart" ] && ! grep -q "GENERATED at build time" "lib/config/org_registry.dart"; then
  echo "   Backing up existing org_registry.dart..."
  cp lib/config/org_registry.dart "$BACKUP_FILE"
fi

# Generate single-config org_registry.dart
./scripts/lib/generate_org_registry.sh \
  "$ORG" \
  "$ENV" \
  "lib/config/org_registry.dart.template" \
  "lib/config/org_registry.dart"

if [ $? -ne 0 ]; then
  echo "❌ Failed to generate org_registry.dart"
  exit 1
fi

# Continue with existing build process...
```

**File**: `.gitignore`

Add generated file to gitignore:

```
# Generated at build time
lib/config/org_registry.dart
```

**File**: `lib/config/org_registry.dart.backup`

Keep original multi-config version as backup for reference.

**Testing checklist**:
- [ ] Build script generates org_registry.dart before building
- [ ] Generated file contains only target Firebase config
- [ ] Build succeeds with generated file
- [ ] org_registry.dart is in .gitignore
- [ ] Backup is created on first run
- [ ] Subsequent builds work correctly

---

### Phase 3: Enhance Verification (Stricter Checks)

**Goal**: Update verification to assert "ONLY expected config exists"

**File**: `scripts/lib/verify_build.sh`

Add new verification function:

```bash
# Verify bundle contains ONLY the expected project ID (single-config builds)
# Returns: 0 (success) or 1 (failure)
# This is stricter than verify_bundle_project_id - ensures single-config builds
verify_bundle_single_config() {
  local bundle_path="$1"
  local expected_id="$2"

  # Get all project IDs from bundle
  local all_ids=$(extract_all_project_ids_from_bundle "$bundle_path")
  local id_count=$(echo "$all_ids" | wc -l | tr -d ' ')

  if [ -z "$all_ids" ]; then
    echo "❌ Error: Could not extract any project IDs from bundle"
    echo "   Bundle may be corrupted or missing Firebase configuration"
    return 1
  fi

  # Check if expected ID exists
  if ! check_project_id_in_bundle "$bundle_path" "$expected_id"; then
    echo "❌ PROJECT ID NOT FOUND!"
    echo "   Expected: $expected_id"
    echo "   Found in bundle:"
    echo "$all_ids" | sed 's/^/     - /'
    return 1
  fi

  # Strict check: Verify ONLY expected ID exists (single-config build)
  if [ "$id_count" -ne 1 ]; then
    echo "⚠️  WARNING: Multi-config build detected!"
    echo "   Expected: Only $expected_id"
    echo "   Found $id_count configs:"
    echo "$all_ids" | sed 's/^/     - /'
    echo ""
    echo "   This build contains multiple Firebase configurations."
    echo "   For security, builds should contain only the target config."
    return 1
  fi

  # Success: Single config, correct project ID
  echo "✅ Project ID verified: $expected_id (single-config build)"
  return 0
}
```

**File**: `scripts/build_org.sh`

Update to use stricter verification:

```bash
# NEW: Use strict single-config verification
echo "🔍 Verifying build configuration..."
if ! verify_bundle_single_config "build/web/main.dart.js" "$EXPECTED_PROJECT_ID"; then
  echo ""
  echo "❌ BUILD VERIFICATION FAILED!"
  echo "The compiled bundle does not pass single-config verification."
  echo "This build is NOT safe to deploy."
  exit 1
fi
```

**Testing checklist**:
- [ ] Verification passes for single-config builds
- [ ] Verification fails for multi-config builds
- [ ] Clear error messages explain what's wrong
- [ ] Build script uses strict verification

---

### Phase 4: Update Documentation

**File**: `CLAUDE.md`

Update the "Deployment Safety Features" section:

```markdown
### Deployment Safety Features

All deployment scripts include automatic verification:
- ✅ **Single-config builds**: Each build contains only its target Firebase config
- ✅ Compiled bundle verified for correct project ID
- ✅ Build manifest tracks org, env, timestamp, git commit
- ✅ Deployment blocked if manifest doesn't match
- ✅ Stale builds (>48h) generate warnings
- ✅ Production deploys require typing exact project ID
- ✅ All deployments logged to `deployments.log`

**Security Model:**
1. Build-time code generation creates `org_registry.dart` with only target Firebase config
2. Flutter tree-shaking removes unused Firebase configs
3. Each build physically cannot connect to wrong Firebase projects
4. Verification confirms ONLY expected config exists in bundle
5. Wrong deployments are impossible, not just caught

**Verification Process:**
1. Build script generates single-config `org_registry.dart` from template
2. Flutter builds with only target Firebase config included
3. Verifies compiled JavaScript contains ONLY correct project ID
4. Creates `.build-manifest.json` with metadata
5. Deploy script re-verifies manifest and bundle before deployment
6. Logs deployment to audit trail

**If verification fails:**
- Build will abort with clear error message
- Shows expected vs actual project ID(s)
- If multiple configs found, explains security risk
- Build directory will not be created
- Deployment will be blocked
```

**File**: `lib/config/org_registry.dart.template`

Add header comment explaining the system:

```dart
/// DO NOT EDIT THIS FILE MANUALLY
///
/// This file is GENERATED at build time from org_registry.dart.template
/// by scripts/lib/generate_org_registry.sh
///
/// Each build contains only the Firebase configuration for its target org/env.
/// This ensures security (principle of least privilege) and safety (wrong
/// deployments are physically impossible).
///
/// To modify the organization registry:
/// 1. Edit lib/config/org_registry.dart.template
/// 2. Run build script: ./scripts/build_org.sh <org> <env>
/// 3. Generated file is created automatically
```

**Testing checklist**:
- [ ] CLAUDE.md updated with single-config security model
- [ ] Template has clear "DO NOT EDIT" warning
- [ ] Documentation explains why this is more secure

---

### Phase 5: Transition & Cleanup

**Goal**: Clean up old files and ensure smooth transition

**Tasks**:

1. **Move current org_registry.dart to backup**:
   ```bash
   mv lib/config/org_registry.dart lib/config/org_registry.dart.backup
   ```

2. **Add org_registry.dart to .gitignore**:
   ```
   # Generated at build time - do not commit
   lib/config/org_registry.dart
   ```

3. **Keep backup for reference** (committed to git):
   ```bash
   # Backup is useful for understanding the original multi-config structure
   git add lib/config/org_registry.dart.backup
   ```

4. **Update README or CLAUDE.md** with migration notes:
   ```markdown
   ### Build System Changes (2025-10-28)

   The app now uses single-config builds for security:
   - `org_registry.dart` is generated at build time (don't edit directly)
   - Edit `org_registry.dart.template` to modify org configurations
   - Each build contains only its target Firebase config
   - See `org_registry.dart.backup` for original multi-config version
   ```

**Testing checklist**:
- [ ] Original file backed up
- [ ] Generated file in .gitignore
- [ ] Backup file committed to git
- [ ] Migration documented
- [ ] No accidental commits of generated file

**Note**: Comprehensive validation will happen automatically on first real usage when you run `./scripts/build_org.sh` for an actual build. The verification scripts will confirm single-config builds and catch any issues immediately.

---

## Implementation Checklist

### Phase 1: Template System Foundation
- [ ] Create `lib/config/org_registry.dart.template` from current file
- [ ] Add placeholders: `// FIREBASE_IMPORTS_PLACEHOLDER` and `// ORG_CONFIG_PLACEHOLDER`
- [ ] Create `scripts/lib/generate_org_registry.sh`
- [ ] Implement `generate_org_registry()` function
- [ ] Add case statements for rescuenet/production, rescuenet/staging, humedica/production
- [ ] Make script executable: `chmod +x scripts/lib/generate_org_registry.sh`
- [ ] Test generation for all org/env combinations
- [ ] Verify generated files have correct imports

### Phase 2: Integrate into Build Process
- [ ] Update `scripts/build_org.sh` to call generation script
- [ ] Add backup logic for existing org_registry.dart
- [ ] Test build succeeds with generated file
- [ ] Add `lib/config/org_registry.dart` to `.gitignore`
- [ ] Commit template and backup file

### Phase 3: Enhance Verification
- [ ] Add `verify_bundle_single_config()` to `verify_build.sh`
- [ ] Update build script to use strict verification
- [ ] Test verification passes for single-config
- [ ] Test verification fails for multi-config
- [ ] Verify error messages are clear

### Phase 4: Update Documentation
- [ ] Update `CLAUDE.md` deployment safety section
- [ ] Add "DO NOT EDIT" warning to template
- [ ] Document security model and benefits
- [ ] Add migration notes

### Phase 5: Transition & Cleanup
- [ ] Move original org_registry.dart to .backup
- [ ] Verify .gitignore is correct
- [ ] Commit backup file
- [ ] Document changes

**Validation happens automatically on first real usage** - no separate testing phase needed.

---

## Success Criteria

✅ **Security**: Each build contains only credentials for its target Firebase project
✅ **Safety**: Wrong deployments are physically impossible (not just caught)
✅ **Verification**: Strict checks confirm single-config builds
✅ **Maintainability**: Template system is easy to understand and modify
✅ **Speed**: Build process remains fast (generation adds <1 second)
✅ **Simplicity**: Uses simple bash and sed, no complex tools
✅ **Backward Compatible**: Backup of original multi-config version preserved

---

## Rollout Plan

1. Implement all 5 phases (no separate testing phase needed)
2. First real usage validates the implementation:
   - Run `./scripts/build_org.sh rescuenet staging`
   - Verification scripts will confirm single-config build
   - Any issues caught immediately with clear error messages
3. Once staging build succeeds, use for production with confidence
4. Original bug is now physically impossible

---

## Future Enhancements (Not in Scope)

- Dart-based generation script (instead of bash) for better maintainability
- Automated testing in CI/CD
- Generate other config files (firebaserc) using same system
- Runtime verification that only expected Firebase project is accessible

---

## Notes for Claude Code Execution

This plan can be executed by subagents with these commands:

**Phase 1:**
```
Create template system: org_registry.dart.template and generate_org_registry.sh script
```

**Phase 2:**
```
Integrate code generation into build_org.sh script
```

**Phase 3:**
```
Add strict single-config verification to verify_build.sh
```

**Phase 4:**
```
Update documentation in CLAUDE.md with new security model
```

**Phase 5:**
```
Clean up and transition to generated file system
```

Each phase is independent and builds on the previous. Validation happens automatically on first real build - no separate testing phase needed. The implementation follows security best practices while maintaining simplicity and speed.
