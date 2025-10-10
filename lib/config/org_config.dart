import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'org_config.freezed.dart';

/// Configuration for an organization in the multi-tenant system.
///
/// Each organization has:
/// - Unique identifier and display name
/// - Optional branding (logo, primary color)
/// - Separate Firebase projects for production and staging
/// - Optional feature flags
@freezed
class OrgConfig with _$OrgConfig {
  const factory OrgConfig({
    /// Unique organization identifier (e.g., 'rescuenet')
    required String id,

    /// Display name for the organization (e.g., 'RescueNet')
    required String name,

    /// Optional path to organization logo in assets
    String? logoAssetPath,

    /// Optional organization primary brand color
    Color? primaryColor,

    /// Firebase options for production environment
    required FirebaseOptions productionFirebase,

    /// Firebase options for staging environment
    required FirebaseOptions stagingFirebase,

    /// Optional feature flags for org-specific features
    @Default({}) Map<String, dynamic> features,
  }) = _OrgConfig;
}
