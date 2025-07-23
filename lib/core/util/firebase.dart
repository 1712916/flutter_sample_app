import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

Future configFirebase() async {
  await Firebase.initializeApp();

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Non-async exceptions
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
