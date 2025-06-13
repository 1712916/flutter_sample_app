import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/index.dart';

class GameSettingCubit extends Cubit<GameSettingState> {
  GameSettingCubit() : super(GameSettingState.initial());

  final SimpleStorage simpleStorage = SimpleStorage();

  static final String gameControllerKey = 'game_controller_key';
  static final String blinkingMarkerKey = 'blinking_marker_key';

  void init() {
    // Initialize any necessary data or state here
    Future.wait([
      simpleStorage.getBool(gameControllerKey),
      simpleStorage.getBool(blinkingMarkerKey),
    ]).then(
      (value) {
        emit(state.copyWith(
          gameController: value[0] ?? true,
          blinkingMarker: value[1] ?? true,
        ));
      },
    );
  }

  void toggleGameController(bool value) {
    emit(state.copyWith(gameController: value));
    simpleStorage.saveBool(gameControllerKey, value);
  }

  void toggleBlinkingMarker(bool value) {
    emit(state.copyWith(blinkingMarker: value));
    simpleStorage.saveBool(blinkingMarkerKey, value);
  }
}

class GameSettingState extends Equatable {
  final bool gameController;
  final bool blinkingMarker;

  GameSettingState({
    required this.gameController,
    required this.blinkingMarker,
  });

  factory GameSettingState.initial() {
    return GameSettingState(
      gameController: false,
      blinkingMarker: false,
    );
  }

  GameSettingState copyWith({
    bool? gameController,
    bool? blinkingMarker,
  }) {
    return GameSettingState(
      gameController: gameController ?? this.gameController,
      blinkingMarker: blinkingMarker ?? this.blinkingMarker,
    );
  }

  @override
  List<Object?> get props => [
        gameController,
        blinkingMarker,
      ];
}
