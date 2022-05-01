import 'package:flutter/material.dart';
import 'package:flutter_sample_app/routers/route.dart';
import 'package:flutter_sample_app/views/pages/home/home_page.dart';
import 'package:get_it/get_it.dart';

class PageDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<Widget>(() => HomePage(cubit: injector()), instanceName: RouteManager.home);
  }
}