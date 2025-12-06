// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_logs_by_item_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workLogsByItemHash() => r'8dcedfa48bf3eb2d032a3f9791fa29d4ffb80f44';

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

abstract class _$WorkLogsByItem
    extends BuildlessAutoDisposeStreamNotifier<List<LogEntry>> {
  late final String itemId;

  Stream<List<LogEntry>> build(String itemId);
}

/// Watches work logs for a specific item.
/// Only rebuilds when logs for THIS item change.
///
/// Useful for item history/audit trail.
///
/// Usage:
/// ```dart
/// final itemHistory = ref.watch(workLogsByItemProvider(itemId));
/// ```
///
/// Copied from [WorkLogsByItem].
@ProviderFor(WorkLogsByItem)
const workLogsByItemProvider = WorkLogsByItemFamily();

/// Watches work logs for a specific item.
/// Only rebuilds when logs for THIS item change.
///
/// Useful for item history/audit trail.
///
/// Usage:
/// ```dart
/// final itemHistory = ref.watch(workLogsByItemProvider(itemId));
/// ```
///
/// Copied from [WorkLogsByItem].
class WorkLogsByItemFamily extends Family<AsyncValue<List<LogEntry>>> {
  /// Watches work logs for a specific item.
  /// Only rebuilds when logs for THIS item change.
  ///
  /// Useful for item history/audit trail.
  ///
  /// Usage:
  /// ```dart
  /// final itemHistory = ref.watch(workLogsByItemProvider(itemId));
  /// ```
  ///
  /// Copied from [WorkLogsByItem].
  const WorkLogsByItemFamily();

  /// Watches work logs for a specific item.
  /// Only rebuilds when logs for THIS item change.
  ///
  /// Useful for item history/audit trail.
  ///
  /// Usage:
  /// ```dart
  /// final itemHistory = ref.watch(workLogsByItemProvider(itemId));
  /// ```
  ///
  /// Copied from [WorkLogsByItem].
  WorkLogsByItemProvider call(String itemId) {
    return WorkLogsByItemProvider(itemId);
  }

  @override
  WorkLogsByItemProvider getProviderOverride(
    covariant WorkLogsByItemProvider provider,
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
  String? get name => r'workLogsByItemProvider';
}

/// Watches work logs for a specific item.
/// Only rebuilds when logs for THIS item change.
///
/// Useful for item history/audit trail.
///
/// Usage:
/// ```dart
/// final itemHistory = ref.watch(workLogsByItemProvider(itemId));
/// ```
///
/// Copied from [WorkLogsByItem].
class WorkLogsByItemProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<WorkLogsByItem, List<LogEntry>> {
  /// Watches work logs for a specific item.
  /// Only rebuilds when logs for THIS item change.
  ///
  /// Useful for item history/audit trail.
  ///
  /// Usage:
  /// ```dart
  /// final itemHistory = ref.watch(workLogsByItemProvider(itemId));
  /// ```
  ///
  /// Copied from [WorkLogsByItem].
  WorkLogsByItemProvider(String itemId)
    : this._internal(
        () => WorkLogsByItem()..itemId = itemId,
        from: workLogsByItemProvider,
        name: r'workLogsByItemProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workLogsByItemHash,
        dependencies: WorkLogsByItemFamily._dependencies,
        allTransitiveDependencies:
            WorkLogsByItemFamily._allTransitiveDependencies,
        itemId: itemId,
      );

  WorkLogsByItemProvider._internal(
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
  Stream<List<LogEntry>> runNotifierBuild(covariant WorkLogsByItem notifier) {
    return notifier.build(itemId);
  }

  @override
  Override overrideWith(WorkLogsByItem Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkLogsByItemProvider._internal(
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
  AutoDisposeStreamNotifierProviderElement<WorkLogsByItem, List<LogEntry>>
  createElement() {
    return _WorkLogsByItemProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkLogsByItemProvider && other.itemId == itemId;
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
mixin WorkLogsByItemRef
    on AutoDisposeStreamNotifierProviderRef<List<LogEntry>> {
  /// The parameter `itemId` of this provider.
  String get itemId;
}

class _WorkLogsByItemProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<WorkLogsByItem, List<LogEntry>>
    with WorkLogsByItemRef {
  _WorkLogsByItemProviderElement(super.provider);

  @override
  String get itemId => (origin as WorkLogsByItemProvider).itemId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
