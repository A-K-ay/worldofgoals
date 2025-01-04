import 'package:drift/drift.dart';
import '../dao/achievement_dao.dart';
import '../database.dart';
import '../tables/achievements_table.dart';
import 'base_repository.dart';
import '../services/database_service.dart';

/// Repository implementation for Achievement-related operations
class AchievementRepository implements BaseRepository<Achievement> {
  late final AchievementDao _achievementDao;
  final DatabaseService _databaseService;

  AchievementRepository(this._databaseService) {
    _initDao();
  }

  Future<void> _initDao() async {
    final db = await _databaseService.database;
    _achievementDao = AchievementDao(db);
  }

  @override
  Future<void> create(Achievement achievement) async {
    await _achievementDao.createAchievement(
      AchievementsCompanion(
        id: Value(achievement.id),
        userId: Value(achievement.userId),
        type: Value(achievement.type),
        progress: Value(achievement.progress),
        completed: Value(achievement.completed),
      ),
    );
  }

  @override
  Future<Achievement?> read(String id) async {
    return _achievementDao.getAchievementById(id);
  }

  @override
  Future<bool> update(Achievement achievement) async {
    return _achievementDao.updateAchievement(
      AchievementsCompanion(
        id: Value(achievement.id),
        userId: Value(achievement.userId),
        type: Value(achievement.type),
        progress: Value(achievement.progress),
        completed: Value(achievement.completed),
        completedAt: Value(achievement.completedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<bool> delete(String id) async {
    return await _achievementDao.deleteAchievement(id) > 0;
  }

  @override
  Future<List<Achievement>> getAll() async {
    return _achievementDao.getAllAchievements();
  }

  /// Get achievements for a specific user
  Future<List<Achievement>> getAchievementsByUser(String userId) async {
    return _achievementDao.getAchievementsByUserId(userId);
  }

  /// Get achievements by type
  Future<List<Achievement>> getAchievementsByType(String userId, AchievementType type) async {
    return _achievementDao.getAchievementsByType(userId, type);
  }

  /// Update achievement progress
  Future<bool> updateProgress(String id, int progress) async {
    return _achievementDao.updateProgress(id, progress);
  }

  /// Get incomplete achievements
  Future<List<Achievement>> getIncompleteAchievements(String userId) async {
    return _achievementDao.getIncompleteAchievements(userId);
  }

  /// Get completed achievements
  Future<List<Achievement>> getCompletedAchievements(String userId) async {
    return _achievementDao.getCompletedAchievements(userId);
  }
}
