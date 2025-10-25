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
