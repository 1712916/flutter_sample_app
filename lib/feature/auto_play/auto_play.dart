import 'auto_play_sort_game.dart';

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
