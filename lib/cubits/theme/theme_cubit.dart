import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_app/resources/theme/app_colors.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void setUp() {
    //todo: read from shareRef
  }

  void switchMode(ThemeMode themeMode) {
    emit(themeMode);
  }

  AppColors get getColors => AppColors.getColor(AppColors.getColorStyle(state));
}