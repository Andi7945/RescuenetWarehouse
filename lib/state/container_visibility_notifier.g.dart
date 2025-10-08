// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_visibility_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containerVisibilityAsyncHash() =>
    r'97dae472922413a694bdb517c773111ee7f9ca34';

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
