import 'hal/hal.dart';

final keyMap = {
  49: 0x1, // 1
  50: 0x2, // 2
  51: 0x3, // 3
  52: 0xC, // 4
  81: 0x4, // Q
  87: 0x5, // W
  69: 0x6, // E
  82: 0xD, // R
  65: 0x7, // A
  83: 0x8, // S
  68: 0x9, // D
  70: 0xE, // F
  90: 0xA, // Z
  88: 0x0, // X
  67: 0xB, // C
  86: 0xF // V
};

typedef OnNextKeyPressed = void Function(int);

class Keyboard {
  Hal hal;

  final List<bool> _keysPressed = List.filled(keyMap.length, false);
  int? _chipKey;

  // Some Chip-8 instructions require waiting for the next key press.
  OnNextKeyPressed? onNextKeyPress;
  var isExit = false;

  Keyboard() : hal = Hal();

  bool isKeyPressed(int key) => _keysPressed[key];

  void senseKey() {
    final key = hal.readKey();
    isExit = key == exitFlag;

    if (!keyMap.containsKey(key)) return;

    _chipKey = keyMap[key]!;
    _keysPressed[_chipKey!] = true;
  }

  void senseEnd() {
    if (onNextKeyPress != null && _chipKey != null) {
      onNextKeyPress!(_chipKey!);
      onNextKeyPress = null;
    }

    _chipKey = null;
    _keysPressed.fillRange(0, _keysPressed.length, false);
  }
}
