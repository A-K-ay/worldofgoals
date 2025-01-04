import 'package:drift/drift.dart';
import 'users_table.dart';

/// Enum for achievement types
enum AchievementType {
  taskCompletion,
  levelUp,
  streakMaintenance,
  xpMilestone,
  customGoal
}

/// Table definition for storing achievement information
class Achievements extends Table {
  // Primary key UUID for achievement identification
  TextColumn get id => text()();
  
  // Foreign key to Users table
  TextColumn get userId => text().references(Users, #id)();
  
  // Type of achievement
  TextColumn get type => textEnum<AchievementType>()();
  
  // Current progress towards completion (0-100)
  IntColumn get progress => integer().withDefault(const Constant(0))();
  
  // Whether the achievement is completed
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  
  // When the achievement was completed
  DateTimeColumn get completedAt => dateTime().nullable()();
  
  // When the achievement was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // When the achievement was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {userId},
    {type},
    {completed},
  ];
}
