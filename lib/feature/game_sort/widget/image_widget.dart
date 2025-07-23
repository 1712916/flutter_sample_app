import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// Widget hiển thị từng ô vuông
class GridTileImage extends StatelessWidget {
  final ui.Image image;
  final int gridSize;
  final int row;
  final int col;

  const GridTileImage({
    Key? key,
    required this.image,
    required this.gridSize,
    required this.row,
    required this.col,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: ImageTilePainter(
          image: image,
          gridSize: gridSize,
          row: row,
          col: col,
        ),
        child: SizedBox.shrink(),
      ),
    );
  }
}

// CustomPainter để vẽ từng phần của ảnh
class ImageTilePainter extends CustomPainter {
  final ui.Image image;
  final int gridSize;
  final int row;
  final int col;

  ImageTilePainter({
    required this.image,
    required this.gridSize,
    required this.row,
    required this.col,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tileWidth = image.width / gridSize;
    final tileHeight = image.height / gridSize;

    final srcRect = Rect.fromLTWH(
      col * tileWidth,
      row * tileHeight,
      tileWidth,
      tileHeight,
    );

    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
