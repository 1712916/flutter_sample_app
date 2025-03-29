abstract class CrudRepository<T, Id> {
  Future<T> create(T item);
  Future<T> read(Id id);
  Future<T> update(T item);
  Future<bool> delete(T item);
}

abstract class CrudException implements Exception {}

class NotFoundException extends CrudException {}

class CreateErrorException extends CrudException {}

abstract class SearchRepository<T> {
  Future<List<T>> search(String keyword);
}

abstract class GetOneByNameRepository<T> {
  Future<T?> getOneByName(String name);
}

abstract class GetListRepository<T> {
  Future<List<T>> getAll();
}
