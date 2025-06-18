import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../feature/app_store_review/app_store_review.dart';
import '../feature/game/game_page.dart';
import '../feature/game/widget/crop_image_view.dart';
import '../feature/game_memory/memory_game_page.dart';
import '../feature/sticker/sticker_page.dart';
import '../main.dart';
import '../widgets/background_music_player.dart';

class RouteManager {
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
}

void goToHome({BuildContext? context}) {
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
