import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<bool> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      print('User signed in: ${user?.email!.toString()}');
      return true;
    } catch (e) {
      // Handle any errors that occur
      if(e is PlatformException) {
        switch (e.code) {
          case "ERROR_INVALID_EMAIL":
            print("The email address is not valid.");
            break;
          case "ERROR_WRONG_PASSWORD":
            print("The password is not valid.");
            break;
          case "ERROR_USER_NOT_FOUND":
            print(
                "No user corresponding to the given email address was found.");
            break;
          case "ERROR_USER_DISABLED":
            print("The user with the email address has been disabled.");
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            print(
                "Too many requests have been made to sign in with this email address.");
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            print(
                "This operation is not allowed. You must enable this service in the console.");
            break;
          default:
            print("An undefined Error happened.");
        }
      } else {
        print("Else: $e");
      }
    }
    return false;
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