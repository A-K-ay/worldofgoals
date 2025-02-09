import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/app_utils.dart'; // Import AppUtils
import 'secure_storage_service.dart';

/// Manages user sessions and tokens
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  final Map<String, _Session> _sessions = {};
  static const _sessionDuration = Duration(days: 7);
  static final _uuid = Uuid();
  final _secureStorageService = SecureStorageService();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  /// Create a new session for a user
  Future<String> createSession(String userId) async {
    final token = _generateToken(userId);
    await _secureStorageService
        .setSessionToken(token); // Store token in secure storage
    _sessions[token] = _Session(
      userId: userId,
      expiresAt: DateTime.now().add(_sessionDuration),
    );
    return token;
  }

  /// Check if a session is valid
  bool isValidSession(String? storedToken) {
    if (storedToken == null) return false;
    final decodedToken = _decodeToken(storedToken);
    if (decodedToken == null) return false;

    final expiryTimestamp = decodedToken['expiryTimestamp'];
    if (expiryTimestamp == null) return false;

    final expiryDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(expiryTimestamp));
    if (DateTime.now().isAfter(expiryDate)) {
      _secureStorageService
          .removeSessionToken(); // Remove expired token from secure storage
      return false;
    }
    return true;
  }

  /// Get user ID from token
  String? getUserIdFromToken(String? token) {
    if (token == null) return null;
    if (!isValidSession(token)) return null; // Validate session first
    final decodedToken = _decodeToken(token);
    if (decodedToken == null) return null;
    return decodedToken['userId'];
  }

  /// Remove a session
  Future<void> removeSession(String token) async {
    _sessions.remove(token);
    await _secureStorageService
        .removeSessionToken(); // Remove token from secure storage
  }

  /// Generate a secure token
  String _generateToken(String userId) {
    final random = _uuid.v4();
    final now = DateTime.now();
    final expiryTime = now.add(_sessionDuration);
    final expiryTimestamp = expiryTime.millisecondsSinceEpoch.toString();
    final data =
        '$expiryTimestamp|$userId|$random|$now'; // Use '|' as separator
    return base64.encode(utf8.encode(data)); // Encode to base64
  }

  /// Check for existing session in secure storage
  Future<String?> checkForExistingSession() async {
    AppUtils.logger.i('Checking for existing session...'); // Add log
    final storedToken = await _secureStorageService.getSessionToken();
    if (storedToken != null) {
      AppUtils.logger.i('Stored token found: $storedToken'); // Add log
      if (isValidSession(storedToken)) {
        AppUtils.logger.i('Session is valid.'); // Add log
        return storedToken;
      } else {
        AppUtils.logger.w('Session is invalid, removing...'); // Add log
        await removeSession(storedToken); //remove invalid session
      }
    } else {
      AppUtils.logger.i('No stored token found.'); // Add log
    }
    return null;
  }

  /// Load session from secure storage (if exists)
  Future<void> loadSessionFromStorage() async {
    AppUtils.logger.i('Loading session from storage...'); // Add log
    final storedToken = await _secureStorageService.getSessionToken();
    if (storedToken != null) {
      AppUtils.logger.i('Stored token found: $storedToken'); // Add log
      final userId = getUserIdFromToken(storedToken);
      if (userId != null) {
        AppUtils.logger
            .i('User ID retrieved: $userId, creating session...'); // Add log
        _sessions[storedToken] = _Session(
          userId: userId,
          expiresAt: DateTime.now()
              .add(_sessionDuration), //TODO: calculate real expiry date
        );
      } else {
        AppUtils.logger.w('Invalid token, removing...'); // Add log
        await _secureStorageService.removeSessionToken(); //remove invalid token
      }
    } else {
      AppUtils.logger.i('No stored token found.'); // Add log
    }
  }

  /// Decode token and extract data
  Map<String, dynamic>? _decodeToken(String token) {
    try {
      final decodedBytes = base64.decode(token);
      final decodedString = utf8.decode(decodedBytes);
      final parts = decodedString.split('|'); // Use '|' as separator
      if (parts.length == 4) {
        final expiryTimestamp = parts[0];
        final userId = parts[1];
        return {
          'expiryTimestamp': expiryTimestamp,
          'userId': userId,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Internal session class
class _Session {
  final String userId;
  final DateTime expiresAt;

  _Session({
    required this.userId,
    required this.expiresAt,
  });
}
