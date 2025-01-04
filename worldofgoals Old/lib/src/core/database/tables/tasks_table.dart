import 'package:drift/drift.dart';
import 'users_table.dart';

/// Enum for task difficulty levels
enum TaskDifficulty {
  easy,
  medium,
  hard,
  epic
}

/// Enum for task status
enum TaskStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled
}

/// Table definition for storing task information
class Tasks extends Table {
  // Primary key UUID for task identification
  TextColumn get id => text()();
  
  // Foreign key to Users table
  TextColumn get userId => text().references(Users, #id)();
  
  // Task title
  TextColumn get title => text().withLength(min: 1, max: 100)();
  
  // Task description
  TextColumn get description => text().nullable()();
  
  // Task difficulty level
  TextColumn get difficulty => textEnum<TaskDifficulty>()();
  
  // Experience points reward for completing the task
  IntColumn get xpReward => integer()();
  
  // Current status of the task
  TextColumn get status => textEnum<TaskStatus>().withDefault(const Constant('pending'))();
  
  // Due date for the task
  DateTimeColumn get dueDate => dateTime().nullable()();
  
  // When the task was completed
  DateTimeColumn get completedAt => dateTime().nullable()();
  
  // When the task was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // When the task was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {userId},
    {status},
    {dueDate},
  ];
}
