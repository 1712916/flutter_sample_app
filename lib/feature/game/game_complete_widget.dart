import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../widgets/diaglog.dart';
import '../../widgets/text.dart';

class GameCompleteWidget extends StatelessWidget with ShowDialog {
  const GameCompleteWidget({
    super.key,
    required this.countStep,
    required this.onPlayAgain,
    required this.onExit,
  });

  final int countStep;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

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
                LKey.gameCompleteTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LKey.gameCompleteDescription.tr(
                  context: context,
                  namedArgs: {'countStep': countStep.toString()},
                ),
                // 'You completed the game in $countStep steps!',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: onPlayAgain,
                    icon: Icon(Icons.replay, color: theme.iconColor),
                    label: LText(
                      LKey.playAgain,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onExit,
                    icon: Icon(Icons.exit_to_app, color: theme.iconColor),
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
}
