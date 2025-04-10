import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/index.dart';

class GameSettingCubit extends Cubit<GameSettingState> {
  GameSettingCubit() : super(GameSettingState.initial());

  final SimpleStorage simpleStorage = SimpleStorage();

  static final String gameControllerKey = 'game_controller_key';

  void init() {
    // Initialize any necessary data or state here
    simpleStorage.getBool(gameControllerKey).then((value) {
      emit(state.copyWith(gameController: value ?? true));
    });
  }

  void toggleGameController(bool value) {
    emit(state.copyWith(gameController: value));
    simpleStorage.saveBool(gameControllerKey, value);
  }
}

class GameSettingState extends Equatable {
  final bool gameController;

  GameSettingState({
    required this.gameController,
  });

  factory GameSettingState.initial() {
    return GameSettingState(
      gameController: false,
    );
  }

  GameSettingState copyWith({
    bool? gameController,
  }) {
    return GameSettingState(
      gameController: gameController ?? this.gameController,
    );
  }

  @override
  List<Object?> get props => [
        gameController,
      ];
}
