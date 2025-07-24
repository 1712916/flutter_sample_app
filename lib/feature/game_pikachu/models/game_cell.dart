class GameCell {
  int number;
  bool isSelected;
  bool isMatched;
  bool isEmpty;
  bool isHinted;

  GameCell({
    this.number = 0,
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
  }

  void setNumber(int value) {
    number = value;
    isEmpty = false;
  }

  void markAsMatched() {
    isMatched = true;
    isSelected = false;
    isEmpty = true;  // Make cell invisible
    number = 0;      // Reset number
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
      isSelected: isSelected,
      isMatched: isMatched,
      isEmpty: isEmpty,
      isHinted: isHinted,
    );
  }

  @override
  String toString() {
    return 'GameCell(number: $number, isEmpty: $isEmpty, isSelected: $isSelected, isMatched: $isMatched)';
  }
}
