import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meow_app/feature/setting_page_new.dart';

import '../feature/image/image_list_page.dart';
import '../routers/route.dart';

class PageDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<Widget>(() => ImageListPage(cubit: injector()), instanceName: RouteManager.mainPage);
    injector.registerFactory<Widget>(() => SettingNewPage(), instanceName: RouteManager.settingPage);
  }
}
