import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as imglib;

import '../../helpers/helpers.dart';
import '../../views/pages/game/game_manager.dart';
import '../cubits.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState(loadStatus: LoadStatus.init));

  late GameManager gameManager;

  static GameManager _initGame(GameInfo gameInfo) {
    GameManager.cellSize = gameInfo.cellSize;
    return GameManager()..init(gameInfo.image);
  }

  void init() async {}

  void initByUrl(String url) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    await _getCroppedFile(url);
    if (state.image != null) {
      await initBoardGame();
      emit(state.copyWith(loadStatus: LoadStatus.loaded, cells: gameManager.cells));
    } else {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  Future initBoardGame() async {
    gameManager = await compute<GameInfo, GameManager>(_initGame, GameInfo(GameManager.cellSize, state.image!));
  }

  void reloadScramble() async {
    await initBoardGame();
    emit(
      state.copyWith(
        loadStatus: LoadStatus.loaded,
        cells: gameManager.cells,
        isComplete: false,
      ),
    );
  }

  void controller(MoveType moveType) {
    gameManager.controller(moveType);
    gameManager.checkDone().then((value) {
      emit(state.copyWith(isComplete: value));
    });
  }

  Future<CroppedFile?> openEditImage(String url) async {
    //down load image => lưu lại => lấy path
    String? path = await DownloadHelper.downloadToInternal(url);
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
      return croppedFile;
    }
    return null;
  }

  Future _getCroppedFile(String url) async {
    final response = await openEditImage(url);
    if (response != null) {
      await _roundingSizeImage(await response.readAsBytes());
    } else {}
  }

  Future _roundingSizeImage(Uint8List? croppedFile) async {
    final imageInfo = await decodeImageFromList(croppedFile!);
    final int roundingSize = (imageInfo.width / GameManager.heightRatio).floor() * GameManager.heightRatio;
    final imglib.Image? image = imglib.copyCrop(imglib.decodeImage(croppedFile)!, 0, 0, roundingSize, roundingSize);

    emit(
      state.copyWith(
        image: image,
      ),
    );
  }
}

class GameInfo {
  final double cellSize;
  final imglib.Image image;

  GameInfo(this.cellSize, this.image);
}
