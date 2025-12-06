// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignments_by_item_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignmentsByItemHash() => r'2f0eb2e6655daaecba6e7296565ad6a229d85b9d';

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

abstract class _$AssignmentsByItem
    extends BuildlessAutoDisposeStreamNotifier<List<Assignment>> {
  late final String itemId;

  Stream<List<Assignment>> build(String itemId);
}

/// Watches assignments for a specific item.
/// Only rebuilds when assignments for THIS item change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByItemProvider(itemId));
/// ```
///
/// Copied from [AssignmentsByItem].
@ProviderFor(AssignmentsByItem)
const assignmentsByItemProvider = AssignmentsByItemFamily();

/// Watches assignments for a specific item.
/// Only rebuilds when assignments for THIS item change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByItemProvider(itemId));
/// ```
///
/// Copied from [AssignmentsByItem].
class AssignmentsByItemFamily extends Family<AsyncValue<List<Assignment>>> {
  /// Watches assignments for a specific item.
  /// Only rebuilds when assignments for THIS item change.
  ///
  /// Usage:
  /// ```dart
  /// final assignments = ref.watch(assignmentsByItemProvider(itemId));
  /// ```
  ///
  /// Copied from [AssignmentsByItem].
  const AssignmentsByItemFamily();

  /// Watches assignments for a specific item.
  /// Only rebuilds when assignments for THIS item change.
  ///
  /// Usage:
  /// ```dart
  /// final assignments = ref.watch(assignmentsByItemProvider(itemId));
  /// ```
  ///
  /// Copied from [AssignmentsByItem].
  AssignmentsByItemProvider call(String itemId) {
    return AssignmentsByItemProvider(itemId);
  }

  @override
  AssignmentsByItemProvider getProviderOverride(
    covariant AssignmentsByItemProvider provider,
  ) {
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
  String? get name => r'assignmentsByItemProvider';
}

/// Watches assignments for a specific item.
/// Only rebuilds when assignments for THIS item change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByItemProvider(itemId));
/// ```
///
/// Copied from [AssignmentsByItem].
class AssignmentsByItemProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          AssignmentsByItem,
          List<Assignment>
        > {
  /// Watches assignments for a specific item.
  /// Only rebuilds when assignments for THIS item change.
  ///
  /// Usage:
  /// ```dart
  /// final assignments = ref.watch(assignmentsByItemProvider(itemId));
  /// ```
  ///
  /// Copied from [AssignmentsByItem].
  AssignmentsByItemProvider(String itemId)
    : this._internal(
        () => AssignmentsByItem()..itemId = itemId,
        from: assignmentsByItemProvider,
        name: r'assignmentsByItemProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$assignmentsByItemHash,
        dependencies: AssignmentsByItemFamily._dependencies,
        allTransitiveDependencies:
            AssignmentsByItemFamily._allTransitiveDependencies,
        itemId: itemId,
      );

  AssignmentsByItemProvider._internal(
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
  Stream<List<Assignment>> runNotifierBuild(
    covariant AssignmentsByItem notifier,
  ) {
    return notifier.build(itemId);
  }

  @override
  Override overrideWith(AssignmentsByItem Function() create) {
    return ProviderOverride(
      origin: this,
      override: AssignmentsByItemProvider._internal(
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
  AutoDisposeStreamNotifierProviderElement<AssignmentsByItem, List<Assignment>>
  createElement() {
    return _AssignmentsByItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignmentsByItemProvider && other.itemId == itemId;
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
mixin AssignmentsByItemRef
    on AutoDisposeStreamNotifierProviderRef<List<Assignment>> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _AssignmentsByItemProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          AssignmentsByItem,
          List<Assignment>
        >
    with AssignmentsByItemRef {
  _AssignmentsByItemProviderElement(super.provider);

  @override
  String get itemId => (origin as AssignmentsByItemProvider).itemId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
