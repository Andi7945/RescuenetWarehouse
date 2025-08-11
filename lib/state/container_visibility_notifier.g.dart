// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_visibility_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containerVisibilityNotifierHash() =>
    r'6c9bfd34f429570cd4ce95d4eccdc8826ec28fdd';

/// See also [ContainerVisibilityNotifier].
@ProviderFor(ContainerVisibilityNotifier)
final containerVisibilityNotifierProvider = AutoDisposeNotifierProvider<
  ContainerVisibilityNotifier,
  Map<RescueContainer, bool>
>.internal(
  ContainerVisibilityNotifier.new,
  name: r'containerVisibilityNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$containerVisibilityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContainerVisibilityNotifier =
    AutoDisposeNotifier<Map<RescueContainer, bool>>;
String _$containerVisibilityAsyncHash() =>
    r'ab8a312101dc2f1ac5ec63e8931b37e1f4265bb0';

/// AsyncValue-based container visibility provider for loading states support.
///
/// This provider works with the AsyncValue-based containers provider to provide
/// proper loading and error states for container visibility filtering.
///
/// Copied from [ContainerVisibilityAsync].
@ProviderFor(ContainerVisibilityAsync)
final containerVisibilityAsyncProvider = AutoDisposeStreamNotifierProvider<
  ContainerVisibilityAsync,
  Map<RescueContainer, bool>
>.internal(
  ContainerVisibilityAsync.new,
  name: r'containerVisibilityAsyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$containerVisibilityAsyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContainerVisibilityAsync =
    AutoDisposeStreamNotifier<Map<RescueContainer, bool>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
