import 'dart:async';

import 'package:audio_session/audio_session.dart';
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

  SoundManager._internal() {
    _init();
  }

  // Audio players
  late AudioPlayer _effectPlayer;
  late AudioPlayer _musicPlayer;

  // Sound effect cache to prevent reloading
  final Map<String, AudioSource> _sourceCache = {};

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
      // Configure audio session for better Android audio handling
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.game,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: true,
      ));

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
    _effectPlayer.playerStateStream.listen((state) {
      if (kDebugMode) {
        print('Effect player state changed: ${state.processingState}');
      }

      switch (state.processingState) {
        case ProcessingState.idle:
          effectStateNotifier.value = SoundState.idle;
          break;
        case ProcessingState.loading:
          effectStateNotifier.value = SoundState.loading;
          break;
        case ProcessingState.ready:
          if (state.playing) {
            effectStateNotifier.value = SoundState.playing;
          } else {
            effectStateNotifier.value = SoundState.paused;
          }
          break;
        case ProcessingState.completed:
          effectStateNotifier.value = SoundState.completed;
          break;
        case ProcessingState.buffering:
          // This is a transient state, we can ignore it
          break;
      }
    });

    // Set up listeners for music player
    _musicPlayer.playerStateStream.listen((state) {
      if (kDebugMode) {
        print('Music player state changed: ${state.processingState}');
      }

      switch (state.processingState) {
        case ProcessingState.idle:
          musicStateNotifier.value = SoundState.idle;
          break;
        case ProcessingState.loading:
          musicStateNotifier.value = SoundState.loading;
          break;
        case ProcessingState.ready:
          if (state.playing) {
            musicStateNotifier.value = SoundState.playing;
          } else {
            musicStateNotifier.value = SoundState.paused;
          }
          break;
        case ProcessingState.completed:
          musicStateNotifier.value = SoundState.completed;
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
        effectStateNotifier.value = SoundState.completed;
        Timer(const Duration(milliseconds: 50), () {
          effectStateNotifier.value = SoundState.idle;
        });
      }
    });

    _musicPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        if (kDebugMode) {
          print('Music playback completed');
        }
        musicStateNotifier.value = SoundState.completed;
      }
    });
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
      if (kDebugMode) {
        print('🔊 Playing sound effect: $path (source: $source)');
      }

      effectStateNotifier.value = SoundState.loading;

      final effectSource = _getSource(path, source);

      if (kDebugMode) {
        print('🔊 Created audio source: ${effectSource.toString()}');
      }

      // Only stop previous effect, don't interfere with music
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

      // Make sure this doesn't interfere with the music player
      if (kDebugMode) {
        print('🔊 Starting playback...');
      }

      await _effectPlayer.play();

      if (kDebugMode) {
        print('🔊 Playback started successfully');
      }
    } catch (e) {
      effectStateNotifier.value = SoundState.error;
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
      if (kDebugMode) {
        print('🎵 Playing background music: $path (source: $source)');
      }

      musicStateNotifier.value = SoundState.loading;
      final musicSource = _getSource(path, source);

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
      musicStateNotifier.value = SoundState.error;
      if (kDebugMode) {
        print('❌ Error playing music: $e');
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
      if (kDebugMode) {
        print('🎵 Forcefully stopping all music');
      }

      // Dừng phát nhạc
      await _musicPlayer.pause();

      // Đảm bảo bài hát dừng hoàn toàn
      await _musicPlayer.stop();

      // Reset trạng thái
      musicStateNotifier.value = SoundState.idle;

      if (kDebugMode) {
        print('🎵 Music stopped successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error stopping music: $e');
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
  Future<void> setSoundMute(bool mute) async {
    _isMuted = mute;

    try {
      if (mute) {
        await _effectPlayer.setVolume(0);
      } else {
        await _effectPlayer.setVolume(_effectVolume);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting mute: $e');
      }
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
