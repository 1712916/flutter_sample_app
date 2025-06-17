import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/feature/game/cubit/background_music_cubit.dart';
import 'package:meow_app/feature/game/cubit/game_setting_cubit.dart';
import 'package:meow_app/feature/game/sound/game_sound_manager.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/resources/locale/locale_keys.dart';
import 'package:meow_app/widgets/text.dart';

class MusicSelectionWidget extends StatefulWidget {
  const MusicSelectionWidget({Key? key}) : super(key: key);

  @override
  State<MusicSelectionWidget> createState() => _MusicSelectionWidgetState();
}

class _MusicSelectionWidgetState extends State<MusicSelectionWidget> {
  final GameSoundManager _gameSoundManager = GameSoundManager();
  List<String> _availableTracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMusicTracks();
  }

  Future<void> _loadMusicTracks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tracks = await _gameSoundManager.getAvailableMusicFiles();
      setState(() {
        _availableTracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _availableTracks = [
          'night-happiness.mp3',
          'just-relax.mp3',
        ];
        _isLoading = false;
      });
    }
  }

  // Format display name from filename
  String _formatTrackName(String filename) {
    // Remove .mp3 extension
    final name = filename.replaceAll('.mp3', '');
    // Replace dashes with spaces
    final spacedName = name.replaceAll('-', ' ');
    // Capitalize each word
    return spacedName.split(' ').map((word) {
      if (word.isNotEmpty) {
        return '${word[0].toUpperCase()}${word.substring(1)}';
      }
      return '';
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textColor2;

    return BlocBuilder<GameSettingCubit, GameSettingState>(
      builder: (context, state) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ExpansionTile(
          shape: const RoundedRectangleBorder(),
          tilePadding: const EdgeInsets.only(right: 20),
          title: ListTile(
            title: LText(
              LKey.chooseMusicTrack,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: Icon(
              Icons.music_note,
              color: theme.iconColor,
            ),
          ),
          children: [
            ..._availableTracks.map(
              (track) {
                final isSelected = state.currentMusic == track;

                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.music_note : Icons.music_note_outlined,
                    color: theme.iconColor,
                  ),
                  title: Text(
                    _formatTrackName(track),
                    style: theme.textTheme.bodyLarge,
                  ),
                  onTap: () {
                    if (kDebugMode) {
                      print('🎵 Music track selected: $track - Current music: ${state.currentMusic}');
                    }

                    // Luôn thay đổi nhạc khi người dùng chọn bài hát, bất kể đang bật hay tắt
                    final settingCubit = context.read<GameSettingCubit>();
                    final musicCubit = context.read<BackgroundMusicCubit>();

                    // Gọi changeMusic sẽ cập nhật lưu trữ
                    settingCubit.changeMusic(track);

                    // Nếu nhạc đang bật, sử dụng BackgroundMusicCubit để chuyển nhạc
                    if (state.musicEnabled) {
                      musicCubit.switchMusic(track);
                    } else {
                      // Hiển thị thông báo nếu nhạc đang tắt
                      if (kDebugMode) {
                        print('🎵 Music is disabled, track selected but not playing');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã chọn bài hát. Bật nhạc để nghe.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  trailing: isSelected ? const Icon(Icons.check) : null,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
