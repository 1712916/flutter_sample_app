import 'package:flutter/material.dart';

class BlinkingMarker extends StatefulWidget {
  final double size; // Size of the outer square
  final Color cornerColor; // Color of the "L" shapes
  final Duration blinkDuration; // Duration for the blinking animation
  final double cornerSize; // Size of each "L" shape arm
  final EdgeInsetsGeometry? padding;

  const BlinkingMarker({
    Key? key,
    this.size = 80.0,
    this.cornerColor = Colors.red,
    this.blinkDuration = const Duration(milliseconds: 500),
    this.cornerSize = 10.0,
    this.padding,
  }) : super(key: key);

  @override
  _BlinkingMarkerState createState() => _BlinkingMarkerState();
}

class _BlinkingMarkerState extends State<BlinkingMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.blinkDuration,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      padding: widget.padding ?? EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top-left "L" (0 degrees)
          Positioned(
            left: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: CustomPaint(
                      size: Size(widget.cornerSize * 1.5, widget.cornerSize * 1.5),
                      painter: LPainter(widget.cornerColor),
                    ),
                  ),
                );
              },
            ),
          ),
          // Top-right "L" (90 degrees)
          Positioned(
            right: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: CustomPaint(
                      size: Size(widget.cornerSize * 1.5, widget.cornerSize * 1.5),
                      painter: LPainter(widget.cornerColor),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom-left "L" (270 degrees)
          Positioned(
            left: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: CustomPaint(
                    size: Size(widget.cornerSize * 1.5, widget.cornerSize * 1.5),
                    painter: LPainter(widget.cornerColor),
                  ),
                );
              },
            ),
          ),
          // Bottom-right "L" (180 degrees)
          Positioned(
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: CustomPaint(
                      size: Size(widget.cornerSize * 1.5, widget.cornerSize * 1.5),
                      painter: LPainter(widget.cornerColor),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LPainter extends CustomPainter {
  final Color color;

  LPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final double thickness = size.width / 5; // Thickness of the "L" arms
    final double armLength = size.width; // Length of the "L" arms

    // Draw the vertical part of the "L"
    path.moveTo(0, 0);
    path.lineTo(thickness, 0);
    path.lineTo(thickness, armLength);
    path.lineTo(0, armLength);
    path.close();

    // Draw the horizontal part of the "L"
    path.moveTo(thickness, armLength - thickness);
    path.lineTo(armLength, armLength - thickness);
    path.lineTo(armLength, armLength);
    path.lineTo(thickness, armLength);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
