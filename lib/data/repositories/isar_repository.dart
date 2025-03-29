import 'package:isar/isar.dart';

import 'crud_repository.dart';

abstract class GetId<Id> {
  Id? get getId;
}

mixin IsarCrudRepository<T extends GetId<int>, C> on CrudRepository<T, int> {
  Isar get isar;

  IsarCollection<C> get collection;

  C createNewItem(T item);

  C updateNewItem(T item);

  Future<T> getItemFromCollection(C collection);

  @override
  Future<T> create(T item) {
    final C nItem = createNewItem(item);

    return isar.writeTxn(() => collection.put(nItem)).then((id) => getItemFromCollection(nItem));
  }

  @override
  Future<bool> delete(T item) {
    if (item.getId == null) {
      throw NotFoundException();
    }

    return isar.writeTxn(() async {
      return collection.delete(item.getId!);
    });
  }

  @override
  Future<T> read(int id) {
    return isar.writeTxn(() async {
      return collection.get(id).then((collection) {
        if (collection == null) {
          throw NotFoundException();
        }

        return getItemFromCollection(collection);
      });
    });
  }

  @override
  Future<T> update(T item) {
    if (item.getId == null) {
      throw UnimplementedError();
    }

    final nItem = updateNewItem(item);

    return isar.writeTxn(() async {
      return collection.put(nItem).then((id) => getItemFromCollection(nItem));
    });
  }
}
