import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/game/cubit/background_music_cubit.dart';
import 'package:meow_app/feature/game/cubit/game_setting_cubit.dart';

/// Widget quản lý nhạc nền tự động theo vòng đời ứng dụng
/// Wrap bất kỳ widget/màn hình nào cần phát nhạc nền với widget này
class BackgroundMusicWidget extends StatefulWidget {
  final Widget child;
  final String? musicTrack;

  const BackgroundMusicWidget({
    Key? key,
    required this.child,
    this.musicTrack,
  }) : super(key: key);

  @override
  State<BackgroundMusicWidget> createState() => _BackgroundMusicWidgetState();
}

class _BackgroundMusicWidgetState extends State<BackgroundMusicWidget> with WidgetsBindingObserver {
  late BackgroundMusicCubit _musicCubit;
  late GameSettingCubit _gameSettingCubit;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _musicCubit = context.read<BackgroundMusicCubit>();
    _gameSettingCubit = context.read<GameSettingCubit>();
    
    // Bắt đầu phát nhạc khi widget được tạo (nếu được phép trong cài đặt)
    _playMusicIfEnabled();
  }

  @override
  void didUpdateWidget(BackgroundMusicWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu track nhạc thay đổi và đang phát, chuyển sang track mới
    if (widget.musicTrack != oldWidget.musicTrack && _musicCubit.isMusicPlaying()) {
      _playMusicIfEnabled();
    }
  }

  /// Xử lý thay đổi trạng thái ứng dụng (ẩn, hiện)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      print('🎵 BackgroundMusicWidget: App lifecycle changed to $state');
    }

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Lưu trạng thái hiện tại và dừng nhạc khi ứng dụng vào nền
        _wasPlaying = _musicCubit.isMusicPlaying();
        if (_wasPlaying) {
          if (kDebugMode) {
            print('🎵 BackgroundMusicWidget: App going to background, stopping music');
          }
          _musicCubit.stopMusic();
        }
        break;
      case AppLifecycleState.resumed:
        // Phát lại nhạc nếu trước đó đang phát và ứng dụng quay lại
        if (_wasPlaying && _gameSettingCubit.state.musicEnabled) {
          if (kDebugMode) {
            print('🎵 BackgroundMusicWidget: App resumed, restarting music');
          }
          _playMusicIfEnabled();
        }
        break;
      case AppLifecycleState.inactive:
        // Không cần xử lý
        break;
    }
  }

  /// Phát nhạc nếu được bật trong cài đặt
  void _playMusicIfEnabled() {
    final gameSettings = _gameSettingCubit.state;
    if (gameSettings.musicEnabled) {
      final trackToPlay = widget.musicTrack ?? gameSettings.currentMusic;
      if (kDebugMode) {
        print('🎵 BackgroundMusicWidget: Playing music track: $trackToPlay');
      }
      _musicCubit.playMusic(trackToPlay);
    } else if (kDebugMode) {
      print('🎵 BackgroundMusicWidget: Music disabled in settings');
    }
  }

  @override
  void dispose() {
    // Dừng nhạc khi widget bị hủy (rời khỏi màn hình)
    if (_musicCubit.isMusicPlaying()) {
      if (kDebugMode) {
        print('🎵 BackgroundMusicWidget: Widget disposed, stopping music');
      }
      _musicCubit.stopMusic();
    }
    
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi cài đặt âm nhạc
    return BlocListener<GameSettingCubit, GameSettingState>(
      listenWhen: (previous, current) => 
        previous.musicEnabled != current.musicEnabled || 
        previous.currentMusic != current.currentMusic,
      listener: (context, state) {
        if (kDebugMode) {
          print('🎵 BackgroundMusicWidget: Game settings changed - Music enabled: ${state.musicEnabled}');
        }
        if (state.musicEnabled) {
          _playMusicIfEnabled();
        } else if (_musicCubit.isMusicPlaying()) {
          _musicCubit.stopMusic();
        }
      },
      child: widget.child,
    );
  }
}

/// Extension để dễ dàng wrap widget với BackgroundMusicWidget
extension BackgroundMusicWidgetExtension on Widget {
  Widget withBackgroundMusic({String? musicTrack}) {
    return BackgroundMusicWidget(
      musicTrack: musicTrack,
      child: this,
    );
  }
}
