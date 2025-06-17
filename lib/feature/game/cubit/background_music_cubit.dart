import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:meow_app/feature/game/sound/game_sound_manager.dart';

// Trạng thái của MusicCubit
class BackgroundMusicState extends Equatable {
  final bool isPlaying;
  final String? currentTrack;
  final bool isMuted;

  const BackgroundMusicState({
    this.isPlaying = false,
    this.currentTrack,
    this.isMuted = false,
  });

  // Tạo bản sao của state với một số thuộc tính được thay đổi
  BackgroundMusicState copyWith({
    bool? isPlaying,
    String? currentTrack,
    bool? isMuted,
  }) {
    return BackgroundMusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentTrack: currentTrack ?? this.currentTrack,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [isPlaying, currentTrack, isMuted];
}

// Cubit quản lý phát nhạc nền
class BackgroundMusicCubit extends Cubit<BackgroundMusicState> {
  final GameSoundManager _gameSoundManager = GameSoundManager();
  
  // Khởi tạo Cubit với trạng thái ban đầu
  BackgroundMusicCubit() : super(const BackgroundMusicState());

  // Khởi tạo Cubit
  Future<void> initialize({String? defaultTrack}) async {
    await _gameSoundManager.initialize();
    
    emit(state.copyWith(
      currentTrack: defaultTrack,
    ));
  }

  // Phát nhạc nền
  Future<void> playMusic([String? track]) async {
    final trackToPlay = track ?? state.currentTrack;
    
    if (trackToPlay == null) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: Cannot play null track');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: Playing track: $trackToPlay');
      }
      
      await _gameSoundManager.playBackgroundMusic(trackToPlay);
      
      emit(state.copyWith(
        isPlaying: true,
        currentTrack: trackToPlay,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: Error playing music: $e');
      }
    }
  }

  // Dừng nhạc nền
  Future<void> stopMusic() async {
    try {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: Stopping music');
      }
      
      await _gameSoundManager.stopBackgroundMusic();
      
      emit(state.copyWith(
        isPlaying: false,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: Error stopping music: $e');
      }
    }
  }

  // Chuyển đổi bài hát
  Future<void> switchMusic(String track) async {
    try {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: Switching to track: $track');
      }
      
      await _gameSoundManager.switchBackgroundMusic(track);
      
      emit(state.copyWith(
        isPlaying: true,
        currentTrack: track,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: Error switching music: $e');
      }
    }
  }

  // Bắt đầu phát nhạc khi vào màn hình (nếu đã được bật trong cài đặt)
  Future<void> startMusicIfEnabled(bool isMusicEnabled, String currentMusic) async {
    if (isMusicEnabled) {
      await playMusic(currentMusic);
    }
  }

  // Xử lý khi ứng dụng vào nền
  Future<void> handleAppBackground() async {
    // Lưu trạng thái hiện tại
    final wasPlaying = state.isPlaying;
    
    if (kDebugMode) {
      print('🎵 BackgroundMusicCubit: App went to background, music state: ${wasPlaying ? "playing" : "not playing"}');
    }
    
    if (wasPlaying) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: Stopping music before going to background');
      }
      
      // Dừng nhạc dù thế nào đi nữa
      await _gameSoundManager.stopBackgroundMusic();
      
      // Lưu lại rằng nhạc đang phát khi vào nền và cập nhật trạng thái
      emit(state.copyWith(
        isPlaying: false,
      ));
      
      // Kiểm tra lại sau một khoảng thời gian để đảm bảo đã dừng
      Future.delayed(Duration(milliseconds: 500), () async {
        if (_gameSoundManager.isMusicPlaying()) {
          if (kDebugMode) {
            print('🎵 BackgroundMusicCubit: Music still playing after background, forcing stop again');
          }
          await _gameSoundManager.stopBackgroundMusic();
        }
      });
    }
  }

  // Xử lý khi ứng dụng quay lại từ nền
  Future<void> handleAppForeground(bool isMusicEnabled, String currentMusic) async {
    if (isMusicEnabled) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicCubit: App returned to foreground, resuming music');
      }
      // Thêm độ trễ nhỏ để đảm bảo ứng dụng đã hoàn toàn khởi động lại
      await Future.delayed(const Duration(milliseconds: 300));
      await playMusic(currentMusic);
    }
  }

  // Kiểm tra xem nhạc có đang phát không
  bool isMusicPlaying() {
    return state.isPlaying;
  }

  // Lấy danh sách các bài hát có sẵn
  Future<List<String>> getAvailableTracks() async {
    return _gameSoundManager.getAvailableMusicFiles();
  }
}
