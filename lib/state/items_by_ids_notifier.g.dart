// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_by_ids_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemsByIdsHash() => r'4a9d1433854fb2684e55b1046a2126c5e00e5d90';

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

abstract class _$ItemsByIds
    extends BuildlessAutoDisposeStreamNotifier<List<Item>> {
  late final List<String> itemIds;

  Stream<List<Item>> build(List<String> itemIds);
}

/// Watches a subset of items by their IDs.
/// Only rebuilds when items in THIS subset change.
///
/// Useful for assignment views where you need multiple items
/// but not the entire collection.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsByIdsProvider(['id1', 'id2', 'id3']));
/// ```
///
/// Copied from [ItemsByIds].
@ProviderFor(ItemsByIds)
const itemsByIdsProvider = ItemsByIdsFamily();

/// Watches a subset of items by their IDs.
/// Only rebuilds when items in THIS subset change.
///
/// Useful for assignment views where you need multiple items
/// but not the entire collection.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsByIdsProvider(['id1', 'id2', 'id3']));
/// ```
///
/// Copied from [ItemsByIds].
class ItemsByIdsFamily extends Family<AsyncValue<List<Item>>> {
  /// Watches a subset of items by their IDs.
  /// Only rebuilds when items in THIS subset change.
  ///
  /// Useful for assignment views where you need multiple items
  /// but not the entire collection.
  ///
  /// Usage:
  /// ```dart
  /// final items = ref.watch(itemsByIdsProvider(['id1', 'id2', 'id3']));
  /// ```
  ///
  /// Copied from [ItemsByIds].
  const ItemsByIdsFamily();

  /// Watches a subset of items by their IDs.
  /// Only rebuilds when items in THIS subset change.
  ///
  /// Useful for assignment views where you need multiple items
  /// but not the entire collection.
  ///
  /// Usage:
  /// ```dart
  /// final items = ref.watch(itemsByIdsProvider(['id1', 'id2', 'id3']));
  /// ```
  ///
  /// Copied from [ItemsByIds].
  ItemsByIdsProvider call(List<String> itemIds) {
    return ItemsByIdsProvider(itemIds);
  }

  @override
  ItemsByIdsProvider getProviderOverride(
    covariant ItemsByIdsProvider provider,
  ) {
    return call(provider.itemIds);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemsByIdsProvider';
}

/// Watches a subset of items by their IDs.
/// Only rebuilds when items in THIS subset change.
///
/// Useful for assignment views where you need multiple items
/// but not the entire collection.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsByIdsProvider(['id1', 'id2', 'id3']));
/// ```
///
/// Copied from [ItemsByIds].
class ItemsByIdsProvider
    extends AutoDisposeStreamNotifierProviderImpl<ItemsByIds, List<Item>> {
  /// Watches a subset of items by their IDs.
  /// Only rebuilds when items in THIS subset change.
  ///
  /// Useful for assignment views where you need multiple items
  /// but not the entire collection.
  ///
  /// Usage:
  /// ```dart
  /// final items = ref.watch(itemsByIdsProvider(['id1', 'id2', 'id3']));
  /// ```
  ///
  /// Copied from [ItemsByIds].
  ItemsByIdsProvider(List<String> itemIds)
    : this._internal(
        () => ItemsByIds()..itemIds = itemIds,
        from: itemsByIdsProvider,
        name: r'itemsByIdsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemsByIdsHash,
        dependencies: ItemsByIdsFamily._dependencies,
        allTransitiveDependencies: ItemsByIdsFamily._allTransitiveDependencies,
        itemIds: itemIds,
      );

  ItemsByIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemIds,
  }) : super.internal();

  final List<String> itemIds;

  @override
  Stream<List<Item>> runNotifierBuild(covariant ItemsByIds notifier) {
    return notifier.build(itemIds);
  }

  @override
  Override overrideWith(ItemsByIds Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemsByIdsProvider._internal(
        () => create()..itemIds = itemIds,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemIds: itemIds,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<ItemsByIds, List<Item>>
  createElement() {
    return _ItemsByIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsByIdsProvider && other.itemIds == itemIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemsByIdsRef on AutoDisposeStreamNotifierProviderRef<List<Item>> {
  /// The parameter `itemIds` of this provider.
  List<String> get itemIds;
}

class _ItemsByIdsProviderElement
    extends AutoDisposeStreamNotifierProviderElement<ItemsByIds, List<Item>>
    with ItemsByIdsRef {
  _ItemsByIdsProviderElement(super.provider);

  @override
  List<String> get itemIds => (origin as ItemsByIdsProvider).itemIds;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
