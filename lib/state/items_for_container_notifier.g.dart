// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_for_container_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemsForContainerHash() => r'04dfb6412b3fc2b0af6486b14b5b03f9c8d13938';

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

abstract class _$ItemsForContainer
    extends BuildlessAutoDisposeStreamNotifier<List<Item>> {
  late final String containerId;

  Stream<List<Item>> build(String containerId);
}

/// Watches items assigned to a specific container.
///
/// Automatically updates when:
/// - Assignments for this container change
/// - Items in this container change
///
/// This provider solves the infinite loading issue by using containerId
/// (String with value equality) instead of List<String> as the family parameter.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsForContainerProvider(containerId));
/// ```
///
/// Copied from [ItemsForContainer].
@ProviderFor(ItemsForContainer)
const itemsForContainerProvider = ItemsForContainerFamily();

/// Watches items assigned to a specific container.
///
/// Automatically updates when:
/// - Assignments for this container change
/// - Items in this container change
///
/// This provider solves the infinite loading issue by using containerId
/// (String with value equality) instead of List<String> as the family parameter.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsForContainerProvider(containerId));
/// ```
///
/// Copied from [ItemsForContainer].
class ItemsForContainerFamily extends Family<AsyncValue<List<Item>>> {
  /// Watches items assigned to a specific container.
  ///
  /// Automatically updates when:
  /// - Assignments for this container change
  /// - Items in this container change
  ///
  /// This provider solves the infinite loading issue by using containerId
  /// (String with value equality) instead of List<String> as the family parameter.
  ///
  /// Usage:
  /// ```dart
  /// final items = ref.watch(itemsForContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [ItemsForContainer].
  const ItemsForContainerFamily();

  /// Watches items assigned to a specific container.
  ///
  /// Automatically updates when:
  /// - Assignments for this container change
  /// - Items in this container change
  ///
  /// This provider solves the infinite loading issue by using containerId
  /// (String with value equality) instead of List<String> as the family parameter.
  ///
  /// Usage:
  /// ```dart
  /// final items = ref.watch(itemsForContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [ItemsForContainer].
  ItemsForContainerProvider call(String containerId) {
    return ItemsForContainerProvider(containerId);
  }

  @override
  ItemsForContainerProvider getProviderOverride(
    covariant ItemsForContainerProvider provider,
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
  String? get name => r'itemsForContainerProvider';
}

/// Watches items assigned to a specific container.
///
/// Automatically updates when:
/// - Assignments for this container change
/// - Items in this container change
///
/// This provider solves the infinite loading issue by using containerId
/// (String with value equality) instead of List<String> as the family parameter.
///
/// Usage:
/// ```dart
/// final items = ref.watch(itemsForContainerProvider(containerId));
/// ```
///
/// Copied from [ItemsForContainer].
class ItemsForContainerProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<ItemsForContainer, List<Item>> {
  /// Watches items assigned to a specific container.
  ///
  /// Automatically updates when:
  /// - Assignments for this container change
  /// - Items in this container change
  ///
  /// This provider solves the infinite loading issue by using containerId
  /// (String with value equality) instead of List<String> as the family parameter.
  ///
  /// Usage:
  /// ```dart
  /// final items = ref.watch(itemsForContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [ItemsForContainer].
  ItemsForContainerProvider(String containerId)
    : this._internal(
        () => ItemsForContainer()..containerId = containerId,
        from: itemsForContainerProvider,
        name: r'itemsForContainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$itemsForContainerHash,
        dependencies: ItemsForContainerFamily._dependencies,
        allTransitiveDependencies:
            ItemsForContainerFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  ItemsForContainerProvider._internal(
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
  Stream<List<Item>> runNotifierBuild(covariant ItemsForContainer notifier) {
    return notifier.build(containerId);
  }

  @override
  Override overrideWith(ItemsForContainer Function() create) {
    return ProviderOverride(
      origin: this,
      override: ItemsForContainerProvider._internal(
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
  AutoDisposeStreamNotifierProviderElement<ItemsForContainer, List<Item>>
  createElement() {
    return _ItemsForContainerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsForContainerProvider &&
        other.containerId == containerId;
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
mixin ItemsForContainerRef on AutoDisposeStreamNotifierProviderRef<List<Item>> {
  /// The parameter `containerId` of this provider.
  String get containerId;
}

class _ItemsForContainerProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<ItemsForContainer, List<Item>>
    with ItemsForContainerRef {
  _ItemsForContainerProviderElement(super.provider);

  @override
  String get containerId => (origin as ItemsForContainerProvider).containerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
