import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// Configuration for an organization in the multi-tenant system.
///
/// Each organization has:
/// - Unique identifier and display name
/// - Required branding (small and large logos, optional primary color)
/// - Separate Firebase projects for production and staging
/// - Optional feature flags
/// - Email domain restrictions for user registration
class OrgConfig {
  final String id;
  final String name;
  final String smallLogoAssetPath;
  final String largeLogoAssetPath;
  final Color? primaryColor;
  final FirebaseOptions productionFirebase;
  final FirebaseOptions stagingFirebase;
  final Map<String, dynamic> features;

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
