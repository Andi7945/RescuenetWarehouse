import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:rescuenet_warehouse/auth_state.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  String? get currentUserName =>
      _firebaseAuth.currentUser?.email?.split("@")[0];

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<AuthState> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      print('User signed in: ${user?.email!.toString()}');
      return AuthState.success();
    } catch (e) {
      // Handle any errors that occur
      print("Error occured: $e");
      if (e is PlatformException) {
        return AuthState(errorCode: e.code, errorMessage: e.message);
      } else if (e is FirebaseAuthException) {
        return AuthState(errorCode: e.code, errorMessage: e.message);
      } else {
        return const AuthState(
            errorCode: "UNDEFINED",
            errorMessage:
                "The error is not defined yet. Please contact the app developer to implement how to handle the error. In the mean time, please try again later.");
      }
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
