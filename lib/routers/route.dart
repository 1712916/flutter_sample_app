import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:page_transition/page_transition.dart';

class RouteManager {

  static String get mainPage => '/';

  static String get home => '/home';

  static String get imagePage => '/image';

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
    // return PageTransition(child: widget, type: PageTransitionType.leftToRight, settings: settings);
    return MaterialPageRoute(builder: (_) => widget, settings: settings);
   
  }
}
