import 'package:isar/isar.dart';
import 'package:meow_app/feature/image/data/image_collection.dart';
import 'package:path_provider/path_provider.dart';

import '../../feature/favourite/data/favourite_collection.dart';

class IsarDatabase {
  @override
  Future initialize() {
    return Isar.initializeIsarCore().whenComplete(() {
      return getApplicationDocumentsDirectory().then(
        (dir) {
          return Isar.open(
            [
              FavouriteCollectionSchema,
              ImageCollectionSchema,
            ],
            directory: dir.path,
          );
        },
      );
    });
  }
}
