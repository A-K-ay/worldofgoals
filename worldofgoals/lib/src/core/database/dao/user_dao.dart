import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/users_table.dart';

/// Data Access Object for User-related database operations
class UserDao {
  final AppDatabase _db;

  UserDao(this._db);

  /// Create a new user
  Future<void> createUser(UsersCompanion user) async {
    await _db.into(_db.users).insert(user);
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    return (
      _db.select(_db.users)..where((u) => u.id.equals(id))
    ).getSingleOrNull();
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    return (
      _db.select(_db.users)..where((u) => u.email.equals(email))
    ).getSingleOrNull();
  }

  /// Update user
  Future<bool> updateUser(UsersCompanion user) async {
    return _db.update(_db.users).replace(user);
  }

  /// Delete user
  Future<int> deleteUser(String id) async {
    return (
      _db.delete(_db.users)..where((u) => u.id.equals(id))
    ).go();
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    return _db.select(_db.users).get();
  }

  /// Update user XP and level
  Future<bool> updateUserProgress(String id, int xp, int level) async {
    return _db.update(_db.users).replace(
      UsersCompanion(
        id: Value(id),
        xp: Value(xp),
        level: Value(level),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
