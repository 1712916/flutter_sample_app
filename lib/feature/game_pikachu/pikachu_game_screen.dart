import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/widgets.dart';
import 'models/game_cell.dart';
import 'pikachu_game_controller.dart';
import 'widgets/connection_line_painter.dart';

class PikachuGameScreen extends StatefulWidget {
  const PikachuGameScreen({Key? key}) : super(key: key);

  @override
  State<PikachuGameScreen> createState() => _PikachuGameScreenState();
}

class _PikachuGameScreenState extends State<PikachuGameScreen> {
  late PikachuGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PikachuGameController();
    _controller.initializeGame();

    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildLandscapeLayout(),
    );
  }

  Widget _buildLandscapeLayout() {
    return SafeArea(
      child: Column(
        children: [
          // Top bar with stats and controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                // Game Controls (right side)
              ],
            ),
          ),
          // Game Grid (takes remaining space)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: ValueListenableBuilder<List<List<GameCell>>>(
                  valueListenable: _controller.gridNotifier,
                  builder: (context, grid, child) {
                    return _buildGameGrid(grid);
                  },
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            const Text('Score :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            ValueListenableBuilder<int>(
              valueListenable: _controller.scoreNotifier,
              builder: (context, score, child) {
                return Text('$score', style: const TextStyle(fontSize: 18, color: Colors.green));
              },
            ),
          ],
        ),
        Row(
          children: [
            const Text('Moves :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            ValueListenableBuilder<int>(
              valueListenable: _controller.movesNotifier,
              builder: (context, moves, child) {
                return Text('$moves', style: const TextStyle(fontSize: 18, color: Colors.blue));
              },
            ),
          ],
        ),
        Row(
          children: [
            const Text('Time: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            ValueListenableBuilder<int>(
              valueListenable: _controller.timeNotifier,
              builder: (context, time, child) {
                final minutes = time ~/ 60;
                final seconds = time % 60;
                return Text('${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18, color: Colors.red));
              },
            ),
          ],
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
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
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
                        border: Border.all(
                          color: cell.isSelected ? Colors.blue : Colors.grey.shade400,
                          width: cell.isSelected ? 3 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: cell.isEmpty
                            ? null
                            : Text(
                                cell.number.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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

                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
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
                        ),
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
        Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _controller.initializeGame();
            });
          },
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('New', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(60, 32),
          ),
        ),
        const SizedBox(width: 8),
        // ElevatedButton.icon(
        //   onPressed: _controller.canUndo
        //       ? () {
        //           setState(() {
        //             _controller.undoLastMove();
        //           });
        //         }
        //       : null,
        //   icon: const Icon(Icons.undo, size: 16),
        //   label: const Text('Undo', style: TextStyle(fontSize: 12)),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.orange,
        //     foregroundColor: Colors.white,
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //     minimumSize: const Size(60, 32),
        //   ),
        // ),
        ElevatedButton.icon(
          onPressed: () {
            _controller.showHint();
          },
          icon: const Icon(Icons.lightbulb, size: 16),
          label: const Text('Hint', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(60, 32),
          ),
        ),
      ],
    );
  }

  Color _getCellColor(GameCell cell) {
    if (cell.isEmpty) {
      return Colors.grey[300]!;
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

    // Color based on number
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
