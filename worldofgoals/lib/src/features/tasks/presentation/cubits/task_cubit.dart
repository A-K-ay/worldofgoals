import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:worldofgoals/src/core/database/database.dart';
import 'package:worldofgoals/src/core/database/repositories/task_repository.dart';
import 'package:worldofgoals/src/core/database/services/database_service.dart';
import 'package:worldofgoals/src/core/database/tables/tasks_table.dart';
import 'package:worldofgoals/src/features/auth/domain/auth_provider.dart';
import 'package:worldofgoals/src/features/auth/services/local_auth_provider.dart';
import 'package:worldofgoals/src/features/tasks/task_filter.dart';
import 'package:drift/drift.dart';

part 'task_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial()) {
    initTaskRepository();
  }

  TaskFilter? _currentTaskFilter;

  //Add async methhod to init taskRepository
  Future<void> initTaskRepository() async {
    emit(TasksLoading());
    await _taskRepository.initDao(); // Initialize DAO
    updateTaskFilter(TaskFilter(byDate: DateTime.now()));
  }

  final _uuid = Uuid();

  // late final TaskRepository _taskRepository; // Remove late and initialize in constructor

  final _taskRepository = TaskRepository(DatabaseService());

  Future<void> loadTasks() async {
    emit(TasksLoading());
    try {
      final tasks = await _taskRepository; // Await the Future<TaskRepository>
      final String? userId = await LocalAuthProvider()
          .getCurrentUserId(); // TODO: Get current user ID
      if (userId == null) {
        throw Exception('User ID not found');
      }
      var taskList = await tasks.getTasksByUser(userId); // Await getAll()
      taskList = _currentTaskFilter?.filter(taskList) ??
          taskList; // Apply filter if provided;
      emit(TasksLoaded(tasks: taskList));
    } catch (e) {
      emit(TasksError(message: e.toString()));
    }
  }

  Future<void> createTask({
    required String title,
    String? description,
    required TaskDifficulty difficulty,
    DateTime? dueDate,
  }) async {
    emit(TasksLoading());
    try {
      final userId = await LocalAuthProvider()
          .getCurrentUserId(); // TODO: Get current user ID
      if (userId == null) {
        throw Exception('User ID not found');
      }
      final taskId = _uuid.v4();
      final task = Task(
        id: taskId,
        userId: userId,
        title: title,
        description: description,
        difficulty: difficulty,
        xpReward: _getXpReward(difficulty),
        status: TaskStatus.pending,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tasks = await _taskRepository; // Await the Future<TaskRepository>
      await tasks.create(task);
      loadTasks(); // Reload tasks after creating a new one
    } catch (e) {
      emit(TasksError(message: e.toString()));
    }
  }

  int _getXpReward(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 10;
      case TaskDifficulty.medium:
        return 25;
      case TaskDifficulty.hard:
        return 50;
      case TaskDifficulty.epic:
        return 100;
      default:
        return 0;
    }
  }

  void updateTaskFilter(TaskFilter filter) {
    _currentTaskFilter = filter;
    loadTasks();
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    emit(TasksLoading());
    try {
      final task = await _taskRepository.read(taskId);
      if (task == null) {
        throw Exception('Task not found');
      }
      final updatedTask = task.copyWith(
        status: TaskStatus.completed,
        completedAt: Value(DateTime.now()),
      );
      await _taskRepository.update(updatedTask);
      loadTasks(); // Reload tasks after marking as completed
    } catch (e) {
      emit(TasksError(message: e.toString()));
    }
  }
}
