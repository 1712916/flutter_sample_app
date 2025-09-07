import 'package:flutter/foundation.dart';
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
      try {
        store = await openStore(directory: path);
      } catch (e) {
        store = Store.attach(getObjectBoxModel(), path);
      }
    }

    _instance = AObjectBox._create(store);

    return _instance!;
  }

  void close() {
    store.close();
  }

  static void openAdminDashboard() async {
    if (!kDebugMode) return;

    if (Admin.isAvailable() && isFirstRun) {
      // Keep a reference until no longer needed or manually closed.
      isFirstRun = false;
      final ob = await AObjectBox.create();

      admin = Admin(ob.store);
    }
  }

  static void closeAdminDashboard() {
    if (!kDebugMode) return;

    if (Admin.isAvailable() && !isFirstRun) {
      isFirstRun = true;
      admin.close();
    }
  }
}

bool isFirstRun = true;

late Admin admin;
