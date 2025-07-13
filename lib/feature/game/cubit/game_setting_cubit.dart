import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/game/cubit/background_music_cubit.dart';

import '../../../core/index.dart';
import '../sound/game_sound_manager.dart';

class GameSettingCubit extends Cubit<GameSettingState> {
  GameSettingCubit() : super(GameSettingState.initial());

  final SimpleStorage simpleStorage = SimpleStorage();
  final GameSoundManager _gameSoundManager = GameSoundManager();
  
  // Tham chiếu đến BackgroundMusicCubit, sẽ được thiết lập sau
  BackgroundMusicCubit? _musicCubit;

  // Phương thức để thiết lập tham chiếu tới BackgroundMusicCubit
  void setMusicCubit(BackgroundMusicCubit musicCubit) {
    _musicCubit = musicCubit;
  }

  static final String gameControllerKey = 'game_controller_key';
  static final String blinkingMarkerKey = 'blinking_marker_key';
  static final String soundEnabledKey = 'sound_enabled_key';
  static final String musicEnabledKey = 'music_enabled_key';
  static final String currentMusicKey = 'current_music_key';

  void init({BackgroundMusicCubit? musicCubit}) async {
    // Set reference to BackgroundMusicCubit if provided
    if (musicCubit != null) {
      _musicCubit = musicCubit;
    }
    
    // Initialize music manager
    await _gameSoundManager.initialize();

    // Initialize any necessary data or state here
    final results = await Future.wait([
      simpleStorage.getBool(gameControllerKey),
      simpleStorage.getBool(blinkingMarkerKey),
      simpleStorage.getBool(soundEnabledKey),
      simpleStorage.getBool(musicEnabledKey),
      simpleStorage.getString(currentMusicKey),
    ]);

    // Initialize state with stored values or defaults
    final gameController = results[0] ?? true;
    final blinkingMarker = results[1] ?? true;
    final soundEnabled = results[2] ?? true;
    final musicEnabled = results[3] ?? true;
    final currentMusic = results[4] ?? 'night-happiness.mp3';

    emit(state.copyWith(
      gameController: gameController as bool,
      blinkingMarker: blinkingMarker as bool,
      soundEnabled: soundEnabled as bool,
      musicEnabled: musicEnabled as bool,
      currentMusic: currentMusic as String,
    ));

    // Set sound mute state based on settings
    await _gameSoundManager.setSoundMute(!(soundEnabled as bool));

    // IMPORTANT: Don't start background music here
    // Music should only start when entering the Sort Game
  }

  void toggleGameController(bool value) {
    emit(state.copyWith(gameController: value));
    simpleStorage.saveBool(gameControllerKey, value);
  }

  void toggleBlinkingMarker(bool value) {
    emit(state.copyWith(blinkingMarker: value));
    simpleStorage.saveBool(blinkingMarkerKey, value);
  }

  void toggleSoundEnabled(bool value) async {
    emit(state.copyWith(soundEnabled: value));
    simpleStorage.saveBool(soundEnabledKey, value);

    // Update sound manager mute state using GameSoundManager (now independent of music)
    await _gameSoundManager.setSoundMute(!value);
    
    // Note: This no longer affects music playback
  }

  void toggleMusicEnabled(bool value) async {
    emit(state.copyWith(musicEnabled: value));
    simpleStorage.saveBool(musicEnabledKey, value);

    // Start or stop background music using the BackgroundMusicCubit if available
    if (_musicCubit != null) {
      if (value) {
        await _musicCubit!.playMusic(state.currentMusic);
      } else {
        await _musicCubit!.stopMusic();
      }
    } else {
      // Fall back to GameSoundManager if BackgroundMusicCubit is not available
      if (value) {
        await _gameSoundManager.playBackgroundMusic(state.currentMusic);
      } else {
        await _gameSoundManager.stopBackgroundMusic();
      }
    }
  }

  void changeMusic(String musicFile) async {
    if (kDebugMode) {
      print('🎵 Setting new music track in GameSettingCubit: $musicFile - Current enabled: ${state.musicEnabled}');
    }

    // Cập nhật trạng thái
    emit(state.copyWith(currentMusic: musicFile));

    // Lưu vào storage
    simpleStorage.saveString(currentMusicKey, musicFile);

    // Luôn chuyển nhạc nếu đang bật nhạc, không phụ thuộc vào trạng thái phát
    if (state.musicEnabled) {
      if (kDebugMode) {
        print('🎵 Music is enabled, switching to new track');
      }
      
      // Sử dụng BackgroundMusicCubit nếu có
      if (_musicCubit != null) {
        await _musicCubit!.switchMusic(musicFile);
      } else {
        // Fall back to GameSoundManager
        await _gameSoundManager.switchBackgroundMusic(musicFile);
      }
    }
  }

  Future<List<String>> getAvailableMusicFiles() async {
    return _gameSoundManager.getAvailableMusicFiles();
  }
}

class GameSettingState extends Equatable {
  final bool gameController;
  final bool blinkingMarker;
  final bool soundEnabled;
  final bool musicEnabled;
  final String currentMusic;

  GameSettingState({
    required this.gameController,
    required this.blinkingMarker,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.currentMusic,
  });

  factory GameSettingState.initial() {
    return GameSettingState(
      gameController: false,
      blinkingMarker: false,
      soundEnabled: true,
      musicEnabled: true,
      currentMusic: 'night-happiness.mp3',
    );
  }

  GameSettingState copyWith({
    bool? gameController,
    bool? blinkingMarker,
    bool? soundEnabled,
    bool? musicEnabled,
    String? currentMusic,
  }) {
    return GameSettingState(
      gameController: gameController ?? this.gameController,
      blinkingMarker: blinkingMarker ?? this.blinkingMarker,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      currentMusic: currentMusic ?? this.currentMusic,
    );
  }

  @override
  List<Object?> get props => [
        gameController,
        blinkingMarker,
        soundEnabled,
        musicEnabled,
        currentMusic,
      ];
}
