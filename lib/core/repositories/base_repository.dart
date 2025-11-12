abstract class BaseRepository {
  Future<void> initialize();
  Future<void> dispose();
}

abstract class DataRepository<T> extends BaseRepository {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> delete(String id);
  Future<List<T>> search(Map<String, dynamic> query);
}

abstract class StreamRepository<T> extends DataRepository<T> {
  Stream<List<T>> watchAll();
  Stream<T?> watchById(String id);
}