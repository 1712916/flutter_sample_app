import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/game/cubit/game_setting_cubit.dart';
import 'package:meow_app/feature/game/sound/game_sound_manager.dart';

/// Widget quản lý phát nhạc nền và xử lý vòng đời ứng dụng
///
/// Widget này giúp quản lý phát nhạc nền và tự động xử lý việc dừng/tiếp tục
/// nhạc khi ứng dụng chuyển giữa nền và tiền cảnh
class BackgroundMusicPlayer extends StatefulWidget {
  final Widget child;

  /// Có cho phép tự động khôi phục nhạc khi ứng dụng về tiền cảnh không
  final bool autoResumeOnForeground;

  /// Có phát nhạc ngay khi khởi tạo không
  final bool playOnInit;

  /// Bài hát mặc định để phát (nếu không có thì sẽ lấy từ setting)
  final String? defaultMusicFile;

  /// Global key để truy cập từ bên ngoài
  static final GlobalKey<BackgroundMusicPlayerState> globalKey = GlobalKey<BackgroundMusicPlayerState>();

  const BackgroundMusicPlayer({
    Key? key,
    required this.child,
    this.autoResumeOnForeground = true,
    this.playOnInit = true,
    this.defaultMusicFile,
  }) : super(key: key);

  /// Helper method để dễ dàng truy cập từ bất kỳ đâu
  static BackgroundMusicPlayerState? of(BuildContext context) {
    return context.findAncestorStateOfType<BackgroundMusicPlayerState>();
  }

  /// Get the BackgroundMusicPlayerState instance directly using the global key
  static BackgroundMusicPlayerState? getInstance() {
    return globalKey.currentState;
  }

  @override
  State<BackgroundMusicPlayer> createState() => BackgroundMusicPlayerState();
}

class BackgroundMusicPlayerState extends State<BackgroundMusicPlayer> with WidgetsBindingObserver {
  final GameSoundManager _gameSoundManager = GameSoundManager();
  bool _isAppInForeground = true;
  bool _wasMusicPlayingBeforeBackground = false;

  @override
  void initState() {
    super.initState();
    // Đăng ký observer cho lifecycle của ứng dụng
    WidgetsBinding.instance.addObserver(this);

    // Phát nhạc ngay nếu được cấu hình và nhạc được bật trong cài đặt
    if (widget.playOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startMusicIfEnabled();
      });
    }
  }

  @override
  void dispose() {
    // Hủy đăng ký observer
    WidgetsBinding.instance.removeObserver(this);

    // Dừng nhạc nền khi widget bị hủy
    _gameSoundManager.stopBackgroundMusic();

    super.dispose();
  }

  // Xử lý thay đổi trạng thái vòng đời của ứng dụng
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (kDebugMode) {
      print('🎵 BackgroundMusicPlayer: App lifecycle state changed to: $state');
    }

    switch (state) {
      case AppLifecycleState.resumed:
        // Ứng dụng đang ở tiền cảnh
        _isAppInForeground = true;
        // Khôi phục nhạc nếu đã phát trước đó và được cấu hình tự động khôi phục
        if (widget.autoResumeOnForeground) {
          _resumeMusic();
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _gameSoundManager.stopBackgroundMusic();

        // // Ứng dụng đang ở nền hoặc không hiển thị
        // _isAppInForeground = false;
        // // Lưu trạng thái phát nhạc trước khi dừng
        // _wasMusicPlayingBeforeBackground = _gameSoundManager.isMusicPlaying();
        //
        // if (_wasMusicPlayingBeforeBackground) {
        //   if (kDebugMode) {
        //     print('🎵 BackgroundMusicPlayer: App going to background - Stopping music');
        //   }
        //   // Dừng nhạc khi ứng dụng xuống nền
        //
        //   // Kiểm tra lại sau một khoảng thời gian để đảm bảo đã dừng
        //   Future.delayed(Duration(milliseconds: 500), () {
        //     if (_gameSoundManager.isMusicPlaying()) {
        //       if (kDebugMode) {
        //         print('🎵 BackgroundMusicPlayer: Music still playing after background, forcing stop again');
        //       }
        //       _gameSoundManager.stopBackgroundMusic();
        //     }
        //   });
        // }
        break;
    }
  }

  // Bắt đầu phát nhạc nếu nhạc được bật trong cài đặt
  void _startMusicIfEnabled() {
    try {
      final gameSettingState = context.read<GameSettingCubit>().state;

      if (gameSettingState.musicEnabled && !_gameSoundManager.isMusicPlaying()) {
        // Lấy bài hát từ tham số hoặc từ cài đặt
        final musicFile = widget.defaultMusicFile ?? gameSettingState.currentMusic;

        if (kDebugMode) {
          print('🎵 BackgroundMusicPlayer: Starting background music: $musicFile');
        }

        _gameSoundManager.playBackgroundMusic(musicFile);
      }
    } catch (e) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicPlayer: Error starting music: $e');
      }
    }
  }

  // Khôi phục nhạc đã phát trước đó
  void _resumeMusic() {
    try {
      final gameSettingState = context.read<GameSettingCubit>().state;

      if (gameSettingState.musicEnabled && !_gameSoundManager.isMuted()) {
        if (kDebugMode) {
          print('🎵 BackgroundMusicPlayer: Resuming background music: ${gameSettingState.currentMusic}');
        }

        // Thêm độ trễ nhỏ để đảm bảo ứng dụng đã hoàn toàn khôi phục
        // Điều này giúp trên Android, nơi focus âm thanh có thể không khả dụng ngay lập tức
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted && _isAppInForeground) {
            _gameSoundManager.playBackgroundMusic(gameSettingState.currentMusic);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicPlayer: Error resuming music: $e');
      }
    }
  }

  // Start background music if enabled (can be called when entering the game screen)
  void startBackgroundMusic([String? musicFile]) async {
    try {
      if (mounted) {
        final gameSettingState = context.read<GameSettingCubit>().state;

        if (gameSettingState.musicEnabled) {
          final trackToPlay = musicFile ?? widget.defaultMusicFile ?? gameSettingState.currentMusic;

          if (kDebugMode) {
            print('🎵 BackgroundMusicPlayer: Starting background music when entering screen: $trackToPlay');
          }

          _gameSoundManager.playBackgroundMusic(trackToPlay);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicPlayer: Error starting music when entering screen: $e');
      }
    }
  }

  // Phát nhạc (có thể gọi từ bên ngoài thông qua GlobalKey)
  void playMusic([String? musicFile]) {
    if (mounted) {
      final gameSettingState = context.read<GameSettingCubit>().state;

      if (gameSettingState.musicEnabled) {
        final trackToPlay = musicFile ?? widget.defaultMusicFile ?? gameSettingState.currentMusic;

        _gameSoundManager.playBackgroundMusic(trackToPlay);
      }
    }
  }

  // Dừng nhạc (có thể gọi từ bên ngoài thông qua GlobalKey)
  void stopMusic() {
    _gameSoundManager.stopBackgroundMusic();
  }

  // Chuyển bài hát (có thể gọi từ bên ngoài thông qua GlobalKey)
  void switchMusic(String musicFile) {
    if (mounted) {
      final gameSettingState = context.read<GameSettingCubit>().state;

      if (gameSettingState.musicEnabled) {
        _gameSoundManager.switchBackgroundMusic(musicFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Đơn giản trả về child widget
    return widget.child;
  }
}

/// Cách sử dụng BackgroundMusicPlayer trong ứng dụng:
///
/// 1. Sử dụng với BuildContext (được khuyến nghị trong widget):
///    ```dart
///    // Phát nhạc nền
///    context.playBackgroundMusic();
///    // Hoặc chỉ định một bài hát cụ thể
///    context.playBackgroundMusic('night-happiness.mp3');
///
///    // Dừng nhạc nền
///    context.stopBackgroundMusic();
///
///    // Bắt đầu phát nhạc khi vào màn hình
///    context.startBackgroundMusicOnScreen();
///    ```
///
/// 2. Sử dụng với GlobalKey (sử dụng khi không có BuildContext):
///    ```dart
///    // Phát nhạc nền
///    BackgroundMusicPlayer.getInstance()?.playMusic();
///
///    // Dừng nhạc nền
///    BackgroundMusicPlayer.getInstance()?.stopMusic();
///
///    // Chuyển bài hát
///    BackgroundMusicPlayer.getInstance()?.switchMusic('my-music.mp3');
///    ```
///
/// Widget quản lý phát nhạc nền và xử lý vòng đời ứng dụng
