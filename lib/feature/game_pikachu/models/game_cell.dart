import 'cell_content.dart';

class GameCell {
  int number;              // Keep for backward compatibility and game logic
  CellContent? content;    // New flexible content system
  bool isSelected;
  bool isMatched;
  bool isEmpty;
  bool isHinted;

  GameCell({
    this.number = 0,
    this.content,
    this.isSelected = false,
    this.isMatched = false,
    this.isEmpty = true,
    this.isHinted = false,
  });

  void reset() {
    isSelected = false;
    isMatched = false;
    isEmpty = true;
    isHinted = false;
    number = 0;
    content = null;
  }

  void setNumber(int value) {
    number = value;
    isEmpty = false;
  }
  
  void setContent(CellContent cellContent) {
    content = cellContent;
    number = cellContent.id;  // Keep number in sync for game logic
    isEmpty = false;
  }

  void markAsMatched() {
    isMatched = true;
    isSelected = false;
    isEmpty = true;  // Make cell invisible
    number = 0;      // Reset number
    content = null;  // Clear content
  }

  void select() {
    if (!isEmpty && !isMatched) {
      isSelected = true;
    }
  }

  void deselect() {
    isSelected = false;
  }

  void clearHint() {
    isHinted = false;
  }

  void showHint() {
    isHinted = true;
  }

  GameCell copy() {
    return GameCell(
      number: number,
      content: content?.copy(),
      isSelected: isSelected,
      isMatched: isMatched,
      isEmpty: isEmpty,
      isHinted: isHinted,
    );
  }

  @override
  String toString() {
    return 'GameCell(number: $number, content: ${content?.type}, isEmpty: $isEmpty, isSelected: $isSelected, isMatched: $isMatched)';
  }
}
