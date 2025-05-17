import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

import '../../core/index.dart';
import 'crud_repository.dart';
import 'isar_repository.dart' as isarRepo;

part 'image_storage_repository.g.dart';

@collection
class ImageStorageCollection {
  Id id = Isar.autoIncrement;
  String? url;
  String? path;
  List<int>? bytes;

  ImageStorageCollection({
    this.url,
    this.path,
    this.bytes,
  });
}

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
      ..bytes = item.bytes;
  }

  @override
  Future<ImageStorageModel> getItemFromCollection(ImageStorageCollection collection) {
    return Future.value(
      ImageStorageModel(
        id: collection.id,
        url: collection.url,
        path: collection.path,
        bytes: collection.bytes,
      ),
    );
  }

  @override
  ImageStorageCollection updateNewItem(ImageStorageModel item) {
    return ImageStorageCollection()
      ..id = item.id
      ..url = item.url
      ..path = item.path
      ..bytes = item.bytes;
  }

  @override
  Future<List<ImageStorageModel>> getAll() {
    return collection.where().findAll().then((collections) {
      return mapListAsync(collections, getItemFromCollection);
    });
  }
}

class ImageStorageModel extends Equatable implements isarRepo.GetId<int> {
  final int id;
  final String? url;
  final String? path;
  final List<int>? bytes;

  ImageStorageModel({
    required this.id,
    this.url,
    this.path,
    this.bytes,
  });

  @override
  int? get getId => id;

  @override
  List<Object?> get props => [
        id,
        url,
        path,
        bytes,
      ];
}
