import 'dart:math';

import 'package:image/image.dart';

import 'widget/play_area_widget.dart';

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
const Map<int, int> _numberOfSteps = {
  3: 100,
  4: 200,
  5: 400,
  6: 600,
};

class GameManager {
  static double cellSize = 50;
  static int widthRatio = 3;
  static int heightRatio = 3;
  static double ratio = widthRatio / heightRatio;

  static double gameBoardHeight = (heightRatio) * cellSize;
  static double gameBoardWidth = widthRatio * cellSize;
}

class GameEmptyBox {
  int x;
  int y;
  GameEmptyBox({this.x = 0, this.y = 0});

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

List<MoveType> genMoveList(int gameSize) {
  List<MoveType> moveTypes = [];

  Random random = Random();
  MoveType? preMoveType;

  for (int i = 0; i < _numberOfSteps[gameSize]!; i++) {
    moveTypes.add(_nextMoveRandom(preMoveType: preMoveType, random: random));
    preMoveType = moveTypes.last;
  }

  return moveTypes;
}

List<MoveType> getReverseMoves(List<MoveType> scrambleMoves) {
  // Hàm ánh xạ để lấy hướng đối lập
  MoveType getOppositeMove(MoveType move) {
    switch (move) {
      case MoveType.left:
        return MoveType.right;
      case MoveType.right:
        return MoveType.left;
      case MoveType.up:
        return MoveType.down;
      case MoveType.down:
        return MoveType.up;
    }
  }

  // Đảo ngược danh sách và thay thế mỗi move bằng hướng đối lập
  return scrambleMoves.reversed.map(getOppositeMove).toList();
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

class Game {
  late List<List<GameMatrixItem>> gameMatrix;
  late GameEmptyBox emptyBox;
  Map<String, GameMatrixItem> moveTracking = {};
  final int size;

  List<MoveType> scrambleMoves = [];

  Game({required this.size});

  void initializeGame() {
    gameMatrix = List.generate(size, (y) {
      return List.generate(size, (x) {
        return GameMatrixItem(x: x, y: y);
      });
    });

    emptyBox = GameEmptyBox(x: 0, y: 0);
    gameMatrix[0][0].sx = 0;
    gameMatrix[0][0].sy = -1;

    for (var row in gameMatrix) {
      for (var item in row) {
        moveTracking[item.getKey()] = item;
      }
    }

    var moveTypes = genMoveList(size);
    moveTypes.forEach(_move);

    debugLog('Scramble done');
    debugLog('Empty box: ${emptyBox.x}, ${emptyBox.y}');
    printMatrix();
  }

  void _move(MoveType moveType) {
    switch (moveType) {
      case MoveType.left:
        final r = moveTracking[emptyBox.getRightKey()];
        if (r != null) {
          r.sx--;
          moveTracking[emptyBox.getKey()] = r;
          emptyBox.moveRight();
          scrambleMoves.add(MoveType.left);
        }
        break;
      case MoveType.right:
        final r = moveTracking[emptyBox.getLeftKey()];
        if (r != null) {
          r.sx++;
          moveTracking[emptyBox.getKey()] = r;
          emptyBox.moveLeft();
          scrambleMoves.add(MoveType.right);
        }
        break;
      case MoveType.up:
        final r = moveTracking[emptyBox.getDownKey()];
        if (r != null) {
          r.sy--;
          moveTracking[emptyBox.getKey()] = r;
          emptyBox.moveDown();
          scrambleMoves.add(MoveType.up);
        }
        break;
      case MoveType.down:
        final r = moveTracking[emptyBox.getUpKey()];
        if (r != null) {
          r.sy++;
          moveTracking[emptyBox.getKey()] = r;
          emptyBox.moveUp();
          scrambleMoves.add(MoveType.down);
        }
        break;
    }
  }

  void printMatrix() {
    debugLog('=== Game Matrix (sx, sy) ===');
    for (int y = 0; y < size; y++) {
      String row = '';
      for (int x = 0; x < size; x++) {
        final item = gameMatrix[y][x];
        row += '(${item.sx},${item.sy})\t';
      }
      debugLog(row);
    }
    debugLog('=============================');
  }
}
