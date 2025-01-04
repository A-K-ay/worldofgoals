import 'package:drift/drift.dart';
import '../dao/reward_dao.dart';
import '../database.dart';
import '../tables/rewards_table.dart';
import 'base_repository.dart';
import '../services/database_service.dart';

/// Repository implementation for Reward-related operations
class RewardRepository implements BaseRepository<Reward> {
  late final RewardDao _rewardDao;
  final DatabaseService _databaseService;

  RewardRepository(this._databaseService) {
    _initDao();
  }

  Future<void> _initDao() async {
    final db = await _databaseService.database;
    _rewardDao = RewardDao(db);
  }

  @override
  Future<void> create(Reward reward) async {
    await _rewardDao.createReward(
      RewardsCompanion(
        id: Value(reward.id),
        userId: Value(reward.userId),
        title: Value(reward.title),
        description: Value(reward.description),
        xpCost: Value(reward.xpCost),
        status: Value(reward.status),
      ),
    );
  }

  @override
  Future<Reward?> read(String id) async {
    return _rewardDao.getRewardById(id);
  }

  @override
  Future<bool> update(Reward reward) async {
    return _rewardDao.updateReward(
      RewardsCompanion(
        id: Value(reward.id),
        userId: Value(reward.userId),
        title: Value(reward.title),
        description: Value(reward.description),
        xpCost: Value(reward.xpCost),
        status: Value(reward.status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<bool> delete(String id) async {
    return await _rewardDao.deleteReward(id) > 0;
  }

  @override
  Future<List<Reward>> getAll() async {
    return _rewardDao.getAllRewards();
  }

  /// Get rewards for a specific user
  Future<List<Reward>> getRewardsByUser(String userId) async {
    return _rewardDao.getRewardsByUserId(userId);
  }

  /// Get available rewards for a user
  Future<List<Reward>> getAvailableRewards(String userId) async {
    return _rewardDao.getAvailableRewards(userId);
  }

  /// Claim a reward
  Future<bool> claimReward(String id) async {
    return _rewardDao.claimReward(id);
  }

  /// Get claimed rewards for a user
  Future<List<Reward>> getClaimedRewards(String userId) async {
    return _rewardDao.getClaimedRewards(userId);
  }
}
