import 'package:flutter/material.dart';
import 'package:flutter_sample_app/routers/route.dart';
import 'package:flutter_sample_app/views/pages/home/home_page.dart';
import 'package:flutter_sample_app/views/pages/image/image.dart';
import 'package:flutter_sample_app/views/pages/main_page.dart';
import 'package:get_it/get_it.dart';

class PageDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<Widget>(() => MainPage(cubit: injector()), instanceName: RouteManager.mainPage);
    injector.registerFactory<Widget>(() => HomePage(cubit: injector()), instanceName: RouteManager.home);
    injector.registerFactory<Widget>(() => ImagePage(cubit: injector()), instanceName: RouteManager.imagePage);
  }
}