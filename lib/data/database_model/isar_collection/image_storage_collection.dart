import 'package:isar_community/isar.dart';

part 'image_storage_collection.g.dart';

@collection
class ImageStorageCollection {
  Id id = Isar.autoIncrement;
  String? url;
  String? path;
  List<int>? bytes;
  String? feature;

  ImageStorageCollection({
    this.url,
    this.path,
    this.bytes,
    this.feature,
  });
}
