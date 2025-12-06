import 'package:freezed_annotation/freezed_annotation.dart';

part 'environment_detector.freezed.dart';

/// Result of environment detection comparing claimed vs actual Firebase project
@freezed
abstract class EnvironmentDetectionResult with _$EnvironmentDetectionResult {
  const factory EnvironmentDetectionResult({
    /// Actual organization detected from Firebase project ID
    required String actualOrg,

    /// Actual environment detected from Firebase project ID
    required String actualEnv,

    /// Organization claimed via build-time --dart-define
    required String claimedOrg,

    /// Environment claimed via build-time --dart-define
    required String claimedEnv,

    /// Whether actual and claimed environments match
    required bool isMatch,

    /// Warning message if there's a mismatch or unknown project
    String? warningMessage,
  }) = _EnvironmentDetectionResult;

  const EnvironmentDetectionResult._();

  /// Computed getter for checking mismatch (inverse of isMatch)
  bool get hasMismatch => !isMatch;
}

/// Mapping of Firebase project IDs to their (org, env) tuples
/// Add new projects here as organizations are onboarded
const Map<String, ({String org, String env})> _projectIdToEnvironment = {
  'rescuenet-7733b': (org: 'rescuenet', env: 'production'),
  'rescuenet-testing': (org: 'rescuenet', env: 'staging'),
};

/// Detects the actual environment from Firebase project ID and compares
/// it with the claimed environment from build-time configuration.
///
/// This is a pure function with no side effects - fully deterministic and testable.
///
/// Returns [EnvironmentDetectionResult] with:
/// - Match case: isMatch=true, warningMessage=null
/// - Mismatch case: isMatch=false, warning describes the mismatch
/// - Unknown project case: isMatch=false, warning indicates unknown project
EnvironmentDetectionResult detectEnvironmentFromFirebase({
  required String actualProjectId,
  required String claimedOrg,
  required String claimedEnv,
}) {
  // Look up actual org/env from project ID
  final actualConfig = _projectIdToEnvironment[actualProjectId];

  // Case 1: Unknown project ID
  if (actualConfig == null) {
    return EnvironmentDetectionResult(
      actualOrg: 'unknown',
      actualEnv: 'unknown',
      claimedOrg: claimedOrg,
      claimedEnv: claimedEnv,
      isMatch: false,
      warningMessage:
          'Connected to unknown Firebase project: $actualProjectId. '
          'Expected $claimedOrg-$claimedEnv.',
    );
  }

  final actualOrg = actualConfig.org;
  final actualEnv = actualConfig.env;

  // Case 2: Mismatch between claimed and actual
  if (actualOrg != claimedOrg || actualEnv != claimedEnv) {
    return EnvironmentDetectionResult(
      actualOrg: actualOrg,
      actualEnv: actualEnv,
      claimedOrg: claimedOrg,
      claimedEnv: claimedEnv,
      isMatch: false,
      warningMessage:
          'Build claims ${claimedEnv.toUpperCase()} but connected to '
          '${actualEnv.toUpperCase()} Firebase! '
          '(Claimed: $claimedOrg-$claimedEnv, Actual: $actualOrg-$actualEnv)',
    );
  }

  // Case 3: Match - all is well
  return EnvironmentDetectionResult(
    actualOrg: actualOrg,
    actualEnv: actualEnv,
    claimedOrg: claimedOrg,
    claimedEnv: claimedEnv,
    isMatch: true,
    warningMessage: null,
  );
}
