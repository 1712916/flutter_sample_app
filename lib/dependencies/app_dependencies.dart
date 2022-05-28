import 'package:get_it/get_it.dart';

import 'cubit_dependencies.dart';
import 'page_dependencies.dart';

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