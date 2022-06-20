import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/cubits.dart';
import '../base_page/base_page.dart';
import 'directional_control_widget.dart';
import 'game_manager.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key, required this.cubit}) : super(key: key);

  final GameCubit cubit;

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends CustomState<GamePage, GameCubit> {

  @override
  void didChangeDependencies() {
    if (isFirstLoad) {
      GameManager.cellSize = MediaQuery.of(context).size.width / GameManager.widthRatio;
    }
    super.didChangeDependencies();
  }

  @override
  void getPageSettings(arguments) async {
    if (arguments is String) {
      cubit.initByUrl(arguments);
    } else if (true) {}
  }


  @override
  Widget buildContent(BuildContext context) {
    return const _GameContent();
  }

  @override
  PreferredSizeWidget? buildAppbar(BuildContext context) {
    return AppBar();
  }

  @override
  GameCubit get cubit => widget.cubit;
}

class _GameContent extends StatelessWidget {
  const _GameContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        switch (state.loadStatus) {
          case LoadStatus.init:
            return const SizedBox();
          case LoadStatus.loading:
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey,
              ),
            );
          case LoadStatus.loaded:
            final cubit = context.read<GameCubit>();
            final gameManager = cubit.gameManager;
            return SafeArea(
              child: DirectionalControlWidget(
                moveLeft: () => gameManager.controller(MoveType.left),
                moveRight: () => gameManager.controller(MoveType.right),
                moveDown: () => gameManager.controller(MoveType.down),
                moveUp: () => gameManager.controller(MoveType.up),
                child: SizedBox(
                  width: GameManager.gameBoardWidth,
                  height: GameManager.gameBoardHeight,
                  child: Stack(
                    children: cubit.cells,
                  ),
                ),
              ),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}

