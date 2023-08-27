import 'shared/cycle.dart';
import 'hal/hal.dart';
import './cpu.dart';

class Debugger {
  Cpu cpu;
  late final Cycle<String> cycleStr;

  Debugger(this.cpu) {
    cycleStr = Cycle<String>(['tick', 'TICK']);
  }

  void render() {
    Hal().render(0, 80, cycleStr.cycle ?? '');
    showRegisters();
    showStatus();
    showPC();
    showAddress();
  }

  void showRegisters() {
    final xPos = 3;
    final yPos = 68;
    final h = Hal();
    h.render(xPos, yPos, 'Registers');
    for (var i = 0; i < registersLength; i++) {
      h.render(
        xPos + i + 1,
        yPos,
        '${i.toRadixString(16)}: 0x${cpu.registers[i].toRadixString(16)} / ${cpu.registers[i]} ',
      );
    }
  }

  void showStatus() {
    final h = Hal();
    h.render(0, 68, cpu.paused ? 'paused' : 'running');
  }

  void showPC() {
    final h = Hal();
    h.render(3, 80, 'PC');
    h.render(4, 80, '0x${cpu.pc.toRadixString(16)} / ${cpu.pc}');
    h.render(5, 80, '0x${cpu.stack.peek?.toRadixString(16)} / ${cpu.stack.peek}');
  }

  void showAddress() {
    final h = Hal();
    h.render(3, 100, 'Address');
    h.render(4, 100, '0x${cpu.i.toRadixString(16)}');
  }
}
