import 'package:flutter/material.dart';
import 'package:meow_app/views/pages/game/game_manager.dart';

class CellWidget extends StatefulWidget {
  const CellWidget({
    Key? key,
    required this.size,
    required this.jumpSize,
    this.color,
    this.top,
    this.left,
    this.child,
    required this.destination,
  }) : super(key: key);
  final double size;
  final double jumpSize;
  final Color? color;
  final int? top;
  final int? left;
  final Widget? child;
  final GameMatrix destination;

  @override
  CellWidgetState createState() => CellWidgetState();
}

class CellWidgetState extends State<CellWidget> {
  int top = 0;
  int left = 0;

  @override
  void initState() {
    top = widget.top ?? 0;
    left = widget.left ?? 0;
    super.initState();
  }

  bool isGetDestination() {
    return top - 1 == widget.destination.y && left == widget.destination.x;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: top * widget.jumpSize,
      left: left * widget.jumpSize,
      height: widget.size,
      width: widget.size,
      duration: const Duration(milliseconds: 150),
      curve: Curves.linear,
      child: Container(
        padding: const EdgeInsets.all(2),
        color: widget.color ?? Colors.transparent,
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }

  void moveForward() {
    left += 1;
    setState(() {});
  }

  void moveBack() {
    left -= 1;
    setState(() {});
  }

  void moveUp() {
    top -= 1;
    setState(() {});
  }

  void moveDown() {
    top += 1;
    setState(() {});
  }
}
