import 'package:isar_community/isar.dart';
import 'package:meow_app/feature/image/data/image_collection.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/database_model/isar_collection/image_storage_collection.dart';
import '../../feature/favourite/data/favourite_collection.dart';

class IsarDatabase {
  Future initialize() {
    return Isar.initializeIsarCore().whenComplete(() {
      return getApplicationDocumentsDirectory().then(
        (dir) {
          return Isar.open(
            [
              FavouriteCollectionSchema,
              ImageCollectionSchema,
              ImageStorageCollectionSchema,
            ],
            directory: dir.path,
          );
        },
      );
    });
  }
}
