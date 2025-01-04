import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database.dart';
import '../../utils/app_utils.dart';

/// Service for managing database connections and operations
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  AppDatabase? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<AppDatabase> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<AppDatabase> _initDatabase() async {
    AppUtils.logger.i('Initializing database');
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'world_of_goals.db'));
    
    AppUtils.logger.i('Database path: ${file.path}');
    
    return AppDatabase(
      NativeDatabase(
        file,
        logStatements: true,
        setup: (db) {
          // Enable foreign keys
          db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }

  Future<void> closeDatabase() async {
    AppUtils.logger.i('Closing database');
    await _database?.close();
    _database = null;
  }
}
