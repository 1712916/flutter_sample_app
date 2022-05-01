import 'package:flutter_sample_app/dependencies/cubit_dependencies.dart';
import 'package:flutter_sample_app/dependencies/page_dependencies.dart';
import 'package:get_it/get_it.dart';

class AppDependencies {
  static GetIt get injector => GetIt.I;

  static Future<void> init() async {
    await _initAllDependency();
  }

  static Future<void> _initAllDependency () async{
    await Future.wait([
      CubitDependencies.init(injector),
      PageDependencies.init(injector),
    ]);
  }
}