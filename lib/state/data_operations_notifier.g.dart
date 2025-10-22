// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_operations_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isAnyOperationLoadingHash() =>
    r'390e0b4c0149e89ef7115bb3502809e7b05e4d30';

/// Convenience provider to check if any operation is currently loading.
///
/// Copied from [isAnyOperationLoading].
@ProviderFor(isAnyOperationLoading)
final isAnyOperationLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAnyOperationLoading,
  name: r'isAnyOperationLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAnyOperationLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAnyOperationLoadingRef = AutoDisposeProviderRef<bool>;
String _$isOperationLoadingHash() =>
    r'9abbacf0a9e86475bd8908f997c820fcf03d079f';

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

/// Convenience provider to check if a specific operation is loading.
///
/// Copied from [isOperationLoading].
@ProviderFor(isOperationLoading)
const isOperationLoadingProvider = IsOperationLoadingFamily();

/// Convenience provider to check if a specific operation is loading.
///
/// Copied from [isOperationLoading].
class IsOperationLoadingFamily extends Family<bool> {
  /// Convenience provider to check if a specific operation is loading.
  ///
  /// Copied from [isOperationLoading].
  const IsOperationLoadingFamily();

  /// Convenience provider to check if a specific operation is loading.
  ///
  /// Copied from [isOperationLoading].
  IsOperationLoadingProvider call(DataOperation operation) {
    return IsOperationLoadingProvider(operation);
  }

  @override
  IsOperationLoadingProvider getProviderOverride(
    covariant IsOperationLoadingProvider provider,
  ) {
    return call(provider.operation);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isOperationLoadingProvider';
}

/// Convenience provider to check if a specific operation is loading.
///
/// Copied from [isOperationLoading].
class IsOperationLoadingProvider extends AutoDisposeProvider<bool> {
  /// Convenience provider to check if a specific operation is loading.
  ///
  /// Copied from [isOperationLoading].
  IsOperationLoadingProvider(DataOperation operation)
    : this._internal(
        (ref) => isOperationLoading(ref as IsOperationLoadingRef, operation),
        from: isOperationLoadingProvider,
        name: r'isOperationLoadingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isOperationLoadingHash,
        dependencies: IsOperationLoadingFamily._dependencies,
        allTransitiveDependencies:
            IsOperationLoadingFamily._allTransitiveDependencies,
        operation: operation,
      );

  IsOperationLoadingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.operation,
  }) : super.internal();

  final DataOperation operation;

  @override
  Override overrideWith(bool Function(IsOperationLoadingRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsOperationLoadingProvider._internal(
        (ref) => create(ref as IsOperationLoadingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        operation: operation,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsOperationLoadingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsOperationLoadingProvider && other.operation == operation;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, operation.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsOperationLoadingRef on AutoDisposeProviderRef<bool> {
  /// The parameter `operation` of this provider.
  DataOperation get operation;
}

class _IsOperationLoadingProviderElement
    extends AutoDisposeProviderElement<bool>
    with IsOperationLoadingRef {
  _IsOperationLoadingProviderElement(super.provider);

  @override
  DataOperation get operation =>
      (origin as IsOperationLoadingProvider).operation;
}

String _$getOperationErrorHash() => r'733573f6acadc7e89e456a87c19d78facfa72ad8';

/// Convenience provider to get the error for a specific operation.
///
/// Copied from [getOperationError].
@ProviderFor(getOperationError)
const getOperationErrorProvider = GetOperationErrorFamily();

/// Convenience provider to get the error for a specific operation.
///
/// Copied from [getOperationError].
class GetOperationErrorFamily extends Family<Object?> {
  /// Convenience provider to get the error for a specific operation.
  ///
  /// Copied from [getOperationError].
  const GetOperationErrorFamily();

  /// Convenience provider to get the error for a specific operation.
  ///
  /// Copied from [getOperationError].
  GetOperationErrorProvider call(DataOperation operation) {
    return GetOperationErrorProvider(operation);
  }

  @override
  GetOperationErrorProvider getProviderOverride(
    covariant GetOperationErrorProvider provider,
  ) {
    return call(provider.operation);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getOperationErrorProvider';
}

/// Convenience provider to get the error for a specific operation.
///
/// Copied from [getOperationError].
class GetOperationErrorProvider extends AutoDisposeProvider<Object?> {
  /// Convenience provider to get the error for a specific operation.
  ///
  /// Copied from [getOperationError].
  GetOperationErrorProvider(DataOperation operation)
    : this._internal(
        (ref) => getOperationError(ref as GetOperationErrorRef, operation),
        from: getOperationErrorProvider,
        name: r'getOperationErrorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getOperationErrorHash,
        dependencies: GetOperationErrorFamily._dependencies,
        allTransitiveDependencies:
            GetOperationErrorFamily._allTransitiveDependencies,
        operation: operation,
      );

  GetOperationErrorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.operation,
  }) : super.internal();

  final DataOperation operation;

  @override
  Override overrideWith(
    Object? Function(GetOperationErrorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetOperationErrorProvider._internal(
        (ref) => create(ref as GetOperationErrorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        operation: operation,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Object?> createElement() {
    return _GetOperationErrorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetOperationErrorProvider && other.operation == operation;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, operation.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetOperationErrorRef on AutoDisposeProviderRef<Object?> {
  /// The parameter `operation` of this provider.
  DataOperation get operation;
}

class _GetOperationErrorProviderElement
    extends AutoDisposeProviderElement<Object?>
    with GetOperationErrorRef {
  _GetOperationErrorProviderElement(super.provider);

  @override
  DataOperation get operation =>
      (origin as GetOperationErrorProvider).operation;
}

String _$hasOperationErrorHash() => r'68348dbdb2fc87db9c46333aaeb5c8ccfd17ae78';

/// Convenience provider to check if a specific operation has an error.
///
/// Copied from [hasOperationError].
@ProviderFor(hasOperationError)
const hasOperationErrorProvider = HasOperationErrorFamily();

/// Convenience provider to check if a specific operation has an error.
///
/// Copied from [hasOperationError].
class HasOperationErrorFamily extends Family<bool> {
  /// Convenience provider to check if a specific operation has an error.
  ///
  /// Copied from [hasOperationError].
  const HasOperationErrorFamily();

  /// Convenience provider to check if a specific operation has an error.
  ///
  /// Copied from [hasOperationError].
  HasOperationErrorProvider call(DataOperation operation) {
    return HasOperationErrorProvider(operation);
  }

  @override
  HasOperationErrorProvider getProviderOverride(
    covariant HasOperationErrorProvider provider,
  ) {
    return call(provider.operation);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'hasOperationErrorProvider';
}

/// Convenience provider to check if a specific operation has an error.
///
/// Copied from [hasOperationError].
class HasOperationErrorProvider extends AutoDisposeProvider<bool> {
  /// Convenience provider to check if a specific operation has an error.
  ///
  /// Copied from [hasOperationError].
  HasOperationErrorProvider(DataOperation operation)
    : this._internal(
        (ref) => hasOperationError(ref as HasOperationErrorRef, operation),
        from: hasOperationErrorProvider,
        name: r'hasOperationErrorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$hasOperationErrorHash,
        dependencies: HasOperationErrorFamily._dependencies,
        allTransitiveDependencies:
            HasOperationErrorFamily._allTransitiveDependencies,
        operation: operation,
      );

  HasOperationErrorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.operation,
  }) : super.internal();

  final DataOperation operation;

  @override
  Override overrideWith(bool Function(HasOperationErrorRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: HasOperationErrorProvider._internal(
        (ref) => create(ref as HasOperationErrorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        operation: operation,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _HasOperationErrorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasOperationErrorProvider && other.operation == operation;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, operation.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HasOperationErrorRef on AutoDisposeProviderRef<bool> {
  /// The parameter `operation` of this provider.
  DataOperation get operation;
}

class _HasOperationErrorProviderElement extends AutoDisposeProviderElement<bool>
    with HasOperationErrorRef {
  _HasOperationErrorProviderElement(super.provider);

  @override
  DataOperation get operation =>
      (origin as HasOperationErrorProvider).operation;
}

String _$dataOperationsNotifierHash() =>
    r'f5de43b3d8fc145959d6245f5425a62db877ff31';

/// Notifier for managing CRUD operation loading states.
///
/// This notifier provides a centralized way to track loading states for all
/// CRUD operations across Items, Containers, and Assignments. It follows the
/// same pattern as AuthNotifier but extends it to handle multiple concurrent
/// operations with proper error handling.
///
/// Usage:
/// ```dart
/// // Check if item creation is loading
/// final isLoading = ref.watch(dataOperationsNotifierProvider
///   .select((state) => state.isLoading(DataOperation.itemCreate)));
///
/// // Perform an item operation
/// await ref.read(dataOperationsNotifierProvider.notifier)
///   .createItem(newItem);
/// ```
///
/// Copied from [DataOperationsNotifier].
@ProviderFor(DataOperationsNotifier)
final dataOperationsNotifierProvider =
    AutoDisposeNotifierProvider<
      DataOperationsNotifier,
      DataOperationsState
    >.internal(
      DataOperationsNotifier.new,
      name: r'dataOperationsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dataOperationsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DataOperationsNotifier = AutoDisposeNotifier<DataOperationsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
