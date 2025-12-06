// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'containers_by_type_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containersByTypeHash() => r'7b9324149ba0c4f38d3ef8b499da83e4e9e461f6';

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

abstract class _$ContainersByType
    extends BuildlessAutoDisposeStreamNotifier<List<RescueContainer>> {
  late final String containerTypeId;

  Stream<List<RescueContainer>> build(String containerTypeId);
}

/// Watches containers of a specific type.
/// Only rebuilds when containers of THIS type change.
///
/// Usage:
/// ```dart
/// final euroBoxes = ref.watch(containersByTypeProvider('euro-box'));
/// ```
///
/// Copied from [ContainersByType].
@ProviderFor(ContainersByType)
const containersByTypeProvider = ContainersByTypeFamily();

/// Watches containers of a specific type.
/// Only rebuilds when containers of THIS type change.
///
/// Usage:
/// ```dart
/// final euroBoxes = ref.watch(containersByTypeProvider('euro-box'));
/// ```
///
/// Copied from [ContainersByType].
class ContainersByTypeFamily extends Family<AsyncValue<List<RescueContainer>>> {
  /// Watches containers of a specific type.
  /// Only rebuilds when containers of THIS type change.
  ///
  /// Usage:
  /// ```dart
  /// final euroBoxes = ref.watch(containersByTypeProvider('euro-box'));
  /// ```
  ///
  /// Copied from [ContainersByType].
  const ContainersByTypeFamily();

  /// Watches containers of a specific type.
  /// Only rebuilds when containers of THIS type change.
  ///
  /// Usage:
  /// ```dart
  /// final euroBoxes = ref.watch(containersByTypeProvider('euro-box'));
  /// ```
  ///
  /// Copied from [ContainersByType].
  ContainersByTypeProvider call(String containerTypeId) {
    return ContainersByTypeProvider(containerTypeId);
  }

  @override
  ContainersByTypeProvider getProviderOverride(
    covariant ContainersByTypeProvider provider,
  ) {
    return call(provider.containerTypeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'containersByTypeProvider';
}

/// Watches containers of a specific type.
/// Only rebuilds when containers of THIS type change.
///
/// Usage:
/// ```dart
/// final euroBoxes = ref.watch(containersByTypeProvider('euro-box'));
/// ```
///
/// Copied from [ContainersByType].
class ContainersByTypeProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          ContainersByType,
          List<RescueContainer>
        > {
  /// Watches containers of a specific type.
  /// Only rebuilds when containers of THIS type change.
  ///
  /// Usage:
  /// ```dart
  /// final euroBoxes = ref.watch(containersByTypeProvider('euro-box'));
  /// ```
  ///
  /// Copied from [ContainersByType].
  ContainersByTypeProvider(String containerTypeId)
    : this._internal(
        () => ContainersByType()..containerTypeId = containerTypeId,
        from: containersByTypeProvider,
        name: r'containersByTypeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$containersByTypeHash,
        dependencies: ContainersByTypeFamily._dependencies,
        allTransitiveDependencies:
            ContainersByTypeFamily._allTransitiveDependencies,
        containerTypeId: containerTypeId,
      );

  ContainersByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerTypeId,
  }) : super.internal();

  final String containerTypeId;

  @override
  Stream<List<RescueContainer>> runNotifierBuild(
    covariant ContainersByType notifier,
  ) {
    return notifier.build(containerTypeId);
  }

  @override
  Override overrideWith(ContainersByType Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContainersByTypeProvider._internal(
        () => create()..containerTypeId = containerTypeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerTypeId: containerTypeId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<
    ContainersByType,
    List<RescueContainer>
  >
  createElement() {
    return _ContainersByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainersByTypeProvider &&
        other.containerTypeId == containerTypeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerTypeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContainersByTypeRef
    on AutoDisposeStreamNotifierProviderRef<List<RescueContainer>> {
  /// The parameter `containerTypeId` of this provider.
  String get containerTypeId;
}

class _ContainersByTypeProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          ContainersByType,
          List<RescueContainer>
        >
    with ContainersByTypeRef {
  _ContainersByTypeProviderElement(super.provider);

  @override
  String get containerTypeId =>
      (origin as ContainersByTypeProvider).containerTypeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
