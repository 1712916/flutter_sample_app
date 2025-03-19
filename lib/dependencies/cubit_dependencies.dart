import 'package:get_it/get_it.dart';

import '../feature/game/cubit/game_cubit.dart';
import '../feature/image/cubit/image_list_cubit.dart';

class CubitDependencies {
  static Future<void> init(GetIt injector) async {
    injector.registerFactory<ImageListCubit>(() => ImageListCubit());
    injector.registerFactory<GameCubit>(() => GameCubit());
  }
}
