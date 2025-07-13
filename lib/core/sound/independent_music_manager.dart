import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Enum representing the current state of music playback
enum MusicState {
  idle, // Initial state or stopped
  loading, // Loading the music
  playing, // Currently playing
  paused, // Paused
  completed, // Playback completed
  error, // Error occurred
}

/// Enum representing the source type of the music
enum MusicSource {
  asset, // From app assets
  file, // From file system
  url, // From network URL
}

/// Independent music manager that's not coupled to sound effects
class IndependentMusicManager {
  // Singleton instance
  static final IndependentMusicManager _instance = IndependentMusicManager._internal();

  factory IndependentMusicManager() => _instance;

  IndependentMusicManager._internal();

  // Music player
  late AudioPlayer _musicPlayer;

  // Music source cache to prevent reloading
  final Map<String, AudioSource> _sourceCache = {};

  // Volume settings
  double _musicVolume = 0.8;

  // Mute setting (independent of sound effects)
  bool _isMusicMuted = false;

  // State notifiers
  final ValueNotifier<MusicState> musicStateNotifier = ValueNotifier<MusicState>(MusicState.idle);

  bool _isInitialized = false;
  String? _currentTrack;

  // Initialize the music system
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create music player with unique user agent to avoid conflicts
      _musicPlayer = AudioPlayer(userAgent: 'independent_music_player_${DateTime.now().millisecondsSinceEpoch}');

      // Configure audio player listeners
      _setupAudioPlayerListeners();

      _isInitialized = true;
      if (kDebugMode) {
        print('IndependentMusicManager initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing independent music manager: $e');
      }
    }
  }

  void _setupAudioPlayerListeners() {
    // Set up listeners for music player
    _musicPlayer.playerStateStream.listen((state) {
      if (kDebugMode) {
        print('Music player state changed: ${state.processingState}');
      }

      switch (state.processingState) {
        case ProcessingState.idle:
          musicStateNotifier.value = MusicState.idle;
          break;
        case ProcessingState.loading:
          musicStateNotifier.value = MusicState.loading;
          break;
        case ProcessingState.ready:
          if (state.playing) {
            musicStateNotifier.value = MusicState.playing;
          } else {
            musicStateNotifier.value = MusicState.paused;
          }
          break;
        case ProcessingState.completed:
          musicStateNotifier.value = MusicState.completed;
          break;
        case ProcessingState.buffering:
          // This is a transient state, we can ignore it
          break;
      }
    });

    _musicPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (kDebugMode) {
          print('Music playback completed');
        }
        musicStateNotifier.value = MusicState.completed;
      }
    });
  }

  // Get the correct source based on path and source type
  AudioSource _getSource(String path, MusicSource source) {
    if (_sourceCache.containsKey(path)) {
      return _sourceCache[path]!;
    }

    AudioSource audioSource;
    switch (source) {
      case MusicSource.asset:
        if (kDebugMode) {
          print('🎵 Creating asset audio source for: $path');
        }
        audioSource = AudioSource.asset(path);
        break;
      case MusicSource.file:
        if (kDebugMode) {
          print('🎵 Creating file audio source for: $path');
        }
        audioSource = AudioSource.uri(Uri.file(path));
        break;
      case MusicSource.url:
        if (kDebugMode) {
          print('🎵 Creating URL audio source for: $path');
        }
        audioSource = AudioSource.uri(Uri.parse(path));
        break;
    }

    // Cache the source
    _sourceCache[path] = audioSource;
    return audioSource;
  }

  /// Play background music
  Future<void> playMusic(
    String path, {
    MusicSource source = MusicSource.asset,
    double? volume,
    bool loop = true,
    double rate = 1.0,
  }) async {
    if (_isMusicMuted) {
      if (kDebugMode) {
        print('🎵 Music is muted, not playing');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🎵 Playing background music: $path (source: $source)');
      }

      musicStateNotifier.value = MusicState.loading;
      final musicSource = _getSource(path, source);
      _currentTrack = path;

      if (kDebugMode) {
        print('🎵 Created music source: ${musicSource.toString()}');
      }

      await _musicPlayer.stop();

      if (kDebugMode) {
        print('🎵 Setting music audio source...');
      }

      await _musicPlayer.setAudioSource(musicSource);

      if (kDebugMode) {
        print('🎵 Setting music volume: ${volume ?? _musicVolume}');
      }

      await _musicPlayer.setVolume(volume ?? _musicVolume);
      await _musicPlayer.setSpeed(rate);

      if (loop) {
        await _musicPlayer.setLoopMode(LoopMode.one);
      } else {
        await _musicPlayer.setLoopMode(LoopMode.off);
      }

      if (kDebugMode) {
        print('🎵 Starting music playback...');
      }

      await _musicPlayer.play();

      if (kDebugMode) {
        print('🎵 Music playback started successfully');
      }
    } catch (e) {
      musicStateNotifier.value = MusicState.error;
      if (kDebugMode) {
        print('❌ Error playing music: $e');
      }
    }
  }

  /// Switch to new music without stopping current playback first
  Future<void> switchMusic(
    String path, {
    MusicSource source = MusicSource.asset,
    double? volume,
    bool loop = true,
    double rate = 1.0,
  }) async {
    if (_isMusicMuted) {
      if (kDebugMode) {
        print('🎵 Music is muted, not switching');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🎵 Switching to music: $path (source: $source)');
      }

      musicStateNotifier.value = MusicState.loading;
      final musicSource = _getSource(path, source);
      _currentTrack = path;

      if (kDebugMode) {
        print('🎵 Created music source: ${musicSource.toString()}');
      }

      // Set new audio source directly without stopping first
      await _musicPlayer.setAudioSource(musicSource);

      if (kDebugMode) {
        print('🎵 Setting music volume: ${volume ?? _musicVolume}');
      }

      await _musicPlayer.setVolume(volume ?? _musicVolume);
      await _musicPlayer.setSpeed(rate);

      if (loop) {
        await _musicPlayer.setLoopMode(LoopMode.one);
      } else {
        await _musicPlayer.setLoopMode(LoopMode.off);
      }

      if (kDebugMode) {
        print('🎵 Starting new music playback...');
      }

      await _musicPlayer.play();

      if (kDebugMode) {
        print('🎵 Music switch completed successfully');
      }
    } catch (e) {
      musicStateNotifier.value = MusicState.error;
      if (kDebugMode) {
        print('❌ Error switching music: $e');
      }
    }
  }

  /// Stop playing music
  Future<void> stopMusic() async {
    try {
      if (kDebugMode) {
        print('🎵 Stopping music');
      }

      await _musicPlayer.pause();
      await _musicPlayer.stop();

      musicStateNotifier.value = MusicState.idle;
      _currentTrack = null;

      if (kDebugMode) {
        print('🎵 Music stopped successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error stopping music: $e');
      }
    }
  }

  /// Pause music
  Future<void> pauseMusic() async {
    try {
      if (kDebugMode) {
        print('🎵 Pausing music');
      }

      await _musicPlayer.pause();
      musicStateNotifier.value = MusicState.paused;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error pausing music: $e');
      }
    }
  }

  /// Resume music
  Future<void> resumeMusic() async {
    if (_isMusicMuted) {
      if (kDebugMode) {
        print('🎵 Music is muted, not resuming');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🎵 Resuming music');
      }

      await _musicPlayer.play();
      musicStateNotifier.value = MusicState.playing;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resuming music: $e');
      }
    }
  }

  /// Set the volume for background music
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    try {
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting music volume: $e');
      }
    }
  }

  /// Mute or unmute music (independent of sound effects)
  Future<void> setMusicMute(bool mute) async {
    _isMusicMuted = mute;

    try {
      if (mute) {
        await _musicPlayer.setVolume(0);
      } else {
        await _musicPlayer.setVolume(_musicVolume);
      }
    } catch (e, st) {
      log('Error setting music mute: $e', error: e, stackTrace: st);
      if (kDebugMode) {
        print('Error setting music mute: $e');
      }
    }
  }

  /// Toggle music mute state
  Future<void> toggleMusicMute() async {
    await setMusicMute(!_isMusicMuted);
  }

  /// Check if music is muted
  bool isMusicMuted() {
    return _isMusicMuted;
  }

  /// Get the current state of background music
  MusicState getMusicState() {
    return musicStateNotifier.value;
  }

  /// Check if music is playing
  bool isMusicPlaying() {
    return musicStateNotifier.value == MusicState.playing;
  }

  /// Get current track
  String? getCurrentTrack() {
    return _currentTrack;
  }

  /// Dispose of resources
  void dispose() {
    try {
      _musicPlayer.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing music player: $e');
      }
    }

    musicStateNotifier.dispose();
    _sourceCache.clear();
  }
}
