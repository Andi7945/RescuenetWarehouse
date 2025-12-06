// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'containers_by_ready_status_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containersByReadyStatusHash() =>
    r'7bc0e5458a1847fb6569e4931c649350753f297d';

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

abstract class _$ContainersByReadyStatus
    extends BuildlessAutoDisposeStreamNotifier<List<RescueContainer>> {
  late final bool isReady;

  Stream<List<RescueContainer>> build(bool isReady);
}

/// Watches containers by ready status.
/// Only rebuilds when containers with THIS status change.
///
/// Usage:
/// ```dart
/// final readyContainers = ref.watch(containersByReadyStatusProvider(true));
/// ```
///
/// Copied from [ContainersByReadyStatus].
@ProviderFor(ContainersByReadyStatus)
const containersByReadyStatusProvider = ContainersByReadyStatusFamily();

/// Watches containers by ready status.
/// Only rebuilds when containers with THIS status change.
///
/// Usage:
/// ```dart
/// final readyContainers = ref.watch(containersByReadyStatusProvider(true));
/// ```
///
/// Copied from [ContainersByReadyStatus].
class ContainersByReadyStatusFamily
    extends Family<AsyncValue<List<RescueContainer>>> {
  /// Watches containers by ready status.
  /// Only rebuilds when containers with THIS status change.
  ///
  /// Usage:
  /// ```dart
  /// final readyContainers = ref.watch(containersByReadyStatusProvider(true));
  /// ```
  ///
  /// Copied from [ContainersByReadyStatus].
  const ContainersByReadyStatusFamily();

  /// Watches containers by ready status.
  /// Only rebuilds when containers with THIS status change.
  ///
  /// Usage:
  /// ```dart
  /// final readyContainers = ref.watch(containersByReadyStatusProvider(true));
  /// ```
  ///
  /// Copied from [ContainersByReadyStatus].
  ContainersByReadyStatusProvider call(bool isReady) {
    return ContainersByReadyStatusProvider(isReady);
  }

  @override
  ContainersByReadyStatusProvider getProviderOverride(
    covariant ContainersByReadyStatusProvider provider,
  ) {
    return call(provider.isReady);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'containersByReadyStatusProvider';
}

/// Watches containers by ready status.
/// Only rebuilds when containers with THIS status change.
///
/// Usage:
/// ```dart
/// final readyContainers = ref.watch(containersByReadyStatusProvider(true));
/// ```
///
/// Copied from [ContainersByReadyStatus].
class ContainersByReadyStatusProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          ContainersByReadyStatus,
          List<RescueContainer>
        > {
  /// Watches containers by ready status.
  /// Only rebuilds when containers with THIS status change.
  ///
  /// Usage:
  /// ```dart
  /// final readyContainers = ref.watch(containersByReadyStatusProvider(true));
  /// ```
  ///
  /// Copied from [ContainersByReadyStatus].
  ContainersByReadyStatusProvider(bool isReady)
    : this._internal(
        () => ContainersByReadyStatus()..isReady = isReady,
        from: containersByReadyStatusProvider,
        name: r'containersByReadyStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containersByReadyStatusHash,
        dependencies: ContainersByReadyStatusFamily._dependencies,
        allTransitiveDependencies:
            ContainersByReadyStatusFamily._allTransitiveDependencies,
        isReady: isReady,
      );

  ContainersByReadyStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isReady,
  }) : super.internal();

  final bool isReady;

  @override
  Stream<List<RescueContainer>> runNotifierBuild(
    covariant ContainersByReadyStatus notifier,
  ) {
    return notifier.build(isReady);
  }

  @override
  Override overrideWith(ContainersByReadyStatus Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContainersByReadyStatusProvider._internal(
        () => create()..isReady = isReady,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isReady: isReady,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<
    ContainersByReadyStatus,
    List<RescueContainer>
  >
  createElement() {
    return _ContainersByReadyStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainersByReadyStatusProvider && other.isReady == isReady;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isReady.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContainersByReadyStatusRef
    on AutoDisposeStreamNotifierProviderRef<List<RescueContainer>> {
  /// The parameter `isReady` of this provider.
  bool get isReady;
}

class _ContainersByReadyStatusProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          ContainersByReadyStatus,
          List<RescueContainer>
        >
    with ContainersByReadyStatusRef {
  _ContainersByReadyStatusProviderElement(super.provider);

  @override
  bool get isReady => (origin as ContainersByReadyStatusProvider).isReady;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
