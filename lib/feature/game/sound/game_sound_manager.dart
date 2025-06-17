import 'package:flutter/foundation.dart';
import 'package:meow_app/core/sound/sound_manager.dart';

/// Game sound manager for handling game-specific sounds
class GameSoundManager {
  // Singleton instance
  static final GameSoundManager _instance = GameSoundManager._internal();

  factory GameSoundManager() => _instance;

  GameSoundManager._internal();

  // Sound manager reference
  final SoundManager _soundManager = SoundManager();

  /// Play a sound when a move is made in the game
  void playMoveSound() {
    try {
      _soundManager.playEffect('sounds/pop.mp3');
    } catch (e) {
      if (kDebugMode) {
        print('Error playing move sound: $e');
      }
    }
  }

  /// Play a sound when the game is completed
  void playGameCompleteSound() {
    try {
      // You can add a different success sound here if available
      _soundManager.playEffect(
        'sounds/successed.mp3',
        volume: 1.0,
        rate: 0.8, // Slower rate for a different effect
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error playing game complete sound: $e');
      }
    }
  }

  /// Set whether game sounds are muted
  void setMute(bool mute) {
    _soundManager.setMute(mute);
  }

  /// Toggle mute state
  void toggleMute() {
    _soundManager.toggleMute();
  }

  /// Check if sounds are muted
  bool isMuted() {
    return _soundManager.isMuted();
  }
}
