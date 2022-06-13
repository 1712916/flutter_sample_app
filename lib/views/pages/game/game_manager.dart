import 'package:flutter/material.dart';

import 'cell_widget.dart';

class GameManager {
  static double cellSize = 50;
  static int widthRatio = 4;
  static int heightRatio = 4;
  static double ratio = widthRatio / heightRatio;

  static double gameBoardHeight = heightRatio * cellSize;
  static double gameBoardWidth = widthRatio * cellSize;

   String _emptyCellIndex = '0_0';

  // static Map<String, GlobalKey<CellWidgetState>> boardGame = {};

   List<List<GlobalKey<CellWidgetState>>> boardGameStatus = [];

  void initBoardGame() {
    for (int i = 0; i < heightRatio; i++) {
      for (int j = 0; j < widthRatio; j++) {
        String key = '${i}_$j';
        // boardGame[key] = GlobalKey<CellWidgetState>(debugLabel: key);
      }
    }
  }


  void controller(MoveType moveType) {
    List<int> wh = _emptyCellIndex.split('_').map((e) => int.parse(e)).toList();
    print('WWWWHHHH:: ${wh}');
    print('moveType:: ${moveType}');
    int h = wh.first;
    int w = wh.last;

    //todo: check coi thử có quá biên không
    switch (moveType) {
      case MoveType.left:
        if (w + 1 < widthRatio) {
          boardGameStatus[h][w] = boardGameStatus[h][w + 1];
          _emptyCellIndex = '${h}_${w + 1}';
          boardGameStatus[h][w].currentState?.moveBack();
        }

        break;
      case MoveType.right:
        if (w - 1 >= 0) {
          boardGameStatus[h][w] = boardGameStatus[h][w - 1];
          _emptyCellIndex = '${h}_${w - 1}';
          boardGameStatus[h][w].currentState?.moveForward();
        }

        break;
      case MoveType.up:
        if (h + 1 < heightRatio) {
          boardGameStatus[h][w] = boardGameStatus[h + 1][w];
          _emptyCellIndex = '${h + 1}_${w}';
          boardGameStatus[h][w].currentState?.moveUp();
        }
        break;
      case MoveType.down:
        if (h - 1 >= 0) {
          boardGameStatus[h][w] = boardGameStatus[h - 1][w];
          _emptyCellIndex = '${h - 1}_${w}';
          boardGameStatus[h][w].currentState?.moveDown();
        }
        break;
    }
  }
}

enum MoveType { left, right, up, down }
