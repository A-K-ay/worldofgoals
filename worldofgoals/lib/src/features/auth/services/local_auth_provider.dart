import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import 'package:worldofgoals/src/core/database/repositories/user_repository.dart';
import 'package:worldofgoals/src/core/database/services/database_service.dart';
import '../domain/auth_provider.dart';
import 'secure_storage_service.dart';
import 'session_manager.dart';

/// Local authentication provider implementation
class LocalAuthProvider implements AuthProvider {
  final UserRepository _userRepository;
  final SecureStorageService _secureStorage;
  final SessionManager _sessionManager;
  static final _uuid = Uuid();

  LocalAuthProvider({
    UserRepository? userRepository,
    SecureStorageService? secureStorage,
    SessionManager? sessionManager,
  })  : _userRepository = userRepository ?? UserRepository(DatabaseService()),
        _secureStorage = secureStorage ?? SecureStorageService(),
        _sessionManager = sessionManager ?? SessionManager();

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        return AuthResult(
          userId: '',
          error: 'User already exists with this email',
        );
      }

      // Hash password
      final salt = BCrypt.gensalt();
      final hashedPassword = BCrypt.hashpw(password, salt);

      // Create user
      final userId = _uuid.v4();
      await _userRepository.create(User(
        id: userId,
        username: username,
        email: email,
        passwordHash: hashedPassword,
        xp: 0,
        level: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Create session
      final token = await _sessionManager.createSession(userId);
      await _secureStorage.setSessionToken(token);

      return AuthResult(userId: userId, token: token);
    } catch (e) {
      return AuthResult(userId: '', error: e.toString());
    }
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        return AuthResult(userId: '', error: 'User not found');
      }

      final passwordMatch = BCrypt.checkpw(password, user.passwordHash);
      if (!passwordMatch) {
        return AuthResult(userId: '', error: 'Invalid password');
      }

      // Create session
      final token = await _sessionManager.createSession(user.id);
      await _secureStorage.setSessionToken(token);

      return AuthResult(userId: user.id, token: token);
    } catch (e) {
      return AuthResult(userId: '', error: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    final token = await _secureStorage.getSessionToken();
    if (token != null) {
      await _sessionManager.removeSession(token);
      await _secureStorage.removeSessionToken();
    }
  }

  @override
  Future<bool> isSignedIn() async {
    final token = await _secureStorage.getSessionToken();
    if (token == null) return false;
    return _sessionManager.isValidSession(token);
  }

  @override
  Future<String?> getCurrentUserId() async {
    final token = await _secureStorage.getSessionToken();
    if (token == null) return null;
    return _sessionManager.getUserIdFromToken(token);
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) return false;

      final user = await _userRepository.read(userId);
      if (user == null) return false;

      final passwordMatch = BCrypt.checkpw(currentPassword, user.passwordHash);
      if (!passwordMatch) return false;

      // Hash new password
      final salt = BCrypt.gensalt();
      final hashedPassword = BCrypt.hashpw(newPassword, salt);

      // Update user
      await _userRepository.update(user.copyWith(
        passwordHash: hashedPassword,
        updatedAt: DateTime.now(),
      ));

      return true;
    } catch (e) {
      return false;
    }
  }
}
