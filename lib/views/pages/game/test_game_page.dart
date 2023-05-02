import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:meow_app/views/pages/game/cell_widget.dart';
import 'package:meow_app/views/pages/game/directional_control_widget.dart';
import 'package:meow_app/views/pages/game/game_manager.dart';

import 'game_page_2.dart';

class TestGamePage extends StatefulWidget {
  const TestGamePage({Key? key, required this.image}) : super(key: key);
  final imglib.Image image;

  @override
  State<TestGamePage> createState() => _TestGamePageState();
}

class _TestGamePageState extends State<TestGamePage> {
  EmptyBox emptyBox = EmptyBox(x: 0, y: 0);

  late GameMatrix gameMatrix;

  List<List<GlobalKey<CellWidgetState>>> cellMatrix = [
    [
      GlobalKey(),
      GlobalKey(),
      GlobalKey(),
    ],
    [
      GlobalKey(),
      GlobalKey(),
      GlobalKey(),
    ],
    [
      GlobalKey(),
      GlobalKey(),
      GlobalKey(),
    ],
  ];

  Map<String, GlobalKey<CellWidgetState>> moveTracking = {};

  List<Widget> _getCell() {
    final int imageCellWidth = (widget.image.width / GameManager.widthRatio).floor();
    final int imageCellHeight = (widget.image.height / GameManager.heightRatio).floor();
    List<Widget> c = [];
    for (int i = 0; i < gameMatrix.length; i++) {
      for (int j = 0; j < gameMatrix[i].length; j++) {
        c.add(CellWidget(
          key: cellMatrix[i][j],
          size: 100,
          jumpSize: 100,
          destination: gameMatrix[i][j],
          child: RenderImage(
            imageCellHeight: imageCellHeight,
            imageCellWidth: imageCellWidth,
            cellPosition: gameMatrix[i][j],
            image: widget.image,
          ),
          color: Colors.cyan,
        ));

        moveTracking[gameMatrix[i][j].getKey()] = cellMatrix[i][j];
      }
    }
    return c;
  }

  @override
  void initState() {
    super.initState();
    final game = Game()..setUp();
    gameMatrix = game.gameMatrix;
    emptyBox = game.emptyBox;
  }

  void validate() {
    for (var r in gameMatrix) {
      for (var c in r) {
        if (!c.validate()) {
          return;
        }
      }
    }
    print('Xong!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: DirectionalControlWidget(
          moveLeft: () {
            print('moveLeft');

            final k = moveTracking[emptyBox.getRightKey()];
            if (k != null) {
              k.currentState?.moveBack();
              moveTracking[emptyBox.getKey()] = k;
              emptyBox.moveRight();
            }
          },
          moveRight: () {
            final k = moveTracking[emptyBox.getLeftKey()];
            if (k != null) {
              k.currentState?.moveForward();
              moveTracking[emptyBox.getKey()] = k;
              emptyBox.moveLeft();
            }
          },
          moveDown: () {
            print('moveDown');

            final k = moveTracking[emptyBox.getUpKey()];
            if (k != null) {
              k.currentState?.moveDown();
              moveTracking[emptyBox.getKey()] = k;
              emptyBox.moveUp();
              if (emptyBox.getKey() == '0_-1') {
                validate();
              }
            }
          },
          moveUp: () {
            print('moveUp');
            final k = moveTracking[emptyBox.getDownKey()];
            if (k != null) {
              k.currentState?.moveUp();
              moveTracking[emptyBox.getKey()] = k;
              emptyBox.moveDown();
            }
          },
          child: ColoredBox(
            color: Colors.transparent,
            child: Center(
              child: SizedBox(
                width: 100 * 3,
                height: 100 * 3,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: _getCell(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
