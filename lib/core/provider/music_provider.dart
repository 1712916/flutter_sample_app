import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/game/cubit/background_music_cubit.dart';
import 'package:meow_app/feature/game/cubit/game_setting_cubit.dart';
import 'package:meow_app/feature/game/sound/game_sound_manager.dart';

import '../../feature/game/cubit/game_sound_cubit.dart';

/// Widget cung cấp BackgroundMusicCubit và quản lý vòng đời ứng dụng
class MusicProvider extends StatefulWidget {
  final Widget child;
  final String? defaultMusicFile;

  const MusicProvider({
    Key? key,
    required this.child,
    this.defaultMusicFile,
  }) : super(key: key);

  @override
  State<MusicProvider> createState() => _MusicProviderState();
}

late BackgroundMusicCubit musicCubit = BackgroundMusicCubit();

class _MusicProviderState extends State<MusicProvider> {
  late GameSoundCubit _gameSoundCubit;

  @override
  void initState() {
    super.initState();
    _gameSoundCubit = GameSoundCubit();

    // Khởi tạo cubit
    _initializeMusicCubit();
  }

  Future<void> _initializeMusicCubit() async {
    await musicCubit.initialize(defaultTrack: widget.defaultMusicFile);

    if (kDebugMode) {
      print('🎵 MusicProvider: BackgroundMusicCubit initialized');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Khởi tạo lifecycle observer sau khi widget đã được gắn vào cây widget

    // Kết nối BackgroundMusicCubit với GameSettingCubit
    try {
      final gameSettingCubit = context.read<GameSettingCubit>();

      // In thông tin debug
      if (kDebugMode) {
        print('🔄 MusicProvider: Connecting BackgroundMusicCubit to GameSettingCubit');
        print('🔄 MusicProvider: GameSettingCubit state - Music Enabled: ${gameSettingCubit.state.musicEnabled}');
        print('🔄 MusicProvider: GameSettingCubit state - Current Music: ${gameSettingCubit.state.currentMusic}');
      }

      // Thiết lập tham chiếu hai chiều
      gameSettingCubit.setMusicCubit(musicCubit);

      // Không tự động phát nhạc khi khởi tạo nữa
      // Thay vào đó, chúng ta sẽ để các màn hình cụ thể gọi playMusic khi cần
      if (kDebugMode) {
        print('🎵 MusicProvider: Connected to GameSettingCubit, ready to play music when requested');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ MusicProvider: GameSettingCubit not found or error: $e');
      }
    }
  }

  @override
  void dispose() {
    // Dừng nhạc và giải phóng tài nguyên
    if (kDebugMode) {
      print('🎵 MusicProvider: Disposing, stopping music and releasing resources');
    }

    try {
      // Dừng nhạc trực tiếp thông qua GameSoundManager để đảm bảo nó dừng
      final gameSoundManager = GameSoundManager();
      gameSoundManager.stopBackgroundMusic();

      // Sau đó dừng qua Cubit để cập nhật trạng thái
      musicCubit.stopMusic();
    } catch (e) {
      if (kDebugMode) {
        print('🎵 MusicProvider: Error stopping music during dispose: $e');
      }
    }

    // Không cần phải reset _staticRouteObserver vì nó sẽ tồn tại suốt thời gian chạy ứng dụng

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BackgroundMusicCubit>.value(value: musicCubit),
        BlocProvider<GameSoundCubit>.value(value: _gameSoundCubit),
      ],
      child: widget.child,
    );
  }
}

extension MusicProviderX on Widget {
  Widget withMusicProvider({
    String? defaultMusicFile,
  }) {
    return MusicProvider(
      defaultMusicFile: defaultMusicFile,
      child: this,
    );
  }
}
