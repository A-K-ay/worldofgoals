/// Abstract interface for data sources (local or remote)
abstract class BaseDataSource {
  /// Initialize the data source
  Future<void> initialize();

  /// Close the data source
  Future<void> close();

  /// Check if the data source is ready
  Future<bool> isReady();

  /// Clear all data
  Future<void> clearAll();
}
