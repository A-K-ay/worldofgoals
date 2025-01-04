import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// Manages user sessions and tokens
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  final Map<String, _Session> _sessions = {};
  static const _sessionDuration = Duration(days: 7);
  static final _uuid = Uuid();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  /// Create a new session for a user
  Future<String> createSession(String userId) async {
    final token = _generateToken(userId);
    _sessions[token] = _Session(
      userId: userId,
      expiresAt: DateTime.now().add(_sessionDuration),
    );
    return token;
  }

  /// Check if a session is valid
  bool isValidSession(String token) {
    final session = _sessions[token];
    if (session == null) return false;
    
    if (DateTime.now().isAfter(session.expiresAt)) {
      _sessions.remove(token);
      return false;
    }
    
    return true;
  }

  /// Get user ID from token
  String? getUserIdFromToken(String token) {
    final session = _sessions[token];
    if (!isValidSession(token)) return null;
    return session?.userId;
  }

  /// Remove a session
  Future<void> removeSession(String token) async {
    _sessions.remove(token);
  }

  /// Generate a secure token
  String _generateToken(String userId) {
    final random = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$userId:$random:$timestamp';
    return sha256.convert(utf8.encode(data)).toString();
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
