import 'package:meow_app/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

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
