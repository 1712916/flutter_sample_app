import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/index.dart';
import '../sound/game_sound_manager.dart';

class GameSettingCubit extends Cubit<GameSettingState> {
  GameSettingCubit() : super(GameSettingState.initial());

  final SimpleStorage simpleStorage = SimpleStorage();

  static final String gameControllerKey = 'game_controller_key';
  static final String blinkingMarkerKey = 'blinking_marker_key';
  static final String soundEnabledKey = 'sound_enabled_key';

  void init() {
    // Initialize any necessary data or state here
    Future.wait([
      simpleStorage.getBool(gameControllerKey),
      simpleStorage.getBool(blinkingMarkerKey),
      simpleStorage.getBool(soundEnabledKey),
    ]).then(
      (value) {
        emit(state.copyWith(
          gameController: value[0] ?? true,
          blinkingMarker: value[1] ?? true,
          soundEnabled: value[2] ?? true,
        ));

        // Set sound mute state based on settings
        GameSoundManager().setMute(!(value[2] ?? true));
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

  void toggleSoundEnabled(bool value) {
    emit(state.copyWith(soundEnabled: value));
    simpleStorage.saveBool(soundEnabledKey, value);

    // Update sound manager mute state
    GameSoundManager().setMute(!value);
  }
}

class GameSettingState extends Equatable {
  final bool gameController;
  final bool blinkingMarker;
  final bool soundEnabled;

  GameSettingState({
    required this.gameController,
    required this.blinkingMarker,
    required this.soundEnabled,
  });

  factory GameSettingState.initial() {
    return GameSettingState(
      gameController: false,
      blinkingMarker: false,
      soundEnabled: true,
    );
  }

  GameSettingState copyWith({
    bool? gameController,
    bool? blinkingMarker,
    bool? soundEnabled,
  }) {
    return GameSettingState(
      gameController: gameController ?? this.gameController,
      blinkingMarker: blinkingMarker ?? this.blinkingMarker,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  List<Object?> get props => [
        gameController,
        blinkingMarker,
        soundEnabled,
      ];
}
