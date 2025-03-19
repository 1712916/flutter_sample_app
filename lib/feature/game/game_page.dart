import 'dart:math';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/widgets/custom_dropdown_only_child.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../resources/resources.dart';
import '../../../widgets/widgets.dart';
import '../../core/index.dart';
import 'cell_widget.dart';
import 'directional_control_widget.dart';
import 'game_manager.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    Key? key,
    this.image,
  }) : super(key: key);

  final imglib.Image? image;

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  ThemeData get theme => Theme.of(context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(
          //     Icons.settings,
          //     color: theme.iconColor,
          //   ),
          // ),
        ],
      ),
      body: Builder(
        builder: (context) {
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
        },
      ),
    );
  }

  imglib.Image? _image;

  LoadStatus _loadStatus = LoadStatus.init;

  final GlobalKey<_PlayAreaState> _gameBoardKey = GlobalKey();

  int gameSize = 3;

  @override
  void initState() {
    super.initState();
    setImage(widget.image);
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
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      GameMatrixLevel(
                        onTapAction: (x) {
                          gameSize = x;
                          setState(() {});
                        },
                      ),
                      ZoomViewRange(
                        initialZoomLevel: () => _gameBoardKey.currentState?.zoomLevel ?? 0.7,
                        onZoom: (value) {
                          _gameBoardKey.currentState?.setZoom(value);
                        },
                      ),
                      IconButton(
                        onPressed: reloadScramble,
                        icon: Tooltip(
                          message: LKey.reScrambleImage.tr(),
                          child: Icon(
                            HugeIcons.strokeRoundedRefresh,
                            color: theme.iconColor,
                          ),
                        ),
                      ),
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
                  gameSize: gameSize,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              key: UniqueKey(),
              confettiController: confettiController,
              numberOfParticles: 30,
              // number of particles to emit
              gravity: 0.05,
              // gravity - or fall speed
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
          Text(LKey.importImageOption.tr()), // _OpenImageFileWidget(onGetPath: initByFilePath),
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
    this.gameSize = 3,
  }) : super(key: key);

  final imglib.Image image;
  final VoidCallback? onComplete;
  final int gameSize;

  @override
  State<_PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<_PlayArea> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  final ValueNotifier<double> scaleNotifier = ValueNotifier(0.7);

  int get gameSize => widget.gameSize;

  void setZoom(double value) {
    scaleNotifier.value = value;
  }

  double get zoomLevel => scaleNotifier.value;

  EmptyBox emptyBox = EmptyBox(x: 0, y: 0);

  late GameMatrix gameMatrix;

  List<List<GlobalKey<CellWidgetState>>> cellMatrix = [];

  Map<String, GlobalKey<CellWidgetState>> moveTracking = {};

  List<Widget> _getCell() {
    final int imageCellWidth = (widget.image.width / gameSize).floor();
    final int imageCellHeight = (widget.image.height / gameSize).floor();
    List<Widget> c = [];
    for (int i = 0; i < gameMatrix.length; i++) {
      for (int j = 0; j < gameMatrix[i].length; j++) {
        c.add(CellWidget(
          key: cellMatrix[i][j],
          size: GameManager.gameBoardWidth / gameSize,
          jumpSize: GameManager.gameBoardWidth / gameSize,
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
    setUpMatrix();
  }

  @override
  void didUpdateWidget(covariant _PlayArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image || oldWidget.gameSize != widget.gameSize) {
      setUp();
    }

    if (oldWidget.gameSize != widget.gameSize) {
      setUpMatrix();
    }
  }

  void setUpMatrix() {
    cellMatrix = List.generate(gameSize, (i) {
      return List.generate(gameSize, (j) {
        return GlobalKey<CellWidgetState>();
      });
    });
  }

  void setUp() {
    final game = Game(size: gameSize)..initializeGame();
    gameMatrix = game.gameMatrix;
    emptyBox = game.emptyBox;
  }

  bool isScrambling = false;

  void reScramble() {
    if (isScrambling) {
      return;
    }

    isScrambling = true;
    setUp();
    isScrambling = false;
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
                  foregroundPainter: _BoarderPainter(
                    y: gameSize,
                    x: gameSize,
                    color: Theme.of(context).highlightColor2,
                  ),
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
            message: LKey.takeAPhoto.tr(),
            child: const Icon(
              Icons.monochrome_photos,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _getPermission(Permission.photos, () => _openImage(ImageSource.gallery)),
          icon: Tooltip(
            message: LKey.importFromPhoto.tr(),
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
  late List<List<GameMatrixItem>> gameMatrix;
  late EmptyBox emptyBox;
  Map<String, GameMatrixItem> moveTracking = {};
  final int size; // Kích thước bảng N x N

  Game({required this.size}) {
    initializeGame();
  }

  void initializeGame() {
    gameMatrix = List.generate(size, (y) {
      return List.generate(size, (x) {
        return GameMatrixItem(x: x, y: y);
      });
    });

    // Đặt vị trí ô trống ban đầu
    emptyBox = EmptyBox(x: 0, y: 0);
    gameMatrix[0][0].sx = 0;
    gameMatrix[0][0].sy = -1;

    // Khởi tạo moveTracking
    for (var row in gameMatrix) {
      for (var item in row) {
        moveTracking[item.getKey()] = item;
      }
    }

    // Tạo danh sách di chuyển
    var moveTypes = genMoveList();
    moveTypes.forEach(_move);
  }

  void _move(MoveType moveType) {
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
}

class GameMatrixLevel extends StatefulWidget {
  const GameMatrixLevel({super.key, required this.onTapAction});

  final ValueChanged<int> onTapAction;

  @override
  State<GameMatrixLevel> createState() => _GameMatrixLevelState();
}

class _GameMatrixLevelState extends State<GameMatrixLevel> {
  final List<int> items = [
    3,
    4,
    5,
    6,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomDropdownButton<int>(
      initial: 0,
      constraints: const BoxConstraints(
        minWidth: 100,
      ),
      hideDecoration: true,
      title: (item) {
        return Tooltip(
          message: LKey.reScrambleImage.tr(),
          child: IgnorePointer(
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                HugeIcons.strokeRoundedGridTable,
                color: theme.iconColor,
              ),
            ),
          ),
        );
      },
      items: items,
      itemBuilder: (item, isSelected) {
        return Text(
          '${item}x${item}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.iconColor,
          ),
        );
      },
      onChange: (index) {
        widget.onTapAction?.call(items[index]);
      },
    );
  }
}

class ZoomViewRange extends StatelessWidget {
  const ZoomViewRange({super.key, this.onZoom, required this.initialZoomLevel});
  final ValueChanged<double>? onZoom;
  final double Function() initialZoomLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnlyChildDropdownButton(
      dropdownBackgroundColor: theme.actionBackground,
      borderRadius: BorderRadius.circular(40),
      child: Tooltip(
        message: LKey.reScrambleImage.tr(),
        child: IgnorePointer(
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              HugeIcons.strokeRoundedZoomInArea,
              color: theme.iconColor,
            ),
          ),
        ),
      ),
      dropdownBuilder: Builder(builder: (context) {
        return SizedBox(
          child: ZoomSlider(
            initialZoomLevel: initialZoomLevel(),
            onZoom: onZoom,
          ),
        );
      }),
    );
  }
}

class ZoomSlider extends StatefulWidget {
  final double initialZoomLevel;
  final ValueChanged<double>? onZoom;

  const ZoomSlider({super.key, required this.initialZoomLevel, this.onZoom});
  @override
  _ZoomSliderState createState() => _ZoomSliderState();
}

class _ZoomSliderState extends State<ZoomSlider> {
  double _zoomLevel = 0.7;

  @override
  void initState() {
    super.initState();
    _zoomLevel = widget.initialZoomLevel;
  }

  @override
  void didUpdateWidget(covariant ZoomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialZoomLevel != widget.initialZoomLevel) {
      _zoomLevel = widget.initialZoomLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${_zoomLevel.toStringAsFixed(1)}x",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textColor2,
            ),
          ),
          Slider(
            value: _zoomLevel,
            min: 0.3,
            max: 1.0,
            divisions: 50,
            onChanged: (value) {
              setState(() {
                _zoomLevel = value;
              });
              widget.onZoom?.call(value);
            },
            activeColor: theme.highlightColor2,
          ),
        ],
      ),
    );
  }
}
