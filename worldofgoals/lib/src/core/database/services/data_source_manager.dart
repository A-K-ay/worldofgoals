import '../data_sources/base_data_source.dart';
import '../data_sources/local_data_source.dart';
import '../data_sources/remote_data_source.dart';
import '../../utils/app_utils.dart';

enum SyncStrategy {
  /// Local first, then sync with remote
  localFirst,
  
  /// Remote first, then sync with local
  remoteFirst,
  
  /// Local only
  localOnly,
  
  /// Remote only
  remoteOnly,
}

/// Manages multiple data sources and their synchronization
class DataSourceManager {
  static final DataSourceManager _instance = DataSourceManager._internal();
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  SyncStrategy _syncStrategy;
  bool _isInitialized = false;

  factory DataSourceManager() {
    return _instance;
  }

  DataSourceManager._internal()
      : _localDataSource = LocalDataSource(),
        _remoteDataSource = RemoteDataSource(),
        _syncStrategy = SyncStrategy.localOnly;

  /// Initialize the data sources based on the sync strategy
  Future<void> initialize({SyncStrategy? strategy}) async {
    try {
      _syncStrategy = strategy ?? SyncStrategy.localOnly;
      AppUtils.logger.i('Initializing data sources with strategy: $_syncStrategy');

      switch (_syncStrategy) {
        case SyncStrategy.localOnly:
          await _localDataSource.initialize();
          break;
        case SyncStrategy.remoteOnly:
          await _remoteDataSource.initialize();
          break;
        case SyncStrategy.localFirst:
          await _localDataSource.initialize();
          await _remoteDataSource.initialize();
          break;
        case SyncStrategy.remoteFirst:
          await _remoteDataSource.initialize();
          await _localDataSource.initialize();
          break;
      }

      _isInitialized = true;
      AppUtils.logger.i('Data sources initialized');
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to initialize data sources',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get the appropriate data source based on the sync strategy
  BaseDataSource get activeDataSource {
    switch (_syncStrategy) {
      case SyncStrategy.localOnly:
        return _localDataSource;
      case SyncStrategy.remoteOnly:
        return _remoteDataSource;
      case SyncStrategy.localFirst:
      case SyncStrategy.remoteFirst:
        // In the future, this will return a composite data source
        // that handles both local and remote
        return _localDataSource;
    }
  }

  /// Synchronize data between local and remote sources
  Future<void> synchronize() async {
    if (_syncStrategy == SyncStrategy.localOnly ||
        _syncStrategy == SyncStrategy.remoteOnly) {
      return;
    }

    try {
      AppUtils.logger.i('Starting data synchronization');
      // TODO: Implement data synchronization logic
      // This will include:
      // 1. Conflict resolution
      // 2. Merge strategies
      // 3. Version control
      // 4. Error handling
      AppUtils.logger.i('Data synchronization completed');
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to synchronize data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Change the sync strategy at runtime
  Future<void> changeSyncStrategy(SyncStrategy newStrategy) async {
    try {
      AppUtils.logger.i('Changing sync strategy to: $newStrategy');
      if (_syncStrategy == newStrategy) return;

      // Initialize new data sources if needed
      switch (newStrategy) {
        case SyncStrategy.remoteOnly:
        case SyncStrategy.remoteFirst:
          if (!await _remoteDataSource.isReady()) {
            await _remoteDataSource.initialize();
          }
          break;
        case SyncStrategy.localOnly:
        case SyncStrategy.localFirst:
          if (!await _localDataSource.isReady()) {
            await _localDataSource.initialize();
          }
          break;
      }

      _syncStrategy = newStrategy;
      AppUtils.logger.i('Sync strategy changed successfully');
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to change sync strategy',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Close all data sources
  Future<void> close() async {
    try {
      AppUtils.logger.i('Closing data sources');
      await _localDataSource.close();
      await _remoteDataSource.close();
      _isInitialized = false;
      AppUtils.logger.i('Data sources closed');
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to close data sources',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
