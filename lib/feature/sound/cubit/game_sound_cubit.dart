import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meow_app/feature/sound/game_sound_manager.dart';

/// Trạng thái của GameSoundCubit
class GameSoundState extends Equatable {
  final bool soundEnabled;

  const GameSoundState({
    this.soundEnabled = true,
  });

  /// Tạo bản sao của state với một số thuộc tính được thay đổi
  GameSoundState copyWith({
    bool? soundEnabled,
  }) {
    return GameSoundState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  List<Object?> get props => [soundEnabled];
}

/// Cubit quản lý hiệu ứng âm thanh trong game
class GameSoundCubit extends Cubit<GameSoundState> {
  final GameSoundManager _gameSoundManager = GameSoundManager();

  /// Khởi tạo Cubit với trạng thái ban đầu
  GameSoundCubit() : super(const GameSoundState());

  /// Khởi tạo Cubit
  Future<void> initialize({bool soundEnabled = true}) async {
    await _gameSoundManager.initialize();

    emit(state.copyWith(
      soundEnabled: soundEnabled,
    ));

    // Cập nhật trạng thái mute của sound manager
    await _gameSoundManager.setSoundMute(!soundEnabled);
  }

  /// Phát âm thanh khi di chuyển trong game
  Future<void> playMoveSound() async {
    if (!state.soundEnabled) return;

    try {
      if (kDebugMode) {
        print('🎮 GameSoundCubit: Playing move sound');
      }
      await _gameSoundManager.playMoveSound();
    } catch (e) {
      if (kDebugMode) {
        print('🎮 GameSoundCubit: Error playing move sound: $e');
      }
    }
  }

  /// Phát âm thanh khi hoàn thành game
  Future<void> playGameCompleteSound() async {
    if (!state.soundEnabled) return;

    try {
      if (kDebugMode) {
        print('🎮 GameSoundCubit: Playing game complete sound');
      }
      await _gameSoundManager.playGameCompleteSound();
    } catch (e) {
      if (kDebugMode) {
        print('🎮 GameSoundCubit: Error playing game complete sound: $e');
      }
    }
  }

  /// Bật/tắt hiệu ứng âm thanh
  Future<void> toggleSoundEnabled(bool enabled) async {
    try {
      emit(state.copyWith(soundEnabled: enabled));
      await _gameSoundManager.setSoundMute(!enabled);

      if (kDebugMode) {
        print('🎮 GameSoundCubit: Sound ${enabled ? 'enabled' : 'disabled'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🎮 GameSoundCubit: Error toggling sound: $e');
      }
    }
  }
}
