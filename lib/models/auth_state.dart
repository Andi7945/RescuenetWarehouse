class AuthState {
  AuthState.success() : errorCode = null, errorMessage = null;

  const AuthState({required this.errorCode, required this.errorMessage});

  final String? errorCode;
  final String? errorMessage;
}
