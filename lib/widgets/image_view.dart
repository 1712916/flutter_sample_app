import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.memCacheHeight,
    this.memCacheWidth,
    required this.image,
  });

  final int? memCacheHeight;
  final int? memCacheWidth;
  final String image;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CachedNetworkImage(
      memCacheHeight: memCacheHeight,
      memCacheWidth: memCacheWidth,
      imageUrl: image,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return Container(
          color: theme.cardColor2,
        );
      },
    );
  }
}
