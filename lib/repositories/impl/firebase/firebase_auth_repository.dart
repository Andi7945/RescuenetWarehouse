import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../auth_repository.dart';

/// Firebase implementation of AuthRepository.
/// Wraps FirebaseAuth with error handling and type conversion.
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await result.user!.reload();
      }
      
      return result.user;
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw _convertException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _convertException(e);
    }
  }

  /// Converts Firebase and platform exceptions to AuthException.
  AuthException _convertException(Object exception) {
    if (exception is FirebaseAuthException) {
      return AuthException(
        exception.message ?? 'Firebase Auth error occurred',
        code: exception.code,
        originalException: exception,
      );
    } else if (exception is PlatformException) {
      return AuthException(
        exception.message ?? 'Platform error occurred',
        code: exception.code,
        originalException: exception,
      );
    } else {
      return AuthException(
        'An unexpected error occurred during authentication',
        originalException: exception,
      );
    }
  }
}