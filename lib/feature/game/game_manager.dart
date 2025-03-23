import 'dart:math';

import 'package:image/image.dart';

typedef GameMatrix = List<List<GameMatrixItem>>;

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

  static double gameBoardHeight = (heightRatio) * cellSize;
  static double gameBoardWidth = widthRatio * cellSize;

  static const String __emptyCellIndex = '0_0';

  String _emptyCellIndex = __emptyCellIndex;

  late GameMatrix gameMatrix;

  void controller(MoveType moveType) {
    // List<int> wh = _emptyCellIndex.split('_').map((e) => int.parse(e)).toList();
    // int x = wh.first;
    // int y = wh.last;
    //
    // switch (moveType) {
    //   case MoveType.left:
    //     if (x == 0 && y == 0) {
    //       break;
    //     }
    //
    //     if (y + 1 < widthRatio) {
    //       matrixCellState[x][y] = matrixCellState[x][y + 1];
    //       _emptyCellIndex = '${x}_${y + 1}';
    //       matrixCellState[x][y].currentState?.moveBack();
    //     }
    //
    //     break;
    //   case MoveType.right:
    //     if (y - 1 >= 0) {
    //       matrixCellState[x][y] = matrixCellState[x][y - 1];
    //       _emptyCellIndex = '${x}_${y - 1}';
    //       matrixCellState[x][y].currentState?.moveForward();
    //     }
    //
    //     break;
    //   case MoveType.up:
    //     if (x + 1 <= heightRatio || _emptyCellIndex == __emptyCellIndex) {
    //       matrixCellState[x][y] = matrixCellState[x + 1][y];
    //       _emptyCellIndex = '${x + 1}_${y}';
    //       matrixCellState[x][y].currentState?.moveUp();
    //     }
    //
    //     break;
    //   case MoveType.down:
    //     if (x - 1 >= 0 || _emptyCellIndex == '-1_0') {
    //       matrixCellState[x][y] = matrixCellState[x - 1][y];
    //       _emptyCellIndex = '${x - 1}_${y}';
    //       matrixCellState[x][y].currentState?.moveDown();
    //     }
    //     break;
    // }
  }

  void _genCellWidgets(Image image) {
    //thêm khoảng trống
    //Khoảng trống này luôn giữ mãnh bên góc bên trái

    final GameMatrix boardGameMatrix = [];

    boardGameMatrix.add([GameMatrixItem(x: 0, y: 0)]);
    boardGameMatrix.addAll(scramble());

    final int imageCellWidth = (image.width / GameManager.widthRatio).floor();
    final int imageCellHeight = (image.height / GameManager.heightRatio).floor();

    // List<Widget> widgets = [];
    //
    // for (int y = 0; y < GameManager.heightRatio; y++) {
    //   List<GlobalKey<CellWidgetState>> gameStatusRow = [];
    //   for (int x = 0; x < GameManager.widthRatio; x++) {
    //     gameStatusRow.add(GlobalKey());
    //     final cellPosition = boardGameMatrix[y + 1][x];
    //     widgets.add(
    //       CellWidget(
    //         destination: cellPosition,
    //         size: GameManager.cellSize,
    //         jumpSize: GameManager.cellSize,
    //         top: y + 1,
    //         left: x,
    //         key: gameStatusRow.last,
    //         child: _RenderImage(
    //           cellPosition: cellPosition,
    //           imageCellWidth: imageCellWidth,
    //           imageCellHeight: imageCellHeight,
    //           image: image,
    //         ),
    //       ),
    //     );
    //   }
    //   matrixCellState.add(gameStatusRow);
    // }
    // return widgets;
  }

  void init(Image image) {
    // _cells = _genCellWidgets(image);
  }

  List<List<GameMatrixItem>> scramble() {
    List<List<GameMatrixItem>> tempt = _initMatrix();

    List<MoveType> moveTypes = genMoveList();

    EmptyBox emptyBox = EmptyBox(y: 0, x: 0);

    void _move(MoveType moveType) async {
      int x = emptyBox.x;
      int y = emptyBox.y;

      switch (moveType) {
        case MoveType.left:
          if (x + 1 < widthRatio) {
            tempt[y][x] = tempt[y][x + 1];
            emptyBox.x++;
          }

          break;
        case MoveType.right:
          if (x - 1 >= 0) {
            tempt[y][x] = tempt[y][x - 1];
            emptyBox.x--;
          }

          break;
        case MoveType.up:
          if (y + 1 < heightRatio) {
            tempt[y][x] = tempt[y + 1][x];
            emptyBox.y++;
          }

          break;
        case MoveType.down:
          if (y - 1 >= 0) {
            tempt[y][x] = tempt[y - 1][x];
            emptyBox.y--;
          }
          break;
      }
    }

    moveTypes.forEach(_move);

    // for (var moveType in moveTypes) {
    //   int x = emptyBox.x;
    //   int y = emptyBox.y;
    //
    //   switch (moveType) {
    //     case MoveType.left:
    //       if (x + 1 < widthRatio) {
    //         tempt[y][x] = tempt[y][x + 1];
    //         emptyBox = EmptyBox(x: x + 1, y: y);
    //         tempt[y][x + 1] = emptyBox;
    //       }
    //
    //       break;
    //     case MoveType.right:
    //       if (x - 1 >= 0) {
    //         tempt[y][x] = tempt[y][x - 1];
    //         emptyBox = EmptyBox(x: x - 1, y: y);
    //         tempt[y][x - 1] = emptyBox;
    //       }
    //
    //       break;
    //     case MoveType.up:
    //       if (y + 1 < heightRatio) {
    //         tempt[y][x] = tempt[y + 1][x];
    //         emptyBox = EmptyBox(x: x, y: y + 1);
    //         tempt[y + 1][x] = emptyBox;
    //       }
    //
    //       break;
    //     case MoveType.down:
    //       if (y - 1 >= 0) {
    //         tempt[y][x] = tempt[y - 1][x];
    //         emptyBox = EmptyBox(x: x, y: y - 1);
    //         tempt[y - 1][x] = emptyBox;
    //       }
    //       break;
    //   }
    // }

    //chuyển cái ô empty box về vị trí [0,0]

    // while (!(emptyBox.y == 0 && emptyBox.x == 0)) {
    //   int x = emptyBox.x;
    //   int y = emptyBox.y;
    //
    //   if (x > 0) {
    //     tempt[y][x] = tempt[y][x - 1];
    //     emptyBox = EmptyBox(x: x - 1, y: y);
    //     tempt[y][x - 1] = emptyBox;
    //   } else if (y > 0) {
    //     tempt[y][x] = tempt[y - 1][x];
    //     emptyBox = EmptyBox(x: x, y: y - 1);
    //     tempt[y - 1][x] = emptyBox;
    //   }
    // }

    return tempt;
  }

  GameMatrix _initMatrix() {
    GameMatrix tempt = [];
    for (int i = 0; i < heightRatio; i++) {
      final List<GameMatrixItem> row = [];
      for (int j = 0; j < widthRatio; j++) {
        row.add(GameMatrixItem(x: j, y: i));
      }
      tempt.add(row);
    }
    return tempt;
  }

  Future<bool> checkDone() async {
    // for (List<GlobalKey<CellWidgetState>> row in matrixCellState) {
    //   for (GlobalKey<CellWidgetState> cell in row) {
    //     if (!(cell.currentState?.isGetDestination() ?? true)) {
    //       return false;
    //     }
    //   }
    // }
    return true;
  }
}

class EmptyBox {
  int x;
  int y;
  EmptyBox({this.x = 0, this.y = 0});

  String getUpKey() {
    return '${x}_${y - 1}';
  }

  String getDownKey() {
    return '${x}_${y + 1}';
  }

  String getLeftKey() {
    return '${x - 1}_${y}';
  }

  String getRightKey() {
    return '${x + 1}_${y}';
  }

  String getKey() {
    return '${x}_${y}';
  }

  void moveRight() {
    x++;
  }

  void moveLeft() {
    x--;
  }

  void moveUp() {
    y--;
  }

  void moveDown() {
    y++;
  }
}

class GameMatrixItem {
  //**        x ---->
  //**      y
  //**      |
  //**      v

  final int x;
  final int y;
  late int sx; // scramble index x
  late int sy; // scramble index y

  GameMatrixItem({required this.y, required this.x}) {
    sx = x;
    sy = y;
  }

  @override
  String toString() {
    return '($y,$x)';
  }

  String getKey() {
    return '${sx}_${sy}';
  }

  bool validate() {
    return x == sx && y == sy;
  }
}

enum MoveType { left, right, up, down }

List<MoveType> genMoveList() {
  List<MoveType> moveTypes = [];

  Random random = Random();
  MoveType? preMoveType;

  for (int i = 0; i < _numberOfStep; i++) {
    moveTypes.add(_nextMoveRandom(preMoveType: preMoveType, random: random));
    preMoveType = moveTypes.last;
  }

  return moveTypes;
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

class CropModel {
  final Image s;
  final int x;
  final int y;
  final int w;
  final int h;

  CropModel(this.s, this.x, this.y, this.w, this.h);
}

Image crop(CropModel cropModel) {
  return copyCrop(
    cropModel.s,
    x: cropModel.x,
    y: cropModel.y,
    width: cropModel.w,
    height: cropModel.h,
  );
}

List<List<Image>> copyCropMatrix(Image src, int n) {
  if (n <= 0) {
    throw ArgumentError('n must be greater than 0');
  }

  final int partWidth = (src.width / n).floor();
  final int partHeight = (src.height / n).floor();

  List<List<Image>> matrix = List.generate(n, (_) => List.filled(n, Image(width: 0, height: 0)));

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      final int x = j * partWidth;
      final int y = i * partHeight;

      final cropped = Image.fromResized(src, width: partWidth, height: partHeight)..clear(); // Xóa nội dung cũ nếu có

      for (int py = 0; py < partHeight; py++) {
        for (int px = 0; px < partWidth; px++) {
          final pixel = src.getPixel(x + px, y + py);
          cropped.setPixel(px, py, pixel);
        }
      }

      matrix[i][j] = cropped;
    }
  }

  return matrix;
}
