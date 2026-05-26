// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateChangesHash() => r'843eb1a621041def446e0ef856583a025a5a8e47';

/// Stream provider for authentication state changes.
/// Emits the current user when authenticated, null when not.
///
/// Copied from [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = AutoDisposeStreamProvider<User?>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'9f3f123bba0ef9892f0c09fd400b20dd1f23c8dd';

/// Provider for the current authenticated user.
/// Returns null if not authenticated.
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$currentUserNameHash() => r'f3aa1bf78c5c16762cb7d8c4d9766e2f14673ca2';

/// Provider for the current user's name.
/// Extracts name from email prefix (before @) or display name.
///
/// Copied from [currentUserName].
@ProviderFor(currentUserName)
final currentUserNameProvider = AutoDisposeProvider<String?>.internal(
  currentUserName,
  name: r'currentUserNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserNameRef = AutoDisposeProviderRef<String?>;
String _$isAuthenticatedHash() => r'fe6f954f2d7938a820a402d3f97973c87930d8b5';

/// Provider to check if a user is currently authenticated.
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$isAdminHash() => r'da4f9c2642005ded55478956d1306b5b5bf8f303';

/// Returns true if the currently signed-in user is in the org's admin email list.
/// Case-insensitive. Returns false when not authenticated.
///
/// Copied from [isAdmin].
@ProviderFor(isAdmin)
final isAdminProvider = AutoDisposeProvider<bool>.internal(
  isAdmin,
  name: r'isAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAdminRef = AutoDisposeProviderRef<bool>;
String _$authNotifierHash() => r'88b3cc75387d7211bdd2363b04497fe1a3e6b299';

/// Notifier for authentication operations.
/// Provides methods for sign in, sign up, sign out, and password reset.
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AsyncValue<void>>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
