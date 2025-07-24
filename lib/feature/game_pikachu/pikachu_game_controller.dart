import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models/game_cell.dart';

class PikachuGameController {
  static const int rows = 9;
  static const int cols = 16;
  static const int totalPairs = 36; // 72 cells / 2 = 36 pairs

  late ValueNotifier<List<List<GameCell>>> gridNotifier;
  late ValueNotifier<int> scoreNotifier;
  late ValueNotifier<int> movesNotifier;
  late ValueNotifier<int> timeNotifier;
  late ValueNotifier<List<Offset>?> connectionLineNotifier;
  late ValueNotifier<int> animationDurationNotifier; // Dynamic animation duration in milliseconds

  List<List<GameCell>> _grid = [];
  GameCell? _firstSelected;
  GameCell? _secondSelected;
  int _firstSelectedRow = -1;
  int _firstSelectedCol = -1;
  int _secondSelectedRow = -1;
  int _secondSelectedCol = -1;

  Timer? _gameTimer;
  int _elapsedTime = 0;
  bool _gameStarted = false;

  List<List<List<GameCell>>> _gameHistory = [];
  bool get canUndo => _gameHistory.isNotEmpty;

  PikachuGameController() {
    gridNotifier = ValueNotifier([]);
    scoreNotifier = ValueNotifier(0);
    movesNotifier = ValueNotifier(0);
    timeNotifier = ValueNotifier(0);
    connectionLineNotifier = ValueNotifier(null);
    animationDurationNotifier = ValueNotifier(800); // Default 800ms
  }

  void initializeGame() {
    _stopTimer();
    _grid = List.generate(rows, (i) => List.generate(cols, (j) => GameCell()));
    _generateNumbers();
    _shuffleGrid();

    gridNotifier.value = _grid.map((row) => row.map((cell) => cell.copy()).toList()).toList();
    scoreNotifier.value = 0;
    movesNotifier.value = 0;
    timeNotifier.value = 0;
    _elapsedTime = 0;
    _gameStarted = false;

    _firstSelected = null;
    _secondSelected = null;
    _gameHistory.clear();

    _clearAllSelections();
  }

  void _generateNumbers() {
    List<int> numbers = [];

    // Generate pairs of numbers (1-9, repeated to fill the grid)
    int totalCells = rows * cols;
    int pairsNeeded = totalCells ~/ 2;

    for (int i = 0; i < pairsNeeded; i++) {
      int number = (i % 9) + 1; // Numbers 1-9, repeating
      numbers.add(number);
      numbers.add(number);
    }

    // If odd number of cells, add one more random number
    if (totalCells % 2 == 1) {
      numbers.add(math.Random().nextInt(9) + 1);
    }

    // Fill the grid
    int index = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (index < numbers.length) {
          _grid[i][j].setNumber(numbers[index]);
          index++;
        }
      }
    }
  }

  void _shuffleGrid() {
    List<GameCell> allCells = [];

    // Collect all non-empty cells
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (!_grid[i][j].isEmpty) {
          allCells.add(_grid[i][j]);
        }
      }
    }

    // Shuffle the numbers
    List<int> numbers = allCells.map((cell) => cell.number).toList();
    numbers.shuffle();

    // Redistribute the shuffled numbers
    int index = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (!_grid[i][j].isEmpty && index < numbers.length) {
          _grid[i][j].setNumber(numbers[index]);
          index++;
        }
      }
    }
  }

  void onCellTapped(int row, int col) {
    if (!_gameStarted) {
      _startTimer();
      _gameStarted = true;
    }

    GameCell tappedCell = _grid[row][col];

    // Cannot select empty or matched cells
    if (tappedCell.isEmpty || tappedCell.isMatched) {
      return;
    }

    // If this cell is already selected, deselect it
    if (tappedCell.isSelected) {
      tappedCell.deselect();
      if (_firstSelected == tappedCell) {
        _firstSelected = null;
        _firstSelectedRow = -1;
        _firstSelectedCol = -1;
      } else if (_secondSelected == tappedCell) {
        _secondSelected = null;
        _secondSelectedRow = -1;
        _secondSelectedCol = -1;
      }
      _updateGrid();
      return;
    }

    // Clear all hints
    _clearAllHints();

    // If no cell is selected, select this one
    if (_firstSelected == null) {
      _firstSelected = tappedCell;
      _firstSelectedRow = row;
      _firstSelectedCol = col;
      tappedCell.select();
    }
    // If one cell is selected, select this as second
    else if (_secondSelected == null) {
      _secondSelected = tappedCell;
      _secondSelectedRow = row;
      _secondSelectedCol = col;
      tappedCell.select();

      // Check if they match
      _checkMatch();
    }
    // If two cells are already selected, deselect all and select this one
    else {
      _clearAllSelections();
      _firstSelected = tappedCell;
      _firstSelectedRow = row;
      _firstSelectedCol = col;
      tappedCell.select();
      _secondSelected = null;
    }

    _updateGrid();
  }

  void _checkMatch() {
    if (_firstSelected == null || _secondSelected == null) return;

    movesNotifier.value++;

    // Check if numbers match
    if (_firstSelected!.number == _secondSelected!.number) {
      // Check if there's a valid path between the cells
      List<Offset>? pathPoints = _getConnectionPath(_firstSelectedRow, _firstSelectedCol, _secondSelectedRow, _secondSelectedCol);
      if (pathPoints != null) {
        // Match found! Show connection line animation
        _saveGameState();
        
        // Calculate dynamic animation duration based on distance
        int dynamicDuration = _calculateAnimationDuration(_firstSelectedRow, _firstSelectedCol, _secondSelectedRow, _secondSelectedCol, pathPoints);
        animationDurationNotifier.value = dynamicDuration;
        
        // Show the connection line
        connectionLineNotifier.value = pathPoints;
        
        // After animation delay, mark cells as matched
        Future.delayed(Duration(milliseconds: dynamicDuration), () {
          _firstSelected!.markAsMatched();
          _secondSelected!.markAsMatched();
          
          scoreNotifier.value += 10;
          
          // Hide the connection line
          connectionLineNotifier.value = null;
          
          // Check if game is won
          if (_isGameWon()) {
            _stopTimer();
            _showGameWonDialog();
          }
          
          // Clear selections
          _clearAllSelections();
          _updateGrid();
        });
        return;
      }
    }

    // Clear selections after a short delay if no match
    Future.delayed(const Duration(milliseconds: 500), () {
      _clearAllSelections();
      _updateGrid();
    });
  }

  /// Calculate animation duration based on distance between cells and path complexity
  int _calculateAnimationDuration(int row1, int col1, int row2, int col2, List<Offset> pathPoints) {
    // Calculate Manhattan distance (straight-line grid distance)
    int manhattanDistance = (row1 - row2).abs() + (col1 - col2).abs();
    
    // Calculate path complexity (number of turns)
    int pathTurns = pathPoints.length - 2; // Start and end don't count as turns
    
    // Base duration calculation
    // Near cells (distance 1-3): 300-500ms
    // Medium cells (distance 4-8): 500-700ms  
    // Far cells (distance 9+): 700-1000ms
    int baseDuration;
    if (manhattanDistance <= 3) {
      baseDuration = 300 + manhattanDistance * 50; // 350-450ms
    } else if (manhattanDistance <= 8) {
      baseDuration = 500 + (manhattanDistance - 3) * 40; // 540-700ms
    } else {
      baseDuration = 700 + math.min((manhattanDistance - 8) * 30, 300); // 730-1000ms
    }
    
    // Add time for path complexity (each turn adds time)
    int complexityBonus = pathTurns * 100; // 100ms per turn
    
    // Final duration with bounds
    int finalDuration = baseDuration + complexityBonus;
    return math.max(250, math.min(finalDuration, 1200)); // Clamp between 250ms and 1200ms
  }

  List<Offset>? _getConnectionPath(int row1, int col1, int row2, int col2) {
    // Same cell - not valid
    if (row1 == row2 && col1 == col2) return null;
    
    // Try direct paths first
    List<Offset>? directPath = _getDirectPath(row1, col1, row2, col2);
    if (directPath != null) return directPath;
    
    // Try one-turn paths (L-shaped)
    List<Offset>? oneTurnPath = _getOneTurnPath(row1, col1, row2, col2);
    if (oneTurnPath != null) return oneTurnPath;
    
    // Try two-turn paths (requires external border)
    List<Offset>? twoTurnPath = _getTwoTurnPath(row1, col1, row2, col2);
    if (twoTurnPath != null) return twoTurnPath;
    
    return null;
  }

  List<Offset>? _getDirectPath(int row1, int col1, int row2, int col2) {
    // Direct horizontal path (same row)
    if (row1 == row2) {
      if (_isHorizontalPathClear(row1, col1, col2)) {
        return [
          Offset(col1.toDouble(), row1.toDouble()),
          Offset(col2.toDouble(), row2.toDouble()),
        ];
      }
    }
    
    // Direct vertical path (same column)
    if (col1 == col2) {
      if (_isVerticalPathClear(col1, row1, row2)) {
        return [
          Offset(col1.toDouble(), row1.toDouble()),
          Offset(col2.toDouble(), row2.toDouble()),
        ];
      }
    }
    
    return null;
  }

  List<Offset>? _getOneTurnPath(int row1, int col1, int row2, int col2) {
    // L-shaped path: horizontal first, then vertical
    if (_isHorizontalPathClear(row1, col1, col2) && 
        _isVerticalPathClear(col2, row1, row2) &&
        _isCellEmptyOrTarget(row1, col2, row2, col2)) {
      return [
        Offset(col1.toDouble(), row1.toDouble()),
        Offset(col2.toDouble(), row1.toDouble()),
        Offset(col2.toDouble(), row2.toDouble()),
      ];
    }
    
    // L-shaped path: vertical first, then horizontal
    if (_isVerticalPathClear(col1, row1, row2) && 
        _isHorizontalPathClear(row2, col1, col2) &&
        _isCellEmptyOrTarget(row2, col1, row2, col2)) {
      return [
        Offset(col1.toDouble(), row1.toDouble()),
        Offset(col1.toDouble(), row2.toDouble()),
        Offset(col2.toDouble(), row2.toDouble()),
      ];
    }
    
    return null;
  }

  List<Offset>? _getTwoTurnPath(int row1, int col1, int row2, int col2) {
    // Check paths through extended borders (top, bottom, left, right)
    
    // Through top border (row -1)
    if (_canReachThroughTopBorder(row1, col1, row2, col2)) {
      return [
        Offset(col1.toDouble(), row1.toDouble()),
        Offset(col1.toDouble(), -0.5),
        Offset(col2.toDouble(), -0.5),
        Offset(col2.toDouble(), row2.toDouble()),
      ];
    }
    
    // Through bottom border (row rows)
    if (_canReachThroughBottomBorder(row1, col1, row2, col2)) {
      return [
        Offset(col1.toDouble(), row1.toDouble()),
        Offset(col1.toDouble(), rows.toDouble() - 0.5),
        Offset(col2.toDouble(), rows.toDouble() - 0.5),
        Offset(col2.toDouble(), row2.toDouble()),
      ];
    }
    
    // Through left border (col -1)
    if (_canReachThroughLeftBorder(row1, col1, row2, col2)) {
      return [
        Offset(col1.toDouble(), row1.toDouble()),
        Offset(-0.5, row1.toDouble()),
        Offset(-0.5, row2.toDouble()),
        Offset(col2.toDouble(), row2.toDouble()),
      ];
    }
    
    // Through right border (col cols)
    if (_canReachThroughRightBorder(row1, col1, row2, col2)) {
      return [
        Offset(col1.toDouble(), row1.toDouble()),
        Offset(cols.toDouble() - 0.5, row1.toDouble()),
        Offset(cols.toDouble() - 0.5, row2.toDouble()),
        Offset(col2.toDouble(), row2.toDouble()),
      ];
    }
    
    return null;
  }

  bool _hasValidPath(int row1, int col1, int row2, int col2) {
    return _getConnectionPath(row1, col1, row2, col2) != null;
  }

  bool _isHorizontalPathClear(int row, int fromCol, int toCol) {
    int startCol = math.min(fromCol, toCol);
    int endCol = math.max(fromCol, toCol);

    for (int c = startCol + 1; c < endCol; c++) {
      if (!_isCellEmpty(row, c)) return false;
    }
    return true;
  }

  bool _isVerticalPathClear(int col, int fromRow, int toRow) {
    int startRow = math.min(fromRow, toRow);
    int endRow = math.max(fromRow, toRow);

    for (int r = startRow + 1; r < endRow; r++) {
      if (!_isCellEmpty(r, col)) return false;
    }
    return true;
  }

  bool _isCellEmpty(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return true; // Outside grid is considered empty
    return _grid[row][col].isEmpty || _grid[row][col].isMatched;
  }

  bool _isCellEmptyOrTarget(int row, int col, int targetRow, int targetCol) {
    if (row == targetRow && col == targetCol) return true; // This is the target cell
    return _isCellEmpty(row, col);
  }

  bool _canReachThroughTopBorder(int row1, int col1, int row2, int col2) {
    // Check if both cells can reach the top border
    if (!_isVerticalPathClear(col1, -1, row1)) return false;
    if (!_isVerticalPathClear(col2, -1, row2)) return false;

    // Check if there's a clear horizontal path along the top border
    return _isHorizontalPathClear(-1, col1, col2);
  }

  bool _canReachThroughBottomBorder(int row1, int col1, int row2, int col2) {
    // Check if both cells can reach the bottom border
    if (!_isVerticalPathClear(col1, row1, rows)) return false;
    if (!_isVerticalPathClear(col2, row2, rows)) return false;

    // Check if there's a clear horizontal path along the bottom border
    return _isHorizontalPathClear(rows, col1, col2);
  }

  bool _canReachThroughLeftBorder(int row1, int col1, int row2, int col2) {
    // Check if both cells can reach the left border
    if (!_isHorizontalPathClear(row1, -1, col1)) return false;
    if (!_isHorizontalPathClear(row2, -1, col2)) return false;

    // Check if there's a clear vertical path along the left border
    return _isVerticalPathClear(-1, row1, row2);
  }

  bool _canReachThroughRightBorder(int row1, int col1, int row2, int col2) {
    // Check if both cells can reach the right border
    if (!_isHorizontalPathClear(row1, col1, cols)) return false;
    if (!_isHorizontalPathClear(row2, col2, cols)) return false;

    // Check if there's a clear vertical path along the right border
    return _isVerticalPathClear(cols, row1, row2);
  }

  bool _isGameWon() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (!_grid[i][j].isEmpty && !_grid[i][j].isMatched) {
          return false;
        }
      }
    }
    return true;
  }

  void _showGameWonDialog() {
    // This would typically show a dialog in the UI
    print('Congratulations! You won the game!');
    print('Score: ${scoreNotifier.value}');
    print('Moves: ${movesNotifier.value}');
    print('Time: ${_formatTime(_elapsedTime)}');
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _clearAllSelections() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        _grid[i][j].deselect();
      }
    }
    _firstSelected = null;
    _secondSelected = null;
    _firstSelectedRow = -1;
    _firstSelectedCol = -1;
    _secondSelectedRow = -1;
    _secondSelectedCol = -1;
  }

  void _clearAllHints() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        _grid[i][j].clearHint();
      }
    }
  }

  void _updateGrid() {
    gridNotifier.value = _grid.map((row) => row.map((cell) => cell.copy()).toList()).toList();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTime++;
      timeNotifier.value = _elapsedTime;
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void _saveGameState() {
    List<List<GameCell>> stateCopy = _grid.map((row) => row.map((cell) => cell.copy()).toList()).toList();
    _gameHistory.add(stateCopy);

    // Keep only last 10 moves
    if (_gameHistory.length > 10) {
      _gameHistory.removeAt(0);
    }
  }

  void undoLastMove() {
    if (_gameHistory.isNotEmpty) {
      _grid = _gameHistory.removeLast();
      _clearAllSelections();
      _updateGrid();

      // Adjust score and moves
      if (scoreNotifier.value >= 10) {
        scoreNotifier.value -= 10;
      }
      if (movesNotifier.value > 0) {
        movesNotifier.value--;
      }
    }
  }

  void showHint() {
    _clearAllHints();

    // Find a pair that can be matched using the improved path finding
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (_grid[i][j].isEmpty || _grid[i][j].isMatched) continue;

        for (int i2 = 0; i2 < rows; i2++) {
          for (int j2 = 0; j2 < cols; j2++) {
            if (i == i2 && j == j2) continue;
            if (_grid[i2][j2].isEmpty || _grid[i2][j2].isMatched) continue;

            if (_grid[i][j].number == _grid[i2][j2].number && _hasValidPath(i, j, i2, j2)) {
              _grid[i][j].showHint();
              _grid[i2][j2].showHint();
              _updateGrid();

              // Clear hint after 3 seconds
              Future.delayed(const Duration(seconds: 3), () {
                _clearAllHints();
                _updateGrid();
              });
              return;
            }
          }
        }
      }
    }

    // If no hint found, maybe the game is stuck
    print('No valid moves found - game might be unsolvable in current state');
  }

  void dispose() {
    _stopTimer();
    gridNotifier.dispose();
    scoreNotifier.dispose();
    movesNotifier.dispose();
    timeNotifier.dispose();
    connectionLineNotifier.dispose();
    animationDurationNotifier.dispose();
  }
}
