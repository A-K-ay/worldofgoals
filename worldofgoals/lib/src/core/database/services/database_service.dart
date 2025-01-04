import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../database.dart';

/// Singleton service for managing database connections and operations
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static AppDatabase? _database;
  static const int _maxConnections = 5;
  static final List<AppDatabase> _connectionPool = [];
  static final encrypt.Key _key = encrypt.Key.fromSecureRandom(32);
  static final encrypt.IV _iv = encrypt.IV.fromSecureRandom(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Get a database connection from the pool
  Future<AppDatabase> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database with encryption and connection pool
  Future<AppDatabase> _initDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'worldofgoals.sqlite'));
    
    // Initialize connection pool
    for (var i = 0; i < _maxConnections; i++) {
      final db = AppDatabase();
      _connectionPool.add(db);
    }

    return _connectionPool.first;
  }

  /// Encrypt database file
  Future<void> encryptDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'worldofgoals.sqlite'));
    
    if (await file.exists()) {
      final contents = await file.readAsBytes();
      final encrypted = _encrypter.encryptBytes(contents, iv: _iv);
      await file.writeAsBytes(encrypted.bytes);
    }
  }

  /// Decrypt database file
  Future<void> decryptDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'worldofgoals.sqlite'));
    
    if (await file.exists()) {
      final contents = await file.readAsBytes();
      final decrypted = _encrypter.decryptBytes(encrypt.Encrypted(contents), iv: _iv);
      await file.writeAsBytes(decrypted);
    }
  }

  /// Create a backup of the database
  Future<void> createBackup() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, 'worldofgoals.sqlite'));
    final backupFile = File(p.join(dbFolder.path, 
      'worldofgoals_backup_${DateTime.now().toIso8601String()}.sqlite'));
    
    if (await dbFile.exists()) {
      await dbFile.copy(backupFile.path);
      // Encrypt the backup
      final contents = await backupFile.readAsBytes();
      final encrypted = _encrypter.encryptBytes(contents, iv: _iv);
      await backupFile.writeAsBytes(encrypted.bytes);
    }
  }

  /// Close all database connections
  Future<void> closeConnections() async {
    for (var db in _connectionPool) {
      await db.close();
    }
    _connectionPool.clear();
    _database = null;
  }
}
