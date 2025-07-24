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
      ..strokeWidth = 2.0  // Made slimmer (was 4.0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Convert grid coordinates to screen coordinates
    final actualCellHeight = cellHeight > 0 ? cellHeight : cellWidth;
    List<Offset> screenPoints = [];
    
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      double x, y;
      
      // For start and end points, position at cell edges
      if (i == 0 || i == points.length - 1) {
        // Determine edge position based on direction to next/previous point
        Offset? direction;
        if (i == 0 && points.length > 1) {
          // Start point - look at direction to next point
          direction = points[1] - points[0];
        } else if (i == points.length - 1 && points.length > 1) {
          // End point - look at direction from previous point
          direction = points[i] - points[i - 1];
        }
        
        if (direction != null) {
          // Calculate cell center first
          double centerX = (point.dx + 0.5) * cellWidth;
          double centerY = (point.dy + 0.5) * actualCellHeight;
          
          // For start point: position at edge in direction of movement
          // For end point: position at edge where line arrives (opposite of direction)
          bool isEndPoint = (i == points.length - 1);
          
          // Adjust to edge based on direction
          if (direction.dx > 0) {
            // Moving right
            x = isEndPoint 
              ? centerX - cellWidth * 0.4  // End: arrive at left edge
              : centerX + cellWidth * 0.4; // Start: depart from right edge
          } else if (direction.dx < 0) {
            // Moving left
            x = isEndPoint 
              ? centerX + cellWidth * 0.4  // End: arrive at right edge
              : centerX - cellWidth * 0.4; // Start: depart from left edge
          } else {
            x = centerX;
          }
          
          if (direction.dy > 0) {
            // Moving down
            y = isEndPoint 
              ? centerY - actualCellHeight * 0.4  // End: arrive at top edge
              : centerY + actualCellHeight * 0.4; // Start: depart from bottom edge
          } else if (direction.dy < 0) {
            // Moving up
            y = isEndPoint 
              ? centerY + actualCellHeight * 0.4  // End: arrive at bottom edge
              : centerY - actualCellHeight * 0.4; // Start: depart from top edge
          } else {
            y = centerY;
          }
        } else {
          // Fallback to center if no direction found
          x = (point.dx + 0.5) * cellWidth;
          y = (point.dy + 0.5) * actualCellHeight;
        }
      } else {
        // Middle points - use existing logic for borders and centers
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
      }
      
      screenPoints.add(Offset(x, y));
    }

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
      
      // Draw connection points (start and end) - smaller dots
      if (animationProgress > 0.1) {
        Paint pointPaint = Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(screenPoints.first, 4.0, pointPaint); // Smaller radius (was 6.0)
        
        if (animationProgress > 0.9) {
          canvas.drawCircle(screenPoints.last, 4.0, pointPaint); // Smaller radius (was 6.0)
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
