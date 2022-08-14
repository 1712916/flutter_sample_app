import 'package:flutter/material.dart';
import 'package:flutter_sample_app/routers/route.dart';
import 'package:get_it/get_it.dart';

import '../views/views.dart';

class PageDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<Widget>(() => HomePage(cubit: injector()), instanceName: RouteManager.home);
    injector.registerFactory<Widget>(() => EventPage(cubit: injector()), instanceName: RouteManager.event);
  }
}