import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// Configuration for an organization in the multi-tenant system.
///
/// Each organization has:
/// - Unique identifier and display name
/// - Optional branding (logo, primary color)
/// - Separate Firebase projects for production and staging
/// - Optional feature flags
class OrgConfig {
  final String id;
  final String name;
  final String? logoAssetPath;
  final Color? primaryColor;
  final FirebaseOptions productionFirebase;
  final FirebaseOptions stagingFirebase;
  final Map<String, dynamic> features;

  const OrgConfig({
    required this.id,
    required this.name,
    this.logoAssetPath,
    this.primaryColor,
    required this.productionFirebase,
    required this.stagingFirebase,
    this.features = const {},
  });
}
