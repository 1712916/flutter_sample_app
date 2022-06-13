import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../routers/route.dart';
import '../views/pages/pages.dart';

class PageDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<Widget>(() => MainPage(cubit: injector()), instanceName: RouteManager.mainPage);
    injector.registerFactory<Widget>(() => HomePage(cubit: injector()), instanceName: RouteManager.home);
    injector.registerFactory<Widget>(() => ImagePage(cubit: injector()), instanceName: RouteManager.imagePage);
    injector.registerFactory<Widget>(() => ImageListPage(cubit: injector()), instanceName: RouteManager.imageListPage);
    injector.registerFactory<Widget>(() => SettingPage(cubit: injector(),), instanceName: RouteManager.settingPage);
    injector.registerFactory<Widget>(() => const InfoPage(), instanceName: RouteManager.infoPage);
    injector.registerFactory<Widget>(() => const GamePage(), instanceName: RouteManager.gamePage);
  }
}