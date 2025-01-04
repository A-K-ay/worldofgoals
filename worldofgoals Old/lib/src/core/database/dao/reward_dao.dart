import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/rewards_table.dart';

/// Data Access Object for Reward-related database operations
class RewardDao {
  final AppDatabase _db;

  RewardDao(this._db);

  /// Create a new reward
  Future<void> createReward(RewardsCompanion reward) async {
    await _db.into(_db.rewards).insert(reward);
  }

  /// Get reward by ID
  Future<Reward?> getRewardById(String id) async {
    return (
      _db.select(_db.rewards)..where((r) => r.id.equals(id))
    ).getSingleOrNull();
  }

  /// Get rewards by user ID
  Future<List<Reward>> getRewardsByUserId(String userId) async {
    return (
      _db.select(_db.rewards)..where((r) => r.userId.equals(userId))
    ).get();
  }

  /// Get available rewards for user
  Future<List<Reward>> getAvailableRewards(String userId) async {
    return (
      _db.select(_db.rewards)
        ..where((r) => r.userId.equals(userId) & 
                      r.status.equals(RewardStatus.available.name))
    ).get();
  }

  /// Update reward
  Future<bool> updateReward(RewardsCompanion reward) async {
    return _db.update(_db.rewards).replace(reward);
  }

  /// Delete reward
  Future<int> deleteReward(String id) async {
    return (
      _db.delete(_db.rewards)..where((r) => r.id.equals(id))
    ).go();
  }

  /// Get all rewards
  Future<List<Reward>> getAllRewards() async {
    return _db.select(_db.rewards).get();
  }

  /// Claim a reward
  Future<bool> claimReward(String id) async {
    return _db.update(_db.rewards).replace(
      RewardsCompanion(
        id: Value(id),
        status: Value(RewardStatus.claimed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get claimed rewards for user
  Future<List<Reward>> getClaimedRewards(String userId) async {
    return (
      _db.select(_db.rewards)
        ..where((r) => r.userId.equals(userId) & 
                      r.status.equals(RewardStatus.claimed.name))
    ).get();
  }
}
