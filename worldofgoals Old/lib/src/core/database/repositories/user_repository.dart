import 'package:drift/drift.dart';
import '../dao/user_dao.dart';
import '../database.dart';
import 'base_repository.dart';
import '../services/database_service.dart';

/// Repository implementation for User-related operations
class UserRepository implements BaseRepository<User> {
  late final UserDao _userDao;
  final DatabaseService _databaseService;

  UserRepository(this._databaseService) {
    _initDao();
  }

  Future<void> _initDao() async {
    final db = await _databaseService.database;
    _userDao = UserDao(db);
  }

  @override
  Future<void> create(User user) async {
    await _userDao.createUser(
      UsersCompanion(
        id: Value(user.id),
        username: Value(user.username),
        email: Value(user.email),
        passwordHash: Value(user.passwordHash),
        xp: Value(user.xp),
        level: Value(user.level),
      ),
    );
  }

  @override
  Future<User?> read(String id) async {
    return _userDao.getUserById(id);
  }

  @override
  Future<bool> update(User user) async {
    return _userDao.updateUser(
      UsersCompanion(
        id: Value(user.id),
        username: Value(user.username),
        email: Value(user.email),
        passwordHash: Value(user.passwordHash),
        xp: Value(user.xp),
        level: Value(user.level),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<bool> delete(String id) async {
    return await _userDao.deleteUser(id) > 0;
  }

  @override
  Future<List<User>> getAll() async {
    return _userDao.getAllUsers();
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    return _userDao.getUserByEmail(email);
  }

  /// Update user's progress
  Future<bool> updateUserProgress(String id, int xp, int level) async {
    return _userDao.updateUserProgress(id, xp, level);
  }
}
