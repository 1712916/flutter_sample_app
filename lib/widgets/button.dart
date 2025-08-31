import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    this.backgroundColor,
    this.iconColor,
    required this.icon,
    this.onPressed,
  });
  final Color? backgroundColor;
  final Color? iconColor;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      backgroundColor: backgroundColor ?? theme.actionBackground,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? Colors.white,
        ),
      ),
    );
  }
}
