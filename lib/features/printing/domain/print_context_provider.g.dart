// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$printContextHash() => r'0d3a1c750d9c9c0c3d40dc234ffeb2ee242ce9e6';

/// Provides the current print context assembled from auth and org providers.
///
/// This provider watches:
/// - [currentUserNameProvider] for the logged-in user's name
/// - [currentOrgProvider] for organization branding and contact info
///
/// Returns a [PrintContext] with current values and timestamp.
///
/// Copied from [printContext].
@ProviderFor(printContext)
final printContextProvider = AutoDisposeProvider<PrintContext>.internal(
  printContext,
  name: r'printContextProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$printContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrintContextRef = AutoDisposeProviderRef<PrintContext>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
