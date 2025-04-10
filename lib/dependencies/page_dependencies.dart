import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meow_app/feature/game/game_setting_page.dart';
import 'package:meow_app/feature/setting_page_new.dart';

import '../feature/favourite/favourite_page.dart';
import '../feature/image/image_list_page.dart';
import '../routers/route.dart';

class PageDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<Widget>(() => ImageListPage(), instanceName: RouteManager.mainPage);
    injector.registerFactory<Widget>(() => SettingNewPage(), instanceName: RouteManager.settingPage);
    injector.registerFactory<Widget>(() => FavouritePage(), instanceName: RouteManager.favouritePage);
    injector.registerFactory<Widget>(() => GameSettingPage(), instanceName: RouteManager.gameSettingPage);
  }
}
