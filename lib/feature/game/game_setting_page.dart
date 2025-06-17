import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/feature/base_page.dart';
import 'package:meow_app/feature/game/cubit/game_setting_cubit.dart';
import 'package:meow_app/feature/game/widget/music_selection_widget.dart';
import 'package:meow_app/widgets/app_bar.dart';

import '../../resources/theme/theme_data.dart';
import '../../widgets/text.dart';

class GameSettingPage extends StatefulWidget {
  const GameSettingPage({super.key});

  @override
  State<GameSettingPage> createState() => _GameSettingPageState();
}

class _GameSettingPageState extends StateTemplate<GameSettingPage> {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return CustomAppBar(title: LKey.settings.tr(context: context));
  }

  @override
  Widget buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textColor2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Game Control Settings
          IconTitleWidget(
            icon: Icon(
              HugeIcons.strokeRoundedGameController03,
              color: theme.iconColor,
              size: 20,
            ),
            title: LKey.gameControls.tr(context: context),
          ),
          const SizedBox(height: 4),
          Card(
            color: theme.cardColor2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: LText(
                      LKey.gameController,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      HugeIcons.strokeRoundedGameController03,
                      color: theme.iconColor,
                    ),
                    trailing: BlocSelector<GameSettingCubit, GameSettingState, bool>(
                      selector: (state) => state.gameController,
                      builder: (context, isShow) {
                        return Switch(
                          value: isShow,
                          inactiveTrackColor: theme.canvasColor,
                          onChanged: (bool value) {
                            context.read<GameSettingCubit>().toggleGameController(value);
                          },
                        );
                      },
                    ),
                  ),
                  ListTile(
                    title: LText(
                      LKey.emptyBoxFocus,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      HugeIcons.strokeRoundedCenterFocus,
                      color: theme.iconColor,
                    ),
                    trailing: BlocSelector<GameSettingCubit, GameSettingState, bool>(
                      selector: (state) => state.blinkingMarker,
                      builder: (context, isShow) {
                        return Switch(
                          value: isShow,
                          inactiveTrackColor: theme.canvasColor,
                          onChanged: (bool value) {
                            context.read<GameSettingCubit>().toggleBlinkingMarker(value);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sound Settings
          IconTitleWidget(
            icon: Icon(
              HugeIcons.strokeRoundedVolumeHigh,
              color: theme.iconColor,
              size: 20,
            ),
            title: LKey.soundSettings.tr(context: context),
          ),
          const SizedBox(height: 4),
          Card(
            color: theme.cardColor2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: LText(
                      LKey.soundEffects,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      HugeIcons.strokeRoundedVolumeHigh,
                      color: theme.iconColor,
                    ),
                    trailing: BlocSelector<GameSettingCubit, GameSettingState, bool>(
                      selector: (state) => state.soundEnabled,
                      builder: (context, isEnabled) {
                        return Switch(
                          value: isEnabled,
                          inactiveTrackColor: theme.canvasColor,
                          onChanged: (bool value) {
                            context.read<GameSettingCubit>().toggleSoundEnabled(value);
                          },
                        );
                      },
                    ),
                  ),
                  ListTile(
                    title: LText(
                      LKey.backgroundMusic,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: Icon(
                      Icons.music_note,
                      color: theme.iconColor,
                    ),
                    trailing: BlocSelector<GameSettingCubit, GameSettingState, bool>(
                      selector: (state) => state.musicEnabled,
                      builder: (context, isEnabled) {
                        return Switch(
                          value: isEnabled,
                          inactiveTrackColor: theme.canvasColor,
                          onChanged: (bool value) {
                            context.read<GameSettingCubit>().toggleMusicEnabled(value);
                          },
                        );
                      },
                    ),
                  ),
                  // Only show music selection when music is enabled
                  BlocSelector<GameSettingCubit, GameSettingState, bool>(
                    selector: (state) => state.musicEnabled,
                    builder: (context, isMusicEnabled) {
                      if (!isMusicEnabled) return const SizedBox.shrink();
                      return const MusicSelectionWidget();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Copy of IconTitleWidget from setting_page_new.dart
class IconTitleWidget extends StatelessWidget {
  const IconTitleWidget({super.key, required this.icon, required this.title});

  final Widget icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).iconColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
