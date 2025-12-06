// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detected_environment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detectedEnvironmentHash() =>
    r'410b552d90ef593df8e780513d0d061132e0d20a';

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
///
/// Copied from [detectedEnvironment].
@ProviderFor(detectedEnvironment)
final detectedEnvironmentProvider =
    AutoDisposeProvider<EnvironmentDetectionResult>.internal(
      detectedEnvironment,
      name: r'detectedEnvironmentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$detectedEnvironmentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DetectedEnvironmentRef =
    AutoDisposeProviderRef<EnvironmentDetectionResult>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
