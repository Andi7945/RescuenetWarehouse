// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'containers_by_location_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containersByLocationHash() =>
    r'5bc90f20ceeb9a82e3a915b630af19fffb789fbb';

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

abstract class _$ContainersByLocation
    extends BuildlessAutoDisposeStreamNotifier<List<RescueContainer>> {
  late final String locationId;

  Stream<List<RescueContainer>> build(String locationId);
}

/// Watches containers at a specific location.
/// Only rebuilds when containers at THIS location change.
///
/// Usage:
/// ```dart
/// final containers = ref.watch(containersByLocationProvider(locationId));
/// ```
///
/// Copied from [ContainersByLocation].
@ProviderFor(ContainersByLocation)
const containersByLocationProvider = ContainersByLocationFamily();

/// Watches containers at a specific location.
/// Only rebuilds when containers at THIS location change.
///
/// Usage:
/// ```dart
/// final containers = ref.watch(containersByLocationProvider(locationId));
/// ```
///
/// Copied from [ContainersByLocation].
class ContainersByLocationFamily
    extends Family<AsyncValue<List<RescueContainer>>> {
  /// Watches containers at a specific location.
  /// Only rebuilds when containers at THIS location change.
  ///
  /// Usage:
  /// ```dart
  /// final containers = ref.watch(containersByLocationProvider(locationId));
  /// ```
  ///
  /// Copied from [ContainersByLocation].
  const ContainersByLocationFamily();

  /// Watches containers at a specific location.
  /// Only rebuilds when containers at THIS location change.
  ///
  /// Usage:
  /// ```dart
  /// final containers = ref.watch(containersByLocationProvider(locationId));
  /// ```
  ///
  /// Copied from [ContainersByLocation].
  ContainersByLocationProvider call(String locationId) {
    return ContainersByLocationProvider(locationId);
  }

  @override
  ContainersByLocationProvider getProviderOverride(
    covariant ContainersByLocationProvider provider,
  ) {
    return call(provider.locationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'containersByLocationProvider';
}

/// Watches containers at a specific location.
/// Only rebuilds when containers at THIS location change.
///
/// Usage:
/// ```dart
/// final containers = ref.watch(containersByLocationProvider(locationId));
/// ```
///
/// Copied from [ContainersByLocation].
class ContainersByLocationProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          ContainersByLocation,
          List<RescueContainer>
        > {
  /// Watches containers at a specific location.
  /// Only rebuilds when containers at THIS location change.
  ///
  /// Usage:
  /// ```dart
  /// final containers = ref.watch(containersByLocationProvider(locationId));
  /// ```
  ///
  /// Copied from [ContainersByLocation].
  ContainersByLocationProvider(String locationId)
    : this._internal(
        () => ContainersByLocation()..locationId = locationId,
        from: containersByLocationProvider,
        name: r'containersByLocationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containersByLocationHash,
        dependencies: ContainersByLocationFamily._dependencies,
        allTransitiveDependencies:
            ContainersByLocationFamily._allTransitiveDependencies,
        locationId: locationId,
      );

  ContainersByLocationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.locationId,
  }) : super.internal();

  final String locationId;

  @override
  Stream<List<RescueContainer>> runNotifierBuild(
    covariant ContainersByLocation notifier,
  ) {
    return notifier.build(locationId);
  }

  @override
  Override overrideWith(ContainersByLocation Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContainersByLocationProvider._internal(
        () => create()..locationId = locationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        locationId: locationId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<
    ContainersByLocation,
    List<RescueContainer>
  >
  createElement() {
    return _ContainersByLocationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainersByLocationProvider &&
        other.locationId == locationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, locationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContainersByLocationRef
    on AutoDisposeStreamNotifierProviderRef<List<RescueContainer>> {
  /// The parameter `locationId` of this provider.
  String get locationId;
}

class _ContainersByLocationProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          ContainersByLocation,
          List<RescueContainer>
        >
    with ContainersByLocationRef {
  _ContainersByLocationProviderElement(super.provider);

  @override
  String get locationId => (origin as ContainersByLocationProvider).locationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
