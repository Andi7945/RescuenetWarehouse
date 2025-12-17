// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_logs_by_user_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workLogsByUserHash() => r'db67af41a4a2d417b6fcef56b38df6af917d0542';

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

abstract class _$WorkLogsByUser
    extends BuildlessAutoDisposeStreamNotifier<List<LogEntry>> {
  late final String userId;

  Stream<List<LogEntry>> build(String userId);
}

/// Watches work logs for a specific user.
/// Only rebuilds when logs for THIS user change.
///
/// Usage:
/// ```dart
/// final userLogs = ref.watch(workLogsByUserProvider(userId));
/// ```
///
/// Copied from [WorkLogsByUser].
@ProviderFor(WorkLogsByUser)
const workLogsByUserProvider = WorkLogsByUserFamily();

/// Watches work logs for a specific user.
/// Only rebuilds when logs for THIS user change.
///
/// Usage:
/// ```dart
/// final userLogs = ref.watch(workLogsByUserProvider(userId));
/// ```
///
/// Copied from [WorkLogsByUser].
class WorkLogsByUserFamily extends Family<AsyncValue<List<LogEntry>>> {
  /// Watches work logs for a specific user.
  /// Only rebuilds when logs for THIS user change.
  ///
  /// Usage:
  /// ```dart
  /// final userLogs = ref.watch(workLogsByUserProvider(userId));
  /// ```
  ///
  /// Copied from [WorkLogsByUser].
  const WorkLogsByUserFamily();

  /// Watches work logs for a specific user.
  /// Only rebuilds when logs for THIS user change.
  ///
  /// Usage:
  /// ```dart
  /// final userLogs = ref.watch(workLogsByUserProvider(userId));
  /// ```
  ///
  /// Copied from [WorkLogsByUser].
  WorkLogsByUserProvider call(String userId) {
    return WorkLogsByUserProvider(userId);
  }

  @override
  WorkLogsByUserProvider getProviderOverride(
    covariant WorkLogsByUserProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workLogsByUserProvider';
}

/// Watches work logs for a specific user.
/// Only rebuilds when logs for THIS user change.
///
/// Usage:
/// ```dart
/// final userLogs = ref.watch(workLogsByUserProvider(userId));
/// ```
///
/// Copied from [WorkLogsByUser].
class WorkLogsByUserProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<WorkLogsByUser, List<LogEntry>> {
  /// Watches work logs for a specific user.
  /// Only rebuilds when logs for THIS user change.
  ///
  /// Usage:
  /// ```dart
  /// final userLogs = ref.watch(workLogsByUserProvider(userId));
  /// ```
  ///
  /// Copied from [WorkLogsByUser].
  WorkLogsByUserProvider(String userId)
    : this._internal(
        () => WorkLogsByUser()..userId = userId,
        from: workLogsByUserProvider,
        name: r'workLogsByUserProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workLogsByUserHash,
        dependencies: WorkLogsByUserFamily._dependencies,
        allTransitiveDependencies:
            WorkLogsByUserFamily._allTransitiveDependencies,
        userId: userId,
      );

  WorkLogsByUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Stream<List<LogEntry>> runNotifierBuild(covariant WorkLogsByUser notifier) {
    return notifier.build(userId);
  }

  @override
  Override overrideWith(WorkLogsByUser Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkLogsByUserProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<WorkLogsByUser, List<LogEntry>>
  createElement() {
    return _WorkLogsByUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkLogsByUserProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkLogsByUserRef
    on AutoDisposeStreamNotifierProviderRef<List<LogEntry>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _WorkLogsByUserProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<WorkLogsByUser, List<LogEntry>>
    with WorkLogsByUserRef {
  _WorkLogsByUserProviderElement(super.provider);

  @override
  String get userId => (origin as WorkLogsByUserProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
