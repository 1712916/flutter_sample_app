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

class AObjectBox {
  late final Store store;

  AObjectBox._create(this.store);

  static AObjectBox? _instance;

  static Future<AObjectBox> create() async {
    if (_instance != null) {
      return _instance!;
    }

    Store store;

    final docsDir = await getApplicationDocumentsDirectory();
    final path = docsDir.path;

    ///Check is store opened
    if (Store.isOpen(path)) {
      store = Store.attach(getObjectBoxModel(), path);
    } else {
      store = await openStore(directory: path);
    }

    _instance = AObjectBox._create(store);

    return _instance!;
  }

  void close() {
    store.close();
  }
}
