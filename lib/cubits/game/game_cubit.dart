import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:meow_app/cubits/cubits.dart';

import '../../helpers/helpers.dart';
import '../../views/pages/game/cell_widget.dart';
import '../../views/pages/game/game_manager.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState(loadStatus: LoadStatus.init));

  GameManager gameManager = GameManager();

  late List<Widget> _cells;
  List<Widget> get cells => _cells;

  List<Widget> _genCell() {
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

  void init() async {
    emit(state.copyWith());
    final response = await openEditImage('https://cdn2.thecatapi.com/images/1df.png');
    initBoardGame();
  }

  void initBoardGame() {
    _cells = _genCell();
  }

  Future<CroppedFile?> openEditImage(String url) async {
    //down load image => lưu lại => lấy path
    String? path = await DownloadHelper.downloadToInternal(url);
    print('path: $path');
    if (path != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'Edit Image', toolbarColor: Colors.greenAccent, toolbarWidgetColor: Colors.black, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: true),
          IOSUiSettings(
            title: 'Edit Image',
          ),
        ],
      );
      print('croppedFile?.path: ${croppedFile?.path}');
      return croppedFile;
    }
    return null;
  }

  void initByUrl(String url) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    final response = await openEditImage(url);
    initBoardGame();
    emit(state.copyWith(loadStatus: LoadStatus.loaded));

  }
}