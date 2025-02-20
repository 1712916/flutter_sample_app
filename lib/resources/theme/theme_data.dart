import 'package:flutter/material.dart';

import 'app_colors.dart';

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

    return appColors.iconColor;
  }

  Color get imagePlaceholderColor {
    AppColors appColors = AppColors.getColor(ThemeResource._getColorStyle(ThemeMode.light));

    return Color(0xFFF1F1F1);
  }

  Color get actionBackground {
    AppColors appColors = AppColors.getColor(ThemeResource._getColorStyle(ThemeMode.light));

    return Color(0x998C8686);
  }

  Color get cardColor2 {
    AppColors appColors = AppColors.getColor(ThemeResource._getColorStyle(ThemeMode.light));

    return Color(0xFF423f3d);
  }

  Color get textColor2 {
    return Color(0xFFefefef);
  }
}
