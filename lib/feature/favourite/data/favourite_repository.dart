import 'package:isar/isar.dart' hide GetId;

import '../../../core/index.dart';
import '../../../data/repositories/crud_repository.dart';
import '../../../data/repositories/isar_repository.dart';
import 'favourite_collection.dart';

class FavouriteItem extends GetId<int> {
  @override
  Id? get getId => id;

  final int? id;

  final String url;

  final DateTime favouritedAt;

  FavouriteItem({
    this.id,
    required this.url,
    required this.favouritedAt,
  });
}

abstract class LandCertificateRepository
    implements
        CrudRepository<FavouriteItem, int>,
        GetOneByNameRepository<FavouriteItem>,
        GetListRepository<FavouriteItem> {}

class LandCertificateRepositoryImpl extends LandCertificateRepository
    with IsarCrudRepository<FavouriteItem, FavouriteCollection> {
  final Isar _isar = Isar.getInstance()!;

  @override
  Isar get isar => _isar;

  @override
  IsarCollection<FavouriteCollection> get collection => _isar.favouriteCollections;

  @override
  FavouriteCollection createNewItem(FavouriteItem item) {
    return FavouriteCollection()
      ..url = item.url
      ..favouritedAt = item.favouritedAt;
  }

  @override
  Future<FavouriteItem> getItemFromCollection(FavouriteCollection collection) {
    return Future.value(FavouriteItem(
      id: collection.id,
      url: collection.url,
      favouritedAt: collection.favouritedAt,
    ));
  }

  @override
  FavouriteCollection updateNewItem(FavouriteItem item) {
    return FavouriteCollection()
      ..id = item.id!
      ..url = item.url
      ..favouritedAt = item.favouritedAt;
  }

  @override
  Future<FavouriteItem?> getOneByName(String name) {
    return collection.filter().urlEqualTo(name).findFirst().then((collection) {
      if (collection == null) {
        return null;
      }

      return getItemFromCollection(collection);
    });
  }

  @override
  Future<List<FavouriteItem>> getAll() {
    return collection.where().findAll().then((collections) {
      return mapListAsync(collections, getItemFromCollection);
    });
  }
}
