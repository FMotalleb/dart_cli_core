import 'dart:io';

import 'package:collection/collection.dart';

import 'package:cli_core/cli_core.dart' as cli_core;

void main(List<String> arguments) async {
  // print(stdout.terminalColumns);
  // print(stdout.terminalLines);
  // stdin.echoMode = false;
  // stdin.echoNewlineMode = false;
  // stdin.lineMode = false;
  TerminalPage(stdin: stdin, stderr: stderr, stdout: stdout).drawBox(DecoratedBox(child: MessageBox(text: '')));
  // await for (final input in stdin) {
  //   print('got here as : `$input`');
  // }
}

void viewPage(TerminalPage page) {}

class TerminalPage {
  late Stdin stdin;
  late Stdout stdout;
  late Stdout stderr;

  TerminalPage({
    required this.stdin,
    required this.stdout,
    required this.stderr,
  }) {
    if (stdout.supportsAnsiEscapes == false) {
      throw Exception('terminal has to support ansiEscapes to draw page');
    }
    if (stdin.hasTerminal == false || stdout.hasTerminal == false) {
      throw Exception('input or output stream is not attached to a terminal');
    }
    stdin.echoMode = false;
    stdin.echoNewlineMode = false;
    stdin.lineMode = false;
  }
  void drawBox(DecoratedBox box) {
    for (final i in box.generateMatrix().source) {
      stdout.write('\x1b[${i.y};${i.x}H');
      stdout.write(i.value);
    }
  }
}

class Position {
  final int x;
  final int y;

  Position(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Position && //
        other.x == x &&
        other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'Position(x: $x, y: $y)';
}

class PositionedValue<T> extends Position {
  final T value;
  PositionedValue(super.x, super.y, this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PositionedValue<T> && //
        other.x == x &&
        other.y == y &&
        other.value == value;
  }

  bool positionCheck(Position other) {
    return super == other;
  }

  @override
  int get hashCode => super.hashCode ^ value.hashCode;
}

class MatrixView {
  final List<PositionedValue<String>> source;
  String? getCharAt(Position position) {
    final matchedPoints = source.where((element) => element.positionCheck(position));
    if (matchedPoints.isEmpty) return null;
    return matchedPoints.last.value;
  }

  MatrixView({
    required this.source,
  });
}

class Size {
  final int height;
  final int width;

  Size(this.width, this.height);
}

abstract class TerminalView implements MatrixView {
  Size get size;
  MatrixView generateMatrix();
}

class DecoratedBox implements TerminalView {
  final String horizontal;
  final String vertical;
  final String topLeft;
  final String topRight;
  final String bottomLeft;
  final String bottomRight;
  @override
  final Size size;
  @override
  String? getCharAt(Position position) {
    if (position.x == 1) {
      if (position.y == 1) {
        return topLeft;
      } else if (position.y == size.height) {
        return bottomLeft;
      }
      return vertical;
    } else if (position.x == size.width) {
      if (position.y == 1) {
        return topRight;
      } else if (position.y == size.height) {
        return bottomRight;
      }
      return vertical;
    } else if (position.y == 1 || position.y == size.height) {
      return horizontal;
    }

    return child.getCharAt(Position(position.x - 1, position.y - 1));
    // return message[position.x - 2];
  }

  @override
  MatrixView generateMatrix() {
    return MatrixView(source: buildPositionArray().toList());
  }

  Iterable<PositionedValue<String>> buildPositionArray() sync* {
    for (int x = 1; x <= size.width; x++) {
      for (int y = 1; y <= size.height; y++) {
        yield PositionedValue(
          x,
          y,
          getCharAt(
                Position(x, y),
              ) ??
              '',
        );
      }
    }
  }

  final TerminalView child;

  DecoratedBox({
    required this.child,
    this.horizontal = '═',
    this.vertical = '║',
    this.topLeft = '╔',
    this.topRight = '╗',
    this.bottomLeft = '╚',
    this.bottomRight = '╝',
  }) : size = Size(child.size.width + 2, child.size.height + 2);

  @override
  List<PositionedValue<String>> get source => buildPositionArray().toList();
}

class MessageBox implements TerminalView {
  final List<String> lines;
  final String text;
  MessageBox({
    required this.text,
  }) : lines = text.split('\n');
  Iterable<PositionedValue<String>> buildPositionArray() sync* {
    for (int x = 1; x <= size.width; x++) {
      for (int y = 1; y <= size.height; y++) {
        yield PositionedValue(
          x,
          y,
          getCharAt(
                Position(x, y),
              ) ??
              '',
        );
      }
    }
  }

  @override
  MatrixView generateMatrix() => MatrixView(source: source);

  @override
  String? getCharAt(Position position) {
    return (lines.elementAtOrNull(position.y - 1) ?? '').split('').elementAtOrNull(position.x - 1);
  }

  @override
  Size get size => Size(
        lines.map((e) => e.length).max,
        lines.length,
      );

  @override
  List<PositionedValue<String>> get source => buildPositionArray().toList();
}
