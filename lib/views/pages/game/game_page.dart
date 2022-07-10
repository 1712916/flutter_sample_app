import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as imglib;

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
    return _GameContent();
  }

  @override
  PreferredSizeWidget? buildAppbar(BuildContext context) {
    return AppBar();
  }

  @override
  GameCubit get cubit => widget.cubit;
}

class _GameContent extends StatelessWidget {
  _GameContent({Key? key}) : super(key: key);

  final ValueNotifier<bool> viewContent = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      buildWhen: (oldState, currentState) {
        return oldState.loadStatus != currentState.loadStatus;
      },
      builder: (context, state) {
        final cubit = context.read<GameCubit>();

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
            return SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _Image(),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              cubit.reloadScramble();
                            },
                            icon: const Tooltip(
                              message: 'Re-Scramble cells of image',
                              child: Icon(Icons.refresh),
                            ),
                          ),
                          IconButton(
                            onPressed: () {

                            },
                            icon: const Tooltip(
                              message: 'Re-Scramble cells of image',
                              child: Icon(Icons.monochrome_photos),
                            ),
                          ),
                          IconButton(
                            onPressed: () {

                            },
                            icon: const Tooltip(
                              message: 'Re-Scramble cells of image',
                              child: Icon(Icons.add_photo_alternate_outlined ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black),
                  const Expanded(
                    child: _PlayArea(),
                  ),
                ],
              ),
            );

            return ValueListenableBuilder<bool>(
              valueListenable: viewContent,
              builder: (context, value, _) {
                return Stack(
                  children: [
                    SafeArea(
                      child: Column(
                        children: [
                          _Image(),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    cubit.reloadScramble();
                                  },
                                  icon: Icon(Icons.onetwothree))
                            ],
                          ),
                          const Divider(color: Colors.black),
                          Expanded(
                            child: _PlayArea(),
                          ),
                        ],
                      ),
                    ),
                    // value ? const SizedBox() : Container(
                    //   width: double.maxFinite,
                    //   height: double.maxFinite,
                    //   color: Colors.transparent,
                    //   child: Center(
                    //     child: Container(
                    //       padding: const EdgeInsets.all(16),
                    //       decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.grey.withOpacity(0.5)),
                    //       child: Text('Please waiting'),
                    //     ),
                    //   ),
                    // ),
                  ],
                );
              },
            );

          default:
            return const SizedBox();
        }
      },
      listener: (context, state) async {
        if (state.loadStatus == LoadStatus.loaded) {
          // final cubit = context.read<GameCubit>();
          // final gameManager = cubit.gameManager;
          // gameManager.controller(MoveType.up);
          // viewContent.value = true;
        }
      },
      listenWhen: (oldState, newState) {
        return oldState.loadStatus != newState.loadStatus;
      },
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) => previous.image != current.image,
      builder: (context, state) {
        if (state.image == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          child: Image.memory(imglib.encodePng(state.image!) as Uint8List),
          width: MediaQuery.of(context).size.width / 3,
        );
      },
    );
  }
}

class _PlayArea extends StatelessWidget {
  const _PlayArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) => previous.cells != current.cells,
      builder: (context, state) {
        if (state.cells == null) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<GameCubit>();
        final gameManager = cubit.gameManager;
        return Transform.scale(
          scale: 0.5,
          child: DirectionalControlWidget(
            moveLeft: () => gameManager.controller(MoveType.left),
            moveRight: () => gameManager.controller(MoveType.right),
            moveDown: () => gameManager.controller(MoveType.down),
            moveUp: () => gameManager.controller(MoveType.up),
            child: SizedBox(
              width: GameManager.gameBoardWidth,
              height: GameManager.gameBoardHeight,
              child: Stack(
                fit: StackFit.expand,
                children: state.cells!,
              ),
            ),
          ),
        );
      },
    );
  }
}
