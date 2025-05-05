import 'package:get_it/get_it.dart';

import '../feature/ads/cubit/ads_cubit.dart';
import '../feature/app_menu/cubit/app_menu_cubit.dart';
import '../feature/favourite/cubit/favourite_cubit.dart';
import '../feature/game/cubit/game_setting_cubit.dart';
import '../feature/image/cubit/image_list_cubit.dart';

class CubitDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<ImageListCubit>(() => ImageListCubit());
    injector.registerFactory<FavouriteCubit>(() => FavouriteCubit());
    injector.registerFactory<GameSettingCubit>(() {
      return GameSettingCubit()..init();
    });
    injector.registerFactory<AppMenuCubit>(() => AppMenuCubit());
    injector.registerFactory<AdsCubit>(() => AdsCubit());
  }
}
