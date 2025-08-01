import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth_repository.dart';

/// Mock implementation of AuthRepository for testing.
/// Simulates authentication behavior without Firebase dependencies.
class MockAuthRepository implements AuthRepository {
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  User? _currentUser;
  final Map<String, MockUser> _users = {};

  MockAuthRepository() {
    // Add some default test users
    _users['test@rescuenet.net'] = MockUser(
      uid: 'test-uid-1',
      email: 'test@rescuenet.net',
      displayName: 'Test User',
      password: 'password123',
    );
    _users['admin@rescuenet.net'] = MockUser(
      uid: 'admin-uid-1',
      email: 'admin@rescuenet.net',
      displayName: 'Admin User',
      password: 'admin123',
    );
  }

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    
    final mockUser = _users[email];
    if (mockUser == null) {
      throw const AuthException('User not found', code: 'user-not-found');
    }
    
    if (mockUser.password != password) {
      throw const AuthException('Wrong password', code: 'wrong-password');
    }
    
    _currentUser = mockUser;
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    
    if (_users.containsKey(email)) {
      throw const AuthException('Email already in use', code: 'email-already-in-use');
    }
    
    // Validate email domain (like the real app)
    if (!email.endsWith('@rescuenet.net')) {
      throw const AuthException('Invalid email domain', code: 'invalid-email');
    }
    
    final newUser = MockUser(
      uid: 'mock-uid-${_users.length + 1}',
      email: email,
      displayName: name,
      password: password,
    );
    
    _users[email] = newUser;
    _currentUser = newUser;
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate network delay
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    
    if (!_users.containsKey(email)) {
      throw const AuthException('User not found', code: 'user-not-found');
    }
    
    // In a real implementation, this would send an email
    // Mock implementation just succeeds silently
  }

  /// Add a test user for specific test scenarios
  void addTestUser(String email, String password, {String? displayName}) {
    _users[email] = MockUser(
      uid: 'test-uid-${_users.length + 1}',
      email: email,
      displayName: displayName ?? email.split('@').first,
      password: password,
    );
  }

  /// Clear all users (useful for test cleanup)
  void clearUsers() {
    _users.clear();
    _currentUser = null;
    _authStateController.add(null);
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

/// Mock implementation of Firebase User for testing
class MockUser implements User {
  @override
  final String uid;
  
  @override
  final String? email;
  
  @override
  final String? displayName;
  
  final String password; // Not part of Firebase User, but useful for mock

  MockUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.password,
  });

  // Implement required User properties with reasonable defaults
  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  UserMetadata get metadata => MockUserMetadata();

  @override
  String? get phoneNumber => null;

  @override
  String? get photoURL => null;

  @override
  List<UserInfo> get providerData => [];

  @override
  String? get refreshToken => 'mock-refresh-token';

  @override
  String? get tenantId => null;

  // Implement required User methods with mock behavior
  @override
  Future<void> delete() async {
    throw UnimplementedError('delete not implemented in mock');
  }

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    return 'mock-id-token-$uid';
  }

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async {
    throw UnimplementedError('getIdTokenResult not implemented in mock');
  }

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    throw UnimplementedError('linkWithCredential not implemented in mock');
  }

  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) async {
    throw UnimplementedError('linkWithPhoneNumber not implemented in mock');
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    throw UnimplementedError('reauthenticateWithCredential not implemented in mock');
  }

  @override
  Future<void> reload() async {
    // Mock implementation - no-op
  }

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {
    // Mock implementation - no-op
  }

  @override
  Future<User> unlink(String providerId) async {
    throw UnimplementedError('unlink not implemented in mock');
  }

  @override
  Future<void> updateDisplayName(String? displayName) async {
    // Mock implementation - no-op in this simple mock
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    throw UnimplementedError('updateEmail not implemented in mock');
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    throw UnimplementedError('updatePassword not implemented in mock');
  }

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {
    throw UnimplementedError('updatePhoneNumber not implemented in mock');
  }

  @override
  Future<void> updatePhotoURL(String? photoURL) async {
    // Mock implementation - no-op
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    // Mock implementation - no-op
  }

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {
    throw UnimplementedError('verifyBeforeUpdateEmail not implemented in mock');
  }

  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) async {
    throw UnimplementedError('linkWithPopup not implemented in mock');
  }

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    throw UnimplementedError('linkWithProvider not implemented in mock');
  }

  @override
  Future<void> linkWithRedirect(AuthProvider provider) async {
    throw UnimplementedError('linkWithRedirect not implemented in mock');
  }

  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) async {
    throw UnimplementedError('reauthenticateWithPopup not implemented in mock');
  }

  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) async {
    throw UnimplementedError('reauthenticateWithProvider not implemented in mock');
  }

  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) async {
    throw UnimplementedError('reauthenticateWithRedirect not implemented in mock');
  }

  @override
  MultiFactor get multiFactor => throw UnimplementedError('multiFactor not implemented in mock');
}

/// Mock implementation of UserMetadata
class MockUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now().subtract(const Duration(days: 30));

  @override
  DateTime? get lastSignInTime => DateTime.now().subtract(const Duration(hours: 1));
}