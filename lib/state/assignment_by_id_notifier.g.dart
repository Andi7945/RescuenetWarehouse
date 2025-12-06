// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_by_id_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignmentByIdHash() => r'38ef5b4321c6e867e5580cf93eec522b41f07057';

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

abstract class _$AssignmentById
    extends BuildlessAutoDisposeStreamNotifier<Assignment?> {
  late final String assignmentId;

  Stream<Assignment?> build(String assignmentId);
}

/// Watches a single assignment by ID.
/// Only rebuilds when THIS specific assignment changes.
///
/// Usage:
/// ```dart
/// final assignment = ref.watch(assignmentByIdProvider(assignmentId));
/// ```
///
/// Copied from [AssignmentById].
@ProviderFor(AssignmentById)
const assignmentByIdProvider = AssignmentByIdFamily();

/// Watches a single assignment by ID.
/// Only rebuilds when THIS specific assignment changes.
///
/// Usage:
/// ```dart
/// final assignment = ref.watch(assignmentByIdProvider(assignmentId));
/// ```
///
/// Copied from [AssignmentById].
class AssignmentByIdFamily extends Family<AsyncValue<Assignment?>> {
  /// Watches a single assignment by ID.
  /// Only rebuilds when THIS specific assignment changes.
  ///
  /// Usage:
  /// ```dart
  /// final assignment = ref.watch(assignmentByIdProvider(assignmentId));
  /// ```
  ///
  /// Copied from [AssignmentById].
  const AssignmentByIdFamily();

  /// Watches a single assignment by ID.
  /// Only rebuilds when THIS specific assignment changes.
  ///
  /// Usage:
  /// ```dart
  /// final assignment = ref.watch(assignmentByIdProvider(assignmentId));
  /// ```
  ///
  /// Copied from [AssignmentById].
  AssignmentByIdProvider call(String assignmentId) {
    return AssignmentByIdProvider(assignmentId);
  }

  @override
  AssignmentByIdProvider getProviderOverride(
    covariant AssignmentByIdProvider provider,
  ) {
    return call(provider.assignmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'assignmentByIdProvider';
}

/// Watches a single assignment by ID.
/// Only rebuilds when THIS specific assignment changes.
///
/// Usage:
/// ```dart
/// final assignment = ref.watch(assignmentByIdProvider(assignmentId));
/// ```
///
/// Copied from [AssignmentById].
class AssignmentByIdProvider
    extends AutoDisposeStreamNotifierProviderImpl<AssignmentById, Assignment?> {
  /// Watches a single assignment by ID.
  /// Only rebuilds when THIS specific assignment changes.
  ///
  /// Usage:
  /// ```dart
  /// final assignment = ref.watch(assignmentByIdProvider(assignmentId));
  /// ```
  ///
  /// Copied from [AssignmentById].
  AssignmentByIdProvider(String assignmentId)
    : this._internal(
        () => AssignmentById()..assignmentId = assignmentId,
        from: assignmentByIdProvider,
        name: r'assignmentByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$assignmentByIdHash,
        dependencies: AssignmentByIdFamily._dependencies,
        allTransitiveDependencies:
            AssignmentByIdFamily._allTransitiveDependencies,
        assignmentId: assignmentId,
      );

  AssignmentByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.assignmentId,
  }) : super.internal();

  final String assignmentId;

  @override
  Stream<Assignment?> runNotifierBuild(covariant AssignmentById notifier) {
    return notifier.build(assignmentId);
  }

  @override
  Override overrideWith(AssignmentById Function() create) {
    return ProviderOverride(
      origin: this,
      override: AssignmentByIdProvider._internal(
        () => create()..assignmentId = assignmentId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        assignmentId: assignmentId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<AssignmentById, Assignment?>
  createElement() {
    return _AssignmentByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignmentByIdProvider &&
        other.assignmentId == assignmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, assignmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AssignmentByIdRef on AutoDisposeStreamNotifierProviderRef<Assignment?> {
  /// The parameter `assignmentId` of this provider.
  String get assignmentId;
}

class _AssignmentByIdProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<AssignmentById, Assignment?>
    with AssignmentByIdRef {
  _AssignmentByIdProviderElement(super.provider);

  @override
  String get assignmentId => (origin as AssignmentByIdProvider).assignmentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
