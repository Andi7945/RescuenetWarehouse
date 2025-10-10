import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'org_config.dart';
import 'org_registry.dart';
import '../main.dart' show kOrgId, kEnvironment;

part 'org_provider.g.dart';

/// Provider for the current organization configuration.
///
/// This reads the ORG build-time constant and returns the corresponding
/// organization configuration. Use this for accessing org-specific branding
/// (logo, name, colors, feature flags).
///
/// Example:
/// ```dart
/// final org = ref.watch(currentOrgProvider);
/// Text('Welcome to ${org.name}');
/// ```
@riverpod
OrgConfig currentOrg(Ref ref) {
  return getOrgConfig(kOrgId);
}

/// Provider for the current environment name.
///
/// This reads the ENV build-time constant. Returns 'staging' or 'production'.
///
/// Example:
/// ```dart
/// final env = ref.watch(currentEnvironmentProvider);
/// if (env == 'staging') {
///   // Show staging banner
/// }
/// ```
@riverpod
String currentEnvironment(Ref ref) {
  return kEnvironment;
}
