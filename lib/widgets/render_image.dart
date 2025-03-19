import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

import '../core/index.dart';
import '../feature/game/game_manager.dart';

class RenderImage extends StatefulWidget {
  const RenderImage({
    Key? key,
    required this.cellPosition,
    required this.image,
    required this.imageCellHeight,
    required this.imageCellWidth,
  }) : super(key: key);

  final GameMatrixItem cellPosition;
  final imglib.Image image;
  final int imageCellHeight;
  final int imageCellWidth;

  @override
  State<RenderImage> createState() => _RenderImageState();
}

class _RenderImageState extends State<RenderImage> with SafeSetState {
  Uint8List? _uint8list;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final croppedImage = await compute(
      crop,
      CropModel(
        widget.image,
        widget.cellPosition.x * widget.imageCellWidth,
        widget.cellPosition.y * widget.imageCellHeight,
        widget.imageCellWidth,
        widget.imageCellHeight,
      ),
    );

    // final croppedImage = crop(CropModel(
    //   widget.image,
    //   widget.cellPosition.x * widget.imageCellWidth,
    //   widget.cellPosition.y * widget.imageCellHeight,
    //   widget.imageCellWidth,
    //   widget.imageCellHeight,
    // ));

    final encodedImage = await compute(imglib.encodePng, croppedImage);

    setState(() {
      _uint8list = Uint8List.fromList(encodedImage);
    });
  }

  @override
  void didUpdateWidget(covariant RenderImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      _uint8list = null;
      _loadImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _uint8list != null ? Image.memory(_uint8list!, fit: BoxFit.cover) : Container(color: Colors.grey.shade200);
  }
}

class RenderImage2 extends StatefulWidget {
  const RenderImage2({super.key, required this.image, required this.x, required this.y, required this.size});
  final ui.Image image;
  final double x;
  final double y;
  final double size;

  @override
  State<RenderImage2> createState() => _RenderImage2State();
}

class _RenderImage2State extends State<RenderImage2> {
  Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final croppedImage = await newCrop(
      widget.image,
      x: widget.x,
      y: widget.y,
      size: widget.size,
    );

    setState(() {
      _image = croppedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _image != null ? _image! : Container(color: Colors.grey.shade200);
  }
}

Future<Image> newCrop(
  ui.Image source, {
  required double x,
  required double y,
  required double size,
}) async {
  final controller = CropController(
    aspectRatio: 1,
  );

  controller.image = source;
  controller.crop = Rect.fromLTWH(x, y, size, size);
  return controller.croppedImage();
}
