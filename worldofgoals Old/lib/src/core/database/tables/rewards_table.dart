import 'package:drift/drift.dart';
import 'users_table.dart';

/// Enum for reward status
enum RewardStatus {
  available,
  claimed,
  expired
}

/// Table definition for storing reward information
class Rewards extends Table {
  // Primary key UUID for reward identification
  TextColumn get id => text()();
  
  // Foreign key to Users table
  TextColumn get userId => text().references(Users, #id)();
  
  // Reward title
  TextColumn get title => text().withLength(min: 1, max: 100)();
  
  // Reward description
  TextColumn get description => text().nullable()();
  
  // Experience points cost to claim the reward
  IntColumn get xpCost => integer()();
  
  // Current status of the reward
  TextColumn get status => textEnum<RewardStatus>().withDefault(const Constant('available'))();
  
  // When the reward was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // When the reward was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {userId},
    {status},
  ];
}
