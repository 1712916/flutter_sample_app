import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:share_plus/share_plus.dart';

import '../../../widgets/widgets.dart';

class GameCompleteWidget extends StatelessWidget with ShowDialog {
  const GameCompleteWidget({
    super.key,
    required this.countStep,
    required this.onPlayAgain,
    required this.onExit,
    this.referralCode = 'meow_app_with_love',
  });

  final int countStep;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;
  final String referralCode;

  void _shareAppLink(BuildContext context) {
    final url = 'https://bossxomlut.github.io/meow/?ref=$referralCode';
    final message = LKey.shareGameDescription.tr(
      context: context,
      namedArgs: {
        'countStep': countStep.toString(),
        'url': url,
      },
    );

    Share.share(message);
  }

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
                style: const TextStyle(
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _shareAppLink(context),
                icon: Icon(Icons.share, color: theme.iconColor),
                label: LText(LKey.share, style: theme.textTheme.titleMedium),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
