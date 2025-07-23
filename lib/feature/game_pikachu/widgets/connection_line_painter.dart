import 'package:flutter/material.dart';

class ConnectionLinePainter extends CustomPainter {
  final List<Offset> points;
  final double cellWidth;
  final double cellHeight;
  final double animationProgress;
  final int gridCols;
  final int gridRows;

  ConnectionLinePainter({
    required this.points,
    required this.cellWidth,
    this.cellHeight = 0.0, // Default to cellWidth if not provided
    required this.animationProgress,
    this.gridCols = 16,
    this.gridRows = 9,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Convert grid coordinates to screen coordinates
    final actualCellHeight = cellHeight > 0 ? cellHeight : cellWidth;
    List<Offset> screenPoints = points.map((point) {
      double x, y;
      
      // Convert grid coordinates to actual screen positions
      // Grid coordinates: (col, row) where col is 0-15, row is 0-8
      if (point.dx < 0) {
        // Left border - extend left of the grid
        x = point.dx * cellWidth;
      } else if (point.dx >= gridCols) {
        // Right border - extend right of the grid  
        x = point.dx * cellWidth;
      } else {
        // Normal cell - center of the cell
        x = (point.dx + 0.5) * cellWidth;
      }
      
      if (point.dy < 0) {
        // Top border - extend above the grid
        y = point.dy * actualCellHeight;
      } else if (point.dy >= gridRows) {
        // Bottom border - extend below the grid
        y = point.dy * actualCellHeight;
      } else {
        // Normal cell - center of the cell
        y = (point.dy + 0.5) * actualCellHeight;
      }
      
      return Offset(x, y);
    }).toList();

    // Draw animated line segments
    Path path = Path();
    if (screenPoints.isNotEmpty) {
      path.moveTo(screenPoints[0].dx, screenPoints[0].dy);

      // Calculate total line length
      double totalLength = 0;
      for (int i = 1; i < screenPoints.length; i++) {
        totalLength += (screenPoints[i] - screenPoints[i - 1]).distance;
      }

      // Draw line up to animation progress
      double currentLength = 0;
      double targetLength = totalLength * animationProgress;

      for (int i = 1; i < screenPoints.length; i++) {
        double segmentLength = (screenPoints[i] - screenPoints[i - 1]).distance;
        
        if (currentLength + segmentLength <= targetLength) {
          // Draw complete segment
          path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
          currentLength += segmentLength;
        } else {
          // Draw partial segment
          double remainingLength = targetLength - currentLength;
          double ratio = remainingLength / segmentLength;
          
          Offset partialEnd = Offset(
            screenPoints[i - 1].dx + (screenPoints[i].dx - screenPoints[i - 1].dx) * ratio,
            screenPoints[i - 1].dy + (screenPoints[i].dy - screenPoints[i - 1].dy) * ratio,
          );
          
          path.lineTo(partialEnd.dx, partialEnd.dy);
          break;
        }
      }

      canvas.drawPath(path, paint);
      
      // Draw connection points (start and end)
      if (animationProgress > 0.1) {
        Paint pointPaint = Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(screenPoints.first, 6.0, pointPaint);
        
        if (animationProgress > 0.9) {
          canvas.drawCircle(screenPoints.last, 6.0, pointPaint);
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
