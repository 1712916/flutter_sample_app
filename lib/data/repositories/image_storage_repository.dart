
import 'package:isar_community/isar.dart';

import '../../core/index.dart';
import '../database_model/isar_collection/image_storage_collection.dart';
import '../models/image_storage_model.dart';
import 'crud_repository.dart';
import 'isar_repository.dart' as isarRepo;

final ImageStorageRepository imageStorageRepository = ImageStorageRepositoryImpl();

abstract class ImageStorageRepository
    implements CrudRepository<ImageStorageModel, int>, GetListRepository<ImageStorageModel> {
  static ImageStorageRepository instance = imageStorageRepository;
}

class ImageStorageRepositoryImpl extends ImageStorageRepository
    with isarRepo.IsarCrudRepository<ImageStorageModel, ImageStorageCollection> {
  final Isar _isar = Isar.getInstance()!;

  @override
  Isar get isar => _isar;

  @override
  IsarCollection<ImageStorageCollection> get collection => isar.imageStorageCollections;

  @override
  ImageStorageCollection createNewItem(ImageStorageModel item) {
    return ImageStorageCollection()
      ..url = item.url
      ..path = item.path
      ..bytes = item.bytes
      ..feature = item.feature?.toString();
  }

  @override
  Future<ImageStorageModel> getItemFromCollection(ImageStorageCollection collection) {
    return Future.value(
      ImageStorageModel(
        id: collection.id,
        url: collection.url,
        path: collection.path,
        bytes: collection.bytes,
        feature: collection.feature?.toImageStorageFeature(),
      ),
    );
  }

  @override
  ImageStorageCollection updateNewItem(ImageStorageModel item) {
    return ImageStorageCollection()
      ..id = item.id
      ..url = item.url
      ..path = item.path
      ..bytes = item.bytes
      ..feature = item.feature?.toString();
  }

  @override
  Future<List<ImageStorageModel>> getAll() {
    return collection.where().findAll().then((collections) {
      return mapListAsync(collections, getItemFromCollection);
    });
  }
}
