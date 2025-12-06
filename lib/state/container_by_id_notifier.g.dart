// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_by_id_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containerByIdHash() => r'48dd53665f293e296d98e49f34c95f05f8dc3ceb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ContainerById
    extends BuildlessAutoDisposeStreamNotifier<RescueContainer?> {
  late final String containerId;

  Stream<RescueContainer?> build(String containerId);
}

/// Watches a single container by ID.
/// Only rebuilds when THIS specific container changes.
///
/// Returns RescueContainer (expanded with type, location, destination).
///
/// Usage:
/// ```dart
/// final container = ref.watch(containerByIdProvider(containerId));
/// ```
///
/// Copied from [ContainerById].
@ProviderFor(ContainerById)
const containerByIdProvider = ContainerByIdFamily();

/// Watches a single container by ID.
/// Only rebuilds when THIS specific container changes.
///
/// Returns RescueContainer (expanded with type, location, destination).
///
/// Usage:
/// ```dart
/// final container = ref.watch(containerByIdProvider(containerId));
/// ```
///
/// Copied from [ContainerById].
class ContainerByIdFamily extends Family<AsyncValue<RescueContainer?>> {
  /// Watches a single container by ID.
  /// Only rebuilds when THIS specific container changes.
  ///
  /// Returns RescueContainer (expanded with type, location, destination).
  ///
  /// Usage:
  /// ```dart
  /// final container = ref.watch(containerByIdProvider(containerId));
  /// ```
  ///
  /// Copied from [ContainerById].
  const ContainerByIdFamily();

  /// Watches a single container by ID.
  /// Only rebuilds when THIS specific container changes.
  ///
  /// Returns RescueContainer (expanded with type, location, destination).
  ///
  /// Usage:
  /// ```dart
  /// final container = ref.watch(containerByIdProvider(containerId));
  /// ```
  ///
  /// Copied from [ContainerById].
  ContainerByIdProvider call(String containerId) {
    return ContainerByIdProvider(containerId);
  }

  @override
  ContainerByIdProvider getProviderOverride(
    covariant ContainerByIdProvider provider,
  ) {
    return call(provider.containerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'containerByIdProvider';
}

/// Watches a single container by ID.
/// Only rebuilds when THIS specific container changes.
///
/// Returns RescueContainer (expanded with type, location, destination).
///
/// Usage:
/// ```dart
/// final container = ref.watch(containerByIdProvider(containerId));
/// ```
///
/// Copied from [ContainerById].
class ContainerByIdProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<ContainerById, RescueContainer?> {
  /// Watches a single container by ID.
  /// Only rebuilds when THIS specific container changes.
  ///
  /// Returns RescueContainer (expanded with type, location, destination).
  ///
  /// Usage:
  /// ```dart
  /// final container = ref.watch(containerByIdProvider(containerId));
  /// ```
  ///
  /// Copied from [ContainerById].
  ContainerByIdProvider(String containerId)
    : this._internal(
        () => ContainerById()..containerId = containerId,
        from: containerByIdProvider,
        name: r'containerByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containerByIdHash,
        dependencies: ContainerByIdFamily._dependencies,
        allTransitiveDependencies:
            ContainerByIdFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  ContainerByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerId,
  }) : super.internal();

  final String containerId;

  @override
  Stream<RescueContainer?> runNotifierBuild(covariant ContainerById notifier) {
    return notifier.build(containerId);
  }

  @override
  Override overrideWith(ContainerById Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContainerByIdProvider._internal(
        () => create()..containerId = containerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerId: containerId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<ContainerById, RescueContainer?>
  createElement() {
    return _ContainerByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerByIdProvider && other.containerId == containerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContainerByIdRef
    on AutoDisposeStreamNotifierProviderRef<RescueContainer?> {
  /// The parameter `containerId` of this provider.
  String get containerId;
}

class _ContainerByIdProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          ContainerById,
          RescueContainer?
        >
    with ContainerByIdRef {
  _ContainerByIdProviderElement(super.provider);

  @override
  String get containerId => (origin as ContainerByIdProvider).containerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
