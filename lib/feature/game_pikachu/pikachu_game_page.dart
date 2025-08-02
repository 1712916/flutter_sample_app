import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../core/index.dart';
import '../../widgets/widgets.dart';
import 'models/cell_content_factory.dart';
import 'models/game_background_config.dart';
import 'models/game_cell.dart';
import 'pikachu_game_controller.dart';
import 'widgets/connection_line_painter.dart';

class PikachuGamePage extends StatefulWidget {
  const PikachuGamePage({Key? key}) : super(key: key);

  @override
  State<PikachuGamePage> createState() => _PikachuGamePageState();
}

class _PikachuGamePageState extends State<PikachuGamePage> {
  late PikachuGameController _controller;
  GameBackgroundConfig _currentBackground = BackgroundPresets.gaming;

  @override
  void initState() {
    super.initState();
    final isMeow = SettingManager.isMeow;

    _controller = PikachuGameController();

    final config = isMeow ? CellContentConfig.presets[0] : CellContentConfig.presets[1];

    _controller.changeContentType(config);

    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  ThemeData get theme => context.appTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _currentBackground.buildDecoration(),
        child: _buildLandscapeLayout(),
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return SafeArea(
      child: Column(
        children: [
          // Top bar with stats and controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Reduced vertical padding
            decoration: BoxDecoration(
              color: Colors.transparent, // Transparent background
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8), // Smaller radius
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildGameControls(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildGameStats(),
                ),
              ],
            ),
          ),
          // Game Grid (takes remaining space)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Stack(
                  children: [
                    if (_controller.secretImage != null)
                      Positioned.fill(child: Image.file(File(_controller.secretImage!))),
                    ValueListenableBuilder<List<List<GameCell>>>(
                      valueListenable: _controller.gridNotifier,
                      builder: (context, grid, child) {
                        return _buildGameGrid(grid);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Compact Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              ValueListenableBuilder<int>(
                valueListenable: _controller.scoreNotifier,
                builder: (context, score, child) {
                  return Text('$score',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green));
                },
              ),
            ],
          ),
        ),
        // Compact Moves
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              ValueListenableBuilder<int>(
                valueListenable: _controller.movesNotifier,
                builder: (context, moves, child) {
                  return Text('$moves',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue));
                },
              ),
            ],
          ),
        ),
        // Compact Time
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              ValueListenableBuilder<int>(
                valueListenable: _controller.timeNotifier,
                builder: (context, time, child) {
                  final minutes = time ~/ 60;
                  final seconds = time % 60;
                  return Text('${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameGrid(List<List<GameCell>> grid) {
    return AspectRatio(
      aspectRatio: 16 / 9, // Maintain proper grid proportions for landscape
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gridWidth = constraints.maxWidth;
          final gridHeight = constraints.maxHeight;
          final cellWidth = gridWidth / 16;
          final cellHeight = gridHeight / 9;

          return Stack(
            children: [
              // Game grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling to fit view
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 16,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 0, // Increased spacing between cells
                  mainAxisSpacing: 0, // Increased spacing between cells
                ),
                itemCount: 16 * 9,
                itemBuilder: (context, index) {
                  final row = index ~/ 16;
                  final col = index % 16;
                  final cell = grid[row][col];

                  return GestureDetector(
                    onTap: () {
                      _controller.onCellTapped(row, col);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getCellColor(cell),
                        border: cell.isEmpty
                            ? null // No border for empty cells
                            : Border.all(
                                color: cell.isSelected ? theme.highlightColor2 : Colors.transparent,
                                width: cell.isSelected ? 0.4 : 0.2,
                              ),
                      ),
                      child: Center(
                        child: cell.isEmpty
                            ? null
                            : cell.content?.buildWidget(
                                  fontSize: 20, // Increased font size
                                  isSelected: cell.isSelected,
                                  isMatched: cell.isMatched,
                                  isHinted: cell.isHinted,
                                ) ??
                                Text(
                                  cell.number.toString(), // Fallback to number
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20, // Increased font size
                                    color: cell.isMatched ? Colors.grey : Colors.black,
                                  ),
                                ),
                      ),
                    ),
                  );
                },
              ),
              // Connection line overlay
              ValueListenableBuilder<List<Offset>?>(
                valueListenable: _controller.connectionLineNotifier,
                builder: (context, connectionLine, child) {
                  if (connectionLine == null) return const SizedBox.shrink();

                  return ValueListenableBuilder<int>(
                    valueListenable: _controller.animationDurationNotifier,
                    builder: (context, duration, child) {
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: duration),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, animationProgress, child) {
                          return CustomPaint(
                            size: Size.infinite,
                            painter: ConnectionLinePainter(
                              points: connectionLine,
                              cellWidth: cellWidth,
                              cellHeight: cellHeight,
                              animationProgress: animationProgress,
                              gridCols: 16,
                              gridRows: 9,
                              lineColor: Colors.green,
                              pointColor: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameControls() {
    return Row(
      children: [
        CircleAppBackButton(),
        const Spacer(),
        // Primary action buttons (icon only with tooltips)
        Tooltip(
          message: 'New Game',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6), // Smaller radius
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _controller.initializeGame();
                });
              },
              icon: const Icon(Icons.refresh, size: 16), // Smaller icon consistent with settings
              style: IconButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.all(4), // Reduced padding
                minimumSize: const Size(32, 32), // Smaller minimum size
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4), // Reduced spacing
        Tooltip(
          message: 'Show Hint',
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6), // Smaller radius
            ),
            child: IconButton(
              onPressed: () {
                _controller.showHint();
              },
              icon: const Icon(Icons.lightbulb_outline, size: 16), // Smaller icon consistent with settings
              style: IconButton.styleFrom(
                foregroundColor: Colors.green,
                padding: const EdgeInsets.all(4), // Reduced padding
                minimumSize: const Size(32, 32), // Smaller minimum size
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4), // Reduced spacing
        // Settings dropdown menu
        PopupMenuButton<String>(
          tooltip: 'Settings',
          // icon: Icon(Icons.settings, size: 16, color: Colors.grey[700]), // Made smaller to match other icons
          padding: const EdgeInsets.all(4), // Reduced padding
          iconSize: 16, // Explicit smaller icon size
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32), // Match other button constraints
          menuPadding: EdgeInsets.zero,
          offset: Offset(0, 38),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(6), // Smaller radius
            ),
            child: IgnorePointer(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, size: 16), // Smaller icon consistent with settings
                style: IconButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.all(4), // Reduced padding
                  minimumSize: const Size(32, 32), // Smaller minimum size
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ),
          onSelected: (value) {
            switch (value) {
              case 'theme':
                _showContentTypePicker();
                break;
              case 'background':
                _showBackgroundPicker();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'theme',
              child: Row(
                children: [
                  Icon(Icons.palette, size: 20, color: Colors.purple),
                  SizedBox(width: 8),
                  Text('Game Theme'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'background',
              child: Row(
                children: [
                  Icon(Icons.wallpaper, size: 20, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('Background'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCellColor(GameCell cell) {
    if (cell.isEmpty) {
      return Colors.transparent; // Make empty cells completely invisible
    }
    if (cell.isMatched) {
      return Colors.grey[400]!;
    }
    if (cell.isSelected) {
      return Colors.yellow[200]!;
    }
    if (cell.isHinted) {
      return Colors.lightGreen[200]!;
    }

    // Use content-based color if available
    if (cell.content != null) {
      return cell.content!.getBackgroundColor();
    }

    // Fallback: Color based on number for backward compatibility
    final colors = [
      Colors.red[100]!,
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.orange[100]!,
      Colors.purple[100]!,
      Colors.pink[100]!,
      Colors.cyan[100]!,
      Colors.lime[100]!,
      Colors.indigo[100]!,
    ];

    return colors[(cell.number - 1) % colors.length];
  }

  void _showContentTypePicker() {
    ChooseGameContentWidget(
      currentContentConfig: _controller.currentContentConfig,
    ).show(context).then(
      (value) {
        if (value != null) {
          setState(() {
            _controller.changeContentType(value);
          });
        }
      },
    );
  }

  void _showBackgroundPicker() {
    ChooseBackgroundWidget(currentBackground: _currentBackground).show(context).then(
      (value) {
        if (value != null) {
          setState(() {
            _currentBackground = value;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    // Restore default orientation when leaving the game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }
}

class ChooseBackgroundWidget extends StatelessWidget with ShowDialog<GameBackgroundConfig> {
  const ChooseBackgroundWidget({super.key, required this.currentBackground});

  final GameBackgroundConfig currentBackground;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Background'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: BackgroundPresets.all.entries.map((entry) {
            String name = entry.key;
            GameBackgroundConfig config = entry.value;
            bool isSelected = currentBackground == config;

            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: config.buildDecoration(),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : null,
                ),
              ),
              subtitle: Text(_getBackgroundDescription(config)),
              onTap: () {
                Navigator.of(context).pop(config);
              },
              trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
            );
          }).toList(),
        ),
      ),
      // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      // actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _getBackgroundDescription(GameBackgroundConfig config) {
    switch (config.type) {
      case BackgroundType.gradient:
        return 'Gradient with ${config.gradientColors?.length ?? 0} colors';
      case BackgroundType.solid:
        return 'Solid color background';
      case BackgroundType.image:
        return 'Image background';
    }
  }
}

class ChooseGameContentWidget extends StatelessWidget with ShowDialog<CellContentConfig> {
  const ChooseGameContentWidget({super.key, required this.currentContentConfig});

  final CellContentConfig currentContentConfig;

  @override
  Widget build(BuildContext context) {
    Map<String, String> animalMap = {
      'Meow': 'assets/icon/cat.svg',
      'Gaow': 'assets/icon/dog.svg',
      'Mixed': 'assets/icon/paw.svg',
    };
    final theme = context.appTheme;
    return AlertDialog(
      title: const Text('Choose Game Theme'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: CellContentConfig.presets.map((config) {
            bool isSelected = config == currentContentConfig;
            return ListTile(
              leading: SvgPicture.asset(
                animalMap[config.name] ?? 'assets/icon/default.svg',
                color: theme.iconColor,
                width: 24,
                height: 24,
              ),
              title: Text(
                config.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : null,
                ),
              ),
              subtitle: Text(config.description),
              onTap: () {
                Navigator.of(context).pop(config);
              },
              trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
