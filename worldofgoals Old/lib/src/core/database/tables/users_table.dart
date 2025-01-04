import 'package:drift/drift.dart';

/// Table definition for storing user information locally
class Users extends Table {
  // Primary key UUID for user identification
  TextColumn get id => text()();
  
  // User's chosen display name
  TextColumn get username => text().withLength(min: 3, max: 50)();
  
  // User's email address for authentication
  TextColumn get email => text().unique()();
  
  // Hashed password for local authentication
  TextColumn get passwordHash => text()();
  
  // Experience points earned by the user
  IntColumn get xp => integer().withDefault(const Constant(0))();
  
  // Current level of the user
  IntColumn get level => integer().withDefault(const Constant(1))();
  
  // Timestamp when the user was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Timestamp when the user was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {email},
  ];
}
