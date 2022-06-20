import 'package:get_it/get_it.dart';

import '../cubits/cubits.dart';

class CubitDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<MainCubit>(() => MainCubit());
    injector.registerFactory<HomeCubit>(() => HomeCubit());
    injector.registerFactory<ImageCubit>(() => ImageCubit());
    injector.registerFactory<ImageListCubit>(() => ImageListCubit());
    injector.registerFactory<SettingsCubit>(() => SettingsCubit());
    injector.registerFactory<GameCubit>(() => GameCubit());
  }
}