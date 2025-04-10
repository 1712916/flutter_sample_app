import 'dart:math';
import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image/image.dart' as imglib;
import 'package:meow_app/feature/game/game_complete_widget.dart';
import 'package:meow_app/resources/theme/theme_data.dart';
import 'package:meow_app/widgets/custom_dropdown_only_child.dart';

import '../../../widgets/widgets.dart';
import '../../core/index.dart';
import '../../routers/route.dart';
import 'game_manager.dart';
import 'play_area_widget.dart';

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
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(RouteManager.gameSettingPage);
            },
            icon: Icon(
              HugeIcons.strokeRoundedSettings01,
              color: theme.iconColor,
            ),
          ),
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

  final GlobalKey<PlayAreaState> _gameBoardKey = GlobalKey();

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
                child: PlayArea(
                  key: _gameBoardKey,
                  image: _image!,
                  onComplete: () {
                    confettiController.play();
                    GameCompleteWidget(
                      countStep: _gameBoardKey.currentState!.countMoveStep,
                      onExit: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      onPlayAgain: () {
                        Navigator.of(context).pop();
                        reloadScramble();
                      },
                    ).show(context);
                  },
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
