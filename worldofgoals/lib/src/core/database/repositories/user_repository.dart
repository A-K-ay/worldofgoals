import 'package:drift/drift.dart';

import '../database.dart';
import '../services/database_service.dart';
import '../tables/users_table.dart';
import 'base_repository.dart';
import '../../utils/app_utils.dart';

/// Repository implementation for User-related operations
class UserRepository implements BaseRepository<User> {
  final DatabaseService _databaseService;

  UserRepository(this._databaseService);

  @override
  Future<void> create(dynamic user) async {
    try {
      AppUtils.logger.i('Creating user: ${user.email}');
      final db = await _databaseService.database;
      if (user is UsersCompanion) {
        await db.into(db.users).insert(user);
      } else {
        throw ArgumentError('Invalid user type. Expected UsersCompanion');
      }
      AppUtils.logger.i('User created successfully');
    } catch (e, stackTrace) {
      AppUtils.logger.e('Error creating user', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<User?> read(String id) async {
    try {
      AppUtils.logger.i('Reading user: $id');
      final db = await _databaseService.database;
      return await (db.select(db.users)..where((u) => u.id.equals(id)))
          .getSingleOrNull();
    } catch (e, stackTrace) {
      AppUtils.logger.e('Error reading user', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> update(User user) async {
    try {
      AppUtils.logger.i('Updating user: ${user.id}');
      final db = await _databaseService.database;
      return await db.update(db.users).replace(user);
    } catch (e, stackTrace) {
      AppUtils.logger.e('Error updating user', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      AppUtils.logger.i('Deleting user: $id');
      final db = await _databaseService.database;
      return await (db.delete(db.users)..where((u) => u.id.equals(id))).go() > 0;
    } catch (e, stackTrace) {
      AppUtils.logger.e('Error deleting user', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<User>> getAll() async {
    try {
      AppUtils.logger.i('Getting all users');
      final db = await _databaseService.database;
      return await db.select(db.users).get();
    } catch (e, stackTrace) {
      AppUtils.logger.e('Error getting all users', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      AppUtils.logger.i('Getting user by email: $email');
      final db = await _databaseService.database;
      return await (db.select(db.users)..where((u) => u.email.equals(email)))
          .getSingleOrNull();
    } catch (e, stackTrace) {
      AppUtils.logger.e('Error getting user by email', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update user's progress
  Future<bool> updateUserProgress(String id, int xp, int level) async {
    try {
      AppUtils.logger.i('Updating user progress: $id');
      final db = await _databaseService.database;
      return await db.update(db.users)
          .replace(UsersCompanion(
            id: Value(id),
            xp: Value(xp),
            level: Value(level),
            updatedAt: Value(DateTime.now()),
          ));
    } catch (e, stackTrace) {
      AppUtils.logger.e('Error updating user progress', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
