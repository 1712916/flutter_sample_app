import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_cropper/image_cropper.dart';
import 'package:meow_app/helpers/download_helper.dart';
import 'package:meow_app/resources/locale/locale_keys.dart';

class ImageUtil {
  Future<CroppedFile?> openEditImage(String url, {String? path}) async {
    //down load image => lưu lại => lấy path
    String? imageTemptPath = path ?? await DownloadHelper.downloadToInternal(url);
    if (imageTemptPath != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageTemptPath,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        compressQuality: 50,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: LocaleKeys.editImage.tr(),
            toolbarColor: Colors.greenAccent,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: LocaleKeys.editImage.tr(),
            minimumAspectRatio: 1.0,
            aspectRatioLockDimensionSwapEnabled: true,
            aspectRatioPickerButtonHidden: true,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: true,
            rectHeight: 4000,
            rectWidth: 4000,
            rectX: 0,
            rectY: 0,
            resetButtonHidden: true,
          ),
        ],
      );
      return croppedFile;
    }
    return null;
  }

  Future<imglib.Image?> getCroppedFile(String url, int heightRatio, {String? path}) async {
    final response = await openEditImage(url, path: path);
    if (response != null) {
      return roundingSizeImage(await response.readAsBytes(), heightRatio);
    }
    return null;
  }

  Future<imglib.Image> roundingSizeImage(Uint8List croppedFile, int heightRatio) async {
    return cropImage(ImageParam(croppedFile, heightRatio));
  }

  static Future<imglib.Image> cropImage(ImageParam imageParam) async {
    final int roundingSize =
        ((await decodeImageFromList(imageParam.croppedFile)).width / imageParam.heightRatio).floor() *
            imageParam.heightRatio;
    return imglib.copyCrop(imglib.decodeImage(imageParam.croppedFile)!, 0, 0, roundingSize, roundingSize);
  }
}

class ImageParam {
  final Uint8List croppedFile;
  final int heightRatio;

  ImageParam(this.croppedFile, this.heightRatio);
}
