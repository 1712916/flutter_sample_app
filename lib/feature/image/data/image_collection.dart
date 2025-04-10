import 'package:isar/isar.dart';

import 'image_cate.dart';

part 'image_collection.g.dart';

@collection
class ImageCollection {
  Id id = Isar.autoIncrement;

  late String url;

  @enumerated
  late ImageCate cate;
}
