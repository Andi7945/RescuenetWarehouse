// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debounced_data_operations_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isAnyDebouncedOperationLoadingHash() =>
    r'c17cc536484a58d92c542c6664d849984c78cd9d';

/// Convenience provider to check if any operation is currently loading (with debouncing)
///
/// Copied from [isAnyDebouncedOperationLoading].
@ProviderFor(isAnyDebouncedOperationLoading)
final isAnyDebouncedOperationLoadingProvider =
    AutoDisposeProvider<bool>.internal(
      isAnyDebouncedOperationLoading,
      name: r'isAnyDebouncedOperationLoadingProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$isAnyDebouncedOperationLoadingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAnyDebouncedOperationLoadingRef = AutoDisposeProviderRef<bool>;
String _$isDebouncedOperationLoadingHash() =>
    r'04b9f635ec0487a1235183bcd0289e1a60cf7eee';

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

/// Convenience provider to check if a specific operation is loading (with debouncing)
///
/// Copied from [isDebouncedOperationLoading].
@ProviderFor(isDebouncedOperationLoading)
const isDebouncedOperationLoadingProvider = IsDebouncedOperationLoadingFamily();

/// Convenience provider to check if a specific operation is loading (with debouncing)
///
/// Copied from [isDebouncedOperationLoading].
class IsDebouncedOperationLoadingFamily extends Family<bool> {
  /// Convenience provider to check if a specific operation is loading (with debouncing)
  ///
  /// Copied from [isDebouncedOperationLoading].
  const IsDebouncedOperationLoadingFamily();

  /// Convenience provider to check if a specific operation is loading (with debouncing)
  ///
  /// Copied from [isDebouncedOperationLoading].
  IsDebouncedOperationLoadingProvider call(DataOperation operation) {
    return IsDebouncedOperationLoadingProvider(operation);
  }

  @override
  IsDebouncedOperationLoadingProvider getProviderOverride(
    covariant IsDebouncedOperationLoadingProvider provider,
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
  String? get name => r'isDebouncedOperationLoadingProvider';
}

/// Convenience provider to check if a specific operation is loading (with debouncing)
///
/// Copied from [isDebouncedOperationLoading].
class IsDebouncedOperationLoadingProvider extends AutoDisposeProvider<bool> {
  /// Convenience provider to check if a specific operation is loading (with debouncing)
  ///
  /// Copied from [isDebouncedOperationLoading].
  IsDebouncedOperationLoadingProvider(DataOperation operation)
    : this._internal(
        (ref) => isDebouncedOperationLoading(
          ref as IsDebouncedOperationLoadingRef,
          operation,
        ),
        from: isDebouncedOperationLoadingProvider,
        name: r'isDebouncedOperationLoadingProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$isDebouncedOperationLoadingHash,
        dependencies: IsDebouncedOperationLoadingFamily._dependencies,
        allTransitiveDependencies:
            IsDebouncedOperationLoadingFamily._allTransitiveDependencies,
        operation: operation,
      );

  IsDebouncedOperationLoadingProvider._internal(
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
    bool Function(IsDebouncedOperationLoadingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsDebouncedOperationLoadingProvider._internal(
        (ref) => create(ref as IsDebouncedOperationLoadingRef),
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
    return _IsDebouncedOperationLoadingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsDebouncedOperationLoadingProvider &&
        other.operation == operation;
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
mixin IsDebouncedOperationLoadingRef on AutoDisposeProviderRef<bool> {
  /// The parameter `operation` of this provider.
  DataOperation get operation;
}

class _IsDebouncedOperationLoadingProviderElement
    extends AutoDisposeProviderElement<bool>
    with IsDebouncedOperationLoadingRef {
  _IsDebouncedOperationLoadingProviderElement(super.provider);

  @override
  DataOperation get operation =>
      (origin as IsDebouncedOperationLoadingProvider).operation;
}

String _$getDebouncedOperationErrorHash() =>
    r'42b1737450c96710e5a6971d0509380aeb1ccb18';

/// Convenience provider to get the error for a specific operation (with debouncing)
///
/// Copied from [getDebouncedOperationError].
@ProviderFor(getDebouncedOperationError)
const getDebouncedOperationErrorProvider = GetDebouncedOperationErrorFamily();

/// Convenience provider to get the error for a specific operation (with debouncing)
///
/// Copied from [getDebouncedOperationError].
class GetDebouncedOperationErrorFamily extends Family<Object?> {
  /// Convenience provider to get the error for a specific operation (with debouncing)
  ///
  /// Copied from [getDebouncedOperationError].
  const GetDebouncedOperationErrorFamily();

  /// Convenience provider to get the error for a specific operation (with debouncing)
  ///
  /// Copied from [getDebouncedOperationError].
  GetDebouncedOperationErrorProvider call(DataOperation operation) {
    return GetDebouncedOperationErrorProvider(operation);
  }

  @override
  GetDebouncedOperationErrorProvider getProviderOverride(
    covariant GetDebouncedOperationErrorProvider provider,
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
  String? get name => r'getDebouncedOperationErrorProvider';
}

/// Convenience provider to get the error for a specific operation (with debouncing)
///
/// Copied from [getDebouncedOperationError].
class GetDebouncedOperationErrorProvider extends AutoDisposeProvider<Object?> {
  /// Convenience provider to get the error for a specific operation (with debouncing)
  ///
  /// Copied from [getDebouncedOperationError].
  GetDebouncedOperationErrorProvider(DataOperation operation)
    : this._internal(
        (ref) => getDebouncedOperationError(
          ref as GetDebouncedOperationErrorRef,
          operation,
        ),
        from: getDebouncedOperationErrorProvider,
        name: r'getDebouncedOperationErrorProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$getDebouncedOperationErrorHash,
        dependencies: GetDebouncedOperationErrorFamily._dependencies,
        allTransitiveDependencies:
            GetDebouncedOperationErrorFamily._allTransitiveDependencies,
        operation: operation,
      );

  GetDebouncedOperationErrorProvider._internal(
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
    Object? Function(GetDebouncedOperationErrorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetDebouncedOperationErrorProvider._internal(
        (ref) => create(ref as GetDebouncedOperationErrorRef),
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
    return _GetDebouncedOperationErrorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetDebouncedOperationErrorProvider &&
        other.operation == operation;
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
mixin GetDebouncedOperationErrorRef on AutoDisposeProviderRef<Object?> {
  /// The parameter `operation` of this provider.
  DataOperation get operation;
}

class _GetDebouncedOperationErrorProviderElement
    extends AutoDisposeProviderElement<Object?>
    with GetDebouncedOperationErrorRef {
  _GetDebouncedOperationErrorProviderElement(super.provider);

  @override
  DataOperation get operation =>
      (origin as GetDebouncedOperationErrorProvider).operation;
}

String _$hasDebouncedOperationErrorHash() =>
    r'0675681da4d6c3cc8569da5b9b320b64f8dbc08c';

/// Convenience provider to check if a specific operation has an error (with debouncing)
///
/// Copied from [hasDebouncedOperationError].
@ProviderFor(hasDebouncedOperationError)
const hasDebouncedOperationErrorProvider = HasDebouncedOperationErrorFamily();

/// Convenience provider to check if a specific operation has an error (with debouncing)
///
/// Copied from [hasDebouncedOperationError].
class HasDebouncedOperationErrorFamily extends Family<bool> {
  /// Convenience provider to check if a specific operation has an error (with debouncing)
  ///
  /// Copied from [hasDebouncedOperationError].
  const HasDebouncedOperationErrorFamily();

  /// Convenience provider to check if a specific operation has an error (with debouncing)
  ///
  /// Copied from [hasDebouncedOperationError].
  HasDebouncedOperationErrorProvider call(DataOperation operation) {
    return HasDebouncedOperationErrorProvider(operation);
  }

  @override
  HasDebouncedOperationErrorProvider getProviderOverride(
    covariant HasDebouncedOperationErrorProvider provider,
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
  String? get name => r'hasDebouncedOperationErrorProvider';
}

/// Convenience provider to check if a specific operation has an error (with debouncing)
///
/// Copied from [hasDebouncedOperationError].
class HasDebouncedOperationErrorProvider extends AutoDisposeProvider<bool> {
  /// Convenience provider to check if a specific operation has an error (with debouncing)
  ///
  /// Copied from [hasDebouncedOperationError].
  HasDebouncedOperationErrorProvider(DataOperation operation)
    : this._internal(
        (ref) => hasDebouncedOperationError(
          ref as HasDebouncedOperationErrorRef,
          operation,
        ),
        from: hasDebouncedOperationErrorProvider,
        name: r'hasDebouncedOperationErrorProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$hasDebouncedOperationErrorHash,
        dependencies: HasDebouncedOperationErrorFamily._dependencies,
        allTransitiveDependencies:
            HasDebouncedOperationErrorFamily._allTransitiveDependencies,
        operation: operation,
      );

  HasDebouncedOperationErrorProvider._internal(
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
    bool Function(HasDebouncedOperationErrorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasDebouncedOperationErrorProvider._internal(
        (ref) => create(ref as HasDebouncedOperationErrorRef),
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
    return _HasDebouncedOperationErrorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasDebouncedOperationErrorProvider &&
        other.operation == operation;
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
mixin HasDebouncedOperationErrorRef on AutoDisposeProviderRef<bool> {
  /// The parameter `operation` of this provider.
  DataOperation get operation;
}

class _HasDebouncedOperationErrorProviderElement
    extends AutoDisposeProviderElement<bool>
    with HasDebouncedOperationErrorRef {
  _HasDebouncedOperationErrorProviderElement(super.provider);

  @override
  DataOperation get operation =>
      (origin as HasDebouncedOperationErrorProvider).operation;
}

String _$debouncedDataOperationsNotifierHash() =>
    r'34d19de9708133493a86031334fa2d6b1598ead9';

/// Enhanced notifier that combines DataOperationsNotifier with debounced loading
///
/// This provides the same functionality as DataOperationsNotifier but with
/// intelligent loading state management that prevents loading flashes for
/// fast operations while maintaining proper feedback for longer operations.
///
/// Copied from [DebouncedDataOperationsNotifier].
@ProviderFor(DebouncedDataOperationsNotifier)
final debouncedDataOperationsNotifierProvider = AutoDisposeNotifierProvider<
  DebouncedDataOperationsNotifier,
  DataOperationsState
>.internal(
  DebouncedDataOperationsNotifier.new,
  name: r'debouncedDataOperationsNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$debouncedDataOperationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DebouncedDataOperationsNotifier =
    AutoDisposeNotifier<DataOperationsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
