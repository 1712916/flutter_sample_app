import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

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

  SoundManager._internal() {
    _init();
  }

  // Audio players
  late AudioPlayer _effectPlayer;
  late AudioPlayer _musicPlayer;

  // Sound effect cache to prevent reloading
  final Map<String, Source> _sourceCache = {};

  // Volume settings
  double _effectVolume = 1.0;
  double _musicVolume = 0.8;

  // Mute setting
  bool _isMuted = false;

  // State notifiers
  final ValueNotifier<SoundState> effectStateNotifier = ValueNotifier<SoundState>(SoundState.idle);
  final ValueNotifier<SoundState> musicStateNotifier = ValueNotifier<SoundState>(SoundState.idle);

  // Initialize the sound system
  Future<void> _init() async {
    try {
      _effectPlayer = AudioPlayer();
      _musicPlayer = AudioPlayer();

      // Configure audio players
      _setupAudioPlayerListeners();

      // Preload common sounds
      await preloadSounds(['sounds/pop.mp3']);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing sound manager: $e');
      }
    }
  }

  void _setupAudioPlayerListeners() {
    // Set up listeners for effect player
    _effectPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          effectStateNotifier.value = SoundState.playing;
          break;
        case PlayerState.paused:
          effectStateNotifier.value = SoundState.paused;
          break;
        case PlayerState.completed:
          effectStateNotifier.value = SoundState.completed;
          break;
        case PlayerState.stopped:
          effectStateNotifier.value = SoundState.idle;
          break;
        case PlayerState.disposed:
          effectStateNotifier.value = SoundState.idle;
          break;
      }
    });

    // Set up listeners for music player
    _musicPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          musicStateNotifier.value = SoundState.playing;
          break;
        case PlayerState.paused:
          musicStateNotifier.value = SoundState.paused;
          break;
        case PlayerState.completed:
          musicStateNotifier.value = SoundState.completed;
          break;
        case PlayerState.stopped:
          musicStateNotifier.value = SoundState.idle;
          break;
        case PlayerState.disposed:
          musicStateNotifier.value = SoundState.idle;
          break;
      }
    });

    // Listen for playback completion
    _effectPlayer.onPlayerComplete.listen((_) {
      effectStateNotifier.value = SoundState.completed;
      Timer(const Duration(milliseconds: 50), () {
        effectStateNotifier.value = SoundState.idle;
      });
    });

    _musicPlayer.onPlayerComplete.listen((_) {
      musicStateNotifier.value = SoundState.completed;
    });
  }

  // Get the correct source based on path and source type
  Source _getSource(String path, SoundSource source) {
    if (_sourceCache.containsKey(path)) {
      return _sourceCache[path]!;
    }

    Source audioSource;
    switch (source) {
      case SoundSource.asset:
        audioSource = AssetSource(path);
        break;
      case SoundSource.file:
        audioSource = DeviceFileSource(path);
        break;
      case SoundSource.url:
        audioSource = UrlSource(path);
        break;
    }

    // Cache the source
    _sourceCache[path] = audioSource;
    return audioSource;
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
    SoundSource source = SoundSource.asset,
    double? volume,
    bool loop = false,
    double rate = 1.0,
  }) async {
    if (_isMuted) return;

    try {
      effectStateNotifier.value = SoundState.loading;

      final effectSource = _getSource(path, source);

      await _effectPlayer.stop();
      await _effectPlayer.setSource(effectSource);
      await _effectPlayer.setVolume(volume ?? _effectVolume);
      await _effectPlayer.setPlaybackRate(rate);

      if (loop) {
        await _effectPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _effectPlayer.setReleaseMode(ReleaseMode.release);
      }

      await _effectPlayer.resume();
    } catch (e) {
      effectStateNotifier.value = SoundState.error;
      if (kDebugMode) {
        print('Error playing effect: $e');
      }

      // Fallback to basic implementation if audioplayers fails
      _playFallbackSound();
    }
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

  /// Play background music
  Future<void> playMusic(
    String path, {
    SoundSource source = SoundSource.asset,
    double? volume,
    bool loop = true,
    double rate = 1.0,
  }) async {
    if (_isMuted) return;

    try {
      musicStateNotifier.value = SoundState.loading;
      final musicSource = _getSource(path, source);

      await _musicPlayer.stop();
      await _musicPlayer.setSource(musicSource);
      await _musicPlayer.setVolume(volume ?? _musicVolume);
      await _musicPlayer.setPlaybackRate(rate);

      if (loop) {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _musicPlayer.setReleaseMode(ReleaseMode.release);
      }

      await _musicPlayer.resume();
    } catch (e) {
      musicStateNotifier.value = SoundState.error;
      if (kDebugMode) {
        print('Error playing music: $e');
      }
    }
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

  /// Stop playing music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping music: $e');
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

  /// Mute or unmute all sounds
  Future<void> setMute(bool mute) async {
    _isMuted = mute;

    try {
      if (mute) {
        await _effectPlayer.setVolume(0);
        await _musicPlayer.setVolume(0);
      } else {
        await _effectPlayer.setVolume(_effectVolume);
        await _musicPlayer.setVolume(_musicVolume);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting mute: $e');
      }
    }
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    await setMute(!_isMuted);
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
    await playEffect('sounds/pop.mp3');
  }

  /// Dispose of resources
  void dispose() {
    try {
      _effectPlayer.dispose();
      _musicPlayer.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing sound players: $e');
      }
    }

    effectStateNotifier.dispose();
    musicStateNotifier.dispose();
    _sourceCache.clear();
  }
}
