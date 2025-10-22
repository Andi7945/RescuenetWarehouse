// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_containers_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allContainersStreamHash() =>
    r'a60d4a417090ecde9ea588e349494950725bc25d';

/// Stream-based provider for backward compatibility.
/// This maintains the existing Stream&lt;List&lt;RescueContainer&gt;&gt; pattern that other
/// parts of the app may depend on.
///
/// Copied from [allContainersStream].
@ProviderFor(allContainersStream)
final allContainersStreamProvider =
    AutoDisposeStreamProvider<List<RescueContainer>>.internal(
      allContainersStream,
      name: r'allContainersStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allContainersStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllContainersStreamRef =
    AutoDisposeStreamProviderRef<List<RescueContainer>>;
String _$allContainersAsyncHash() =>
    r'2f32fa441390bca4d37ffa7feac60a2d123da5f2';

/// AsyncValue-based containers provider for loading states support.
///
/// This provider wraps the containers stream in AsyncValue to provide proper
/// loading, error, and data states for UI components. It follows the enhanced
/// pattern from LOADING_INDICATORS_DESIGN.md while maintaining compatibility
/// with the existing AllContainersNotifier.
///
/// Usage:
/// ```dart
/// AsyncValueBuilder<List<RescueContainer>>(
///   value: ref.watch(allContainersAsyncProvider),
///   data: (containers) => ContainerGrid(containers: containers),
/// )
/// ```
///
/// Copied from [AllContainersAsync].
@ProviderFor(AllContainersAsync)
final allContainersAsyncProvider =
    AutoDisposeStreamNotifierProvider<
      AllContainersAsync,
      List<RescueContainer>
    >.internal(
      AllContainersAsync.new,
      name: r'allContainersAsyncProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allContainersAsyncHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllContainersAsync = AutoDisposeStreamNotifier<List<RescueContainer>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
