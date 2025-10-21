import 'package:isar_community/isar.dart';

part 'favourite_collection.g.dart';

@collection
class FavouriteCollection {
  Id id = Isar.autoIncrement;

  late String url;

  late DateTime favouritedAt;
}
