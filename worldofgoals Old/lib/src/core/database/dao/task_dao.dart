import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/tasks_table.dart';

/// Data Access Object for Task-related database operations
class TaskDao {
  final AppDatabase _db;

  TaskDao(this._db);

  /// Create a new task
  Future<void> createTask(TasksCompanion task) async {
    await _db.into(_db.tasks).insert(task);
  }

  /// Get task by ID
  Future<Task?> getTaskById(String id) async {
    return (
      _db.select(_db.tasks)..where((t) => t.id.equals(id))
    ).getSingleOrNull();
  }

  /// Get tasks by user ID
  Future<List<Task>> getTasksByUserId(String userId) async {
    return (
      _db.select(_db.tasks)..where((t) => t.userId.equals(userId))
    ).get();
  }

  /// Update task
  Future<bool> updateTask(TasksCompanion task) async {
    return _db.update(_db.tasks).replace(task);
  }

  /// Delete task
  Future<int> deleteTask(String id) async {
    return (
      _db.delete(_db.tasks)..where((t) => t.id.equals(id))
    ).go();
  }

  /// Get all tasks
  Future<List<Task>> getAllTasks() async {
    return _db.select(_db.tasks).get();
  }

  /// Get pending tasks for user
  Future<List<Task>> getPendingTasks(String userId) async {
    return (
      _db.select(_db.tasks)
        ..where((t) => t.userId.equals(userId) & 
                      t.status.equals(TaskStatus.pending.name))
        ..orderBy([(t) => OrderingTerm(expression: t.dueDate)])
    ).get();
  }

  /// Update task status
  Future<bool> updateTaskStatus(String id, TaskStatus status) async {
    return _db.update(_db.tasks).replace(
      TasksCompanion(
        id: Value(id),
        status: Value(status),
        completedAt: Value(status == TaskStatus.completed ? DateTime.now() : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
