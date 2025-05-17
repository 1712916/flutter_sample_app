import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as imglib;
import 'package:meow_app/core/index.dart';

class ImageUtil {
  Future<imglib.Image> roundingSizeImage(Uint8List croppedFile, int heightRatio) async {
    return cropImage(ImageParam(croppedFile, heightRatio));
  }

  static Future<imglib.Image> cropImage(ImageParam imageParam) async {
    final int roundingSize =
        ((await decodeImageFromList(imageParam.croppedFile)).width / imageParam.heightRatio).floor() *
            imageParam.heightRatio;
    return imglib.copyCrop(
      imglib.decodeImage(imageParam.croppedFile)!,
      x: 0,
      y: 0,
      width: roundingSize,
      height: roundingSize,
    );
  }

  static Future<Size> getImageSize(String path) async {
    File file;
    if (path.isUrl) {
      file = await DefaultCacheManager().getSingleFile(path);
    } else {
      file = File(path); // Or any other way to get a File instance.
    }
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());

    return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
  }
}

class ImageParam {
  final Uint8List croppedFile;
  final int heightRatio;

  ImageParam(this.croppedFile, this.heightRatio);
}
