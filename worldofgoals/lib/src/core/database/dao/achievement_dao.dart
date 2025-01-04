import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/achievements_table.dart';

/// Data Access Object for Achievement-related database operations
class AchievementDao {
  final AppDatabase _db;

  AchievementDao(this._db);

  /// Create a new achievement
  Future<void> createAchievement(AchievementsCompanion achievement) async {
    await _db.into(_db.achievements).insert(achievement);
  }

  /// Get achievement by ID
  Future<Achievement?> getAchievementById(String id) async {
    return (
      _db.select(_db.achievements)..where((a) => a.id.equals(id))
    ).getSingleOrNull();
  }

  /// Get achievements by user ID
  Future<List<Achievement>> getAchievementsByUserId(String userId) async {
    return (
      _db.select(_db.achievements)..where((a) => a.userId.equals(userId))
    ).get();
  }

  /// Get achievements by type
  Future<List<Achievement>> getAchievementsByType(String userId, AchievementType type) async {
    return (
      _db.select(_db.achievements)
        ..where((a) => a.userId.equals(userId) & a.type.equals(type.name))
    ).get();
  }

  /// Update achievement
  Future<bool> updateAchievement(AchievementsCompanion achievement) async {
    return _db.update(_db.achievements).replace(achievement);
  }

  /// Delete achievement
  Future<int> deleteAchievement(String id) async {
    return (
      _db.delete(_db.achievements)..where((a) => a.id.equals(id))
    ).go();
  }

  /// Get all achievements
  Future<List<Achievement>> getAllAchievements() async {
    return _db.select(_db.achievements).get();
  }

  /// Update achievement progress
  Future<bool> updateProgress(String id, int progress) async {
    final isCompleted = progress >= 100;
    return _db.update(_db.achievements).replace(
      AchievementsCompanion(
        id: Value(id),
        progress: Value(progress),
        completed: Value(isCompleted),
        completedAt: Value(isCompleted ? DateTime.now() : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get incomplete achievements for user
  Future<List<Achievement>> getIncompleteAchievements(String userId) async {
    return (
      _db.select(_db.achievements)
        ..where((a) => a.userId.equals(userId) & a.completed.equals(false))
    ).get();
  }

  /// Get completed achievements for user
  Future<List<Achievement>> getCompletedAchievements(String userId) async {
    return (
      _db.select(_db.achievements)
        ..where((a) => a.userId.equals(userId) & a.completed.equals(true))
    ).get();
  }
}
