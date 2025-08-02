import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meow_app/feature/game_pikachu/pikachu_game_loader.dart';
import 'package:meow_app/feature/game_pikachu/pikachu_game_page.dart';

import '../core/util/app_store_review.dart';
import '../feature/game_memory/memory_game_page.dart';
import '../feature/game_pikachu/widgets/game_loading_page.dart';
import '../feature/game_sort/game_page.dart';
import '../feature/game_sort/widget/crop_image_view.dart';
import '../feature/game_sticker/sticker_page.dart';
import '../feature/onboarding/onboarding_util.dart';
import '../feature/sound/background_music_player.dart';
import '../main.dart';

class RouteManager {
  static String get onboardingPage => '/onboarding';

  static String get mainPage => '/';

  static String get home => '/home';

  static String get imagePage => '/image';

  static String get imageListPage => '/image-list';

  static String get settingPage => '/setting';

  static String get infoPage => '/info';

  static String get gamePage => '/game';

  static String get favouritePage => '/favourite';

  static String get gameSettingPage => '/game/settings';

  static String get gameMenuPage => '/game/menu';

  static String get stickerPage => '/sticker';

  static String get stickerListPage => '/sticker/list';

  static String get pikachuGamePage => '/game/pikachu';

  static getRoute(RouteSettings settings) {
    late Widget widget;
    try {
      widget = GetIt.I.get<Widget>(instanceName: settings.name);
    } catch (e) {
      widget = Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Builder(builder: (context) {
            return Text(
              '404 Page Not Found',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            );
          }),
        ),
      );
    }
    // return PageTransition(child: widget, type: PageTransitionType.leftToRight, settings: settings);
    return MaterialPageRoute(builder: (_) => widget, settings: settings);
  }

  /// Initial route for the app based on onboarding status.
  static String _initialRoute = RouteManager.mainPage;

  static String get initialRoute => _initialRoute;

  static Future<String> getInitialRoute() async {
    await _checkOnboardingStatus();
    return _initialRoute;
  }

  static Future<void> _checkOnboardingStatus() async {
    final onboardingCompleted = await OnboardingUtil.isOnboardingCompleted();
    _initialRoute = onboardingCompleted ? RouteManager.mainPage : RouteManager.onboardingPage;
  }

  static resetInitialRoute() {
    _initialRoute = RouteManager.mainPage;
  }
}

void goToHome() {
  Navigator.of(navKey.currentContext!).pushNamedAndRemoveUntil(
    RouteManager.mainPage,
    (route) => false,
  );
}

void goToCropImageView(String url, {BuildContext? context}) {
  Navigator.of(context ?? navKey.currentContext!).push(
    MaterialPageRoute(
      builder: (context) => CropImageView(
        url: url,
      ),
    ),
  );
}

void goToSortGamePage(ui.Image image, {BuildContext? context}) {
  Navigator.of(context ?? navKey.currentContext!).pushReplacement(
    MaterialPageRoute(
      builder: (context) {
        return BackgroundMusicPlayer(child: SortGamePage(image: image));
      },
    ),
  ).whenComplete(() {
    InAppReviewUtil().checkAndShowReviewDialog();
  });
}

void goToMemoryGamePage(BuildContext context, {required List<String> imagePaths}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BackgroundMusicPlayer(
        child: MemoryGamePage(
          key: MemoryGamePage.memoryGameKey,
          imagePaths: imagePaths,
        ),
      ),
    ),
  );
}

void goToStickerPage({BuildContext? context, String? path}) {
  Navigator.of(context ?? navKey.currentContext!).push(
    MaterialPageRoute(
      builder: (context) => StickerPage(path: path),
    ),
  );
}

void goToStickerListPage({BuildContext? context}) {
  Navigator.of(context ?? navKey.currentContext!).pushNamed(RouteManager.stickerListPage);
}

void goToGameSetting([BuildContext? context]) {
  Navigator.of(context ?? navKey.currentContext!).pushNamed(RouteManager.gameSettingPage);
}

void goToPikachuGame([BuildContext? context]) {
  Navigator.push(
    context ?? navKey.currentContext!,
    MaterialPageRoute(
      builder: (context) => GameLoadingPage(
        onComplete: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BackgroundMusicPlayer(
                child: PikachuGamePage(),
              ),
            ),
          );
        },
        onProcess: () async {
          await PikachuGameLoader().loadGame();
        },
      ),
    ),
  );
}
