import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../routers/route.dart';
import '../../widgets/widgets.dart';
import '../image/cubit/image_list_cubit.dart';
import 'auto_play_memory_game.dart';

class AutoPlaySelectionWidget extends StatelessWidget with ShowDialog {
  const AutoPlaySelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24.0),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LText(
                LKey.autoPlay,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LKey.autoPlayDescription.tr(context: context),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Auto-play options
              Column(
                children: [
                  _AutoPlayOption(
                    title: LKey.sortGame.tr(context: context),
                    description: 'Auto-play the sliding puzzle game',
                    icon: Icons.grid_3x3,
                    onTap: () => _startAutoPlay(context, AutoPlayGameType.sortGame),
                    theme: theme,
                  ),
                  const SizedBox(height: 12),
                  _AutoPlayOption(
                    title: LKey.memoryGame.tr(context: context),
                    description: 'Auto-play the memory matching game',
                    icon: Icons.memory,
                    onTap: () => _startAutoPlay(context, AutoPlayGameType.memoryGame),
                    theme: theme,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close, color: theme.iconColor),
                    label: LText(
                      LKey.exit,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startAutoPlay(BuildContext context, AutoPlayGameType gameType) {
    Navigator.of(context).pop();

    switch (gameType) {
      case AutoPlayGameType.sortGame:
        enhancedAutoPlayGameNotifier.enable(AutoPlayGameType.sortGame);
        context.read<ImageListCubit>().reset();
        goToHome();
        break;
      case AutoPlayGameType.memoryGame:
        // For memory game, we use a different approach
        enhancedAutoPlayGameNotifier.enable(AutoPlayGameType.memoryGame);
        context.read<ImageListCubit>().reset();
        goToHome();
        break;
    }
  }
}

class _AutoPlayOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;

  const _AutoPlayOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.highlightColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.highlightColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textColor2.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
