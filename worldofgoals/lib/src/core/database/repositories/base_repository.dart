/// Base repository interface that defines common CRUD operations
abstract class BaseRepository<T> {
  /// Create a new entity
  Future<void> create(T entity);

  /// Read an entity by its ID
  Future<T?> read(String id);

  /// Update an existing entity
  Future<bool> update(T entity);

  /// Delete an entity by its ID
  Future<bool> delete(String id);

  /// Get all entities
  Future<List<T>> getAll();
}
