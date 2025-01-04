# World of Goals - Architecture Documentation

## Overview
World of Goals is a gamified task management Flutter application that uses an offline-first architecture with future cloud synchronization capabilities.

## Core Architecture

### 1. Data Layer Architecture

#### Database Design
- **Technology**: Drift (SQLite) for local storage
- **Future Integration**: PostgreSQL for cloud storage
- **Tables**:
  - Users: User management and authentication
  - Tasks: Task tracking and management
  - Rewards: Achievement rewards system
  - Achievements: User progress tracking

#### Data Source Architecture
```
├── data_sources/
│   ├── base_data_source.dart     # Common interface
│   ├── local_data_source.dart    # SQLite implementation
│   └── remote_data_source.dart   # Future PostgreSQL implementation
├── services/
│   ├── database_service.dart     # Database connection management
│   └── data_source_manager.dart  # Data source orchestration
```

#### Sync Strategies
- **LocalOnly**: Current MVP implementation using SQLite
- **LocalFirst**: Future implementation prioritizing offline access
- **RemoteFirst**: Alternative strategy for online-first scenarios
- **RemoteOnly**: Cloud-only implementation option

### 2. Authentication System

#### Components
- **AuthProvider Interface**: Abstract authentication provider
- **LocalAuthProvider**: Current implementation using SQLite
- **SecureStorage**: Encrypted storage for sensitive data
- **SessionManager**: Token-based session management

#### Security Features
- Password hashing using BCrypt
- Encrypted storage for credentials
- Session token management
- Secure storage for sensitive data

### 3. Repository Pattern

#### Implementation
```dart
abstract class BaseRepository<T> {
  Future<void> create(T item);
  Future<T?> read(String id);
  Future<bool> update(T item);
  Future<bool> delete(String id);
  Future<List<T>> getAll();
}
```

#### Repositories
- **UserRepository**: User data management
- **TaskRepository**: Task operations
- **RewardRepository**: Reward system management
- **AchievementRepository**: Achievement tracking

## Feature Documentation

### 1. Authentication

#### Registration Flow
1. User enters email, username, and password
2. System validates input
3. Password is hashed using BCrypt
4. User record is created in local database
5. Session token is generated and stored
6. User is redirected to home screen

#### Login Flow
1. User enters email and password
2. System validates credentials
3. Session token is generated
4. Token is stored in secure storage
5. User is redirected to home screen

#### Session Management
- Token-based authentication
- 7-day session duration
- Secure token storage
- Automatic session validation

### 2. Database Management

#### Local Database
- Automatic initialization
- Connection pooling
- Error handling
- Logging system

#### Future Cloud Integration
1. **Implementation Steps**:
   ```dart
   // Initialize with remote support
   await DataSourceManager().initialize(
     strategy: SyncStrategy.localFirst,
   );

   // Use repositories as normal
   final userRepo = UserRepository(DataSourceManager().activeDataSource);
   ```

2. **Sync Process**:
   - Automatic conflict resolution
   - Offline changes tracking
   - Background synchronization
   - Error recovery

### 3. Security Implementation

#### Data Encryption
- Secure storage for sensitive data
- Session token encryption
- Password hashing
- Database encryption (planned)

#### Error Handling
- Comprehensive error logging
- User-friendly error messages
- Graceful failure recovery
- Debug logging in development

## Future Roadmap

### 1. PostgreSQL Integration
- Implement RemoteDataSource
- Add cloud synchronization
- Handle offline/online transitions
- Implement conflict resolution

### 2. Enhanced Security
- Two-factor authentication
- Biometric authentication
- Enhanced encryption
- Security auditing

### 3. Performance Optimizations
- Connection pooling
- Cache management
- Background sync
- Batch operations

## Development Guidelines

### 1. Code Organization
```
lib/
├── src/
│   ├── core/           # Core functionality
│   │   ├── database/   # Database implementation
│   │   ├── config/     # App configuration
│   │   └── utils/      # Utilities
│   └── features/       # Feature modules
│       ├── auth/       # Authentication
│       ├── tasks/      # Task management
│       └── rewards/    # Reward system
```

### 2. Best Practices
- Follow repository pattern
- Implement proper error handling
- Add comprehensive logging
- Write unit tests
- Document public APIs
- Use dependency injection

### 3. Testing Strategy
- Unit tests for business logic
- Integration tests for repositories
- Widget tests for UI components
- End-to-end tests for flows
