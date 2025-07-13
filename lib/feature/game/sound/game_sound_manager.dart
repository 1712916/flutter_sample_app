import 'package:flutter/foundation.dart';
import 'package:meow_app/core/sound/music_manager.dart';
import 'package:meow_app/core/sound/independent_music_manager.dart';
import 'package:meow_app/core/sound/independent_sound_manager.dart';

/// Game sound manager for handling game-specific sounds
/// Now uses independent music and sound managers that are decoupled
class GameSoundManager {
  // Singleton instance
  static final GameSoundManager _instance = GameSoundManager._internal();

  factory GameSoundManager() => _instance;

  GameSoundManager._internal();

  // Independent manager references - music and sound are now decoupled
  final IndependentMusicManager _musicManager = IndependentMusicManager();
  final IndependentSoundManager _soundManager = IndependentSoundManager();
  final MusicManager _musicFileManager = MusicManager();

  // Current background music file
  String _currentMusicFile = MusicManager.defaultMusic;

  bool _isInitialized = false;

  /// Initialize the game sound manager
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    try {
      if (kDebugMode) {
        print('🎵 Initializing GameSoundManager');
      }

      // Initialize both independent managers and music file manager
      await Future.wait([
        _soundManager.initialize(),
        _musicManager.initialize(),
        _musicFileManager.initialize(),
      ]);

      if (kDebugMode) {
        print('🎵 GameSoundManager initialization complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing game sound manager: $e');
      }
    } finally {
      _isInitialized = true;
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
        print('🎉 Playing game completion sound');
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
      final filePath = await _musicFileManager.getMusicFilePath(fileName);

      if (filePath != null) {
        if (kDebugMode) {
          print('🎵 Starting background music: $fileName');
        }

        // Play the music using the independent music manager
        await _musicManager.playMusic(
          filePath,
          source: MusicSource.file,
          loop: true,
          volume: 0.5, // Lower volume for background music
        );

        if (kDebugMode) {
          print('🎵 Background music started successfully');
        }
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
        print('🎵 Stopping background music');
      }

      await _musicManager.stopMusic();

      if (kDebugMode) {
        print('🎵 Background music stopped successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping background music: $e');
      }
    }
  }

  /// Toggle background music playback
  Future<void> toggleBackgroundMusic() async {
    if (_musicManager.isMusicPlaying()) {
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
      print('🎵 Switching background music to: $musicFile');
    }

    // Update current music file
    _currentMusicFile = musicFile;

    // Get the path to the new music file
    final filePath = await _musicFileManager.getMusicFilePath(musicFile);

    if (filePath != null) {
      if (kDebugMode) {
        print('🎵 Switching to new music track: $musicFile');
      }

      // Use switchMusic method which doesn't stop current playback first
      await _musicManager.switchMusic(
        filePath,
        source: MusicSource.file,
        loop: true,
        volume: 0.5,
      );

      if (kDebugMode) {
        print('🎵 Music switch completed successfully');
      }
    } else {
      if (kDebugMode) {
        print('New music file not found: $musicFile');
      }
    }
  }

  /// Get list of available music files
  Future<List<String>> getAvailableMusicFiles() async {
    return _musicFileManager.getAvailableMusicFiles();
  }

  /// Get the current music file name
  String getCurrentMusicFile() {
    return _currentMusicFile;
  }

  /// Check if background music is playing
  bool isMusicPlaying() {
    return _musicManager.isMusicPlaying();
  }

  /// Set whether game sounds are muted (independent of music)
  Future<void> setSoundMute(bool mute) async {
    await _soundManager.setSoundMute(mute);
  }

  /// Set whether background music is muted (independent of sound effects)
  Future<void> setMusicMute(bool mute) async {
    await _musicManager.setMusicMute(mute);
  }

  /// Toggle sound effects mute state
  Future<void> toggleSoundMute() async {
    await _soundManager.toggleSoundMute();
  }

  /// Toggle music mute state
  Future<void> toggleMusicMute() async {
    await _musicManager.toggleMusicMute();
  }

  /// Check if sound effects are muted
  bool isSoundMuted() {
    return _soundManager.isSoundMuted();
  }

  /// Check if music is muted
  bool isMusicMuted() {
    return _musicManager.isMusicMuted();
  }
}
