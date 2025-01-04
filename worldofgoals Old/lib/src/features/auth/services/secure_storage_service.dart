import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// Service for securely storing sensitive data
class SecureStorageService {
  final EncryptedSharedPreferences _storage;
  static final SecureStorageService _instance = SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal() : _storage = EncryptedSharedPreferences();

  /// Store a value securely
  Future<bool> setValue(String key, String value) async {
    return await _storage.setString(key, value);
  }

  /// Retrieve a stored value
  Future<String?> getValue(String key) async {
    return await _storage.getString(key);
  }

  /// Remove a stored value
  Future<bool> removeValue(String key) async {
    return await _storage.remove(key);
  }

  /// Clear all stored values
  Future<bool> clearAll() async {
    return await _storage.clear();
  }

  /// Store session token
  Future<bool> setSessionToken(String token) async {
    return await setValue('session_token', token);
  }

  /// Get session token
  Future<String?> getSessionToken() async {
    return await getValue('session_token');
  }

  /// Remove session token
  Future<bool> removeSessionToken() async {
    return await removeValue('session_token');
  }
}
