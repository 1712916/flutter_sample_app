import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import 'showcase_util.dart';

class AppShowcase extends StatelessWidget {
  const AppShowcase({super.key, required this.info, required this.child});

  final ShowcaseInfo info;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.black87;
    return Showcase(
      key: info.key,
      title: info.title,
      description: info.description,
      titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor),
      descTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
      tooltipBorderRadius: BorderRadius.circular(20),
      tooltipPadding: const EdgeInsets.all(16),
      descriptionAlignment: Alignment.center,
      child: child,
    );
  }
}
