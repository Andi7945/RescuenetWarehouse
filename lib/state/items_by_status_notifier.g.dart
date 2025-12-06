// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_by_status_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemsByStatusHash() => r'ded704cc0b76690cbf648b0e7a4d2a2ed73d53e2';

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

abstract class _$ItemsByStatus
    extends BuildlessAutoDisposeStreamNotifier<List<Item>> {
  late final OperationalStatus status;

  Stream<List<Item>> build(OperationalStatus status);
}

/// Watches items with a specific operational status.
/// Only rebuilds when items with THIS status change.
///
/// Usage:
/// ```dart
/// final deployableItems = ref.watch(
///   itemsByStatusProvider(OperationalStatus.deployable),
/// );
/// ```
///
/// Copied from [ItemsByStatus].
@ProviderFor(ItemsByStatus)
const itemsByStatusProvider = ItemsByStatusFamily();

/// Watches items with a specific operational status.
/// Only rebuilds when items with THIS status change.
///
/// Usage:
/// ```dart
/// final deployableItems = ref.watch(
///   itemsByStatusProvider(OperationalStatus.deployable),
/// );
/// ```
///
/// Copied from [ItemsByStatus].
class ItemsByStatusFamily extends Family<AsyncValue<List<Item>>> {
  /// Watches items with a specific operational status.
  /// Only rebuilds when items with THIS status change.
  ///
  /// Usage:
  /// ```dart
  /// final deployableItems = ref.watch(
  ///   itemsByStatusProvider(OperationalStatus.deployable),
  /// );
  /// ```
  ///
  /// Copied from [ItemsByStatus].
  const ItemsByStatusFamily();

  /// Watches items with a specific operational status.
  /// Only rebuilds when items with THIS status change.
  ///
  /// Usage:
  /// ```dart
  /// final deployableItems = ref.watch(
  ///   itemsByStatusProvider(OperationalStatus.deployable),
  /// );
  /// ```
  ///
  /// Copied from [ItemsByStatus].
  ItemsByStatusProvider call(OperationalStatus status) {
    return ItemsByStatusProvider(status);
  }

  @override
  ItemsByStatusProvider getProviderOverride(
    covariant ItemsByStatusProvider provider,
  ) {
    return call(provider.status);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemsByStatusProvider';
}

/// Watches items with a specific operational status.
/// Only rebuilds when items with THIS status change.
///
/// Usage:
/// ```dart
/// final deployableItems = ref.watch(
///   itemsByStatusProvider(OperationalStatus.deployable),
/// );
/// ```
///
/// Copied from [ItemsByStatus].
class ItemsByStatusProvider
    extends AutoDisposeStreamNotifierProviderImpl<ItemsByStatus, List<Item>> {
  /// Watches items with a specific operational status.
  /// Only rebuilds when items with THIS status change.
  ///
  /// Usage:
  /// ```dart
  /// final deployableItems = ref.watch(
  ///   itemsByStatusProvider(OperationalStatus.deployable),
  /// );
  /// ```
  ///
  /// Copied from [ItemsByStatus].
  ItemsByStatusProvider(OperationalStatus status)
    : this._internal(
        () => ItemsByStatus()..status = status,
        from: itemsByStatusProvider,
        name: r'itemsByStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemsByStatusHash,
        dependencies: ItemsByStatusFamily._dependencies,
        allTransitiveDependencies:
            ItemsByStatusFamily._allTransitiveDependencies,
        status: status,
      );

  ItemsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final OperationalStatus status;

  @override
  Stream<List<Item>> runNotifierBuild(covariant ItemsByStatus notifier) {
    return notifier.build(status);
  }

  @override
  Override overrideWith(ItemsByStatus Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemsByStatusProvider._internal(
        () => create()..status = status,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<ItemsByStatus, List<Item>>
  createElement() {
    return _ItemsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemsByStatusRef on AutoDisposeStreamNotifierProviderRef<List<Item>> {
  /// The parameter `status` of this provider.
  OperationalStatus get status;
}

class _ItemsByStatusProviderElement
    extends AutoDisposeStreamNotifierProviderElement<ItemsByStatus, List<Item>>
    with ItemsByStatusRef {
  _ItemsByStatusProviderElement(super.provider);

  @override
  OperationalStatus get status => (origin as ItemsByStatusProvider).status;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
