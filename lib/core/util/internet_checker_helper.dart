import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

class InternetCheckerHelper {
  InternetCheckerHelper._();
  static final Connectivity _connectivity = Connectivity();

  static Connectivity get connectivity => _connectivity;

  static bool get isConnected => true;
  // static bool get isConnected => _currentResult != ConnectivityResult.none;

  static ConnectivityResult _currentResult = ConnectivityResult.none;

  static void changeConnectivityResult(List<ConnectivityResult> connectivityResult) {
    try {
      log('Internet change: ${connectivityResult.last.name}');
      _currentResult = connectivityResult.last;
    } catch (e) {
      log('Internet change error: $e');
    }
  }

  static Future checkInternetAccess({Function? onConnected, Function? onDisconnected}) async {
    if (isConnected) {
      await onConnected?.call();
    } else {
      await onDisconnected?.call();
    }
  }
}
