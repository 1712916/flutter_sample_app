import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

class InternetCheckerHelper {
  InternetCheckerHelper._();
  static final Connectivity _connectivity = Connectivity();

  static Connectivity get  connectivity => _connectivity;

  static bool get isConnected => _currentResult != ConnectivityResult.none;

  static ConnectivityResult _currentResult = ConnectivityResult.none;

  static void changeConnectivityResult(ConnectivityResult connectivityResult) {
    log('Internet change: ${connectivityResult.name}');
    _currentResult = connectivityResult;
  }

  static Future checkInternetAccess({Function? onConnected, Function? onDisconnected}) async {
    if (isConnected) {
      await onConnected?.call();
    } else {
      await onDisconnected?.call();
    }
  }
}