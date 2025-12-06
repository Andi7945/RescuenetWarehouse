// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_by_id_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemByIdHash() => r'44d5c0b52556132a5a59516fb6c97d1f512f5a5e';

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

abstract class _$ItemById extends BuildlessAutoDisposeStreamNotifier<Item?> {
  late final String itemId;

  Stream<Item?> build(String itemId);
}

/// Watches a single item by ID.
/// Only rebuilds when THIS specific item changes.
///
/// Usage:
/// ```dart
/// final item = ref.watch(itemByIdProvider(itemId));
/// ```
///
/// Copied from [ItemById].
@ProviderFor(ItemById)
const itemByIdProvider = ItemByIdFamily();

/// Watches a single item by ID.
/// Only rebuilds when THIS specific item changes.
///
/// Usage:
/// ```dart
/// final item = ref.watch(itemByIdProvider(itemId));
/// ```
///
/// Copied from [ItemById].
class ItemByIdFamily extends Family<AsyncValue<Item?>> {
  /// Watches a single item by ID.
  /// Only rebuilds when THIS specific item changes.
  ///
  /// Usage:
  /// ```dart
  /// final item = ref.watch(itemByIdProvider(itemId));
  /// ```
  ///
  /// Copied from [ItemById].
  const ItemByIdFamily();

  /// Watches a single item by ID.
  /// Only rebuilds when THIS specific item changes.
  ///
  /// Usage:
  /// ```dart
  /// final item = ref.watch(itemByIdProvider(itemId));
  /// ```
  ///
  /// Copied from [ItemById].
  ItemByIdProvider call(String itemId) {
    return ItemByIdProvider(itemId);
  }

  @override
  ItemByIdProvider getProviderOverride(covariant ItemByIdProvider provider) {
    return call(provider.itemId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'itemByIdProvider';
}

/// Watches a single item by ID.
/// Only rebuilds when THIS specific item changes.
///
/// Usage:
/// ```dart
/// final item = ref.watch(itemByIdProvider(itemId));
/// ```
///
/// Copied from [ItemById].
class ItemByIdProvider
    extends AutoDisposeStreamNotifierProviderImpl<ItemById, Item?> {
  /// Watches a single item by ID.
  /// Only rebuilds when THIS specific item changes.
  ///
  /// Usage:
  /// ```dart
  /// final item = ref.watch(itemByIdProvider(itemId));
  /// ```
  ///
  /// Copied from [ItemById].
  ItemByIdProvider(String itemId)
    : this._internal(
        () => ItemById()..itemId = itemId,
        from: itemByIdProvider,
        name: r'itemByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemByIdHash,
        dependencies: ItemByIdFamily._dependencies,
        allTransitiveDependencies: ItemByIdFamily._allTransitiveDependencies,
        itemId: itemId,
      );

  ItemByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final String itemId;

  @override
  Stream<Item?> runNotifierBuild(covariant ItemById notifier) {
    return notifier.build(itemId);
  }

  @override
  Override overrideWith(ItemById Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemByIdProvider._internal(
        () => create()..itemId = itemId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<ItemById, Item?> createElement() {
    return _ItemByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemByIdProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ItemByIdRef on AutoDisposeStreamNotifierProviderRef<Item?> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _ItemByIdProviderElement
    extends AutoDisposeStreamNotifierProviderElement<ItemById, Item?>
    with ItemByIdRef {
  _ItemByIdProviderElement(super.provider);

  @override
  String get itemId => (origin as ItemByIdProvider).itemId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
