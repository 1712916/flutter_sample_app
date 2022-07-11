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
    return AppBar(
      leading: const BackButton(
        color: Colors.black,
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
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
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _Image(),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  cubit.reloadScramble();
                                },
                                icon: const Tooltip(
                                  message: 'Re-Scramble cells of image',
                                  child: Icon(Icons.refresh),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Tooltip(
                                  message: 'Re-Scramble cells of image',
                                  child: Icon(Icons.monochrome_photos),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Tooltip(
                                  message: 'Re-Scramble cells of image',
                                  child: Icon(Icons.add_photo_alternate_outlined),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black),
                      const Expanded(
                        child: Center(
                          child: _PlayArea(),
                        ),
                      ),
                    ],
                  ),
                  // Align(
                  //   alignment: Alignment.topCenter,
                  //   child: ConfettiWidget(
                  //     key: UniqueKey(),
                  //     confettiController: confettiController,
                  //     numberOfParticles: 30, // number of particles to emit
                  //     gravity: 0.05, // gravity - or fall speed
                  //     shouldLoop: true,
                  //     blastDirection: pi/2,
                  //     colors: const [
                  //       Colors.green,
                  //       Colors.blue,
                  //       Colors.pink
                  //     ], // manually specify the colors to be used
                  //   ),
                  // ),
                ],
              ),
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

        return Transform.scale(
          scale: 0.7,
          child: CustomPaint(
            foregroundPainter: _BoarderPainter(y: 4, x: 3, color: Colors.orangeAccent),
            child: SizedBox(
              width: GameManager.gameBoardWidth,
              height: GameManager.gameBoardHeight,
              child: DirectionalControlWidget(
                moveLeft: () => cubit.controller(MoveType.left),
                moveRight: () => cubit.controller(MoveType.right),
                moveDown: () => cubit.controller(MoveType.down),
                moveUp: () => cubit.controller(MoveType.up),
                child: ColoredBox(
                  color: Colors.transparent,
                  child: Stack(
                    children: state.cells!,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BoarderPainter extends CustomPainter {
  final int y;
  final int x;
  final Color? color;

  _BoarderPainter({required this.y, required this.x, this.color});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color ?? Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height / y);
    path.moveTo(-1, 0);
    path.lineTo(size.width / x, 0);
    path.lineTo(size.width / x, size.height / y);
    path.lineTo(size.width + 1, size.height / y);
    canvas.drawPath(path, paint);
  }
}
