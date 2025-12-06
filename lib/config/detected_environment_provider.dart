import 'package:firebase_core/firebase_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'environment_detector.dart';
import 'org_provider.dart';

part 'detected_environment_provider.g.dart';

/// Provider that performs runtime environment detection.
///
/// This provider reads the actual Firebase project ID at runtime and compares
/// it against the build-time org and environment constants. It returns a
/// [EnvironmentDetectionResult] indicating whether the claimed environment
/// matches the actual Firebase project configuration.
///
/// Dependencies:
/// - Firebase project ID (from Firebase.app().options.projectId)
/// - Claimed org (from currentOrgProvider)
/// - Claimed environment (from currentEnvironmentProvider)
///
/// The provider will auto-update if any dependencies change (though org and
/// environment are build-time constants, so this is unlikely in practice).
///
/// Example:
/// ```dart
/// final detection = ref.watch(detectedEnvironmentProvider);
/// if (detection.hasMismatch) {
///   // Show warning in UI
///   print('Warning: ${detection.warningMessage}');
/// }
/// ```
@riverpod
EnvironmentDetectionResult detectedEnvironment(DetectedEnvironmentRef ref) {
  // Get actual Firebase project ID at runtime
  final actualProjectId = Firebase.app().options.projectId;

  // Get claimed org and env from build-time constants
  final claimedOrg = ref.watch(currentOrgProvider).id;
  final claimedEnv = ref.watch(currentEnvironmentProvider);

  // Call pure function to verify
  return detectEnvironmentFromFirebase(
    actualProjectId: actualProjectId,
    claimedOrg: claimedOrg,
    claimedEnv: claimedEnv,
  );
}
