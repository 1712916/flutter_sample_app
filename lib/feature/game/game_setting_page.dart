import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/feature/base_page.dart';
import 'package:meow_app/feature/game/cubit/game_setting_cubit.dart';
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
    return ListView(
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
                // activeColor: theme.highlightColor2,
                inactiveTrackColor: theme.canvasColor,
                onChanged: (bool value) {
                  context.read<GameSettingCubit>().toggleGameController(value);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
