// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'53a3524e4f21d848d157dc923be4dc8ffb98261c';

/// Provider for AuthRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
///
/// Copied from [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$itemRepositoryHash() => r'0a5876582b27afb1b6c977ec22b637fee0ba5fe1';

/// Provider for ItemRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
///
/// Copied from [itemRepository].
@ProviderFor(itemRepository)
final itemRepositoryProvider = AutoDisposeProvider<ItemRepository>.internal(
  itemRepository,
  name: r'itemRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$itemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ItemRepositoryRef = AutoDisposeProviderRef<ItemRepository>;
String _$containerRepositoryHash() =>
    r'4668e2138c592ef902c1c1598420d7f121aa006d';

/// Provider for ContainerRepository.
/// Returns Firebase implementation in production, Mock implementation in tests.
///
/// Copied from [containerRepository].
@ProviderFor(containerRepository)
final containerRepositoryProvider =
    AutoDisposeProvider<ContainerRepository>.internal(
      containerRepository,
      name: r'containerRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$containerRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContainerRepositoryRef = AutoDisposeProviderRef<ContainerRepository>;
String _$isMockModeHash() => r'27486b2a316b9b4f942ee7f5e56db20c6c727f89';

/// Utility provider to check if we're running in mock mode.
/// Useful for conditional behavior in the app.
///
/// Copied from [isMockMode].
@ProviderFor(isMockMode)
final isMockModeProvider = AutoDisposeProvider<bool>.internal(
  isMockMode,
  name: r'isMockModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isMockModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsMockModeRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
