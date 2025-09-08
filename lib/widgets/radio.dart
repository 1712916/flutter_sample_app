import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

class AppRadio extends StatelessWidget {
  const AppRadio({super.key, required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: Theme.of(context).copyWith(
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return theme.highlightColor2; // selected color
            }
            return theme.iconColor; // unselected color
          }),
        ),
      ),
      child: Radio<bool>(
        value: isSelected,
        groupValue: true,
      ),
    );
  }
}
