import 'dart:async';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';

import 'feature/game/widget/image_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageCropAndGridPage(
        imageProvider: NetworkImage('https://cdn2.thecatapi.com/images/21e.jpg'), // Hoặc FileImage(File(path))
      ),
    );
  }
}

class ImageCropAndGridPage extends StatefulWidget {
  final ImageProvider imageProvider;

  const ImageCropAndGridPage({Key? key, required this.imageProvider}) : super(key: key);

  @override
  _ImageCropAndGridPageState createState() => _ImageCropAndGridPageState();
}

class _ImageCropAndGridPageState extends State<ImageCropAndGridPage> {
  final CropController _cropController = CropController(aspectRatio: 1.0); // Hình vuông
  bool _isLoading = false;
  ui.Image? _croppedImage;
  int _gridSize = 3; // Số ô vuông mỗi chiều (3x3 grid)

  // Xử lý cắt ảnh và chuyển sang hiển thị lưới
  Future<void> _cropAndShowGrid() async {
    setState(() => _isLoading = true);
    try {
      // Cắt ảnh
      final croppedImage = await _cropController.croppedBitmap();

      // Resize ảnh để tối ưu (nếu cần)
      final resizedImage = await _resizeImage(croppedImage, maxSize: 1800);

      setState(() {
        _croppedImage = resizedImage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cropping image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Hàm resize ui.Image
  Future<ui.Image> _resizeImage(ui.Image image, {required int maxSize}) async {
    if (image.width <= maxSize && image.height <= maxSize) {
      return image;
    }

    final aspectRatio = image.width / image.height;
    int newWidth, newHeight;
    if (aspectRatio > 1) {
      newWidth = maxSize;
      newHeight = (maxSize / aspectRatio).round();
    } else {
      newHeight = maxSize;
      newWidth = (maxSize * aspectRatio).round();
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..filterQuality = FilterQuality.medium;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
      paint,
    );

    final picture = recorder.endRecording();
    return await picture.toImage(newWidth, newHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop and Grid Image')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _croppedImage == null
              ? Column(
                  children: [
                    Expanded(
                      child: CropImage(
                        controller: _cropController,
                        image: Image(
                          image: widget.imageProvider,
                          fit: BoxFit.contain,
                        ),
                        gridColor: Colors.white,
                        gridCornerSize: 20,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _cropAndShowGrid,
                      child: const Text('Crop Image'),
                    ),
                  ],
                )
              : Column(
                  children: [
                    RawImage(
                      image: _croppedImage,
                      width: double.infinity,
                    ),
                    Expanded(
                      child: GridImageView(
                        image: _croppedImage!,
                        gridSize: _gridSize,
                      ),
                    ),
                  ],
                ),
    );
  }
}

// Widget hiển thị lưới các ô vuông
class GridImageView extends StatelessWidget {
  final ui.Image image;
  final int gridSize;

  const GridImageView({Key? key, required this.image, required this.gridSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        final row = index ~/ gridSize;
        final col = index % gridSize;
        return GridTileImage(
          image: image,
          gridSize: gridSize,
          row: row,
          col: col,
        );
      },
    );
  }
}
