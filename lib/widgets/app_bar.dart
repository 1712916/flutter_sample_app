import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final VoidCallback? onBack;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.showBackButton = true,
    this.bottom,
    this.leading,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: titleWidget ?? Text(title),
      backgroundColor: Colors.transparent,
      leading: leading ?? AppBackButton(onBack: onBack),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) {
      return const SizedBox();
    }

    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: theme.iconColor,
      ),
      onPressed: onBack ??
          () {
            Navigator.of(context).pop();
          },
    );
  }
}

class CircleAppBackButton extends StatelessWidget {
  const CircleAppBackButton({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return CircleAvatar(
      backgroundColor: theme.actionBackground,
      radius: 18,
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
