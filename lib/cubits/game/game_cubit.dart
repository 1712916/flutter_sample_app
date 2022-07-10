import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as imglib;

import '../../helpers/helpers.dart';
import '../../views/pages/game/game_manager.dart';
import '../cubits.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState(loadStatus: LoadStatus.init));

  GameManager gameManager = GameManager();

  void init() async {}

  void initByUrl(String url) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    await _getCroppedFile(url);
    if (state.image != null) {
      initBoardGame();
      emit(state.copyWith(loadStatus: LoadStatus.loaded, cells: gameManager.cells));
    } else {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void initBoardGame() {
    gameManager.init(state.image!);
  }

  void reloadScramble() {
    gameManager = GameManager();
    initBoardGame();
    emit(state.copyWith(loadStatus: LoadStatus.loaded, cells: gameManager.cells));
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
    } else {

    }

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
