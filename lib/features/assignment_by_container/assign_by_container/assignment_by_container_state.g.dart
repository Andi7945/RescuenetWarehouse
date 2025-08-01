// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_by_container_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignmentByContainerStateHash() =>
    r'22fc7fbf783e5446fbab0a12e29470e1c5ea77a3';

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

abstract class _$AssignmentByContainerState
    extends BuildlessAutoDisposeNotifier<Map<Item, Assignment>> {
  late final String containerId;

  Map<Item, Assignment> build(String containerId);
}

/// See also [AssignmentByContainerState].
@ProviderFor(AssignmentByContainerState)
const assignmentByContainerStateProvider = AssignmentByContainerStateFamily();

/// See also [AssignmentByContainerState].
class AssignmentByContainerStateFamily extends Family<Map<Item, Assignment>> {
  /// See also [AssignmentByContainerState].
  const AssignmentByContainerStateFamily();

  /// See also [AssignmentByContainerState].
  AssignmentByContainerStateProvider call(String containerId) {
    return AssignmentByContainerStateProvider(containerId);
  }

  @override
  AssignmentByContainerStateProvider getProviderOverride(
    covariant AssignmentByContainerStateProvider provider,
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
  String? get name => r'assignmentByContainerStateProvider';
}

/// See also [AssignmentByContainerState].
class AssignmentByContainerStateProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AssignmentByContainerState,
          Map<Item, Assignment>
        > {
  /// See also [AssignmentByContainerState].
  AssignmentByContainerStateProvider(String containerId)
    : this._internal(
        () => AssignmentByContainerState()..containerId = containerId,
        from: assignmentByContainerStateProvider,
        name: r'assignmentByContainerStateProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$assignmentByContainerStateHash,
        dependencies: AssignmentByContainerStateFamily._dependencies,
        allTransitiveDependencies:
            AssignmentByContainerStateFamily._allTransitiveDependencies,
        containerId: containerId,
      );

  AssignmentByContainerStateProvider._internal(
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
  Map<Item, Assignment> runNotifierBuild(
    covariant AssignmentByContainerState notifier,
  ) {
    return notifier.build(containerId);
  }

  @override
  Override overrideWith(AssignmentByContainerState Function() create) {
    return ProviderOverride(
      origin: this,
      override: AssignmentByContainerStateProvider._internal(
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
  AutoDisposeNotifierProviderElement<
    AssignmentByContainerState,
    Map<Item, Assignment>
  >
  createElement() {
    return _AssignmentByContainerStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignmentByContainerStateProvider &&
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
mixin AssignmentByContainerStateRef
    on AutoDisposeNotifierProviderRef<Map<Item, Assignment>> {
  /// The parameter `containerId` of this provider.
  String get containerId;
}

class _AssignmentByContainerStateProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AssignmentByContainerState,
          Map<Item, Assignment>
        >
    with AssignmentByContainerStateRef {
  _AssignmentByContainerStateProviderElement(super.provider);

  @override
  String get containerId =>
      (origin as AssignmentByContainerStateProvider).containerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
