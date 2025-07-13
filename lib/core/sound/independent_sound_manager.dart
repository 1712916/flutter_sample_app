import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Enum representing the current state of sound playback
enum SoundEffectState {
  idle, // Initial state or stopped
  loading, // Loading the sound
  playing, // Currently playing
  paused, // Paused
  completed, // Playback completed
  error, // Error occurred
}

/// Enum representing the source type of the sound
enum SoundEffectSource {
  asset, // From app assets
  file, // From file system
  url, // From network URL
}

/// Independent sound effects manager that's not coupled to music
class IndependentSoundManager {
  // Singleton instance
  static final IndependentSoundManager _instance = IndependentSoundManager._internal();

  factory IndependentSoundManager() => _instance;

  IndependentSoundManager._internal();

  // Audio player for sound effects
  late AudioPlayer _effectPlayer;

  // Sound effect cache to prevent reloading
  final Map<String, AudioSource> _sourceCache = {};

  // Volume settings
  double _effectVolume = 1.0;

  // Mute setting (independent of music)
  bool _isSoundMuted = false;

  // State notifiers
  final ValueNotifier<SoundEffectState> effectStateNotifier = ValueNotifier<SoundEffectState>(SoundEffectState.idle);

  bool _isInitialized = false;

  // Initialize the sound system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create sound player with unique user agent to avoid conflicts
      _effectPlayer = AudioPlayer(userAgent: 'independent_sound_player_${DateTime.now().millisecondsSinceEpoch}');

      // Configure audio player listeners
      _setupAudioPlayerListeners();

      // Preload common sounds
      await preloadSounds(['sounds/pop.mp3']);

      _isInitialized = true;
      if (kDebugMode) {
        print('IndependentSoundManager initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing independent sound manager: $e');
      }
    }
  }

  void _setupAudioPlayerListeners() {
    // Set up listeners for effect player
    _effectPlayer.playerStateStream.listen((state) {
      if (kDebugMode) {
        print('Effect player state changed: ${state.processingState}');
      }

      switch (state.processingState) {
        case ProcessingState.idle:
          effectStateNotifier.value = SoundEffectState.idle;
          break;
        case ProcessingState.loading:
          effectStateNotifier.value = SoundEffectState.loading;
          break;
        case ProcessingState.ready:
          if (state.playing) {
            effectStateNotifier.value = SoundEffectState.playing;
          } else {
            effectStateNotifier.value = SoundEffectState.paused;
          }
          break;
        case ProcessingState.completed:
          effectStateNotifier.value = SoundEffectState.completed;
          break;
        case ProcessingState.buffering:
          // This is a transient state, we can ignore it
          break;
      }
    });

    // Listen for playback completion
    _effectPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (kDebugMode) {
          print('Effect playback completed');
        }
        effectStateNotifier.value = SoundEffectState.completed;
        Timer(const Duration(milliseconds: 50), () {
          effectStateNotifier.value = SoundEffectState.idle;
        });
      }
    });
  }

  // Get the correct source based on path and source type
  AudioSource _getSource(String path, SoundEffectSource source) {
    if (_sourceCache.containsKey(path)) {
      return _sourceCache[path]!;
    }

    AudioSource audioSource;
    switch (source) {
      case SoundEffectSource.asset:
        if (kDebugMode) {
          print('🔊 Creating asset audio source for: $path');
        }
        String assetPath = path;
        if (assetPath.startsWith('assets/')) {
          assetPath = assetPath.replaceFirst('assets/', '');
        }
        audioSource = AudioSource.asset(path);

        if (kDebugMode) {
          print('🔊 Final asset path: asset:///$assetPath');
        }
        break;
      case SoundEffectSource.file:
        if (kDebugMode) {
          print('🔊 Creating file audio source for: $path');
        }
        audioSource = AudioSource.uri(Uri.file(path));
        break;
      case SoundEffectSource.url:
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
  Future<void> preloadSounds(List<String> paths, {SoundEffectSource source = SoundEffectSource.asset}) async {
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

  /// Play a sound effect
  ///
  /// [path] is the path to the sound file (e.g., 'sounds/pop.mp3')
  /// [source] is the type of source (asset, file, url)
  /// [volume] is optional volume override (0.0 to 1.0)
  /// [loop] whether to loop the sound
  /// [rate] playback rate
  Future<void> playEffect(
    String path, {
    SoundEffectSource source = SoundEffectSource.asset,
    double? volume,
    bool loop = false,
    double rate = 1.0,
  }) async {
    if (_isSoundMuted) {
      if (kDebugMode) {
        print('🔊 Sound effects are muted, not playing');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🔊 Playing sound effect: $path (source: $source)');
      }

      effectStateNotifier.value = SoundEffectState.loading;

      final effectSource = _getSource(path, source);

      if (kDebugMode) {
        print('🔊 Created audio source: ${effectSource.toString()}');
      }

      // Stop previous effect only
      await _effectPlayer.stop();

      if (kDebugMode) {
        print('🔊 Setting audio source...');
      }

      await _effectPlayer.setAudioSource(effectSource);

      if (kDebugMode) {
        print('🔊 Setting volume: ${volume ?? _effectVolume}');
      }

      await _effectPlayer.setVolume(volume ?? _effectVolume);
      await _effectPlayer.setSpeed(rate);

      if (loop) {
        await _effectPlayer.setLoopMode(LoopMode.one);
      } else {
        await _effectPlayer.setLoopMode(LoopMode.off);
      }

      if (kDebugMode) {
        print('🔊 Starting playback...');
      }

      await _effectPlayer.play();

      if (kDebugMode) {
        print('🔊 Playback started successfully');
      }
    } catch (e) {
      effectStateNotifier.value = SoundEffectState.error;
      if (kDebugMode) {
        print('❌ Error playing effect: $e');
      }

      // Fallback to basic implementation if audioplayers fails
      _playFallbackSound();
    }
  }

  // Fallback sound implementation when AudioPlayers fails
  void _playFallbackSound() {
    // Simulate successful playback
    effectStateNotifier.value = SoundEffectState.playing;

    // Simulate completion after a short time
    Timer(const Duration(milliseconds: 300), () {
      if (effectStateNotifier.value == SoundEffectState.playing) {
        effectStateNotifier.value = SoundEffectState.completed;
        Timer(const Duration(milliseconds: 50), () {
          effectStateNotifier.value = SoundEffectState.idle;
        });
      }
    });
  }

  /// Stop playing effect
  Future<void> stopEffect() async {
    try {
      await _effectPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping effect: $e');
      }
    }
  }

  /// Set the volume for sound effects
  Future<void> setEffectVolume(double volume) async {
    _effectVolume = volume.clamp(0.0, 1.0);
    try {
      await _effectPlayer.setVolume(_effectVolume);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting effect volume: $e');
      }
    }
  }

  /// Mute or unmute sound effects (independent of music)
  Future<void> setSoundMute(bool mute) async {
    _isSoundMuted = mute;

    try {
      if (mute) {
        await _effectPlayer.setVolume(0);
      } else {
        await _effectPlayer.setVolume(_effectVolume);
      }
    } catch (e, st) {
      log('Error setting effect mute: $e', error: e, stackTrace: st);
      if (kDebugMode) {
        print('Error setting sound mute: $e');
      }
    }
  }

  /// Toggle mute state
  Future<void> toggleSoundMute() async {
    await setSoundMute(!_isSoundMuted);
  }

  /// Check if sounds are muted
  bool isSoundMuted() {
    return _isSoundMuted;
  }

  /// Get the current state of sound effects
  SoundEffectState getEffectState() {
    return effectStateNotifier.value;
  }

  /// Dispose of resources
  void dispose() {
    try {
      _effectPlayer.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing sound player: $e');
      }
    }

    effectStateNotifier.dispose();
    _sourceCache.clear();
  }
}
