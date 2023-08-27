import 'cli.dart';

const exitFlag = -9999;

class Hal {
  static final Hal _instance = Hal._();
  late Konsole _konsole;

  factory Hal() => _instance;
  Hal._();

  void setAdapter(Konsole konsole) {
    _konsole = konsole;
  }

  void shutdown() => _konsole.shutdown();
  void clearScreen() => _konsole.clearScreen();
  int? readKey() => _konsole.readKey();
  void render(int row, int col, String value) => _konsole.render(row, col, value);
}
