import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/game/widget/crop_image_view.dart';

import '../../routers/route.dart';
import '../game/game_manager.dart';
import '../game/game_page.dart';
import '../game/widget/play_area_widget.dart';
import '../game_memory/game_menu_page.dart';
import '../image/cubit/image_list_cubit.dart';
import '../image/image_list_page.dart';

abstract class AutoPlay {
  Future<void> init();

  /// Starts the auto-play functionality.
  Future<void> startAutoPlay();

  /// Stops the auto-play functionality.
  Future<void> stopAutoPlay();

  //run the auto-play game
  Future<void> runAutoPlayGame() async {
    await init();
    await startAutoPlay();
    await stopAutoPlay();
  }
}

AutoPlaySortGame autoPlaySortGame = AutoPlaySortGame();

class AutoPlaySortGame extends AutoPlay {
  late final BuildContext context;
  late final PageController pageController;

  AutoPlaySortGame();

  @override
  Future<void> init() async {
    // Initialization logic for auto-play, if any.
  }

  @override
  Future<void> startAutoPlay() async {
    await Future.delayed(const Duration(seconds: 3));

    //swipe to some page

    final randomStep = Random().nextInt(5) + 1;

    for (int i = 1; i <= randomStep; i++) {
      await pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.linear);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    //get current image
    final imageListCubit = context.read<ImageListCubit>();

    final currentImage = imageListCubit.currentImage?.url ?? '';

    //check if current image is gif type, let go to next image with other type
    int i = 0;
    while (i < 3) {
      if (currentImage.endsWith('.gif')) {
        await pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.linear);
        await Future.delayed(const Duration(milliseconds: 500));
        i++;
      } else {
        break;
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    goToGameMenu(context);

    await Future.delayed(const Duration(seconds: 3));

    final ImageListCubit cubit = context.read<ImageListCubit>();
    final currentSelectedImage = cubit.currentImage?.url ?? '';

    goToCropImageView(currentSelectedImage, context: context);

    await Future.delayed(const Duration(seconds: 3));

    final gestureDetector = goToGameKey.currentWidget as TakeImageButton;
    gestureDetector.onTapAction.call();
    await Future.delayed(const Duration(seconds: 3));

    final gameArea = SortGamePage.playAreaBoardKey.currentState!;

    final revertScramble = getReverseMoves(gameArea.game.scrambleMoves).map(
      (e) => Direction.values[e.index],
    );

    print('length revertScramble: ${revertScramble.length}');
    await Future.delayed(const Duration(seconds: 3));

    for (final move in revertScramble) {
      gameArea!.move(move);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    gameArea.move(Direction.down);

    //print done
    print('Auto-play completed for Sort Game');
  }

  @override
  Future<void> stopAutoPlay() async {
    //todo: call api stop to record
  }
}
