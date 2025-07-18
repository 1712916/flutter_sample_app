import 'package:flutter/material.dart';

class ZoomWidget extends StatefulWidget {
  const ZoomWidget({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _ZoomWidgetState createState() => _ZoomWidgetState();
}

class _ZoomWidgetState extends State<ZoomWidget> {
  Matrix4 _matrix = Matrix4.identity();
  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _offset = Offset.zero;

  //get width
  double get _width => MediaQuery.of(context).size.width;
  double get _height => MediaQuery.of(context).size.height;

  void _handleScaleStart(ScaleStartDetails details) {}

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Handle two-finger zoom and rotation
      if (details.scale != 1.0) {
        _scale = (_scale * details.scale).clamp(0.6, 3.0);
      }
      if (details.rotation != 0.0) {
        _rotation = details.rotation;
      }

      //update offset based on the scale and rotation
      _offset += details.focalPointDelta;

      _matrix = Matrix4.identity()
        ..scale(_scale)
        ..rotateZ(_rotation);
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _matrix = Matrix4.identity();
      _scale = 1.0;
      _rotation = 0; // Reset to 0 radians
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 100),
            left: _offset.dx,
            top: _offset.dy + _height / 2 - _width / 2,
            child: SizedBox(
              width: _width,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                onScaleEnd: _handleScaleEnd,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  transform: _matrix,
                  curve: Curves.linear,
                  transformAlignment: Alignment.center,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
