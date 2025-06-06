import 'dart:developer';
import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/core/index.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../../../widgets/widgets.dart';
import '../../../routers/route.dart';
import '../../image/image_list_page.dart';

final GlobalKey goToGameKey = GlobalKey();

class CropImageView extends StatefulWidget {
  const CropImageView({super.key, required this.url});

  final String url;

  @override
  State<CropImageView> createState() => _CropImageViewState();
}

class _CropImageViewState extends State<CropImageView> {
  final controller = CropController(
    aspectRatio: 1,
    // defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.iconColor;

    return Scaffold(
      appBar: CustomAppBar(title: LKey.cropImage.tr(context: context)),
      backgroundColor: theme.scaffoldBackgroundColor2,
      body: Stack(
        children: [
          Center(
            child: Builder(builder: (context) {
              if (widget.url.isUrl) {
                return FutureBuilder(
                  future: DefaultCacheManager().getSingleFile(widget.url),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CropImage(
                        controller: controller,
                        image: Image.file(snapshot.data as File),
                      );
                    }

                    if (snapshot.hasError) {
                      return CropImage(
                        controller: controller,
                        image: Image.network(widget.url),
                      );
                    }

                    return const SizedBox();
                  },
                );
              }

              return CropImage(
                controller: controller,
                image: Image.file(File(widget.url)),
              );
            }),
          ),
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: TakeImageButton(
              key: goToGameKey,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedImageCrop,
                color: theme.iconColor,
                size: 32.0,
              ),
              onTapAction: () async {
                try {
                  final croppedImage = (await controller.croppedBitmap());
                  goToSortGamePage(croppedImage);
                } catch (e, st) {
                  log('Error cropping image: $e', stackTrace: st);
                  Toast.makeText(
                    context: context,
                    message: LKey.haveAnErrorDetail.tr(),
                    toastLength: Toast.LENGTH_LONG,
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
