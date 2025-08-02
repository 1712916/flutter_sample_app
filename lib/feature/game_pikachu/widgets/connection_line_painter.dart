import 'package:flutter/material.dart';

class ConnectionLinePainter extends CustomPainter {
  final List<Offset> points;
  final double cellWidth;
  final double cellHeight;
  final double animationProgress;
  final int gridCols;
  final int gridRows;
  final Color lineColor;
  final Color pointColor;

  ConnectionLinePainter({
    required this.points,
    required this.cellWidth,
    this.cellHeight = 0.0,
    required this.animationProgress,
    this.gridCols = 16,
    this.gridRows = 9,
    this.lineColor = Colors.red,
    this.pointColor = Colors.yellow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final actualCellHeight = cellHeight > 0 ? cellHeight : cellWidth;
    List<Offset> screenPoints = [];

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      double x, y;

      if (i == 0 || i == points.length - 1) {
        Offset? direction;
        if (i == 0 && points.length > 1) {
          direction = points[1] - points[0];
        } else if (i == points.length - 1 && points.length > 1) {
          direction = points[i] - points[i - 1];
        }

        if (direction != null) {
          double centerX = (point.dx + 0.5) * cellWidth;
          double centerY = (point.dy + 0.5) * actualCellHeight;
          bool isEndPoint = (i == points.length - 1);

          if (direction.dx > 0) {
            x = isEndPoint ? centerX - cellWidth * 0.4 : centerX + cellWidth * 0.4;
          } else if (direction.dx < 0) {
            x = isEndPoint ? centerX + cellWidth * 0.4 : centerX - cellWidth * 0.4;
          } else {
            x = centerX;
          }

          if (direction.dy > 0) {
            y = isEndPoint ? centerY - actualCellHeight * 0.4 : centerY + actualCellHeight * 0.4;
          } else if (direction.dy < 0) {
            y = isEndPoint ? centerY + actualCellHeight * 0.4 : centerY - actualCellHeight * 0.4;
          } else {
            y = centerY;
          }
        } else {
          x = (point.dx + 0.5) * cellWidth;
          y = (point.dy + 0.5) * actualCellHeight;
        }
      } else {
        if (point.dx < 0) {
          x = point.dx * cellWidth;
        } else if (point.dx >= gridCols) {
          x = point.dx * cellWidth;
        } else {
          x = (point.dx + 0.5) * cellWidth;
        }

        if (point.dy < 0) {
          y = point.dy * actualCellHeight;
        } else if (point.dy >= gridRows) {
          y = point.dy * actualCellHeight;
        } else {
          y = (point.dy + 0.5) * actualCellHeight;
        }
      }

      screenPoints.add(Offset(x, y));
    }

    // Draw animated path
    Path path = Path();
    if (screenPoints.isNotEmpty) {
      path.moveTo(screenPoints[0].dx, screenPoints[0].dy);

      double totalLength = 0;
      for (int i = 1; i < screenPoints.length; i++) {
        totalLength += (screenPoints[i] - screenPoints[i - 1]).distance;
      }

      double currentLength = 0;
      double targetLength = totalLength * animationProgress;

      const double edgeThreshold = 12.0;
      const double edgeExtension = 6.0;

      for (int i = 1; i < screenPoints.length; i++) {
        double segmentLength = (screenPoints[i] - screenPoints[i - 1]).distance;

        if (currentLength + segmentLength <= targetLength) {
          Offset adjustedPoint = screenPoints[i];
          double dx = adjustedPoint.dx;
          double dy = adjustedPoint.dy;

          // Nới điểm ra nếu chạm biên dưới hoặc phải
          if (dx >= size.width - edgeThreshold) {
            dx += edgeExtension;
          }
          if (dy >= size.height - edgeThreshold) {
            dy += edgeExtension;
          }

          adjustedPoint = Offset(dx, dy);
          path.lineTo(adjustedPoint.dx, adjustedPoint.dy);
          currentLength += segmentLength;
        } else {
          double remainingLength = targetLength - currentLength;
          double ratio = remainingLength / segmentLength;

          double dx = screenPoints[i - 1].dx + (screenPoints[i].dx - screenPoints[i - 1].dx) * ratio;
          double dy = screenPoints[i - 1].dy + (screenPoints[i].dy - screenPoints[i - 1].dy) * ratio;

          // Nới điểm cuối nếu chạm biên
          if (screenPoints[i].dx >= size.width - edgeThreshold) {
            dx += edgeExtension;
          }
          if (screenPoints[i].dy >= size.height - edgeThreshold) {
            dy += edgeExtension;
          }

          path.lineTo(dx, dy);
          break;
        }
      }

      canvas.drawPath(path, paint);

      // Vẽ các điểm kết nối
      if (animationProgress > 0.1) {
        Paint pointPaint = Paint()
          ..color = pointColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(screenPoints.first, 4.0, pointPaint);

        if (animationProgress > 0.9) {
          canvas.drawCircle(screenPoints.last, 4.0, pointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(ConnectionLinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.cellWidth != cellWidth ||
        oldDelegate.cellHeight != cellHeight ||
        oldDelegate.gridCols != gridCols ||
        oldDelegate.gridRows != gridRows;
  }
}
