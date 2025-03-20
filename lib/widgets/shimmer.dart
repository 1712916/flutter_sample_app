import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.cardColor2,
      highlightColor: theme.splashColor,
      child: Container(
        color: theme.cardColor2,
      ),
    );
  }
}
