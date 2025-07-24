# Pikachu Game

A matching game where players need to connect pairs of identical numbers on a 16x9 grid.

## Game Features

### Grid Layout

- **Size**: 16 columns × 9 rows (144 total cells)
- **Content**: Each cell contains a number from 1-9
- **Pairs**: Numbers are distributed in pairs across the grid

### Gameplay

1. **Objective**: Find and connect matching pairs of numbers
2. **Selection**: Tap on cells to select them
3. **Matching**: Two selected cells with the same number will be matched if there's a valid path
4. **Path Rules**: Cells can be connected through:
   - **Direct Lines**: Horizontal or vertical lines with no obstacles
   - **One Turn (L-shaped)**: One 90-degree turn with clear path segments
   - **Two Turns**: Through extended borders (top, bottom, left, right edges)
5. **Border Connections**: Cells on edges can connect through imaginary extended borders
6. **Path Validation**: All path segments must be clear of unmatched cells

### Game Elements

- **Score**: Earn 10 points for each successful match
- **Moves**: Track the number of attempts made
- **Timer**: Keep track of elapsed game time
- **Hint System**: Get help finding valid matches
- **Undo**: Reverse the last successful match

### Visual Features

- **Color Coding**: Different colors for each number (1-9)
- **Selection Highlight**: Selected cells have red borders and yellow background
- **Hint Highlight**: Hinted cells have green background
- **Matched State**: Matched cells become completely invisible (transparent)
- **Animations**: Smooth transitions for cell state changes
- **Connection Line Animation**: Animated red line shows the path between matching cells with dynamic timing
  - Near cells (1-3 steps): 350-450ms animation
  - Medium distance (4-8 steps): 540-700ms animation  
  - Far cells (9+ steps): 730-1000ms animation
  - Complex paths with multiple turns get additional time
- **Path Visualization**: Visual feedback shows exactly how cells are connected
- **Clean Grid Design**: Square cells with no border radius for sharp, clean look
- **Fitted Layout**: Grid automatically scales to fit available space perfectly
- **Fullscreen Experience**: No app bar for maximum game area
- **Landscape Mode**: Optimized UI layout for landscape orientation
- **Responsive Design**: Adaptive layout for both portrait and landscape modes

### Controls

- **Back**: Return to previous screen
- **New Game**: Start a fresh game with reshuffled numbers
- **Undo**: Reverse the last move (if available)
- **Hint**: Highlight a possible matching pair

### Orientation Support

- **Forced Landscape**: Game automatically switches to landscape mode for optimal gameplay
- **Adaptive Layout**:
  - **Landscape**: Top bar with stats and controls, grid below taking full remaining space
  - **Portrait**: Top section with stats and controls, grid below
- **Auto-restore**: Returns to default orientation when exiting the game
- **Top Bar Design**: Game information and controls are positioned at the top for easy access

## Implementation Details

### File Structure

```
game_pikachu/
├── pikachu_game_screen.dart      # Main game UI
├── pikachu_game_controller.dart  # Game logic and state management
├── models/
│   └── game_cell.dart           # Cell data model
└── demo/
    └── pikachu_game_demo.dart   # Standalone demo app
```

### Key Classes

- **PikachuGameScreen**: Main UI widget with grid display and controls
- **PikachuGameController**: Handles game logic, state, and scoring
- **GameCell**: Model for individual grid cells with state properties

### Game State Management

- Uses `ValueNotifier` for reactive UI updates
- Maintains game history for undo functionality
- Timer management for elapsed time tracking
- Automatic game completion detection

## Integration

The game is integrated into the main app through:

- Route management in `RouteManager.pikachuGamePage`
- Dependency injection in `PageDependencies`
- Navigation from the game menu

## Usage

Players can access the game through the main app's game menu or run the standalone demo for testing.
