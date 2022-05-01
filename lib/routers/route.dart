import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RouteManager {

  static String get home => '/';

  static getRoute(RouteSettings settings) {
    late Widget widget;
    try {
     widget = GetIt.I.get<Widget>(instanceName: settings.name);
    } catch (e) {
      widget = Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Builder(
            builder: (context) {
              return Text(
                '404 Page Not Found',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5,
              );
            }
          ),
        ),
      );
    }
    return MaterialPageRoute(builder: (_) => widget, settings: settings);
  }
}
