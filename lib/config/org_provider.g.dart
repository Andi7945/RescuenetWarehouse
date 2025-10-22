// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentOrgHash() => r'0b9b289068e8cfe6a29b35db9bdd97bb7d192e1d';

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
///
/// Copied from [currentOrg].
@ProviderFor(currentOrg)
final currentOrgProvider = AutoDisposeProvider<OrgConfig>.internal(
  currentOrg,
  name: r'currentOrgProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentOrgHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentOrgRef = AutoDisposeProviderRef<OrgConfig>;
String _$currentEnvironmentHash() =>
    r'e4763fc60ddb14c45db19887fbe582a530fd5fb2';

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
///
/// Copied from [currentEnvironment].
@ProviderFor(currentEnvironment)
final currentEnvironmentProvider = AutoDisposeProvider<String>.internal(
  currentEnvironment,
  name: r'currentEnvironmentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentEnvironmentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentEnvironmentRef = AutoDisposeProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
