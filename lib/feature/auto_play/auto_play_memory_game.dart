import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../routers/route.dart';
import '../../widgets/widgets.dart';
import '../game/game_menu_page.dart';
import '../game_memory/memory_game_page.dart';
import '../image/cubit/image_list_cubit.dart';
import '../image/image_selection_widget.dart';
import 'auto_play.dart';
import 'auto_play_recording_service.dart';

class AutoPlayMemoryGame extends AutoPlay {
  late BuildContext context;
  late PageController pageController;

  AutoPlayMemoryGame();

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
    await Future.delayed(const Duration(milliseconds: 800));

    // Swipe to some page to get different images
    final randomStep = Random().nextInt(3) + 1; // Giảm từ 5 xuống 3

    for (int i = 1; i <= randomStep; i++) {
      await pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.linear);
      await Future.delayed(const Duration(milliseconds: 150));
    }

    // Get current image
    final imageListCubit = context.read<ImageListCubit>();
    final currentImage = imageListCubit.currentImage?.url ?? '';

    // Check if current image is gif type, let go to next image with other type
    int i = 0;
    while (i < 2) {
      // Giảm từ 3 xuống 2
      if (currentImage.endsWith('.gif')) {
        await pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.linear);
        await Future.delayed(const Duration(milliseconds: 150));
        i++;
      } else {
        break;
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));

    // Go to game menu
    goToGameMenu(context);

    await Future.delayed(const Duration(milliseconds: 400));

    // Navigate to memory game through image selection
    _startMemoryGameSelection();

    await Future.delayed(const Duration(milliseconds: 400));

    // Auto play the memory game
    await _playMemoryGame();

    print('Auto-play completed for Memory Game');
  }

  void _startMemoryGameSelection() {
    // Navigate to memory game selection screen with auto-play key
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageSelectionScreen(
          key: ImageSelectionScreen.autoPlayKey,
          maxImage: 8,
          minImage: 8,
          onSubmitImage: (imagePaths) {
            Navigator.pop(context);
            goToMemoryGamePage(
              context,
              imagePaths: imagePaths,
            );
          },
          selectImageTitle: LKey.startGame.tr(context: context),
        ),
      ),
    );
  }

  Future<void> _playMemoryGame() async {
    // Wait for image selection screen to appear
    await Future.delayed(const Duration(milliseconds: 200));

    // Auto-select 8 random images by simulating UI interactions
    await _autoSelectImagesInSelectionScreen();

    // Wait for memory game to load after selection
    await Future.delayed(const Duration(milliseconds: 200));

    // Start auto-playing the memory game
    await _autoPlayMemoryGame();
  }

  Future<void> _autoSelectImagesInSelectionScreen() async {
    // Wait for the selection screen to be fully rendered
    await Future.delayed(const Duration(milliseconds: 500));

    final imageListCubit = context.read<ImageListCubit>();
    final totalImages = imageListCubit.state.images?.length ?? 0;

    if (totalImages >= 8) {
      // Chọn 8 vị trí đầu tiên
      final selectedIndices = Set<int>.from(List.generate(8, (index) => index));

      print('Auto-selecting images at indices: $selectedIndices');

      // Get the selection screen state and auto-select images
      final selectionScreenState = ImageSelectionScreen.autoPlayKey.currentState;
      if (selectionScreenState != null) {
        // Simulate selecting images one by one with delays
        await Future.delayed(const Duration(milliseconds: 600));
        selectionScreenState.autoSelectImages(selectedIndices);

        // Wait a bit more then start the game
        await Future.delayed(const Duration(milliseconds: 300));

        print('Auto-starting memory game...');
        selectionScreenState.autoStartGame();
      } else {
        print('Could not find selection screen state, falling back to direct navigation');

        // Fallback: Get image paths and navigate directly
        final selectedImagePaths = selectedIndices.map((index) {
          return imageListCubit.state.images![index].url!;
        }).toList();

        Navigator.pop(context);
        goToMemoryGamePage(context, imagePaths: selectedImagePaths);
      }
    }
  }

  Future<void> _autoPlayMemoryGame() async {
    // Wait for memory game page to be fully loaded
    await Future.delayed(const Duration(milliseconds: 1200));

    // Get the memory game state
    final memoryGameState = MemoryGamePage.memoryGameKey.currentState;
    if (memoryGameState == null) {
      print('Memory game state not found');
      return;
    }

    final random = Random();
    final totalCards = memoryGameState.cardKeys.length;

    print('Starting auto-play for memory game with $totalCards cards');

    // Lưu lịch sử các thẻ đã lật: {nội dung: [chỉ số thẻ]}
    final Map<String, List<int>> flipHistory = {};
    final Set<int> flippedCardIndices = {}; // Tất cả thẻ đã lật

    // Auto-play loop
    while (!memoryGameState.matchedCards.every((matched) => matched)) {
      await Future.delayed(Duration(milliseconds: 400 + random.nextInt(200))); // Giảm từ 1000+500 xuống 400+200

      if (memoryGameState.isFlipping) {
        await Future.delayed(const Duration(milliseconds: 300)); // Giảm từ 600 xuống 300
        continue;
      }

      int? nextCardIndex;

      // Nếu đã có thẻ đầu tiên được chọn
      if (memoryGameState.firstCardIndex != null) {
        final firstCardIndex = memoryGameState.firstCardIndex!;
        final firstCardContent = memoryGameState.scrambledContents[firstCardIndex];

        print('First card selected: $firstCardIndex with content: $firstCardContent');

        // Kiểm tra trong lịch sử có thẻ nào trùng nội dung không
        final matchingCards = flipHistory[firstCardContent] ?? [];

        // Tìm thẻ trùng nội dung trong lịch sử (khác với thẻ đầu tiên và chưa ghép)
        for (final cardIndex in matchingCards) {
          if (cardIndex != firstCardIndex && !memoryGameState.matchedCards[cardIndex]) {
            nextCardIndex = cardIndex;
            print('Found matching card in history: $cardIndex');
            break;
          }
        }

        // Nếu không tìm được thẻ trùng trong lịch sử, lật thẻ mới chưa lật
        if (nextCardIndex == null) {
          for (int i = 0; i < totalCards; i++) {
            if (!memoryGameState.matchedCards[i] && !flippedCardIndices.contains(i) && i != firstCardIndex) {
              nextCardIndex = i;
              print('Flipping new card: $i');
              break;
            }
          }
        }

        // Nếu vẫn không tìm được, lật bất kỳ thẻ nào chưa ghép
        if (nextCardIndex == null) {
          for (int i = 0; i < totalCards; i++) {
            if (!memoryGameState.matchedCards[i] && i != firstCardIndex) {
              nextCardIndex = i;
              print('Flipping any unmatched card: $i');
              break;
            }
          }
        }
      } else {
        // Chưa có thẻ nào được chọn, lật thẻ đầu tiên
        // Ưu tiên lật thẻ chưa lật lần nào

        //index của các thẻ chưa matched
        final unMatchedCards = Set<int>.from(
            memoryGameState.matchedCards.asMap().entries.where((entry) => !entry.value).map((entry) => entry.key));

        //unMatchedCards trừ ra các thẻ đã lật trong flippedCardIndices
        final availableCards = unMatchedCards.difference(flippedCardIndices);

        nextCardIndex =
            availableCards.isNotEmpty ? availableCards.elementAt(random.nextInt(availableCards.length)) : null;

        // Nếu không có thẻ mới, lật bất kỳ thẻ nào chưa ghép
        if (nextCardIndex == null) {
          for (int i = 0; i < totalCards; i++) {
            if (!memoryGameState.matchedCards[i]) {
              nextCardIndex = i;
              print('Flipping first card (any): $i');
              break;
            }
          }
        }
      }

      if (nextCardIndex != null) {
        print('Auto-flipping card at index $nextCardIndex');
        await memoryGameState.simulateCardTap(nextCardIndex);

        // Lưu vào lịch sử
        final content = memoryGameState.scrambledContents[nextCardIndex];
        flipHistory.putIfAbsent(content, () => []).add(nextCardIndex);
        flippedCardIndices.add(nextCardIndex);

        print('Added to history: content=$content, index=$nextCardIndex');
        print('Current flip history: $flipHistory');

        await Future.delayed(const Duration(milliseconds: 400)); // Giảm từ 800 xuống 400
      } else {
        print('No cards available to flip - this should not happen');
        break;
      }
    }

    print('Memory game auto-play completed!');
  }

  @override
  Future<void> stopAutoPlay() async {
    await Future.delayed(const Duration(seconds: 3));
    enhancedAutoPlayGameNotifier.disable();

    if (AutoPlayRecordingService.recordGame) {
      try {
        await _recordingService.stop();
        await Future.delayed(const Duration(seconds: 3));

        enhancedAutoPlayGameNotifier.enable(AutoPlayGameType.memoryGame);
        context.read<ImageListCubit>().reset();
        goToHome();
      } catch (e) {}
    }
  }
}

// Enum for auto-play game types
enum AutoPlayGameType {
  sortGame,
  memoryGame,
}

// Enhanced auto-play notifier that supports different game types
class AutoPlayGameNotifier extends ValueNotifier<AutoPlayGameType?> {
  AutoPlayGameNotifier() : super(null);

  bool get isEnabled => value != null;

  void enable(AutoPlayGameType gameType) {
    value = gameType;
  }

  void disable() {
    value = null;
  }

  void toggle(AutoPlayGameType gameType) {
    if (value == gameType) {
      disable();
    } else {
      enable(gameType);
    }
  }
}

// Create instances
AutoPlayMemoryGame autoPlayMemoryGame = AutoPlayMemoryGame();
final AutoPlayGameNotifier enhancedAutoPlayGameNotifier = AutoPlayGameNotifier();
