import 'package:flutter/material.dart';

enum ColorStyle {
  light,
  dark,
}

class AppColors {
  AppColors();

  factory AppColors.getColor(ColorStyle colorStyle) {
    switch (colorStyle) {
      case ColorStyle.light:
        return LightColors();
      case ColorStyle.dark:
        return DarkColors();
      default:
        return LightColors();
    }
  }

  static ColorStyle getColorStyle(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return ColorStyle.dark;
      default:
        return ColorStyle.light;
    }
  }

  external Color get primaryColor;

  external Color get backgroundColor;

  external Color get canvasColor;

  external Color get cardColor;

  external Color get hintColor;

  external Color get errorColor;

  external Color get focusColor;

  external Color get disabledColor;

  external Color get dividerColor;

  external Color get shadowColor;
}

class LightColors extends AppColors {
  @override
  Color get primaryColor => const Color(0xFFE3FDFD);

  @override
  Color get backgroundColor => const Color(0xFFE3FDFD);

  @override
  Color get canvasColor => const Color(0xFFE3FDFD);

  @override
  Color get cardColor => const Color(0xFFE3FDFD);

  @override
  Color get hintColor => const Color(0xFFE3FDFD);

  @override
  Color get errorColor => const Color(0xFFE3FDFD);

  @override
  Color get focusColor => const Color(0xFFE3FDFD);

  @override
  Color get disabledColor => const Color(0xFFE3FDFD);

  @override
  Color get dividerColor => const Color(0xFFE3FDFD);

  @override
  Color get shadowColor => const Color(0xFFE3FDFD);
}

class DarkColors extends AppColors {
  @override
  Color get primaryColor => const Color(0xFF222831);

  @override
  Color get backgroundColor => const Color(0xFFE3FDFD);

  @override
  Color get canvasColor => const Color(0xFFE3FDFD);

  @override
  Color get cardColor => const Color(0xFFE3FDFD);

  @override
  Color get hintColor => const Color(0xFFE3FDFD);

  @override
  Color get errorColor => const Color(0xFFE3FDFD);

  @override
  Color get focusColor => const Color(0xFFE3FDFD);

  @override
  Color get disabledColor => const Color(0xFFE3FDFD);

  @override
  Color get dividerColor => const Color(0xFFE3FDFD);

  @override
  Color get shadowColor => const Color(0xFFE3FDFD);
}
