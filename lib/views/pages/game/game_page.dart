import 'dart:math';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:meow_app/views/pages/game/test_game_page.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../cubits/cubits.dart';
import '../../../helpers/helpers.dart';
import '../../../resources/resources.dart';
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
    } else if (true) {
      cubit.openErrorPage();
    }
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
  final ConfettiController confettiController = ConfettiController(duration: const Duration(seconds: 3));

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
          case LoadStatus.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(LocaleKeys.importImageOption.tr()),
                  const _OpenImageFileWidget(),
                ],
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
                                icon: Tooltip(
                                  message: LocaleKeys.reScrambleImage.tr(),
                                  child: const Icon(Icons.refresh),
                                ),
                              ),
                              const _OpenImageFileWidget(),
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
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      key: UniqueKey(),
                      confettiController: confettiController,
                      numberOfParticles: 30, // number of particles to emit
                      gravity: 0.05, // gravity - or fall speed
                      shouldLoop: false,
                      blastDirection: pi / 2,
                      colors: const [Colors.green, Colors.blue, Colors.pink], // manually specify the colors to be used
                    ),
                  ),
                ],
              ),
            );
          default:
            return const SizedBox();
        }
      },
      listener: (context, state) async {
        if (state.isComplete ?? false) {
          confettiController.play();
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TestGamePage(image: state.image!),
          ));
        }
      },
      listenWhen: (oldState, newState) {
        return oldState.isComplete != newState.isComplete;
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
          child: _MemoryImage(image: state.image!),
          width: MediaQuery.of(context).size.width / 3,
        );
      },
    );
  }
}

class _MemoryImage extends StatefulWidget {
  const _MemoryImage({Key? key, required this.image}) : super(key: key);

  final imglib.Image image;

  @override
  State<_MemoryImage> createState() => _MemoryImageState();
}

class _MemoryImageState extends State<_MemoryImage> {
  Widget? w = null;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    w = Image.memory(imglib.encodePng(widget.image) as Uint8List);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return w ?? const Placeholder();
  }
}

class _PlayArea extends StatefulWidget {
  const _PlayArea({Key? key}) : super(key: key);

  @override
  State<_PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<_PlayArea> {
  final ValueNotifier<double> scaleNotifier = ValueNotifier(0.7);

  @override
  void dispose() {
    scaleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) => previous.cells != current.cells,
      builder: (context, state) {
        if (state.cells == null) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<GameCubit>();

        return ValueListenableBuilder<double>(
          valueListenable: scaleNotifier,
          builder: (context, value, _) {
            return Stack(
              children: [
                Transform.scale(
                  scale: value,
                  child: CustomPaint(
                    foregroundPainter: _BoarderPainter(y: 3, x: 3, color: Colors.orangeAccent),
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
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Slider(
                    value: value,
                    onChanged: (value) {
                      scaleNotifier.value = value;
                    },
                    min: 0.5,
                    max: 1.0,
                    divisions: 5,
                    activeColor: Theme.of(context).primaryColor,
                    label: '${value * 100}%',
                    thumbColor: Theme.of(context).focusColor,
                  ),
                ),
              ],
            );
          },
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
    return true;
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

class _OpenImageFileWidget extends StatelessWidget {
  const _OpenImageFileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () async {
            await PermissionHelper.request(Permission.camera, onGranted: () async {
              XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 90);
              if (imageFile != null) {
                cubit.initByFilePath(imageFile.path);
              }
            });
          },
          icon: Tooltip(
            message: LocaleKeys.takeAPhoto.tr(),
            child: const Icon(
              Icons.monochrome_photos,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            await PermissionHelper.request(Permission.photos, onGranted: () async {
              XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
              if (imageFile != null) {
                cubit.initByFilePath(imageFile.path);
              }
            });
          },
          icon: Tooltip(
            message: LocaleKeys.importFromPhoto.tr(),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
