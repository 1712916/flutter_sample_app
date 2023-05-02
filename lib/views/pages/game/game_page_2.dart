import 'dart:math';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:meow_app/cubits/game/util/image_util.dart';
import 'package:meow_app/views/pages/game/cell_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../cubits/cubits.dart';
import '../../../helpers/helpers.dart';
import '../../../resources/resources.dart';
import 'directional_control_widget.dart';
import 'game_manager.dart';

class GamePage2 extends StatefulWidget {
  const GamePage2({Key? key, this.url, this.path}) : super(key: key);

  final String? url;
  final String? path;

  @override
  _GamePage2State createState() => _GamePage2State();
}

class _GamePage2State extends State<GamePage2> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _GameContent(
        url: widget.url,
        path: widget.path,
      ),
    );
  }
}

class _GameContent extends StatefulWidget {
  _GameContent({Key? key, this.url, this.path}) : super(key: key);

  final String? url;
  final String? path;

  @override
  State<_GameContent> createState() => _GameContentState();
}

class _GameContentState extends State<_GameContent> {
  imglib.Image? _image;

  LoadStatus _loadStatus = LoadStatus.init;

  final GlobalKey<_PlayAreaState> _gameBoardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.path != null) {
    } else if (widget.url != null) {
      initByUrl(widget.url!);
    } else {
      _loadStatus = LoadStatus.error;
    }
  }

  void initByUrl(String url) async {
    setImage(await ImageUtil().getCroppedFile(url, GameManager.heightRatio));
  }

  void initByFilePath(String path) async {
    setImage(await ImageUtil().getCroppedFile('', GameManager.heightRatio, path: path));
  }

  void setImage(imglib.Image? image) {
    if (image != null) {
      _image = image;
      _loadStatus = LoadStatus.loaded;
      setState(() {});
    }
  }

  final ConfettiController confettiController = ConfettiController(duration: const Duration(seconds: 3));

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadStatus) {
      case LoadStatus.init:
        return const SizedBox();
      case LoadStatus.loading:
        return _loadingWidget();
      case LoadStatus.error:
        return _errorWidget();
      case LoadStatus.loaded:
        GameManager.cellSize = MediaQuery.of(context).size.width / GameManager.widthRatio;
        return _gameWidget();
      default:
        return const SizedBox();
    }
  }

  SafeArea _gameWidget() {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Image(image: _image!),
                  Row(
                    children: [
                      IconButton(
                        onPressed: reloadScramble,
                        icon: Tooltip(
                          message: LocaleKeys.reScrambleImage.tr(),
                          child: const Icon(Icons.refresh),
                        ),
                      ),
                      _OpenImageFileWidget(onGetPath: initByFilePath),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.black),
              Expanded(
                child: _PlayArea(
                  key: _gameBoardKey,
                  image: _image!,
                  onComplete: () => confettiController.play(),
                ),
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
  }

  Center _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LocaleKeys.importImageOption.tr()),
          _OpenImageFileWidget(onGetPath: initByFilePath),
        ],
      ),
    );
  }

  Center _loadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.grey,
      ),
    );
  }

  void reloadScramble() {
    _gameBoardKey.currentState?.reScramble();
  }
}

class _Image extends StatelessWidget {
  const _Image({Key? key, required this.image}) : super(key: key);

  final imglib.Image image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: _MemoryImage(image: image),
      width: MediaQuery.of(context).size.width / 3,
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

  @override
  void didUpdateWidget(covariant _MemoryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _loadImage();
    }
  }

  void _loadImage() async {
    w = Image.memory(imglib.encodePng(widget.image) as Uint8List);
  }

  @override
  Widget build(BuildContext context) {
    return w ?? const Placeholder();
  }
}

class _PlayArea extends StatefulWidget {
  const _PlayArea({
    Key? key,
    required this.image,
    this.onComplete,
  }) : super(key: key);

  final imglib.Image image;
  final VoidCallback? onComplete;

  @override
  State<_PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<_PlayArea> {
  final ValueNotifier<double> scaleNotifier = ValueNotifier(0.7);

  EmptyBox emptyBox = EmptyBox(x: 0, y: 0);

  late GameMatrix gameMatrix;

  List<List<GlobalKey<CellWidgetState>>> cellMatrix = [
    [
      GlobalKey(),
      GlobalKey(),
      GlobalKey(),
    ],
    [
      GlobalKey(),
      GlobalKey(),
      GlobalKey(),
    ],
    [
      GlobalKey(),
      GlobalKey(),
      GlobalKey(),
    ],
  ];

  Map<String, GlobalKey<CellWidgetState>> moveTracking = {};

  List<Widget> _getCell() {
    final int imageCellWidth = (widget.image.width / GameManager.widthRatio).floor();
    final int imageCellHeight = (widget.image.height / GameManager.heightRatio).floor();
    List<Widget> c = [];
    for (int i = 0; i < gameMatrix.length; i++) {
      for (int j = 0; j < gameMatrix[i].length; j++) {
        c.add(CellWidget(
          key: cellMatrix[i][j],
          size: GameManager.gameBoardWidth / GameManager.widthRatio,
          jumpSize: GameManager.gameBoardWidth / GameManager.widthRatio,
          destination: gameMatrix[i][j],
          child: RenderImage(
            imageCellHeight: imageCellHeight,
            imageCellWidth: imageCellWidth,
            cellPosition: gameMatrix[i][j],
            image: widget.image,
          ),
        ));

        moveTracking[gameMatrix[i][j].getKey()] = cellMatrix[i][j];
      }
    }
    return c;
  }

  @override
  void dispose() {
    scaleNotifier.dispose();
    super.dispose();
  }

  void validate() {
    for (var r in gameMatrix) {
      for (var c in r) {
        if (!c.validate()) {
          return;
        }
      }
    }
    widget.onComplete?.call();
  }

  @override
  void initState() {
    super.initState();
    setUp();
  }

  @override
  void didUpdateWidget(covariant _PlayArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      setUp();
    }
  }

  void setUp() {
    final game = Game()..setUp();
    gameMatrix = game.gameMatrix;
    emptyBox = game.emptyBox;
  }

  void reScramble() {
    setUp();
    setState(() {});
  }

  void _moveLeft() {
    final k = moveTracking[emptyBox.getRightKey()];
    if (k != null) {
      k.currentState?.moveBack();
      moveTracking[emptyBox.getKey()] = k;
      emptyBox.moveRight();
    }
  }

  void _moveRight() {
    final k = moveTracking[emptyBox.getLeftKey()];
    if (k != null) {
      k.currentState?.moveForward();
      moveTracking[emptyBox.getKey()] = k;
      emptyBox.moveLeft();
    }
  }

  void _moveDown() {
    final k = moveTracking[emptyBox.getUpKey()];
    if (k != null) {
      k.currentState?.moveDown();
      moveTracking[emptyBox.getKey()] = k;
      emptyBox.moveUp();
      if (emptyBox.getKey() == '0_-1') {
        validate();
      }
    }
  }

  void _moveUp() {
    final k = moveTracking[emptyBox.getDownKey()];
    if (k != null) {
      k.currentState?.moveUp();
      moveTracking[emptyBox.getKey()] = k;
      emptyBox.moveDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: scaleNotifier,
      builder: (context, value, _) {
        return DirectionalControlWidget(
          moveLeft: _moveLeft,
          moveRight: _moveRight,
          moveDown: _moveDown,
          moveUp: _moveUp,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: value,
                child: CustomPaint(
                  foregroundPainter: _BoarderPainter(y: 3, x: 3, color: Colors.orangeAccent),
                  child: SizedBox(
                    width: GameManager.gameBoardWidth,
                    height: GameManager.gameBoardHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: _getCell(),
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
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color ?? Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Path path = Path();
    path.moveTo(0, -size.height / y);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    path.lineTo(size.width / x, 0);
    path.lineTo(size.width / x, -size.height / y);
    path.lineTo(-1, -size.height / y);
    canvas.drawPath(path, paint);
  }
}

class _OpenImageFileWidget extends StatelessWidget {
  const _OpenImageFileWidget({
    Key? key,
    this.onGetPath,
  }) : super(key: key);

  final ValueChanged<String>? onGetPath;

  void _openImage(ImageSource imageSource) async {
    XFile? imageFile = await ImagePicker().pickImage(source: imageSource, imageQuality: 90);
    if (imageFile != null) {
      onGetPath?.call(imageFile.path);
    }
  }

  void _getPermission(Permission permission, Function onGranted) async {
    await PermissionHelper.request(permission, onGranted: onGranted);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _getPermission(Permission.camera, () => _openImage(ImageSource.camera)),
          icon: Tooltip(
            message: LocaleKeys.takeAPhoto.tr(),
            child: const Icon(
              Icons.monochrome_photos,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _getPermission(Permission.photos, () => _openImage(ImageSource.gallery)),
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

class Game {
  GameMatrix gameMatrix = [
    [
      GameMatrixItem(x: 0, y: 0)
        ..sx = 0
        ..sy = -1,
      GameMatrixItem(y: 0, x: 1),
      GameMatrixItem(y: 0, x: 2),
    ],
    [
      GameMatrixItem(y: 1, x: 0),
      GameMatrixItem(y: 1, x: 1),
      GameMatrixItem(y: 1, x: 2),
    ],
    [
      GameMatrixItem(y: 2, x: 0),
      GameMatrixItem(y: 2, x: 1),
      GameMatrixItem(y: 2, x: 2),
    ],
  ];
  EmptyBox emptyBox = EmptyBox(x: 0, y: 0);
  Map<String, GameMatrixItem> moveTracking = {};

  void setUp() {
    for (int i = 0; i < gameMatrix.length; i++) {
      for (int j = 0; j < gameMatrix[i].length; j++) {
        moveTracking[gameMatrix[i][j].getKey()] = gameMatrix[i][j];
      }
    }
    var moveTypes = genMoveList();
    void _move(MoveType moveType) async {
      switch (moveType) {
        case MoveType.left:
          final r = moveTracking[emptyBox.getRightKey()];
          if (r != null) {
            r.sx--;
            moveTracking[emptyBox.getKey()] = r;
            emptyBox.moveRight();
          }

          break;
        case MoveType.right:
          final r = moveTracking[emptyBox.getLeftKey()];
          if (r != null) {
            r.sx++;
            moveTracking[emptyBox.getKey()] = r;
            emptyBox.moveLeft();
          }

          break;
        case MoveType.up:
          final r = moveTracking[emptyBox.getDownKey()];
          if (r != null) {
            r.sy--;
            moveTracking[emptyBox.getKey()] = r;
            emptyBox.moveDown();
          }

          break;
        case MoveType.down:
          final r = moveTracking[emptyBox.getUpKey()];
          if (r != null) {
            r.sy++;
            moveTracking[emptyBox.getKey()] = r;
            emptyBox.moveUp();
          }
          break;
      }
    }

    moveTypes.forEach(_move);
  }
}
