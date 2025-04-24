import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:meow_app/feature/game/widget/control_bar_widget.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../game_manager.dart';
import 'cell_widget.dart';
import 'directional_control_widget.dart';
import 'image_widget.dart';

class PlayArea extends StatefulWidget {
  const PlayArea({
    Key? key,
    required this.image,
    this.onComplete,
    this.gameSize = 3,
  }) : super(key: key);

  final ui.Image image;
  final VoidCallback? onComplete;
  final int gameSize;

  @override
  State<PlayArea> createState() => PlayAreaState();
}

class PlayAreaState extends State<PlayArea> {
  final ValueNotifier<double> scaleNotifier = ValueNotifier(0.7);
  final Map<int, List<List<imglib.Image>>> _imageCache = {};
  final Map<String, GlobalKey<CellWidgetState>> moveTracking = {};

  late GameEmptyBox emptyBox;
  late GameMatrix gameMatrix;
  late List<List<GlobalKey<CellWidgetState>>> cellMatrix;

  bool isScrambling = false;

  int get gameSize => widget.gameSize;
  double get zoomLevel => scaleNotifier.value;

  int _countMoveStep = 0;

  int get countMoveStep => _countMoveStep;

  void incrementStep() {
    _countMoveStep++;
  }

  void resetStep() {
    _countMoveStep = 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _imageCache.clear();
    scaleNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image || oldWidget.gameSize != widget.gameSize) {
      _initializeGame();
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _initializeGame() {
    _setupMatrixKeys();
    _setupGame();
  }

  void _setupMatrixKeys() {
    cellMatrix = List.generate(gameSize, (i) {
      return List.generate(gameSize, (j) => GlobalKey<CellWidgetState>());
    });
  }

  void _setupGame() async {
    final game = Game(size: gameSize)..initializeGame();
    gameMatrix = game.gameMatrix;
    emptyBox = game.emptyBox;
    resetStep();
  }

  void _validateGame() {
    for (final row in gameMatrix) {
      for (final cell in row) {
        if (!cell.validate()) return;
      }
    }
    widget.onComplete?.call();
  }

  void setZoom(double value) {
    scaleNotifier.value = value;
  }

  void reScramble() {
    if (isScrambling) return;
    isScrambling = true;
    debugLog('Resetting game...');
    _setupGame();
    debugLog('EmptyBox position after scramble: ${emptyBox.getKey()}');
    isScrambling = false;
    setState(() {});
  }

  void _move(Direction direction) {
    String? key;
    VoidCallback? moveCell;

    switch (direction) {
      case Direction.left:
        key = emptyBox.getRightKey();
        moveCell = () => emptyBox.moveRight();
        break;
      case Direction.right:
        key = emptyBox.getLeftKey();
        moveCell = () => emptyBox.moveLeft();
        break;
      case Direction.up:
        key = emptyBox.getDownKey();
        moveCell = () => emptyBox.moveDown();
        break;
      case Direction.down:
        key = emptyBox.getUpKey();
        moveCell = () => emptyBox.moveUp();
        break;
    }

    final cellKey = moveTracking[key];
    if (cellKey?.currentState == null) {
      debugLog('No cell to move in direction $direction from ${emptyBox.getKey()}');
      return;
    }

    debugLog('Moving $direction | EmptyBox: ${emptyBox.getKey()} → $key');

    switch (direction) {
      case Direction.left:
        cellKey!.currentState!.moveBack();
        break;
      case Direction.right:
        cellKey!.currentState!.moveForward();
        break;
      case Direction.up:
        cellKey!.currentState!.moveUp();
        break;
      case Direction.down:
        cellKey!.currentState!.moveDown();
        break;
    }

    moveTracking[emptyBox.getKey()] = cellKey!;
    moveCell();
    incrementStep();

    debugLog('Move #$countMoveStep | New EmptyBox Position: ${emptyBox.getKey()}');

    if (direction == Direction.down && emptyBox.getKey() == '0_-1') {
      debugLog('Triggering validation after downward move.');
      _validateGame();
    }
  }

  List<Widget> _buildCells(double s) {
    final cellSize = (s / gameSize).floor();

    final List<Widget> widgets = [];
    for (int i = 0; i < gameMatrix.length; i++) {
      for (int j = 0; j < gameMatrix[i].length; j++) {
        final cell = gameMatrix[i][j];
        final cellKey = cellMatrix[i][j];
        widgets.add(
          CellWidget(
            key: cellKey,
            size: cellSize.toDouble(),
            jumpSize: cellSize.toDouble(),
            destination: cell,
            child: GridTileImage(
              image: widget.image,
              gridSize: gameSize,
              col: cell.x,
              row: cell.y,
            ),
          ),
        );
        moveTracking[cell.getKey()] = cellKey;
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return ControlBarWrapper(
      onDirectionTap: (value) {
        _move(value);
      },
      child: ValueListenableBuilder<double>(
        valueListenable: scaleNotifier,
        builder: (context, scale, _) {
          return DirectionalControlWidget(
            moveLeft: () => _move(Direction.left),
            moveRight: () => _move(Direction.right),
            moveUp: () => _move(Direction.up),
            moveDown: () => _move(Direction.down),
            child: Center(
              child: Transform.scale(
                scale: scale,
                child: CustomPaint(
                  foregroundPainter: _BoarderPainter(
                    x: gameSize,
                    y: gameSize,
                    color: Theme.of(context).highlightColor2,
                  ),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: _buildCells(constraints.maxWidth),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum Direction { left, right, up, down }

class _BoarderPainter extends CustomPainter {
  final int y;
  final int x;
  final Color? color;

  _BoarderPainter({required this.y, required this.x, this.color});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color ?? Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();
    path.moveTo(0, -size.height / y);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    path.lineTo(size.width / x, 0);
    path.lineTo(size.width / x, -size.height / y);
    path.lineTo(-1, -size.height / y);
    canvas.drawPath(path, paint);
  }
}

void debugLog(String message) {
  if (kDebugMode) {
    debugPrint('[DEBUG] $message');
  }
}
