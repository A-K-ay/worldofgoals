import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:worldofgoals/src/features/auth/domain/auth_provider.dart';
import 'package:worldofgoals/src/features/auth/services/session_manager.dart';
import 'package:worldofgoals/src/features/auth/services/secure_storage_service.dart';
import '../../../core/database/database.dart';
import '../../../core/database/repositories/user_repository.dart';
import '../../../core/database/services/database_service.dart';
import '../../../core/utils/app_utils.dart';

class LocalAuthProvider implements AuthProvider {
  static final LocalAuthProvider _instance = LocalAuthProvider._internal();
  final _uuid = const Uuid();
  late final UserRepository _userRepository;
  final _sessionManager = SessionManager();
  final _secureStorage = SecureStorageService();
  final _databaseService = DatabaseService();

  factory LocalAuthProvider() {
    return _instance;
  }

  LocalAuthProvider._internal() {
    _userRepository = UserRepository(_databaseService);
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      AppUtils.logger.i('Attempting to register user: $email');

      // Check if user exists
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        AppUtils.logger.w('User already exists: $email');
        return AuthResult(
          userId: '',
          error: 'A user with this email already exists',
        );
      }

      // Hash password
      final salt = BCrypt.gensalt();
      final hashedPassword = BCrypt.hashpw(password, salt);

      // Create user
      final userId = _uuid.v4();
      final user = UsersCompanion.insert(
        id: userId,
        username: username,
        email: email,
        passwordHash: hashedPassword,
        xp: const Value(0),
        level: const Value(1),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      await _userRepository.create(user);

      // Create session
      final token = await _sessionManager.createSession(userId);
      await _secureStorage.setSessionToken(token);

      AppUtils.logger.i('User registered successfully: $userId');
      return AuthResult(userId: userId, token: token);
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Registration failed',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult(userId: '', error: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AppUtils.logger.i('Attempting to sign in user: $email');

      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        AppUtils.logger.w('User not found: $email');
        return AuthResult(userId: '', error: 'Invalid email or password');
      }

      final passwordMatch = BCrypt.checkpw(password, user.passwordHash);
      if (!passwordMatch) {
        AppUtils.logger.w('Invalid password for user: $email');
        return AuthResult(userId: '', error: 'Invalid email or password');
      }

      // Create session
      final token = await _sessionManager.createSession(user.id);
      await _secureStorage.setSessionToken(token);

      AppUtils.logger.i('User signed in successfully: ${user.id}');
      return AuthResult(userId: user.id, token: token);
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Sign in failed',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthResult(userId: '', error: 'Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return isAuthenticated();
  }

  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.getSessionToken();
      if (token == null || token.isEmpty) return false;

      final userId = await _sessionManager.getUserIdFromToken(token);
      if (userId == null) {
        await _secureStorage.removeSessionToken();
        return false;
      }

      final user = await _userRepository.read(userId);
      return user != null;
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to check authentication status',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      AppUtils.logger.i('Signing out user');
      final token = await _secureStorage.getSessionToken();
      if (token != null) {
        await _sessionManager.removeSession(token);
      }
      await _secureStorage.removeSessionToken();
      AppUtils.logger.i('User signed out successfully');
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Sign out failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    try {
      final token = await _secureStorage.getSessionToken();
      if (token == null || token.isEmpty) return null;

      return _sessionManager.getUserIdFromToken(token);
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to get current user ID',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      AppUtils.logger.i('Attempting to change password');
      final userId = await getCurrentUserId();
      if (userId == null) {
        AppUtils.logger.w('No current user found');
        return false;
      }

      final user = await _userRepository.read(userId);
      if (user == null) {
        AppUtils.logger.w('User not found: $userId');
        return false;
      }

      final passwordMatch = BCrypt.checkpw(currentPassword, user.passwordHash);
      if (!passwordMatch) {
        AppUtils.logger.w('Invalid current password');
        return false;
      }

      // Hash new password
      final salt = BCrypt.gensalt();
      final hashedPassword = BCrypt.hashpw(newPassword, salt);

      // Update user
      final updatedUser = user.copyWith(
        passwordHash: hashedPassword,
        updatedAt: DateTime.now(),
      );

      await _userRepository.update(updatedUser);
      AppUtils.logger.i('Password changed successfully');
      return true;
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to change password',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
