import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../core/util/storage.dart';
import '../../resources/locale/locale_keys.dart';

class ShowcaseUtil {
  static final SimpleStorage _simpleStorage = SimpleStorage();

  static const String showCaseKey = 'showCase';

  static final List<ShowcaseInfo> _steps = [
    ShowcaseInfo(
      title: LKey.switchViewTitle.tr(),
      description: LKey.switchViewDescription.tr(),
      key: GlobalKey(),
    ),
    ShowcaseInfo(
      title: LKey.gridViewTitle.tr(),
      description: LKey.gridViewDescription.tr(),
      key: GlobalKey(),
    ),
    ShowcaseInfo(
      title: LKey.shareViewTitle.tr(),
      description: LKey.shareViewDescription.tr(),
      key: GlobalKey(),
    ),
    ShowcaseInfo(
      title: LKey.gameBoardTitle.tr(),
      description: LKey.gameBoardDescription.tr(),
      key: GlobalKey(),
    ),
  ];

  static int get lastStepIndex => _steps.length - 1;

  static ShowcaseInfo get switchViewKey => _steps[0];

  static ShowcaseInfo get gridViewKey => _steps[1];

  static ShowcaseInfo get shareViewKey => _steps[2];

  static ShowcaseInfo get gameBoardKey => _steps[3];

  static bool _isShowed = false;

  static bool get enableShowcase => !_isShowed;

  static void startShowcase(BuildContext context) {
    if (_isShowed) {
      return;
    }

    ShowCaseWidget.of(context).startShowCase(_steps.map((e) => e.key).toList());
    _isShowed = true;

    _simpleStorage.saveBool(showCaseKey, _isShowed);
  }

  static Future init() async {
    final rs = await _simpleStorage.getBool(showCaseKey);

    _isShowed = rs ?? false;
  }

  static Future reset() async {
    _isShowed = false;
    await _simpleStorage.saveBool(showCaseKey, false);
  }
}

class ShowcaseInfo {
  final String title;
  final String description;
  final GlobalKey key;

  ShowcaseInfo({
    required this.title,
    required this.description,
    required this.key,
  });
}
