// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_logs_by_container_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workLogsByContainerHash() =>
    r'0ae83bf3110dd89e23ac887d528785e2a6c32230';

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

abstract class _$WorkLogsByContainer
    extends BuildlessAutoDisposeStreamNotifier<List<LogEntry>> {
  late final String containerId;

  Stream<List<LogEntry>> build(String containerId);
}

/// Watches work logs for a specific container.
/// Only rebuilds when logs for THIS container change.
///
/// Useful for container history/audit trail.
///
/// Usage:
/// ```dart
/// final containerHistory = ref.watch(workLogsByContainerProvider(containerId));
/// ```
///
/// Copied from [WorkLogsByContainer].
@ProviderFor(WorkLogsByContainer)
const workLogsByContainerProvider = WorkLogsByContainerFamily();

/// Watches work logs for a specific container.
/// Only rebuilds when logs for THIS container change.
///
/// Useful for container history/audit trail.
///
/// Usage:
/// ```dart
/// final containerHistory = ref.watch(workLogsByContainerProvider(containerId));
/// ```
///
/// Copied from [WorkLogsByContainer].
class WorkLogsByContainerFamily extends Family<AsyncValue<List<LogEntry>>> {
  /// Watches work logs for a specific container.
  /// Only rebuilds when logs for THIS container change.
  ///
  /// Useful for container history/audit trail.
  ///
  /// Usage:
  /// ```dart
  /// final containerHistory = ref.watch(workLogsByContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [WorkLogsByContainer].
  const WorkLogsByContainerFamily();

  /// Watches work logs for a specific container.
  /// Only rebuilds when logs for THIS container change.
  ///
  /// Useful for container history/audit trail.
  ///
  /// Usage:
  /// ```dart
  /// final containerHistory = ref.watch(workLogsByContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [WorkLogsByContainer].
  WorkLogsByContainerProvider call(String containerId) {
    return WorkLogsByContainerProvider(containerId);
  }

  @override
  WorkLogsByContainerProvider getProviderOverride(
    covariant WorkLogsByContainerProvider provider,
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
  String? get name => r'workLogsByContainerProvider';
}

/// Watches work logs for a specific container.
/// Only rebuilds when logs for THIS container change.
///
/// Useful for container history/audit trail.
///
/// Usage:
/// ```dart
/// final containerHistory = ref.watch(workLogsByContainerProvider(containerId));
/// ```
///
/// Copied from [WorkLogsByContainer].
class WorkLogsByContainerProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          WorkLogsByContainer,
          List<LogEntry>
        > {
  /// Watches work logs for a specific container.
  /// Only rebuilds when logs for THIS container change.
  ///
  /// Useful for container history/audit trail.
  ///
  /// Usage:
  /// ```dart
  /// final containerHistory = ref.watch(workLogsByContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [WorkLogsByContainer].
  WorkLogsByContainerProvider(String containerId)
    : this._internal(
        () => WorkLogsByContainer()..containerId = containerId,
        from: workLogsByContainerProvider,
        name: r'workLogsByContainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workLogsByContainerHash,
        dependencies: WorkLogsByContainerFamily._dependencies,
        allTransitiveDependencies:
            WorkLogsByContainerFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  WorkLogsByContainerProvider._internal(
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
  Stream<List<LogEntry>> runNotifierBuild(
    covariant WorkLogsByContainer notifier,
  ) {
    return notifier.build(containerId);
  }

  @override
  Override overrideWith(WorkLogsByContainer Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkLogsByContainerProvider._internal(
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
  AutoDisposeStreamNotifierProviderElement<WorkLogsByContainer, List<LogEntry>>
  createElement() {
    return _WorkLogsByContainerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkLogsByContainerProvider &&
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
mixin WorkLogsByContainerRef
    on AutoDisposeStreamNotifierProviderRef<List<LogEntry>> {
  /// The parameter `containerId` of this provider.
  String get containerId;
}

class _WorkLogsByContainerProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          WorkLogsByContainer,
          List<LogEntry>
        >
    with WorkLogsByContainerRef {
  _WorkLogsByContainerProviderElement(super.provider);

  @override
  String get containerId => (origin as WorkLogsByContainerProvider).containerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
