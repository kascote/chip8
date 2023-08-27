import 'dart:io';
import 'package:dart_console/dart_console.dart';

import 'hal.dart';

abstract class Konsole {
  void shutdown();
  void clearScreen();
  int? readKey();
  void render(int row, int col, String value);
}

class CliConsole extends Konsole {
  static final CliConsole _instance = CliConsole._();

  factory CliConsole() => _instance;
  late Console _console;

  CliConsole._() {
    _console = Console();
    _console.rawMode = true;
    _console.hideCursor();
  }

  @override
  void shutdown() {
    _console.rawMode = false;
    _console.showCursor();
  }

  @override
  void clearScreen() => _console.clearScreen();

  @override
  int? readKey() {
    final key = stdin.readByteSync();
    if (key <= 0) {
      return null;
    }

    if (String.fromCharCode(key) == 'q') {
      return exitFlag;
    }

    return null;
  }

  @override
  void render(int row, int col, String value) {
    _console.cursorPosition = Coordinate(row, col);
    _console.write(value);
  }
}
