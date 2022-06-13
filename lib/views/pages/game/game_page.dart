import 'package:flutter/material.dart';

import 'cell_widget.dart';
import 'directional_control_widget.dart';
import 'game_manager.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String? message;
  bool isFirstInit = true;
  late List<Widget> cells;

  GameManager gameManager = GameManager();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstInit) {
      GameManager.cellSize = MediaQuery.of(context).size.width / GameManager.widthRatio;
      gameManager.initBoardGame();
      cells = genCell();
      isFirstInit = false;
    }

    return Scaffold(
      body: SafeArea(
        child: DirectionalControlWidget(
          moveLeft: () => gameManager.controller(MoveType.left),
          moveRight: () => gameManager.controller(MoveType.right),
          moveDown: () => gameManager.controller(MoveType.down),
          moveUp: () => gameManager.controller(MoveType.up),
          child: SizedBox(
            width: GameManager.gameBoardWidth,
            height: GameManager.gameBoardHeight,
            child: Stack(
              children: [
                ...cells,
                // ...List.generate(GameManager.widthRatio * GameManager.heightRatio, (index) => Text('${index%GameManager.heightRatio}_${index%GameManager.widthRatio}')),
                // ...List.generate(GameManager.widthRatio * GameManager.heightRatio, (index) => CellWidget(size: GameManager.cellSize, key: GameManager.boardGame['${index%GameManager.heightRatio}_${index%GameManager.widthRatio}'],)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> genCell() {
    List<Widget> widgets = [];
    for (int i = 0; i < GameManager.heightRatio; i++) {
      List<GlobalKey<CellWidgetState>> gameStatusRow = [];
      for (int j = 0; j < GameManager.widthRatio; j++) {
        String key = '${i}_$j';
        gameStatusRow.add(GlobalKey());
        if (i != 0 || j != 0) {
          widgets.add(CellWidget(
            size: GameManager.cellSize,
            top: GameManager.cellSize * i,
            left: GameManager.cellSize * j,
            key: gameStatusRow.last,
            child: Text('$key'),
          ));
        } else {
          // widgets.add(CellWidget(size: GameManager.cellSize, color: Colors.orangeAccent, key: GameManager.boardGame['$key'], child: Text('$key'),));
        }
      }
      gameManager.boardGameStatus.add(gameStatusRow);
    }
    return widgets;
  }
}


