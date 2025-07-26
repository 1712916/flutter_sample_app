import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/game_sort/widget/crop_image_view.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../routers/route.dart';
import '../../widgets/widgets.dart';
import '../game/game_menu_page.dart';
import '../game_sort/game_manager.dart';
import '../game_sort/game_page.dart';
import '../game_sort/widget/play_area_widget.dart';
import '../image/cubit/image_list_cubit.dart';
import '../image/image_list_page.dart';
import 'auto_play.dart';
import 'auto_play_memory_game.dart';
import 'auto_play_recording_service.dart';

class AutoPlaySortGame extends AutoPlay {
  late BuildContext context;
  late PageController pageController;

  AutoPlaySortGame();

  // Use the shared recording service
  final AutoPlayRecordingService _recordingService = AutoPlayRecordingService();

  @override
  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 3));
    if (AutoPlayRecordingService.recordGame) {
      await _recordingService.start();
    }
  }

  @override
  Future<void> startAutoPlay() async {
    await Future.delayed(const Duration(seconds: 3));

    //swipe to some page

    final randomStep = Random().nextInt(5) + 1;

    for (int i = 1; i <= randomStep; i++) {
      await pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.linear);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    //get current image
    final imageListCubit = context.read<ImageListCubit>();

    final currentImage = imageListCubit.currentImage?.url ?? '';

    //check if current image is gif type, let go to next image with other type
    int i = 0;
    while (i < 3) {
      if (currentImage.endsWith('.gif')) {
        await pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.linear);
        await Future.delayed(const Duration(milliseconds: 800));
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

    await Future.delayed(const Duration(seconds: 2));

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
      gameArea.move(move);
      await Future.delayed(const Duration(milliseconds: 600));
      if (gameArea.game.isCompleted) {
        break;
      }
    }

    gameArea.move(Direction.down);

    //print done
    print('Auto-play completed for Sort Game');
  }

  @override
  Future<void> stopAutoPlay() async {
    await Future.delayed(const Duration(seconds: 3));
    enhancedAutoPlayGameNotifier.disable();

    if (AutoPlayRecordingService.recordGame) {
      try {
        await _recordingService.stop();
        await Future.delayed(const Duration(seconds: 3));

        enhancedAutoPlayGameNotifier.enable(AutoPlayGameType.sortGame);
        context.read<ImageListCubit>().reset();
        goToHome();
      } catch (e) {}
    }
  }
}

class AutoPlayGameConfirmWidget extends StatelessWidget with ShowDialog {
  const AutoPlayGameConfirmWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24.0),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LText(
                LKey.autoPlay,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LKey.autoPlayDescription.tr(
                  context: context,
                ),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      enhancedAutoPlayGameNotifier.enable(AutoPlayGameType.sortGame);
                      context.read<ImageListCubit>().reset();
                      goToHome();
                    },
                    icon: Icon(Icons.play_circle_outlined, color: theme.iconColor),
                    label: LText(
                      LKey.play,
                      style: theme.textTheme.titleMedium,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.highlightColor,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.exit_to_app, color: theme.iconColor),
                    label: LText(
                      LKey.exit,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
