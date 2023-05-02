import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_cropper/image_cropper.dart';
import 'package:meow_app/resources/locale/locale_keys.dart';

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

  void openErrorPage() {
    emit(state.copyWith(loadStatus: LoadStatus.error));
  }

  void initByUrl(String url) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    await _getCroppedFile(url);
    if (state.image != null) {
      // await initBoardGame();
      emit(state.copyWith(isComplete: true));
      // emit(state.copyWith(loadStatus: LoadStatus.loaded, cells: gameManager.cells));
    } else {
      emit(state.copyWith(loadStatus: LoadStatus.error));
    }
  }

  void initByFilePath(String path) async {
    final preImage = state.image;
    await _getCroppedFile('', path: path);
    emit(state.copyWith(isComplete: true));

    if (preImage != state.image) {
      emit(state.copyWith(isComplete: true));

      // emit(state.copyWith(loadStatus: LoadStatus.loading));
      // await initBoardGame();
      // emit(state.copyWith(loadStatus: LoadStatus.loaded, cells: gameManager.cells));
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
        // cells: gameManager.cells,
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

  Future<CroppedFile?> openEditImage(String url, {String? path}) async {
    //down load image => lưu lại => lấy path
    String? imageTemptPath = path ?? await DownloadHelper.downloadToInternal(url);
    if (imageTemptPath != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageTemptPath,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        compressQuality: 30,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: LocaleKeys.editImage.tr(),
            toolbarColor: Colors.greenAccent,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: LocaleKeys.editImage.tr(),
            minimumAspectRatio: 1.0,
            aspectRatioLockDimensionSwapEnabled: true,
            aspectRatioPickerButtonHidden: true,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: true,
            rectHeight: 4000,
            rectWidth: 4000,
            rectX: 0,
            rectY: 0,
            resetButtonHidden: true,
          ),
        ],
      );
      return croppedFile;
    }
    return null;
  }

  Future _getCroppedFile(String url, {String? path}) async {
    final response = await openEditImage(url, path: path);
    if (response != null) {
      await _roundingSizeImage(await response.readAsBytes());
    }
  }

  Future _roundingSizeImage(Uint8List croppedFile) async {
    final imglib.Image? image = await _getImage(ImageParam(croppedFile, GameManager.heightRatio));

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

class ImageParam {
  final Uint8List croppedFile;
  final int heightRatio;

  ImageParam(this.croppedFile, this.heightRatio);
}

Future<imglib.Image> _getImage(ImageParam imageParam) async {
  final int roundingSize =
      ((await decodeImageFromList(imageParam.croppedFile)).width / imageParam.heightRatio).floor() *
          imageParam.heightRatio;
  return imglib.copyCrop(imglib.decodeImage(imageParam.croppedFile)!, 0, 0, roundingSize, roundingSize);
}
