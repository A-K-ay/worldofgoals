import 'package:drift/drift.dart';
import '../dao/task_dao.dart';
import '../database.dart';
import '../tables/tasks_table.dart';
import 'base_repository.dart';
import '../services/database_service.dart';

/// Repository implementation for Task-related operations
class TaskRepository implements BaseRepository<Task> {
  late final TaskDao _taskDao;
  final DatabaseService _databaseService;

  TaskRepository(this._databaseService) {
    _initDao();
  }

  Future<void> _initDao() async {
    final db = await _databaseService.database;
    _taskDao = TaskDao(db);
  }

  @override
  Future<void> create(Task task) async {
    await _taskDao.createTask(
      TasksCompanion(
        id: Value(task.id),
        userId: Value(task.userId),
        title: Value(task.title),
        description: Value(task.description),
        difficulty: Value(task.difficulty),
        xpReward: Value(task.xpReward),
        dueDate: Value(task.dueDate),
      ),
    );
  }

  @override
  Future<Task?> read(String id) async {
    return _taskDao.getTaskById(id);
  }

  @override
  Future<bool> update(Task task) async {
    return _taskDao.updateTask(
      TasksCompanion(
        id: Value(task.id),
        userId: Value(task.userId),
        title: Value(task.title),
        description: Value(task.description),
        difficulty: Value(task.difficulty),
        xpReward: Value(task.xpReward),
        status: Value(task.status),
        dueDate: Value(task.dueDate),
        completedAt: Value(task.completedAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<bool> delete(String id) async {
    return await _taskDao.deleteTask(id) > 0;
  }

  @override
  Future<List<Task>> getAll() async {
    return _taskDao.getAllTasks();
  }

  /// Get tasks for a specific user
  Future<List<Task>> getTasksByUser(String userId) async {
    return _taskDao.getTasksByUserId(userId);
  }

  /// Get pending tasks for a user
  Future<List<Task>> getPendingTasks(String userId) async {
    return _taskDao.getPendingTasks(userId);
  }

  /// Update task status
  Future<bool> updateTaskStatus(String id, TaskStatus status) async {
    return _taskDao.updateTaskStatus(id, status);
  }
}
