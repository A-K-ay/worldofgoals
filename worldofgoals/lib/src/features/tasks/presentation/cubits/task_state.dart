part of 'task_cubit.dart';

abstract class TasksState extends Equatable {
  final List<Task> tasks;

  const TasksState(
    this.tasks,
  );

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {
  TasksInitial() : super([]);
}

class TasksLoading extends TasksState {
  TasksLoading() : super([]);
}

class TasksLoaded extends TasksState {
  const TasksLoaded({
    required this.tasks,
  }) : super(
          tasks,
        );

  final List<Task> tasks;

  @override
  List<Object?> get props => [tasks];
}

class TasksError extends TasksState {
  final String message;

  TasksError({required this.message}) : super([]);
  @override
  List<Object> get props => [message];
}
