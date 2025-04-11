import 'package:isar/isar.dart' hide GetId;

import '../../../core/index.dart';
import '../../../data/repositories/isar_repository.dart';
import 'image_cate.dart';
import 'image_collection.dart';

class ImageItem extends GetId<int> {
  @override
  Id? get getId => id;

  final int? id;

  final String url;
  final double? width;
  final double? height;

  ImageItem({
    this.id,
    required this.url,
    required this.width,
    required this.height,
  });
}

abstract class ImageRepository {
  Future<List<ImageItem>> getList({int offset = 0, int limit = 10});
  Future<void> addList(List<ImageItem> items);
}

class ImageRepositoryImpl extends ImageRepository {
  final Isar _isar = Isar.getInstance()!;

  Isar get isar => _isar;

  IsarCollection<ImageCollection> get collection => _isar.imageCollections;

  ImageCate get cate => SettingManager.isMeow ? ImageCate.cat : ImageCate.dog;

  ImageItem getItemFromCollection(ImageCollection collection) {
    return ImageItem(
      id: collection.id,
      url: collection.url,
      width: collection.width,
      height: collection.height,
    );
  }

  @override
  Future<List<ImageItem>> getList({int offset = 0, int limit = 10}) {
    return isar.writeTxn(() async {
      final collections = await collection.filter().cateEqualTo(cate).offset(offset).limit(limit).findAll();
      return collections.map((collection) => getItemFromCollection(collection)).toList();
    });
  }

  @override
  Future addList(List<ImageItem> items) async {
    final _cate = cate;
    return isar.writeTxn(() async {
      collection.putAll(
        items
            .map((item) => ImageCollection()
              ..url = item.url
              ..width = item.width
              ..height = item.height
              ..cate = _cate)
            .toList(),
      );
    });
  }
}
