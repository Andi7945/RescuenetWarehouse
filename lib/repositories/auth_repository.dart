import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for authentication operations.
/// Provides a clean abstraction over Firebase Auth with testable interfaces.
abstract class AuthRepository {
  /// Stream of authentication state changes.
  /// Emits user when authenticated, null when not authenticated.
  Stream<User?> get authStateChanges;

  /// Currently authenticated user, null if not authenticated.
  User? get currentUser;

  /// Sign in with email and password.
  /// Returns the authenticated user or null if sign in failed.
  /// Throws AuthException on errors.
  Future<User?> signInWithEmailAndPassword(String email, String password);

  /// Create a new user account with email, password and display name.
  /// Returns the created user or null if registration failed.
  /// Throws AuthException on errors.
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  );

  /// Sign out the current user.
  /// Throws AuthException on errors.
  Future<void> signOut();

  /// Send password reset email to the specified email address.
  /// Throws AuthException on errors.
  Future<void> sendPasswordResetEmail(String email);
}

/// Exception thrown by AuthRepository implementations.
class AuthException implements Exception {
  final String message;
  final String? code;
  final Object? originalException;

  const AuthException(this.message, {this.code, this.originalException});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}
