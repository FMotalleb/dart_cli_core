class AnsiEscapeCodes {
  static const eraser = _Eraser();
  static const arrows = _ArrowKeys();
  static const lines = _LineMovements();
  static const positions = _Positioning();
  static const enableAnsiEscape = '\x1B';
  static String keyBuilder(String operator, String parameter) {
    return '${AnsiEscapeCodes.enableAnsiEscape}[$parameter$operator';
  }
}

class _Positioning {
  const _Positioning();
  String setColumn(int column) {
    return AnsiEscapeCodes.keyBuilder('G', column.toString());
  }

  String setPosition({required int column, required int row}) {
    return AnsiEscapeCodes.keyBuilder('H', '$row;$column');
  }
}

class _LineMovements {
  const _LineMovements();
  String moveUp([int count = 1]) {
    return AnsiEscapeCodes.keyBuilder('E', count.toString());
  }

  String moveDown([int count = 1]) {
    return AnsiEscapeCodes.keyBuilder('F', count.toString());
  }
}

enum DeletionMode {
  fromCursorToEnd(0),
  fromStartToCursor(1),
  wholeThing(2),
  ;

  const DeletionMode(this.value);
  final int value;
}

class _Eraser {
  static const deleteLineToken = 'K';
  static const deleteScreenToken = 'J';
  const _Eraser();
  String deleteLine(DeletionMode mode) {
    return AnsiEscapeCodes.keyBuilder(deleteLineToken, mode.value.toString());
  }

  String clearScreen(DeletionMode mode) {
    return AnsiEscapeCodes.keyBuilder(deleteScreenToken, mode.value.toString());
  }
}

enum Arrow {
  up('A'),
  down('B'),
  right('C'),
  left('D'),
  ;

  const Arrow(this.value);
  final String value;
}

class _ArrowKeys {
  const _ArrowKeys();
  String moveTo(
    Arrow direction, [
    int count = 1,
  ]) {
    return AnsiEscapeCodes.keyBuilder(direction.value, count.toString());
  }
}
