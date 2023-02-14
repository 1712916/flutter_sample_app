import 'dart:math';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

import 'cell_widget.dart';

void printMatrix(List<List<dynamic>> matrix) {
  for (int i = 0; i < matrix.length; i++) {
    String row = '';
    for (int j = 0; j < matrix[i].length; j++) {
      row += '${matrix[i][j].toString()} - ';
    }
    print(row);
  }
}

const int _numberOfStep = 100;

class GameManager {
  static double cellSize = 50;
  static int widthRatio = 3;
  static int heightRatio = 3;
  static double ratio = widthRatio / heightRatio;

  static double gameBoardHeight = (heightRatio + 1) * cellSize;
  static double gameBoardWidth = widthRatio * cellSize;

  static const String __emptyCellIndex = '0_0';

  String _emptyCellIndex = __emptyCellIndex;

  late List<Widget> _cells;

  List<Widget> get cells => _cells;

  List<List<GlobalKey<CellWidgetState>>> matrixCellState = [];

  void controller(MoveType moveType) {
    List<int> wh = _emptyCellIndex.split('_').map((e) => int.parse(e)).toList();
    int x = wh.first;
    int y = wh.last;

    switch (moveType) {
      case MoveType.left:
        if (x == 0 && y == 0) {
          break;
        }

        if (y + 1 < widthRatio) {
          matrixCellState[x][y] = matrixCellState[x][y + 1];
          _emptyCellIndex = '${x}_${y + 1}';
          matrixCellState[x][y].currentState?.moveBack();
        }

        break;
      case MoveType.right:
        if (y - 1 >= 0) {
          matrixCellState[x][y] = matrixCellState[x][y - 1];
          _emptyCellIndex = '${x}_${y - 1}';
          matrixCellState[x][y].currentState?.moveForward();
        }

        break;
      case MoveType.up:
        if (x + 1 <= heightRatio || _emptyCellIndex == __emptyCellIndex) {
          matrixCellState[x][y] = matrixCellState[x + 1][y];
          _emptyCellIndex = '${x + 1}_${y}';
          matrixCellState[x][y].currentState?.moveUp();
        }

        break;
      case MoveType.down:
        if (x - 1 >= 0 || _emptyCellIndex == '-1_0') {
          matrixCellState[x][y] = matrixCellState[x - 1][y];
          _emptyCellIndex = '${x - 1}_${y}';
          matrixCellState[x][y].currentState?.moveDown();
        }
        break;
    }
  }

  List<Widget> _genCellWidgets(imglib.Image image) {
    //thêm khoảng trống
    //Khoảng trống này luôn giữ mãnh bên góc bên trái
    matrixCellState.add([GlobalKey()]);

    final List<List<GameMatrix>> boardGameMatrix = [];

    boardGameMatrix.add([const GameMatrix(x: 0, y: 0)]);
    boardGameMatrix.addAll(scramble());

    final int imageCellWidth = (image.width / GameManager.widthRatio).floor();
    final int imageCellHeight = (image.height / GameManager.heightRatio).floor();

    List<Widget> widgets = [];

    for (int y = 0; y < GameManager.heightRatio; y++) {
      List<GlobalKey<CellWidgetState>> gameStatusRow = [];
      for (int x = 0; x < GameManager.widthRatio; x++) {
        gameStatusRow.add(GlobalKey());
        final cellPosition = boardGameMatrix[y + 1][x];
        widgets.add(
          CellWidget(
            destination: cellPosition,
            size: GameManager.cellSize,
            jumpSize: GameManager.cellSize,
            top: y + 1,
            left: x,
            key: gameStatusRow.last,
            child: _RenderImage(
              cellPosition: cellPosition,
              imageCellWidth: imageCellWidth,
              imageCellHeight: imageCellHeight,
              image: image,
            ),
          ),
        );
      }
      matrixCellState.add(gameStatusRow);
    }
    return widgets;
  }

  void init(imglib.Image image) {
    _cells = _genCellWidgets(image);
  }

  List<List<GameMatrix>> scramble() {
    List<List<GameMatrix>> tempt = _genCell();

    List<MoveType> moveTypes = _genMoveList();

    GameMatrix emptyBox = EmptyBox(y: 0, x: 0);

    for (var moveType in moveTypes) {
      int x = emptyBox.x;
      int y = emptyBox.y;

      switch (moveType) {
        case MoveType.left:
          if (x + 1 < widthRatio) {
            tempt[y][x] = tempt[y][x + 1];
            emptyBox = EmptyBox(x: x + 1, y: y);
            tempt[y][x + 1] = emptyBox;
          }

          break;
        case MoveType.right:
          if (x - 1 >= 0) {
            tempt[y][x] = tempt[y][x - 1];
            emptyBox = EmptyBox(x: x - 1, y: y);
            tempt[y][x - 1] = emptyBox;
          }

          break;
        case MoveType.up:
          if (y + 1 < heightRatio) {
            tempt[y][x] = tempt[y + 1][x];
            emptyBox = EmptyBox(x: x, y: y + 1);
            tempt[y + 1][x] = emptyBox;
          }

          break;
        case MoveType.down:
          if (y - 1 >= 0) {
            tempt[y][x] = tempt[y - 1][x];
            emptyBox = EmptyBox(x: x, y: y - 1);
            tempt[y - 1][x] = emptyBox;
          }
          break;
      }
    }

    //chuyển cái ô empty box về vị trí [0,0]

    while (!(emptyBox.y == 0 && emptyBox.x == 0)) {
      int x = emptyBox.x;
      int y = emptyBox.y;

      if (x > 0) {
        tempt[y][x] = tempt[y][x - 1];
        emptyBox = EmptyBox(x: x - 1, y: y);
        tempt[y][x - 1] = emptyBox;
      } else if (y > 0) {
        tempt[y][x] = tempt[y - 1][x];
        emptyBox = EmptyBox(x: x, y: y - 1);
        tempt[y - 1][x] = emptyBox;
      }
    }

    return tempt;
  }

  List<List<GameMatrix>> _genCell() {
    List<List<GameMatrix>> tempt = [];
    for (int i = 0; i < heightRatio; i++) {
      final List<GameMatrix> row = [];
      for (int j = 0; j < widthRatio; j++) {
        row.add(GameMatrix(x: j, y: i));
      }
      tempt.add(row);
    }
    return tempt;
  }

  MoveType _nextMoveRandom({MoveType? preMoveType, Random? random}) {
    Random internalRandom = random ?? Random();

    if (preMoveType == null) {
      return [MoveType.left, MoveType.up][internalRandom.nextInt(2)];
    }

    MoveType oppositePreMoveType = _getOppositeMoveType(preMoveType);

    final List<MoveType> moveTypes = [...MoveType.values]..remove(oppositePreMoveType);
    return moveTypes[internalRandom.nextInt(3)];
  }

  MoveType _getOppositeMoveType(MoveType moveType) {
    switch (moveType) {
      case MoveType.left:
        return MoveType.right;
      case MoveType.right:
        return MoveType.left;
      case MoveType.up:
        return MoveType.down;
      default:
        return MoveType.down;
    }
  }

  List<MoveType> _genMoveList() {
    List<MoveType> moveTypes = [];

    Random random = Random();
    MoveType? preMoveType;

    for (int i = 0; i < _numberOfStep; i++) {
      moveTypes.add(_nextMoveRandom(preMoveType: preMoveType, random: random));
      preMoveType = moveTypes.last;
    }

    return moveTypes;
  }

  Future<bool> checkDone() async {
    for (List<GlobalKey<CellWidgetState>> row in matrixCellState) {
      for (GlobalKey<CellWidgetState> cell in row) {
        if (!(cell.currentState?.isGetDestination() ?? true)) {
          return false;
        }
      }
    }
    return true;
  }
}

class GameMatrix extends Equatable {
  //**        x ---->
  //**      y
  //**      |
  //**      v

  final int x;
  final int y;

  const GameMatrix({required this.y, required this.x});

  @override
  String toString() {
    return '($y,$x)';
  }

  @override
  List<Object?> get props => [
        x,
        y,
      ];
}

class EmptyBox extends GameMatrix {
  const EmptyBox({required int y, required int x}) : super(y: y, x: x);
}

enum MoveType { left, right, up, down }

class _RenderImage extends StatefulWidget {
  const _RenderImage({
    Key? key,
    required this.cellPosition,
    required this.image,
    required this.imageCellHeight,
    required this.imageCellWidth,
  }) : super(key: key);

  final GameMatrix cellPosition;
  final imglib.Image image;
  final int imageCellHeight;
  final int imageCellWidth;

  @override
  State<_RenderImage> createState() => _RenderImageState();
}

class _RenderImageState extends State<_RenderImage> {
  imglib.Image? thumbnail;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final image = widget.image;
    final cellPosition = widget.cellPosition;
    thumbnail = imglib.copyCrop(
      image,
      cellPosition.x * widget.imageCellWidth,
      cellPosition.y * widget.imageCellHeight,
      widget.imageCellWidth,
      widget.imageCellHeight,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (thumbnail == null) {
      return const SizedBox();
    }
    return Image.memory(
      imglib.encodePng(thumbnail!) as Uint8List,
      fit: BoxFit.cover,
    );
  }
}
