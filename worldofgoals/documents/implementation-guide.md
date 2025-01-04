# World of Goals - Technical Implementation Guide

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- SQLite support

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.1
  path: ^1.8.3
  bcrypt: ^1.1.3
  uuid: ^4.2.2
  encrypted_shared_preferences: ^3.0.1
```

## Database Setup

### 1. Initialize Database
```dart
// In database_service.dart
Future<AppDatabase> _initDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'world_of_goals.db'));
  
  return AppDatabase(
    NativeDatabase(
      file,
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON');
      },
    ),
  );
}
```

### 2. Generate Database Code
Run the following command after modifying database schema:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Authentication Implementation

### 1. Register New User
```dart
Future<AuthResult> register({
  required String email,
  required String password,
  required String username,
}) async {
  // Hash password
  final salt = BCrypt.gensalt();
  final hashedPassword = BCrypt.hashpw(password, salt);

  // Create user
  final userId = _uuid.v4();
  final user = UsersCompanion.insert(
    id: userId,
    username: username,
    email: email,
    passwordHash: hashedPassword,
    xp: Value(0),
    level: Value(1),
    createdAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  );

  await _userRepository.create(user);
  
  // Create session
  final token = await _sessionManager.createSession(userId);
  await _secureStorage.setSessionToken(token);

  return AuthResult(userId: userId, token: token);
}
```

### 2. User Login
```dart
Future<AuthResult> signIn({
  required String email,
  required String password,
}) async {
  final user = await _userRepository.getUserByEmail(email);
  if (user == null) return AuthResult(userId: '', error: 'User not found');

  final passwordMatch = BCrypt.checkpw(password, user.passwordHash);
  if (!passwordMatch) return AuthResult(userId: '', error: 'Invalid password');

  final token = await _sessionManager.createSession(user.id);
  await _secureStorage.setSessionToken(token);

  return AuthResult(userId: user.id, token: token);
}
```

## Data Source Implementation

### 1. Local Data Source
```dart
class LocalDataSource implements BaseDataSource {
  final DatabaseService _databaseService;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    await _databaseService.database;
    _isInitialized = true;
  }

  @override
  Future<bool> isReady() async => _isInitialized;
}
```

### 2. Remote Data Source (Future)
```dart
class RemoteDataSource implements BaseDataSource {
  // PostgreSQL configuration
  late final Pool pool;
  
  @override
  Future<void> initialize() async {
    pool = Pool(
      host: 'host',
      port: 5432,
      database: 'database',
      username: 'username',
      password: 'password',
    );
  }
}
```

## Repository Implementation

### 1. Base Repository
```dart
abstract class BaseRepository<T> {
  Future<void> create(T item);
  Future<T?> read(String id);
  Future<bool> update(T item);
  Future<bool> delete(String id);
  Future<List<T>> getAll();
}
```

### 2. User Repository Example
```dart
class UserRepository implements BaseRepository<User> {
  final DatabaseService _databaseService;

  @override
  Future<void> create(dynamic user) async {
    final db = await _databaseService.database;
    if (user is UsersCompanion) {
      await db.into(db.users).insert(user);
    } else {
      throw ArgumentError('Invalid user type');
    }
  }
}
```

## Error Handling

### 1. Database Errors
```dart
try {
  await operation();
} catch (e, stackTrace) {
  AppUtils.logger.e(
    'Database operation failed',
    error: e,
    stackTrace: stackTrace,
  );
  rethrow;
}
```

### 2. Authentication Errors
```dart
try {
  await authenticate();
} catch (e, stackTrace) {
  AppUtils.logger.e(
    'Authentication failed',
    error: e,
    stackTrace: stackTrace,
  );
  return AuthResult(
    userId: '',
    error: 'Authentication failed: ${e.toString()}',
  );
}
```

## Testing

### 1. Repository Tests
```dart
void main() {
  late UserRepository repository;
  late DatabaseService mockDatabase;

  setUp(() {
    mockDatabase = MockDatabaseService();
    repository = UserRepository(mockDatabase);
  });

  test('create user success', () async {
    // Test implementation
  });
}
```

### 2. Authentication Tests
```dart
void main() {
  late LocalAuthProvider authProvider;
  late MockUserRepository mockUserRepo;

  setUp(() {
    mockUserRepo = MockUserRepository();
    authProvider = LocalAuthProvider(userRepository: mockUserRepo);
  });

  test('login success', () async {
    // Test implementation
  });
}
```

## Logging

### 1. Setup Logging
```dart
class AppUtils {
  static final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
}
```

### 2. Usage
```dart
// Info logging
AppUtils.logger.i('Operation successful');

// Error logging
AppUtils.logger.e(
  'Operation failed',
  error: error,
  stackTrace: stackTrace,
);

// Debug logging
AppUtils.logger.d('Debug information');
```

## Security Best Practices

### 1. Password Handling
```dart
// Hash password
final salt = BCrypt.gensalt();
final hashedPassword = BCrypt.hashpw(password, salt);

// Verify password
final isValid = BCrypt.checkpw(password, hashedPassword);
```

### 2. Secure Storage
```dart
// Store sensitive data
await secureStorage.setValue('key', 'sensitive_data');

// Retrieve sensitive data
final data = await secureStorage.getValue('key');
```

## Performance Optimization

### 1. Database Indexing
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
```

### 2. Batch Operations
```dart
await db.transaction(() async {
  for (final item in items) {
    await db.into(db.table).insert(item);
  }
});
```
