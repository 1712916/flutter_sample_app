import 'package:flutter/material.dart';

class DirectionalControlWidget extends StatelessWidget {
  const DirectionalControlWidget({
    Key? key,
    this.moveLeft,
    this.moveRight,
    this.moveUp,
    this.moveDown,
    required this.child,
  }) : super(key: key);

  final Function? moveLeft;
  final Function? moveRight;
  final Function? moveUp;
  final Function? moveDown;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails drag) {
        double value = drag.primaryVelocity ?? 0.0;
        if (value < 0) {
          moveLeft?.call();
        } else if (value > 0) {
          moveRight?.call();
        } else {}
      },
      onVerticalDragEnd: (DragEndDetails drag) {
        double value = drag.primaryVelocity ?? 0.0;
        if (value < 0) {
          moveUp?.call();
        } else if (value > 0) {
          moveDown?.call();
        } else {}
      },
      child: ColoredBox(color: Colors.transparent, child: child),
    );
  }
}
