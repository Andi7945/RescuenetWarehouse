import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_state.dart';
import 'auth_repository.dart';
import 'repository_providers.dart';

part 'auth_providers.g.dart';

/// Stream provider for authentication state changes.
/// Emits the current user when authenticated, null when not.
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}

/// Provider for the current authenticated user.
/// Returns null if not authenticated.
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authAsyncValue = ref.watch(authStateChangesProvider);
  return authAsyncValue.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Provider for the current user's name.
/// Extracts name from email prefix (before @) or display name.
@riverpod
String? currentUserName(CurrentUserNameRef ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  // Prefer display name, fallback to email prefix
  if (user.displayName != null && user.displayName!.isNotEmpty) {
    return user.displayName;
  }

  if (user.email != null) {
    return user.email!.split('@').first;
  }

  return null;
}

/// Provider to check if a user is currently authenticated.
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
}

/// Notifier for authentication operations.
/// Provides methods for sign in, sign up, sign out, and password reset.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Sign in with email and password.
  /// Returns AuthState for backwards compatibility.
  Future<AuthState> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.signInWithEmailAndPassword(email, password);
      state = const AsyncValue.data(null);
      return AuthState.success();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);

      if (e is AuthException) {
        return AuthState(
          errorCode: e.code ?? 'UNKNOWN',
          errorMessage: e.message,
        );
      } else {
        return const AuthState(
          errorCode: 'UNDEFINED',
          errorMessage: 'An unexpected error occurred. Please try again later.',
        );
      }
    }
  }

  /// Create a new user account with email, password, and display name.
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();

    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.createUserWithEmailAndPassword(
        email,
        password,
        name,
      );
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();

    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}
