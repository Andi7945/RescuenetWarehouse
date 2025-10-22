# Multi-Logo Support Implementation Plan

**Date:** 2025-10-22
**Author:** Claude Code
**Status:** Ready for Implementation
**Estimated Time:** ~2 hours

## Overview

Replace single nullable `logoAssetPath` in `OrgConfig` with two required logo paths (`smallLogoAssetPath`, `largeLogoAssetPath`) to support multi-tenant branding across all UI surfaces. Remove all hardcoded logo paths and fallback logic for a fail-fast, clean implementation.

## Goals

- ✅ Non-nullable logo paths in `OrgConfig` (compile-time safety)
- ✅ Remove all hardcoded logo references from UI
- ✅ Create reusable `OrgLogo` widget with size variants
- ✅ Fail-fast approach (no fallbacks, immediate errors)
- ✅ Clean code removal (delete deprecated PDF code)
- ✅ Single atomic commit to `micha-1` branch

## Philosophy

**Fail-Fast** - Misconfiguration should crash immediately in development
**No Legacy Code** - Complete removal of old `logoAssetPath` field
**Type Safety** - Non-nullable fields enforce complete configs
**Simple & Direct** - No fallbacks, no decision trees, no complexity

---

## Step-by-Step Implementation

### STEP 1: Update OrgConfig Data Model

**File:** `lib/config/org_config.dart`

**Task:** Replace single `logoAssetPath` with two required logo fields

**Action:**
```dart
@freezed
class OrgConfig with _$OrgConfig {
  const factory OrgConfig({
    required String id,
    required String name,
    required String smallLogoAssetPath,  // NEW: Required, for navigation/compact
    required String largeLogoAssetPath,  // NEW: Required, for login/prominent
    Color? primaryColor,
    required FirebaseOptions productionFirebase,
    required FirebaseOptions stagingFirebase,
    required Map<String, bool> features,
  }) = _OrgConfig;
}
```

**Changes:**
- ❌ REMOVE: `String? logoAssetPath` field (complete removal, no backward compat)
- ✅ ADD: `required String smallLogoAssetPath`
- ✅ ADD: `required String largeLogoAssetPath`

**Validation:**
- Both fields are required (non-nullable)
- No default values
- No optional parameters

---

### STEP 2: Update Organization Registry

**File:** `lib/config/org_registry.dart`

**Task:** Add logo paths to all org configurations

**Action for Rescuenet:**
```dart
'rescuenet': OrgConfig(
  id: 'rescuenet',
  name: 'Rescue Net',
  smallLogoAssetPath: 'assets/images/LogoRN.png',           // NEW
  largeLogoAssetPath: 'assets/images/rn_logo_big.png',      // NEW
  primaryColor: const Color(0xFF2196F3),
  productionFirebase: rescuenet_prod.RescuenetProductionFirebaseOptions.currentPlatform,
  stagingFirebase: rescuenet_staging.RescuenetStagingFirebaseOptions.currentPlatform,
  features: {},
),
```

**Action for Humedica:**
```dart
'humedica': OrgConfig(
  id: 'humedica',
  name: 'Humedica',
  smallLogoAssetPath: 'assets/images/humedica_logo.svg',    // NEW (fixed .png → .svg)
  largeLogoAssetPath: 'assets/images/humedica_logo.svg',    // NEW
  productionFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
  stagingFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
  features: {},
),
```

**Changes:**
- ❌ REMOVE: Any `logoAssetPath` references
- ✅ ADD: `smallLogoAssetPath` for both orgs
- ✅ ADD: `largeLogoAssetPath` for both orgs
- ✅ FIX: Humedica extension from `.png` to `.svg`

**Validation:**
- All asset paths point to existing files in `assets/images/`
- No nullable operators (`??`) used
- Both orgs have complete configs

---

### STEP 3: Regenerate Freezed Code

**Command:** `dart run build_runner build --delete-conflicting-outputs`

**Task:** Regenerate `org_config.freezed.dart` and `org_config.g.dart`

**Expected Output:**
- `lib/config/org_config.freezed.dart` updated with new constructor
- `lib/config/org_config.g.dart` updated with serialization
- No compilation errors

**Validation:**
```bash
flutter analyze
```
Should show compilation errors in files using old `logoAssetPath` - this is expected.

---

### STEP 4: Create OrgLogo Widget

**File:** `lib/widgets/org_logo.dart` (NEW FILE)

**Task:** Create reusable widget for organization-aware logo display

**Implementation:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescuenet_warehouse/config/org_provider.dart';

enum LogoSize {
  small,  // Navigation drawer, compact spaces
  large,  // Login screen, prominent display
}

/// Displays the current organization's logo with automatic size selection.
///
/// Uses the organization configuration from [currentOrgProvider] to select
/// the appropriate logo asset. Logos are required in org config - no fallbacks.
class OrgLogo extends ConsumerWidget {
  final LogoSize size;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;

  const OrgLogo({
    super.key,
    required this.size,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  });

  /// Convenience constructor for small logos (navigation, headers)
  const OrgLogo.small({
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.centerLeft,
    this.width,
    this.height,
  }) : size = LogoSize.small;

  /// Convenience constructor for large logos (login, splash)
  const OrgLogo.large({
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.width,
    this.height,
  }) : size = LogoSize.large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final org = ref.watch(currentOrgProvider);

    // Direct path selection - no fallbacks
    final logoPath = size == LogoSize.small
        ? org.smallLogoAssetPath
        : org.largeLogoAssetPath;

    // Fail loudly if asset not found
    return Image.asset(
      logoPath,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
    );
  }
}
```

**Key Design Decisions:**
- ✅ Pure `ConsumerWidget` - reads from Riverpod provider
- ✅ Enum for size selection (type-safe)
- ✅ Named constructors (`.small()`, `.large()`) for convenience
- ✅ No `errorBuilder` - let Flutter crash with clear error
- ✅ No fallbacks - configuration errors surface immediately
- ✅ Flexible styling via optional parameters

**Validation:**
- Widget compiles without errors
- Exports enum `LogoSize` for external use if needed
- No dependencies beyond Flutter, Riverpod, and config

---

### STEP 5: Migrate Navigation Drawer

**File:** `lib/ui/rescue_navigation_drawer.dart`

**Task:** Replace hardcoded logo with `OrgLogo.small()`

**Find:** Line ~21
```dart
const SizedBox(
  height: 80,
  child: DrawerHeader(
    child: Image(
      image: AssetImage('assets/images/LogoRN.png'),
      alignment: Alignment.centerLeft,
    ),
  ),
)
```

**Replace with:**
```dart
const SizedBox(
  height: 80,
  child: DrawerHeader(
    child: OrgLogo.small(
      alignment: Alignment.centerLeft,
    ),
  ),
)
```

**Add import:**
```dart
import 'package:rescuenet_warehouse/widgets/org_logo.dart';
```

**Validation:**
- Remove `AssetImage('assets/images/LogoRN.png')` reference
- Widget remains `const` if already a `ConsumerWidget`
- Visual layout unchanged (same height, alignment)

---

### STEP 6: Migrate Login Page

**File:** `lib/ui/auth_page/login_register_page.dart`

**Task 6A:** Convert to `ConsumerWidget`

**Find:** Class declaration
```dart
class LoginRegisterPage extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

**Replace with:**
```dart
class LoginRegisterPage extends ConsumerWidget {
  const LoginRegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ... (rest unchanged)
  }
}
```

**Add import:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

**Task 6B:** Replace hardcoded logo

**Find:** `_logo()` method (line ~73)
```dart
Widget _logo() {
  return const DrawerHeader(
    child: Image(image: AssetImage('assets/images/rn_logo_big.png')),
  );
}
```

**Replace with:**
```dart
Widget _logo() {
  return const DrawerHeader(
    child: OrgLogo.large(),
  );
}
```

**Add import:**
```dart
import 'package:rescuenet_warehouse/widgets/org_logo.dart';
```

**Validation:**
- Class extends `ConsumerWidget`
- `build` method has `WidgetRef ref` parameter
- No `AssetImage('assets/images/rn_logo_big.png')` references
- Visual appearance unchanged

---

### STEP 7: Migrate Forgot Password Page

**File:** `lib/ui/auth_page/auth_forgot_password_page.dart`

**Task 7A:** Convert to `ConsumerWidget`

**Find:** Class declaration
```dart
class AuthForgotPasswordPage extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

**Replace with:**
```dart
class AuthForgotPasswordPage extends ConsumerWidget {
  const AuthForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ... (rest unchanged)
  }
}
```

**Add import:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

**Task 7B:** Replace hardcoded logo

**Find:** `_logo()` method (line ~42)
```dart
Widget _logo() {
  return const DrawerHeader(
    child: Image(
      image: AssetImage('assets/images/LogoRN.png'),
    ),
  );
}
```

**Replace with:**
```dart
Widget _logo() {
  return const DrawerHeader(
    child: OrgLogo.small(),
  );
}
```

**Add import:**
```dart
import 'package:rescuenet_warehouse/widgets/org_logo.dart';
```

**Validation:**
- Class extends `ConsumerWidget`
- `build` method has `WidgetRef ref` parameter
- No `AssetImage('assets/images/LogoRN.png')` references
- Visual appearance unchanged

---

### STEP 8: Update Print Context Provider

**File:** `lib/features/printing/domain/print_context_provider.dart`

**Task:** Remove fallback logic, use `largeLogoAssetPath` directly

**Find:** Line ~42
```dart
logoAssetPath: org.logoAssetPath ?? 'rn_logo_big.png',
```

**Replace with:**
```dart
logoAssetPath: org.largeLogoAssetPath,
```

**Changes:**
- ❌ REMOVE: `?? 'rn_logo_big.png'` fallback
- ❌ REMOVE: Reference to old `logoAssetPath` field
- ✅ USE: Non-nullable `largeLogoAssetPath` field

**Validation:**
- No nullable operators in logo path assignment
- PDFs use large logo variant
- No compilation errors

---

### STEP 9: Delete Deprecated Code

**File:** `lib/pdf/pdf_header_row.dart`

**Task:** Delete deprecated PDF file

**Verification before deletion:**
```bash
grep -r "pdf_header_row" lib/ --include="*.dart"
```

**Expected:** No imports or references (file marked as deprecated)

**Action:** Delete file completely
```bash
rm lib/pdf/pdf_header_row.dart
```

**Validation:**
- File no longer exists
- No compilation errors after deletion
- New PDF generation in `lib/features/printing/` unaffected

---

### STEP 10: Verify Complete Migration

**Task:** Ensure no hardcoded logo paths remain

**Check for old logo references:**
```bash
# Should only show asset paths in org_registry.dart
grep -r "LogoRN.png" lib/ --include="*.dart"

# Should only show asset paths in org_registry.dart
grep -r "rn_logo_big.png" lib/ --include="*.dart"

# Should show no results (old field removed)
grep -r "logoAssetPath\?" lib/ --include="*.dart"

# Should only show org_registry.dart (asset path strings, not fallbacks)
grep -r "?? .*logo" lib/ --include="*.dart"
```

**Expected Results:**
- Logo path strings only in `org_registry.dart`
- No nullable `logoAssetPath?` references
- No fallback operators `??` with logo paths

**Validation:**
```bash
flutter analyze
```
Should show **zero errors** and **zero warnings**.

---

### STEP 11: Update Documentation

**File:** `CLAUDE.md`

**Task:** Add logo configuration documentation

**Location:** In "## Multi-Tenant Configuration" section, add new subsection

**Content:**
```markdown
### Logo Configuration

Each organization MUST provide two logo variants:
- **smallLogoAssetPath**: Compact logo for navigation drawer, headers (recommended: 80px height)
- **largeLogoAssetPath**: Full logo for login screens, PDFs, prominent display

Both fields are required (non-nullable) in `OrgConfig`. No fallbacks exist - missing assets will cause immediate failures in development.

**Usage in UI:**
```dart
// Small logo (navigation, headers)
const OrgLogo.small()

// Large logo (login, splash, prominent display)
const OrgLogo.large()
```

**Logo widget automatically:**
- Reads current org from `currentOrgProvider`
- Selects appropriate size variant
- No fallback logic - fails fast if misconfigured
```

**Validation:**
- Documentation matches implementation
- Examples are accurate
- Placed in appropriate section

---

### STEP 12: Build & Validate

**Task:** Regenerate code and verify compilation

**Commands:**
```bash
# Clean and regenerate all generated code
dart run build_runner build --delete-conflicting-outputs

# Verify no errors
flutter analyze

# Check Riverpod linting
dart run custom_lint
```

**Expected:**
- Build runner completes successfully
- Zero analyzer errors
- Zero analyzer warnings
- Zero custom lint errors

**If errors occur:**
- Check all imports are correct
- Verify all `ConsumerWidget` conversions
- Ensure all logo path references updated

---

### STEP 13: Test Rescuenet Configuration

**Task:** Visual validation with Rescuenet org

**Command:**
```bash
flutter run -d chrome --dart-define=ORG=rescuenet --dart-define=ENV=staging
```

**Manual Testing Checklist:**
- [ ] App launches without errors
- [ ] Navigation drawer shows small Rescuenet logo (`LogoRN.png`)
- [ ] Login page shows large Rescuenet logo (`rn_logo_big.png`)
- [ ] Forgot password page shows small Rescuenet logo
- [ ] Logo alignment correct (left-aligned in drawer, centered on login)
- [ ] No console errors about missing assets

**PDF Testing:**
- [ ] Generate any PDF (packing list, label, or summary)
- [ ] Verify large Rescuenet logo appears in PDF header
- [ ] No errors in PDF generation

---

### STEP 14: Test Humedica Configuration

**Task:** Visual validation with Humedica org

**Command:**
```bash
flutter run -d chrome --dart-define=ORG=humedica --dart-define=ENV=staging
```

**Manual Testing Checklist:**
- [ ] App launches without errors
- [ ] Navigation drawer shows Humedica logo (`humedica_logo.svg`)
- [ ] Login page shows Humedica logo
- [ ] Forgot password page shows Humedica logo
- [ ] SVG logo renders correctly in all locations
- [ ] No console errors about missing assets

**PDF Testing:**
- [ ] Generate any PDF
- [ ] Verify Humedica logo appears in PDF header
- [ ] No errors in PDF generation

---

### STEP 15: Test Failure Scenario (Optional QA)

**Task:** Verify fail-fast behavior

**Action:** Temporarily break configuration
```dart
// In org_registry.dart, temporarily change path
smallLogoAssetPath: 'assets/images/INVALID_PATH.png',
```

**Expected Behavior:**
- App crashes with clear Flutter error
- Error message shows exact missing asset path
- Error points to `Image.asset()` call in `OrgLogo` widget

**After validation:**
- Revert change to correct path
- Verify app works again

**Rationale:** Confirms no silent failures, errors are visible immediately

---

### STEP 16: Run Automated Tests

**Task:** Ensure existing tests still pass

**Command:**
```bash
flutter test
```

**Expected:**
- All existing tests pass
- No new test failures
- Widget tests using auth pages still work

**Note:** We don't add new tests for `OrgLogo` widget since it's a simple presentation component that directly wraps `Image.asset()`. Visual testing (Steps 13-14) provides sufficient validation.

---

### STEP 17: Commit Changes

**Task:** Single atomic commit with all changes

**Pre-commit checklist:**
- [ ] All files modified/created/deleted as planned
- [ ] `flutter analyze` passes
- [ ] Both org configs tested visually
- [ ] Documentation updated

**Commit:**
```bash
git add .
git commit -m "feat: add multi-logo support with small/large variants

- Replace single nullable logoAssetPath with required small/large variants
- Create OrgLogo widget for automatic org-aware logo display
- Migrate navigation drawer, login, and forgot password pages
- Update PDF generation to use large logo variant
- Remove deprecated pdf_header_row.dart
- Update CLAUDE.md documentation

BREAKING CHANGE: OrgConfig.logoAssetPath removed, replaced with
smallLogoAssetPath and largeLogoAssetPath (both required)"
```

**Validation:**
- Commit message follows conventional commits format
- Breaking change noted in commit message
- All changes in single atomic commit

---

### STEP 18: Push & Deploy

**Task:** Push to remote and trigger deployment

**Command:**
```bash
git push origin micha-1
```

**Expected:**
- Push succeeds
- GitHub Actions workflow triggers (`.github/workflows/firebase-hosting-merge.yml`)
- Deployment to rescuenet-7733b (production) starts

**Monitor:**
- Check GitHub Actions tab for workflow status
- Wait for deployment to complete
- Check Firebase Hosting for successful deployment

---

### STEP 19: Production Validation

**Task:** Verify deployment in production

**Actions:**
- [ ] Visit production URL
- [ ] Verify login page shows correct logo
- [ ] Login and verify navigation drawer logo
- [ ] Generate a PDF and verify logo
- [ ] Test password reset flow (logo visible)
- [ ] No console errors in browser devtools

**If issues found:**
- Check asset paths in deployed bundle
- Verify Firebase Hosting served all assets
- Check browser network tab for 404s

---

## Files Modified Summary

### Modified (7 files)
1. `lib/config/org_config.dart` - Add small/large logo fields, remove old field
2. `lib/config/org_registry.dart` - Add logo paths for both orgs
3. `lib/ui/rescue_navigation_drawer.dart` - Use `OrgLogo.small()`
4. `lib/ui/auth_page/login_register_page.dart` - Convert to ConsumerWidget, use `OrgLogo.large()`
5. `lib/ui/auth_page/auth_forgot_password_page.dart` - Convert to ConsumerWidget, use `OrgLogo.small()`
6. `lib/features/printing/domain/print_context_provider.dart` - Use `largeLogoAssetPath` directly
7. `CLAUDE.md` - Document logo configuration

### Created (1 file)
8. `lib/widgets/org_logo.dart` - New reusable logo widget

### Deleted (1 file)
9. `lib/pdf/pdf_header_row.dart` - Remove deprecated code

**Total:** 9 file operations

---

## Acceptance Criteria

### Functional
- ✅ `OrgConfig` has required `smallLogoAssetPath` and `largeLogoAssetPath` fields
- ✅ All UI components use `OrgLogo` widget
- ✅ No hardcoded logo paths in code
- ✅ PDFs use organization's large logo
- ✅ Both Rescuenet and Humedica logos display correctly
- ✅ No fallback logic anywhere

### Technical
- ✅ `flutter analyze` passes with zero warnings
- ✅ All existing tests pass
- ✅ Code follows SRP (OrgLogo has single responsibility)
- ✅ KISS principle applied (no unnecessary complexity)
- ✅ Type-safe with enum for logo sizes

### Quality
- ✅ Fail-fast behavior verified (missing assets crash clearly)
- ✅ Documentation updated and accurate
- ✅ No deprecated code remains
- ✅ Atomic commit with clear message

---

## Rollback Plan

**If issues found in production:**

```bash
# Revert the commit
git revert HEAD

# Push revert
git push origin micha-1

# CI/CD will automatically deploy reverted version
```

**Alternative:** Fix forward by addressing specific issue

---

## Notes for Claude Code Agent

### Agent Execution Strategy

**Use general-purpose agent for:**
- Each step should be executed sequentially (steps depend on previous)
- Step 3 (build_runner) must complete before Step 4
- Steps 5-8 can be done in parallel if agent supports it
- Steps 13-14 require manual validation (agent should prompt user)

### Key Principles to Follow

**KISS (Keep It Simple, Stupid):**
- Direct logo path selection, no conditionals
- No error builders, let Flutter handle failures
- Minimal abstraction (just one widget)

**SRP (Single Responsibility Principle):**
- `OrgLogo` widget: display org-aware logo (one job)
- `OrgConfig`: hold configuration (one job)
- No mixing of concerns

**Modularity:**
- Widget is self-contained, zero external deps beyond Riverpod
- Can be reused anywhere in app
- Easy to extend (e.g., add dark mode logos later)

**Don't Overtest:**
- No unit tests for simple presentation widget
- Visual testing sufficient for UI components
- Existing integration tests cover user flows

**Pure Functions:**
- Logo path selection is pure: `size == LogoSize.small ? small : large`
- No side effects in widget
- Deterministic output for given org + size

### Common Pitfalls to Avoid

❌ Don't add fallback logic
❌ Don't make fields nullable
❌ Don't add error builders
❌ Don't create intermediate commits
❌ Don't add unnecessary tests
❌ Don't overthink - keep it simple

✅ Do fail fast
✅ Do use non-nullable fields
✅ Do test visually with both orgs
✅ Do commit atomically
✅ Do follow the plan exactly

---

## Success Metrics

**Time to Complete:** ~2 hours (as estimated)
**Code Quality:** Zero analyzer warnings, clean commit history
**Visual Quality:** Logos display correctly for both orgs
**Reliability:** Fail-fast behavior prevents silent errors
**Maintainability:** Clean, simple code with no legacy baggage

---

## Completion Checklist

- [ ] All 19 steps completed
- [ ] Zero compilation errors
- [ ] Zero analyzer warnings
- [ ] Both orgs tested visually
- [ ] PDFs generate correctly
- [ ] Documentation updated
- [ ] Committed and pushed
- [ ] Deployed successfully
- [ ] Production validated

**Plan Status:** ✅ Ready for Execution
