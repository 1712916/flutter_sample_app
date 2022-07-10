import 'package:flutter/material.dart';

class CellWidget extends StatefulWidget {
  const CellWidget({
    Key? key,
    required this.size,
    this.color,
    this.top,
    this.left,
    this.child,
  }) : super(key: key);
  final double size;
  final Color? color;
  final double? top;
  final double? left;
  final Widget? child;

  @override
  CellWidgetState createState() => CellWidgetState();
}

class CellWidgetState extends State<CellWidget> {
  double top = 0;
  double left = 0;

  @override
  void initState() {
    top = widget.top ?? 0;
    left = widget.left ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: top,
      left: left,
      duration: const Duration(milliseconds: 150),
      curve: Curves.linear,
      child: Container(
        margin: const EdgeInsets.all(1),
        height: widget.size - 2,
        width: widget.size - 2,
        color: widget.color ?? Colors.grey,
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
  }

  void moveForward() {
    left += widget.size;
    setState(() {});
  }

  void moveBack() {
    left -= widget.size;
    setState(() {});
  }

  void moveUp() {
    top -= widget.size;
    setState(() {});
  }

  void moveDown() {
    top += widget.size;
    setState(() {});
  }
}
