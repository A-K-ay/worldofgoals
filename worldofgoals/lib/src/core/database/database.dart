import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/users_table.dart';
import 'tables/tasks_table.dart';
import 'tables/rewards_table.dart';
import 'tables/achievements_table.dart';

part 'database.g.dart';

/// Main database class for the application
@DriftDatabase(tables: [Users, Tasks, Rewards, Achievements])
class AppDatabase extends _$AppDatabase {
  AppDatabase(NativeDatabase nativeDatabase) : super(nativeDatabase);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Add migration steps here when updating schema
        if (from < 2) {
          // For future migrations
        }
      },
      beforeOpen: (details) async {
        // Validate foreign keys after migrations
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // User Operations

  /// Creates a new user in the database
  Future<int> createUser({
    required String id,
    required String username,
    required String email,
    required String passwordHash,
  }) {
    return into(users).insert(
      UsersCompanion.insert(
        id: id,
        username: username,
        email: email,
        passwordHash: passwordHash,
      ),
    );
  }

  /// Retrieves a user by their email
  Future<User?> getUserByEmail(String email) {
    return (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  /// Updates user's XP and level
  Future<bool> updateUserProgress(String userId, {required int xp, required int level}) {
    return update(users)
      .replace(UsersCompanion(
        id: Value(userId),
        xp: Value(xp),
        level: Value(level),
      ));
  }

  /// Deletes a user from the database
  Future<int> deleteUser(String userId) {
    return (delete(users)..where((u) => u.id.equals(userId))).go();
  }

  // Task Operations

  /// Creates a new task
  Future<int> createTask({
    required String id,
    required String userId,
    required String title,
    required String description,
    required TaskDifficulty difficulty,
    required int xpReward,
    DateTime? dueDate,
  }) {
    return into(tasks).insert(
      TasksCompanion.insert(
        id: id,
        userId: userId,
        title: title,
        description: Value(description),
        difficulty: difficulty,
        xpReward: xpReward,
        dueDate: Value(dueDate),
      ),
    );
  }

  /// Updates task status
  Future<bool> updateTaskStatus(String taskId, TaskStatus status) {
    return update(tasks).replace(TasksCompanion(
      id: Value(taskId),
      status: Value(status),
      completedAt: Value(status == TaskStatus.completed ? DateTime.now() : null),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Get tasks by user ID
  Future<List<Task>> getTasksByUser(String userId) {
    return (select(tasks)..where((t) => t.userId.equals(userId))).get();
  }

  /// Get pending tasks by user ID
  Future<List<Task>> getPendingTasks(String userId) {
    return (select(tasks)
      ..where((t) => t.userId.equals(userId) & t.status.equals(TaskStatus.pending.name))
      ..orderBy([(t) => OrderingTerm(expression: t.dueDate)])).get();
  }

  // Reward Operations

  /// Creates a new reward
  Future<int> createReward({
    required String id,
    required String userId,
    required String title,
    required String description,
    required int xpCost,
  }) {
    return into(rewards).insert(
      RewardsCompanion.insert(
        id: id,
        userId: userId,
        title: title,
        description: Value(description),
        xpCost: xpCost,
      ),
    );
  }

  /// Claims a reward
  Future<bool> claimReward(String rewardId) {
    return update(rewards).replace(RewardsCompanion(
      id: Value(rewardId),
      status: Value(RewardStatus.claimed),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Get available rewards for user
  Future<List<Reward>> getAvailableRewards(String userId) {
    return (select(rewards)
      ..where((r) => r.userId.equals(userId) & r.status.equals(RewardStatus.available.name)))
      .get();
  }

  // Achievement Operations

  /// Creates a new achievement
  Future<int> createAchievement({
    required String id,
    required String userId,
    required AchievementType type,
  }) {
    return into(achievements).insert(
      AchievementsCompanion.insert(
        id: id,
        userId: userId,
        type: type,
      ),
    );
  }

  /// Updates achievement progress
  Future<bool> updateAchievementProgress(String achievementId, int progress) {
    final isCompleted = progress >= 100;
    return update(achievements).replace(AchievementsCompanion(
      id: Value(achievementId),
      progress: Value(progress),
      completed: Value(isCompleted),
      completedAt: Value(isCompleted ? DateTime.now() : null),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Get achievements by user ID
  Future<List<Achievement>> getAchievements(String userId) {
    return (select(achievements)..where((a) => a.userId.equals(userId))).get();
  }

  /// Get incomplete achievements by user ID
  Future<List<Achievement>> getIncompleteAchievements(String userId) {
    return (select(achievements)
      ..where((a) => a.userId.equals(userId) & a.completed.equals(false)))
      .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'goalquest.db'));
    return NativeDatabase(file);
  });
}
