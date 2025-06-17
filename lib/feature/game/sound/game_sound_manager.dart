import 'package:flutter/foundation.dart';
import 'package:meow_app/core/sound/music_manager.dart';
import 'package:meow_app/core/sound/sound_manager.dart';

/// Game sound manager for handling game-specific sounds
class GameSoundManager {
  // Singleton instance
  static final GameSoundManager _instance = GameSoundManager._internal();

  factory GameSoundManager() => _instance;

  GameSoundManager._internal();

  // Sound manager reference
  final SoundManager _soundManager = SoundManager();
  final MusicManager _musicManager = MusicManager();

  // Current background music file
  String _currentMusicFile = MusicManager.defaultMusic;
  bool _isMusicPlaying = false;

  /// Initialize the game sound manager
  Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('🎵 Initializing GameSoundManager');
      }

      // Initialize music manager to check and download music files
      await _musicManager.initialize();

      if (kDebugMode) {
        print('🎵 GameSoundManager initialization complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing game sound manager: $e');
      }
    }
  }

  /// Play a sound when a move is made in the game
  Future<void> playMoveSound() async {
    try {
      if (kDebugMode) {
        print('🎮 Playing move sound...');
      }

      // Use a lower volume for the pop sound to not interfere with music
      await _soundManager.playEffect(
        'assets/sounds/pop.mp3', // Đảm bảo đường dẫn đầy đủ từ gốc của assets
        volume: 0.2, // Slightly lower volume for better mixing
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error playing move sound: $e');
      }
    }
  }

  /// Play a sound when the game is completed
  Future<void> playGameCompleteSound() async {
    try {
      if (kDebugMode) {
        print('� Playing game completion sound');
      }

      // Play the success sound
      await _soundManager.playEffect(
        'assets/sounds/successed.mp3', // Đảm bảo đường dẫn đầy đủ
        volume: 0.2,
        rate: 0.8, // Slower rate for a different effect
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error playing game complete sound: $e');
      }
    }
  }

  /// Start playing background music for the game
  Future<void> playBackgroundMusic([String? musicFile]) async {
    try {
      // Use specified music file or current one
      final fileName = musicFile ?? _currentMusicFile;
      _currentMusicFile = fileName;

      // Get the path to the music file
      final filePath = await _musicManager.getMusicFilePath(fileName);

      if (filePath != null) {
        if (kDebugMode) {
          print('🎵 Starting background music: $fileName');
        }

        // First stop any existing music to release audio resources
        await _soundManager.stopMusic();

        // Small delay to ensure audio resources are properly released
        await Future.delayed(Duration(milliseconds: 200));

        // Now play the music
        await _soundManager.playMusic(
          filePath,
          source: SoundSource.file,
          loop: true,
          volume: 0.5, // Lower volume for background music
        );

        _isMusicPlaying = true;

        // For Android, make a check to ensure music is actually playing
        Future.delayed(Duration(milliseconds: 500), () async {
          if (_soundManager.getMusicState() != SoundState.playing && _isMusicPlaying) {
            if (kDebugMode) {
              print('🎵 Music not playing after attempt, retrying...');
            }
            // Try one more time after a delay
            await _soundManager.playMusic(
              filePath,
              source: SoundSource.file,
              loop: true,
              volume: 0.5,
            );
          }
        });
      } else {
        if (kDebugMode) {
          print('Music file not found: $fileName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing background music: $e');
      }
    }
  }

  /// Stop the background music
  Future<void> stopBackgroundMusic() async {
    try {
      if (kDebugMode) {
        print('🎵 Stopping background music forcefully');
      }

      // Force stop the music player completely
      await _soundManager.stopMusic();

      // Đảm bảo cập nhật trạng thái
      _isMusicPlaying = false;

      // Thêm delay nhỏ và kiểm tra lại để đảm bảo đã dừng
      await Future.delayed(Duration(milliseconds: 100));

      // Kiểm tra nếu vẫn còn phát thì dừng lại một lần nữa
      if (_soundManager.getMusicState() != SoundState.idle) {
        if (kDebugMode) {
          print('🎵 Music still playing after stop, forcing stop again');
        }
        await _soundManager.stopMusic();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping background music: $e');
      }
    }
  }

  /// Toggle background music playback
  Future<void> toggleBackgroundMusic() async {
    if (_isMusicPlaying) {
      if (kDebugMode) {
        print('🎵 Toggling background music: stopping');
      }
      await stopBackgroundMusic();
    } else {
      if (kDebugMode) {
        print('🎵 Toggling background music: starting');
      }
      await playBackgroundMusic();
    }
  }

  /// Switch to a different background music
  Future<void> switchBackgroundMusic(String musicFile) async {
    if (kDebugMode) {
      print('🎵 Switching background music to: $musicFile - Current playing state: ${_isMusicPlaying}');
    }

    // Luôn cập nhật tên tệp nhạc hiện tại
    _currentMusicFile = musicFile;

    // Bất kể trạng thái hiện tại, dừng nhạc và phát lại với tệp mới
    if (kDebugMode) {
      print('🎵 Forcefully stopping current music before switching');
    }

    // Dừng nhạc hiện tại
    await stopBackgroundMusic();

    // Thêm delay dài hơn để đảm bảo tài nguyên được giải phóng
    await Future.delayed(Duration(milliseconds: 500));

    // Phát nhạc mới với tệp đã chọn
    if (kDebugMode) {
      print('🎵 Starting new music track: $musicFile');
    }
    await playBackgroundMusic(musicFile);
  }

  /// Get list of available music files
  Future<List<String>> getAvailableMusicFiles() async {
    return _musicManager.getAvailableMusicFiles();
  }

  /// Get the current music file name
  String getCurrentMusicFile() {
    return _currentMusicFile;
  }

  /// Check if background music is playing
  bool isMusicPlaying() {
    return _isMusicPlaying;
  }

  /// Set whether game sounds are muted
  Future<void> setSoundMute(bool mute) async {
    await _soundManager.setSoundMute(mute);
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    await _soundManager.toggleMute();
  }

  /// Check if sounds are muted
  bool isMuted() {
    return _soundManager.isMuted();
  }
}
