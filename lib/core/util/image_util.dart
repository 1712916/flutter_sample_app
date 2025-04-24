import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

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
}

class ImageParam {
  final Uint8List croppedFile;
  final int heightRatio;

  ImageParam(this.croppedFile, this.heightRatio);
}
