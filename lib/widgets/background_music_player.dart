import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/game/cubit/game_setting_cubit.dart';

import '../feature/game/cubit/background_music_cubit.dart';

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
  bool _isAppInForeground = true;
  bool _wasMusicPlayingBeforeBackground = false;

  BackgroundMusicCubit get _backgroundMusicCubit => context.read<BackgroundMusicCubit>();

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
    stopMusic();

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
        stopMusic();
        break;
    }
  }

  // Bắt đầu phát nhạc nếu nhạc được bật trong cài đặt
  void _startMusicIfEnabled() {
    try {
      if (musicEnabled && !_backgroundMusicCubit.isMusicPlaying()) {
        playMusic();
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

      if (gameSettingState.musicEnabled && !_backgroundMusicCubit.isMuted()) {
        if (kDebugMode) {
          print('🎵 BackgroundMusicPlayer: Resuming background music: ${gameSettingState.currentMusic}');
        }

        // Thêm độ trễ nhỏ để đảm bảo ứng dụng đã hoàn toàn khôi phục
        // Điều này giúp trên Android, nơi focus âm thanh có thể không khả dụng ngay lập tức
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted && _isAppInForeground) {
            _backgroundMusicCubit.playMusic(gameSettingState.currentMusic);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicPlayer: Error resuming music: $e');
      }
    }
  }

  bool get musicEnabled {
    return context.read<GameSettingCubit>().state.musicEnabled;
  }

  // Phát nhạc (có thể gọi từ bên ngoài thông qua GlobalKey)
  void playMusic([String? musicFile]) {
    if (mounted && musicEnabled) {
      _backgroundMusicCubit.playMusic(getTrackToPlay(musicFile));
    }
  }

  String getTrackToPlay([String? musicFile]) {
    final gameSettingState = context.read<GameSettingCubit>().state;
    return musicFile ?? widget.defaultMusicFile ?? gameSettingState.currentMusic;
  }

  // Dừng nhạc (có thể gọi từ bên ngoài thông qua GlobalKey)
  void stopMusic() {
    _backgroundMusicCubit.stopMusic();
  }

  // Chuyển bài hát (có thể gọi từ bên ngoài thông qua GlobalKey)
  void switchMusic(String musicFile) {
    if (mounted) {
      final gameSettingState = context.read<GameSettingCubit>().state;

      if (gameSettingState.musicEnabled) {
        _backgroundMusicCubit.switchMusic(musicFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Đơn giản trả về child widget
    return widget.child;
  }
}
