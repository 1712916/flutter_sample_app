import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../objectbox.g.dart';

@Entity()
class ChatEntity {
  @Id()
  int id;

  ///[message] is not directly string;
  ///in this app it wil
  String message;

  String sender;

  String type;

  DateTime createdAt;

  ChatEntity({
    this.id = 0,
    required this.message,
    required this.sender,
    required this.type,
    required this.createdAt,
  });
}

class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store);

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();

    final store = await openStore(directory: p.join(docsDir.path, "obx-example"));
    return ObjectBox._create(store);
  }
}
