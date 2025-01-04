import 'package:drift/drift.dart';
import '../services/database_service.dart';
import 'base_data_source.dart';
import '../../utils/app_utils.dart';

/// Local SQLite data source implementation
class LocalDataSource implements BaseDataSource {
  final DatabaseService _databaseService;
  bool _isInitialized = false;

  LocalDataSource({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  @override
  Future<void> initialize() async {
    try {
      AppUtils.logger.i('Initializing local data source');
      await _databaseService.database;
      _isInitialized = true;
      AppUtils.logger.i('Local data source initialized');
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to initialize local data source',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    try {
      AppUtils.logger.i('Closing local data source');
      await _databaseService.closeDatabase();
      _isInitialized = false;
      AppUtils.logger.i('Local data source closed');
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to close local data source',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<bool> isReady() async {
    return _isInitialized;
  }

  @override
  Future<void> clearAll() async {
    try {
      AppUtils.logger.i('Clearing all local data');
      final db = await _databaseService.database;
      await db.transaction(() async {
        // Clear all tables in the correct order to respect foreign keys
        await db.delete(db.achievements).go();
        await db.delete(db.rewards).go();
        await db.delete(db.tasks).go();
        await db.delete(db.users).go();
      });
      AppUtils.logger.i('All local data cleared');
    } catch (e, stackTrace) {
      AppUtils.logger.e(
        'Failed to clear local data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
