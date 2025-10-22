import 'package:firebase_core/firebase_core.dart';
import 'org_config.dart';
import 'firebase_options_rescuenet_production.dart' as rescuenet_prod;
import 'firebase_options_rescuenet_testing.dart' as rescuenet_staging;
import 'firebase_options_humedica_prod.dart' as humedica_prod;

/// Registry of all available organizations in the multi-tenant system.
///
/// This uses pure functions with no state for configuration lookup.
/// Organizations are defined at compile time and selected via build flags.

/// Private map containing all organization configurations
final Map<String, OrgConfig> _orgConfigs = {
  'rescuenet': OrgConfig(
    id: 'rescuenet',
    name: 'RescueNet',
    productionFirebase: rescuenet_prod.RescuenetProductionFirebaseOptions.currentPlatform,
    stagingFirebase: rescuenet_staging.RescuenetStagingFirebaseOptions.currentPlatform,
    features: {},
  ),
  'humedica': OrgConfig(
      id: 'humedica',
      name: 'Humedica',
      logoAssetPath: 'assets/images/logo_humedica.png',
      productionFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
      stagingFirebase: humedica_prod.HumedicaFirebaseOptions.currentPlatform,
      features: {},
  )
};

/// Get organization config by ID.
///
/// Throws [ArgumentError] if the organization is not found.
///
/// Example:
/// ```dart
/// final config = getOrgConfig('rescuenet');
/// print(config.name); // 'RescueNet'
/// ```
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
///
/// Example:
/// ```dart
/// final options = getFirebaseOptions('rescuenet', 'staging');
/// await Firebase.initializeApp(options: options);
/// ```
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
///
/// Returns a list of organization identifiers that can be used with
/// [getOrgConfig] and [getFirebaseOptions].
///
/// Example:
/// ```dart
/// final orgs = getAvailableOrgs();
/// print(orgs); // ['rescuenet']
/// ```
List<String> getAvailableOrgs() => _orgConfigs.keys.toList();
