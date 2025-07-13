import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Enum representing the current state of sound playback
enum SoundState {
  idle, // Initial state or stopped
  loading, // Loading the sound
  playing, // Currently playing
  paused, // Paused
  completed, // Playback completed
  error, // Error occurred
}

/// Enum representing the source type of the sound
enum SoundSource {
  asset, // From app assets
  file, // From file system
  url, // From network URL
}

/// A sound manager class that handles playing sounds in the app
class SoundManager {
  // Singleton instance
  static final SoundManager _instance = SoundManager._internal();

  factory SoundManager() => _instance;

  SoundManager._internal();

  // Audio players - DISABLED to prevent conflicts with independent managers
  // late AudioPlayer _effectPlayer;
  // late AudioPlayer _musicPlayer;

  // Sound effect cache to prevent reloading
  final Map<String, AudioSource> _sourceCache = {};

  // Volume settings - DISABLED but kept for compatibility
  // double _effectVolume = 1.0;
  // double _musicVolume = 0.8;

  // Mute setting
  bool _isMuted = false;

  // State notifiers
  final ValueNotifier<SoundState> effectStateNotifier = ValueNotifier<SoundState>(SoundState.idle);
  final ValueNotifier<SoundState> musicStateNotifier = ValueNotifier<SoundState>(SoundState.idle);

  bool _isInitialized = false;

  // Initialize the sound system - DISABLED to prevent conflicts with new independent managers
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        print('SoundManager: DISABLED - Using new independent music and sound managers instead');
      }
      
      // Don't create AudioPlayer instances to prevent conflicts
      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error in SoundManager initialization: $e');
      }
    }
  }

  void _setupAudioPlayerListeners() {
    // DISABLED - No AudioPlayer instances created
    if (kDebugMode) {
      print('SoundManager._setupAudioPlayerListeners: DISABLED');
    }
  }

  // Get the correct source based on path and source type
  AudioSource _getSource(String path, SoundSource source) {
    if (_sourceCache.containsKey(path)) {
      return _sourceCache[path]!;
    }

    AudioSource audioSource;
    switch (source) {
      case SoundSource.asset:
        // For asset files, we need to use a different approach
        if (kDebugMode) {
          print('🔊 Creating asset audio source for: $path');
        }
        // For assets in just_audio, we need to use the correct path format (without 'assets/' prefix)
        // For example, if path is 'assets/sounds/pop.mp3', we need to use 'asset:///sounds/pop.mp3'
        String assetPath = path;
        if (assetPath.startsWith('assets/')) {
          assetPath = assetPath.replaceFirst('assets/', '');
        }
        audioSource = AudioSource.asset(path);

        if (kDebugMode) {
          print('🔊 Final asset path: asset:///$assetPath');
        }
        break;
      case SoundSource.file:
        if (kDebugMode) {
          print('🔊 Creating file audio source for: $path');
        }
        audioSource = AudioSource.uri(Uri.file(path));
        break;
      case SoundSource.url:
        if (kDebugMode) {
          print('🔊 Creating URL audio source for: $path');
        }
        audioSource = AudioSource.uri(Uri.parse(path));
        break;
    }

    // Cache the source
    _sourceCache[path] = audioSource;
    return audioSource;
  }

  /// Preload sounds for faster playback
  Future<void> preloadSounds(List<String> paths, {SoundSource source = SoundSource.asset}) async {
    for (final path in paths) {
      try {
        _getSource(path, source);
      } catch (e) {
        if (kDebugMode) {
          print('Error preloading sound $path: $e');
        }
      }
    }
  }

  /// Play the pop sound (specifically for SortGame)
  Future<void> playPopSound() async {
    try {
      if (kDebugMode) {
        print('🔊 Playing pop sound directly');
      }
      await playEffect('assets/sounds/pop.mp3', volume: 0.7);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error playing pop sound: $e');
      }
      _playFallbackSound();
    }
  }

  /// Play a sound effect - DISABLED
  Future<void> playEffect(
    String path, {
    SoundSource source = SoundSource.asset,
    double? volume,
    bool loop = false,
    double rate = 1.0,
  }) async {
    if (kDebugMode) {
      print('SoundManager.playEffect: DISABLED - Use IndependentSoundManager instead');
    }
    return;
  }

  // Fallback sound implementation when AudioPlayers fails
  void _playFallbackSound() {
    // Simulate successful playback
    effectStateNotifier.value = SoundState.playing;

    // Simulate completion after a short time
    Timer(const Duration(milliseconds: 300), () {
      if (effectStateNotifier.value == SoundState.playing) {
        effectStateNotifier.value = SoundState.completed;
        Timer(const Duration(milliseconds: 50), () {
          effectStateNotifier.value = SoundState.idle;
        });
      }
    });
  }

  /// Play background music - DISABLED
  Future<void> playMusic(
    String path, {
    SoundSource source = SoundSource.asset,
    double? volume,
    bool loop = true,
    double rate = 1.0,
  }) async {
    if (kDebugMode) {
      print('SoundManager.playMusic: DISABLED - Use IndependentMusicManager instead');
    }
    return;
  }

  /// Stop playing effect - DISABLED
  Future<void> stopEffect() async {
    if (kDebugMode) {
      print('SoundManager.stopEffect: DISABLED');
    }
  }

  /// Stop playing music - DISABLED
  Future<void> stopMusic() async {
    if (kDebugMode) {
      print('SoundManager.stopMusic: DISABLED - Use IndependentMusicManager instead');
    }
    return;
  }

  /// Set the volume for sound effects - DISABLED
  Future<void> setEffectVolume(double volume) async {
    // _effectVolume = volume.clamp(0.0, 1.0);
    if (kDebugMode) {
      print('SoundManager.setEffectVolume: DISABLED');
    }
  }

  /// Set the volume for background music - DISABLED
  Future<void> setMusicVolume(double volume) async {
    // _musicVolume = volume.clamp(0.0, 1.0);
    if (kDebugMode) {
      print('SoundManager.setMusicVolume: DISABLED');
    }
  }

  /// Mute or unmute all sounds - DISABLED
  Future<void> setSoundMute(bool mute) async {
    _isMuted = mute;
    if (kDebugMode) {
      print('SoundManager.setSoundMute: DISABLED');
    }
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    await setSoundMute(!_isMuted);
  }

  /// Check if sounds are muted
  bool isMuted() {
    return _isMuted;
  }

  /// Get the current state of sound effects
  SoundState getEffectState() {
    return effectStateNotifier.value;
  }

  /// Get the current state of background music
  SoundState getMusicState() {
    return musicStateNotifier.value;
  }

  /// Dispose of resources - DISABLED
  void dispose() {
    if (kDebugMode) {
      print('SoundManager.dispose: DISABLED');
    }
    effectStateNotifier.dispose();
    musicStateNotifier.dispose();
    _sourceCache.clear();
  }
}
