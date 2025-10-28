# Implementation Plan: Organization-Specific Email Domain Restrictions

## Overview
Implement multi-tenant email domain validation that allows each organization to configure:
- Allowed email domains (e.g., `rescuenet.net`, `humedica.org`)
- Whitelisted individual emails (e.g., specific developer emails)

## Current State
- Email domain validation is hardcoded in `login_register_page.dart:43-47`
- Only validates `rescuenet.net` domain
- Has hardcoded exception for `Michael.Wandtke@hey.com`
- Not multi-tenant aware

## Target Architecture
```
OrgConfig (updated)
  ↓
EmailDomainValidator (pure function)
  ↓
LoginPage (uses validator via Riverpod)
```

## Implementation Steps

### Step 1: Update OrgConfig Model
**File:** `lib/config/org_config.dart`

**Action:** Add two new fields to support email restrictions

**Changes:**
```dart
class OrgConfig {
  final String id;
  final String name;
  final String smallLogoAssetPath;
  final String largeLogoAssetPath;
  final Color? primaryColor;
  final FirebaseOptions productionFirebase;
  final FirebaseOptions stagingFirebase;
  final Map<String, dynamic> features;

  // NEW FIELDS
  /// List of allowed email domains for user registration.
  /// Empty list = no domain restrictions.
  /// Example: ['rescuenet.net', 'rescuenet.org']
  final List<String> allowedEmailDomains;

  /// List of individual emails that bypass domain restrictions.
  /// Useful for developers, admins, or special cases.
  /// Example: ['developer@gmail.com', 'admin@example.com']
  final List<String> whitelistedEmails;

  const OrgConfig({
    required this.id,
    required this.name,
    required this.smallLogoAssetPath,
    required this.largeLogoAssetPath,
    this.primaryColor,
    required this.productionFirebase,
    required this.stagingFirebase,
    this.features = const {},
    this.allowedEmailDomains = const [],
    this.whitelistedEmails = const [],
  });
}
```

**Rationale:**
- Default empty lists preserve backward compatibility
- Non-nullable with defaults (KISS principle)
- Clear documentation in comments

---

### Step 2: Update Organization Registry
**File:** `lib/config/org_registry.dart`

**Action:** Configure email restrictions for each organization

**Changes:**
```dart
final Map<String, OrgConfig> _orgConfigs = {
  'rescuenet': OrgConfig(
    id: 'rescuenet',
    name: 'RescueNet',
    smallLogoAssetPath: 'assets/images/LogoRN.png',
    largeLogoAssetPath: 'assets/images/rn_logo_big.png',
    productionFirebase: rescuenet_prod.RescuenetProductionFirebaseOptions.currentPlatform,
    stagingFirebase: rescuenet_staging.RescuenetStagingFirebaseOptions.currentPlatform,
    // NEW: Email restrictions
    allowedEmailDomains: ['rescuenet.net'],
    whitelistedEmails: ['Michael.Wandtke@hey.com'],
    features: {},
  ),
  'humedica': OrgConfig(
    id: 'humedica',
    name: 'Humedica',
    smallLogoAssetPath: 'assets/images/humedica_logo_small.png',
    largeLogoAssetPath: 'assets/images/humedica_logo_big.png',
    productionFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
    stagingFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
    // NEW: Email restrictions (add appropriate domains)
    allowedEmailDomains: ['humedica.org', 'humedica.de'],
    whitelistedEmails: [],
    features: {},
  ),
};
```

**Rationale:**
- Centralizes configuration
- Each org has independent control
- Preserves existing hardcoded exception

---

### Step 3: Create Email Domain Validator
**File:** `lib/utils/email_validator.dart` (NEW FILE)

**Action:** Create pure function for email domain validation

**Full Implementation:**
```dart
/// Pure function utilities for email validation.
///
/// Provides organization-aware email domain validation for registration flows.
class EmailDomainValidator {
  // Private constructor to prevent instantiation
  EmailDomainValidator._();

  /// Validates if an email is allowed based on domain restrictions and whitelist.
  ///
  /// Returns `null` if validation passes, error message if validation fails.
  ///
  /// Validation rules (in order):
  /// 1. If email is in whitelist → PASS
  /// 2. If allowedDomains is empty → PASS (no restrictions)
  /// 3. If email domain matches allowedDomains → PASS
  /// 4. Otherwise → FAIL
  ///
  /// Example:
  /// ```dart
  /// final error = EmailDomainValidator.validate(
  ///   'user@rescuenet.net',
  ///   allowedDomains: ['rescuenet.net'],
  ///   whitelistedEmails: ['admin@gmail.com'],
  /// );
  /// if (error != null) {
  ///   print('Validation failed: $error');
  /// }
  /// ```
  static String? validate(
    String email, {
    required List<String> allowedDomains,
    required List<String> whitelistedEmails,
  }) {
    // Normalize email
    final normalizedEmail = email.toLowerCase().trim();

    // Rule 1: Check whitelist first (highest priority)
    if (whitelistedEmails.any((e) => e.toLowerCase().trim() == normalizedEmail)) {
      return null; // Whitelisted emails always pass
    }

    // Rule 2: No restrictions if allowedDomains is empty
    if (allowedDomains.isEmpty) {
      return null; // No domain restrictions configured
    }

    // Rule 3: Validate email format
    if (!normalizedEmail.contains('@')) {
      return 'Invalid email format';
    }

    // Extract domain
    final parts = normalizedEmail.split('@');
    if (parts.length != 2 || parts[1].isEmpty) {
      return 'Invalid email format';
    }
    final domain = parts[1];

    // Rule 4: Check if domain is allowed
    final normalizedAllowedDomains = allowedDomains
        .map((d) => d.toLowerCase().trim())
        .toList();

    if (!normalizedAllowedDomains.contains(domain)) {
      // Build friendly error message
      if (allowedDomains.length == 1) {
        return 'Please use an email from ${allowedDomains.first}';
      } else {
        return 'Please use an email from: ${allowedDomains.join(', ')}';
      }
    }

    return null; // Validation passed
  }
}
```

**Rationale:**
- Pure function: no side effects, easy to test
- Clear validation rules documented
- Comprehensive error messages
- Case-insensitive matching (UX improvement)
- Whitelist takes precedence (flexibility)
- Private constructor prevents instantiation (utility class pattern)

**Testing:**
Create `test/utils/email_validator_test.dart` with basic tests:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rescuenet_warehouse/utils/email_validator.dart';

void main() {
  group('EmailDomainValidator', () {
    test('whitelisted email bypasses domain restrictions', () {
      expect(
        EmailDomainValidator.validate(
          'admin@gmail.com',
          allowedDomains: ['rescuenet.net'],
          whitelistedEmails: ['admin@gmail.com'],
        ),
        null,
      );
    });

    test('empty allowedDomains allows any email', () {
      expect(
        EmailDomainValidator.validate(
          'anyone@anywhere.com',
          allowedDomains: [],
          whitelistedEmails: [],
        ),
        null,
      );
    });

    test('valid domain passes validation', () {
      expect(
        EmailDomainValidator.validate(
          'user@rescuenet.net',
          allowedDomains: ['rescuenet.net'],
          whitelistedEmails: [],
        ),
        null,
      );
    });

    test('invalid domain fails validation', () {
      final result = EmailDomainValidator.validate(
        'user@invalid.com',
        allowedDomains: ['rescuenet.net'],
        whitelistedEmails: [],
      );
      expect(result, isNotNull);
      expect(result, contains('rescuenet.net'));
    });

    test('case insensitive matching', () {
      expect(
        EmailDomainValidator.validate(
          'User@RescueNet.NET',
          allowedDomains: ['rescuenet.net'],
          whitelistedEmails: [],
        ),
        null,
      );
    });
  });
}
```

---

### Step 4: Update Login Page
**File:** `lib/ui/auth_page/login_register_page.dart`

**Action:** Replace hardcoded validation with organization-aware validator

**Import Addition:**
```dart
import '../../utils/email_validator.dart';
import '../../config/org_provider.dart';
```

**Replace `createUserWithEmailAndPassword` method (lines 40-69):**
```dart
Future<void> createUserWithEmailAndPassword() async {
  print('pressed Register');
  try {
    // Get current organization configuration
    final orgConfig = ref.read(currentOrgProvider);

    // Validate email domain using organization's configuration
    final domainError = EmailDomainValidator.validate(
      _controllerEmail.text,
      allowedDomains: orgConfig.allowedEmailDomains,
      whitelistedEmails: orgConfig.whitelistedEmails,
    );

    if (domainError != null) {
      setState(() {
        errorMessage = domainError;
      });
      return;
    }

    // Proceed with registration
    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.createUserWithEmailAndPassword(
      email: _controllerEmail.text,
      password: _controllerPassword.text,
      name: _controllerEmail.text.split('@').first, // Use email prefix as name
    );

    // Registration successful, navigate to main app
    Navigator.pushNamed(context, routeContainerWithContent);
  } on AuthException catch (e) {
    setState(() {
      errorMessage = e.message;
    });
  } on FirebaseAuthException catch (e) {
    setState(() {
      errorMessage = e.message;
    });
  } catch (e) {
    print("Error in Login: $e");
  }
}
```

**Rationale:**
- Removes hardcoded domain check
- Uses organization config via Riverpod
- Centralized validation logic
- Cleaner error handling

---

### Step 5: Update CLAUDE.md Documentation
**File:** `CLAUDE.md`

**Action:** Document the new email restriction feature

**Add new section under "Multi-Tenant Configuration":**
```markdown
### Email Domain Restrictions

Each organization can restrict user registration by email domain.

**Configuration in `lib/config/org_registry.dart`:**
```dart
OrgConfig(
  id: 'rescuenet',
  name: 'RescueNet',
  allowedEmailDomains: ['rescuenet.net'],  // Restrict to these domains
  whitelistedEmails: ['dev@gmail.com'],     // Individual exceptions
  // ...
)
```

**Behavior:**
- Empty `allowedEmailDomains` = no restrictions
- `whitelistedEmails` bypass domain restrictions
- Case-insensitive matching
- Validation happens client-side during registration

**Implementation:**
- Validator: `lib/utils/email_validator.dart` (pure function)
- UI integration: `lib/ui/auth_page/login_register_page.dart`
- Config model: `lib/config/org_config.dart`
```

---

## Testing Checklist

### Manual Testing
- [ ] **RescueNet org**: Only `@rescuenet.net` emails can register
- [ ] **RescueNet org**: `Michael.Wandtke@hey.com` can register (whitelisted)
- [ ] **RescueNet org**: `user@gmail.com` cannot register
- [ ] **Humedica org**: Both `@humedica.org` and `@humedica.de` can register
- [ ] **Humedica org**: `user@rescuenet.net` cannot register
- [ ] **Case insensitivity**: `User@RescueNet.NET` works same as `user@rescuenet.net`
- [ ] **Error messages**: Clear and user-friendly

### Build Testing
- [ ] Run `dart analyze` - no new issues
- [ ] Run `flutter test` - all tests pass
- [ ] Build for both orgs without errors:
  ```bash
  flutter build web --dart-define=ORG=rescuenet --dart-define=ENV=staging
  flutter build web --dart-define=ORG=humedica --dart-define=ENV=staging
  ```

### Unit Testing
- [ ] Run `flutter test test/utils/email_validator_test.dart`
- [ ] All 5 test cases pass

---

## Rollout Strategy

### Phase 1: Implementation (This PR)
1. Update models and config
2. Create validator utility
3. Update UI to use validator
4. Add unit tests
5. Update documentation

### Phase 2: Future Enhancements (Separate PRs)
- Server-side validation via Cloud Functions
- Admin UI for managing allowed domains/whitelisted emails
- Audit logging for registration attempts

---

## Files Modified
- `lib/config/org_config.dart` - Add email restriction fields
- `lib/config/org_registry.dart` - Configure restrictions per org
- `lib/utils/email_validator.dart` - NEW: Pure validation function
- `lib/ui/auth_page/login_register_page.dart` - Use validator
- `test/utils/email_validator_test.dart` - NEW: Unit tests
- `CLAUDE.md` - Documentation update

## Files Deleted
None

---

## Agent Execution Instructions

This plan is structured for execution by Claude Code agents:

### Agent 1: Update Configuration
- Execute Step 1 (OrgConfig model)
- Execute Step 2 (Registry configuration)

### Agent 2: Create Validator
- Execute Step 3 (Create email_validator.dart)
- Create unit tests in test/utils/email_validator_test.dart

### Agent 3: Update UI
- Execute Step 4 (Update login_register_page.dart)
- Remove old validation code
- Add imports

### Agent 4: Validation & Documentation
- Run tests: `flutter test`
- Run analysis: `dart analyze`
- Execute Step 5 (Update CLAUDE.md)
- Perform manual testing checklist

---

## Success Criteria

✅ Each organization has independent email domain configuration
✅ Whitelist functionality works for special cases
✅ No hardcoded values in UI layer
✅ Pure function validator is reusable
✅ All existing functionality preserved
✅ Tests pass
✅ Documentation updated
✅ Multi-tenant architecture maintained

---

## Notes

- **SRP**: Each component has single responsibility (config, validation, UI)
- **KISS**: Simple pure function, no over-engineering
- **Modularity**: Validator can be reused elsewhere (admin panels, password reset, etc.)
- **No over-testing**: Basic unit tests only, manual testing for integration
- **Backward compatible**: Empty lists = no restrictions (safe for new orgs)
