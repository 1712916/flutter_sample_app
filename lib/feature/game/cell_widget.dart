import 'package:flutter/material.dart';

import 'game_manager.dart';

class CellWidget extends StatefulWidget {
  const CellWidget({
    Key? key,
    required this.size,
    required this.jumpSize,
    this.color,
    this.child,
    required this.destination,
  }) : super(key: key);
  final double size;
  final double jumpSize;
  final Color? color;
  final Widget? child;
  final GameMatrixItem destination;

  @override
  CellWidgetState createState() => CellWidgetState();
}

class CellWidgetState extends State<CellWidget> {
  @override
  void initState() {
    super.initState();
  }

  bool isGetDestination() {
    return true;
    // return top == widget.destination.y && left == widget.destination.x;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: widget.destination.sy * widget.jumpSize,
      left: widget.destination.sx * widget.jumpSize,
      height: widget.size,
      width: widget.size,
      duration: const Duration(milliseconds: 150),
      curve: Curves.linear,
      child: Container(
        padding: const EdgeInsets.all(0.5),
        color: widget.color ?? Colors.transparent,
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }

  void moveForward() {
    widget.destination.sx += 1;
    setState(() {});
  }

  void moveBack() {
    widget.destination.sx -= 1;
    setState(() {});
  }

  void moveUp() {
    widget.destination.sy -= 1;
    setState(() {});
  }

  void moveDown() {
    widget.destination.sy += 1;
    setState(() {});
  }
}
