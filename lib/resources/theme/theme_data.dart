import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/index.dart';
import 'app_colors.dart';

class ThemeUtils {
  static SimpleStorage simpleStorage = SimpleStorage();

  static ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  static void toggleThemeMode() {
    final ThemeMode themeMode = themeModeNotifier.value;
    themeModeNotifier.value = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    // Save theme mode to local storage

    simpleStorage.saveString('theme_mode', themeModeNotifier.value.toString());
  }

  static Future<void> initThemeMode() async {
    String? themeMode = await simpleStorage.getString('theme_mode');

    if (themeMode == null) {
      themeModeNotifier.value = ThemeMode.system;
    } else {
      themeModeNotifier.value = themeMode == 'ThemeMode.light' ? ThemeMode.light : ThemeMode.dark;
    }
  }

  static ThemeData get lightTheme {
    final lightTheme = ThemeData.light();
    return lightTheme.copyWith(textTheme: GoogleFonts.comfortaaTextTheme(lightTheme.textTheme));
  }

  static ThemeData get darkTheme {
    final darkTheme = ThemeData.dark();
    return darkTheme.copyWith(textTheme: GoogleFonts.comfortaaTextTheme(darkTheme.textTheme));
  }
}

extension ThemeExtension on BuildContext {
  ThemeData get appTheme {
    return Theme.of(this);
  }
}

class ThemeResource {
  static ThemeData getTheme({ThemeData? theme, required ThemeMode themeMode}) {
    ThemeData themeData = theme ?? ThemeData();
    AppColors appColors = AppColors.getColor(_getColorStyle(themeMode));
    return themeData.copyWith(
      primaryColor: appColors.primaryColor,
      textTheme: themeData.textTheme.copyWith(),
      scaffoldBackgroundColor: appColors.backgroundColor,
      canvasColor: appColors.canvasColor,
      cardColor: appColors.cardColor,
      hintColor: appColors.hintColor,
      focusColor: appColors.focusColor,
      disabledColor: appColors.disabledColor,
      dividerColor: appColors.dividerColor,
      shadowColor: appColors.shadowColor,
      colorScheme: themeData.colorScheme.copyWith(
        primary: appColors.primaryColor,
        secondary: appColors.accentColor,
        error: appColors.errorColor,
      ),
    );
  }

  static ColorStyle _getColorStyle(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return ColorStyle.dark;
      default:
        return ColorStyle.light;
    }
  }
}

extension ThemeResourceExtension on ThemeData {
  Color get iconColor {
    AppColors appColors = AppColors.getColor(ThemeResource._getColorStyle(ThemeMode.light));

    switch (brightness) {
      case Brightness.dark:
        return appColors.iconColor;
      default:
        return Color(0x99131313);
    }
  }

  Color get imagePlaceholderColor {
    return Color(0xFFF1F1F1);
  }

  Color get actionBackground {
    switch (brightness) {
      case Brightness.dark:
        return Color(0x998C8686);
      default:
        return Color(0x99F1F1F1);
    }
  }

  Color get cardColor2 {
    switch (brightness) {
      case Brightness.dark:
        return Color(0xFF423f3d);
      default:
        return Color(0xFFFFFFFF);
    }
  }

  Color get textColor2 {
    switch (brightness) {
      case Brightness.dark:
        return Color(0xFFefefef);
      default:
        return Color(0xFF454242);
    }
  }

  Color get highlightColor2 {
    return Colors.yellow;
  }

  Color get scaffoldBackgroundColor2 {
    switch (brightness) {
      case Brightness.dark:
        return scaffoldBackgroundColor;
      default:
        return Color(0xFFFFFBFB);
    }
  }
}
