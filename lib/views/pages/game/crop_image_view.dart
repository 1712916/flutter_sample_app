import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/utils/utils.dart';

import '../../../resources/locale/locale_keys.dart';
import '../../../widgets/widgets.dart';
import 'game_page_3.dart';

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
      appBar: CustomAppBar(title: ''),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(builder: (context) {
              if (widget.url.isUrl) {
                return CropImage(
                  controller: controller,
                  image: Image.network(widget.url),
                );
              }

              return CropImage(
                controller: controller,
                image: Image.file(File(widget.url)),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: _LoadingButton(
        onPressed: () async {
          try {
            final croppedImage = (await controller.croppedBitmap());
            final byteData = await croppedImage.toByteData(format: ImageByteFormat.png);
            final image = imglib.decodePng(byteData!.buffer.asUint8List());
            if (croppedImage != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return GamePage3(image: image);
                  },
                ),
              );
            }
          } catch (e) {
            Toast.makeText(
              context: context,
              message: LKey.haveAnErrorDetail.tr(),
              toastLength: Toast.LENGTH_LONG,
            );
          }
        },
      ),
    );
  }
}

class _LoadingButton extends StatefulWidget {
  const _LoadingButton({super.key, this.onPressed});

  final Future Function()? onPressed;

  @override
  State<_LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<_LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).highlightColor2,
      onPressed: () async {
        setState(() {
          _isLoading = true;
        });
        await widget.onPressed?.call();
        setState(() {
          _isLoading = false;
        });
      },
      child: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            )
          : Icon(Icons.crop),
    );
  }
}
