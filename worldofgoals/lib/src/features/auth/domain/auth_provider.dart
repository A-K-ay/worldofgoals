/// Authentication result containing user info and token
class AuthResult {
  final String userId;
  final String? token;
  final String? error;

  AuthResult({
    required this.userId,
    this.token,
    this.error,
  });

  bool get isSuccess => error == null;
}

/// Interface for authentication providers
abstract class AuthProvider {
  /// Register a new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  });

  /// Sign in an existing user
  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Check if a user is currently signed in
  Future<bool> isSignedIn();

  /// Get the current user's ID
  Future<String?> getCurrentUserId();

  /// Change user's password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
