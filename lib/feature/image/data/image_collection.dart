import 'package:isar_community/isar.dart';

import 'image_cate.dart';

part 'image_collection.g.dart';

@collection
class ImageCollection {
  Id id = Isar.autoIncrement;

  late String url;
  late double? width;
  late double? height;

  @enumerated
  late ImageCate cate;
}
