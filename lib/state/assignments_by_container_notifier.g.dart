// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignments_by_container_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignmentsByContainerHash() =>
    r'eaa44b79e7810ba90c490cfe241df49840195ceb';

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

abstract class _$AssignmentsByContainer
    extends BuildlessAutoDisposeStreamNotifier<List<Assignment>> {
  late final String containerId;

  Stream<List<Assignment>> build(String containerId);
}

/// Watches assignments for a specific container.
/// Only rebuilds when assignments for THIS container change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByContainerProvider(containerId));
/// ```
///
/// Copied from [AssignmentsByContainer].
@ProviderFor(AssignmentsByContainer)
const assignmentsByContainerProvider = AssignmentsByContainerFamily();

/// Watches assignments for a specific container.
/// Only rebuilds when assignments for THIS container change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByContainerProvider(containerId));
/// ```
///
/// Copied from [AssignmentsByContainer].
class AssignmentsByContainerFamily
    extends Family<AsyncValue<List<Assignment>>> {
  /// Watches assignments for a specific container.
  /// Only rebuilds when assignments for THIS container change.
  ///
  /// Usage:
  /// ```dart
  /// final assignments = ref.watch(assignmentsByContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [AssignmentsByContainer].
  const AssignmentsByContainerFamily();

  /// Watches assignments for a specific container.
  /// Only rebuilds when assignments for THIS container change.
  ///
  /// Usage:
  /// ```dart
  /// final assignments = ref.watch(assignmentsByContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [AssignmentsByContainer].
  AssignmentsByContainerProvider call(String containerId) {
    return AssignmentsByContainerProvider(containerId);
  }

  @override
  AssignmentsByContainerProvider getProviderOverride(
    covariant AssignmentsByContainerProvider provider,
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
  String? get name => r'assignmentsByContainerProvider';
}

/// Watches assignments for a specific container.
/// Only rebuilds when assignments for THIS container change.
///
/// Usage:
/// ```dart
/// final assignments = ref.watch(assignmentsByContainerProvider(containerId));
/// ```
///
/// Copied from [AssignmentsByContainer].
class AssignmentsByContainerProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          AssignmentsByContainer,
          List<Assignment>
        > {
  /// Watches assignments for a specific container.
  /// Only rebuilds when assignments for THIS container change.
  ///
  /// Usage:
  /// ```dart
  /// final assignments = ref.watch(assignmentsByContainerProvider(containerId));
  /// ```
  ///
  /// Copied from [AssignmentsByContainer].
  AssignmentsByContainerProvider(String containerId)
    : this._internal(
        () => AssignmentsByContainer()..containerId = containerId,
        from: assignmentsByContainerProvider,
        name: r'assignmentsByContainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$assignmentsByContainerHash,
        dependencies: AssignmentsByContainerFamily._dependencies,
        allTransitiveDependencies:
            AssignmentsByContainerFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  AssignmentsByContainerProvider._internal(
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
  Stream<List<Assignment>> runNotifierBuild(
    covariant AssignmentsByContainer notifier,
  ) {
    return notifier.build(containerId);
  }

  @override
  Override overrideWith(AssignmentsByContainer Function() create) {
    return ProviderOverride(
      origin: this,
      override: AssignmentsByContainerProvider._internal(
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
  AutoDisposeStreamNotifierProviderElement<
    AssignmentsByContainer,
    List<Assignment>
  >
  createElement() {
    return _AssignmentsByContainerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignmentsByContainerProvider &&
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
mixin AssignmentsByContainerRef
    on AutoDisposeStreamNotifierProviderRef<List<Assignment>> {
  /// The parameter `containerId` of this provider.
  String get containerId;
}

class _AssignmentsByContainerProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          AssignmentsByContainer,
          List<Assignment>
        >
    with AssignmentsByContainerRef {
  _AssignmentsByContainerProviderElement(super.provider);

  @override
  String get containerId =>
      (origin as AssignmentsByContainerProvider).containerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
