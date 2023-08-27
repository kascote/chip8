import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import './constants.dart';
import './cpu.dart';
import './debugger.dart';
import 'hal/hal.dart';
import './keyboard.dart';
import './render.dart';
import 'hal/cli.dart';

final tickTime = 1000 ~/ 60;

class Chip8 {
  late Cpu cpu;
  late Keyboard keyboard;
  late Render render;
  // Audio audio;
  late Debugger debugger;

  Chip8() {
    Hal().setAdapter(CliConsole());

    render = Render();
    keyboard = Keyboard();

    cpu = Cpu(
      keyboard: keyboard,
      render: render,
    );

    debugger = Debugger(cpu);
  }

  bool loadRomFromFile(File romFile) {
    final romBinary = Uint8List.fromList(romFile.readAsBytesSync());
    cpu.loadProgramIntoMemory(romBinary);

    return true;
  }

  void run() {
    Duration tickInterval = Duration(milliseconds: tickTime);

    cpu.render.resetScreen();
    // cpu.render.clear();

    Timer.periodic(tickInterval, (timer) {
      try {
        cpu.cycle();
        debugger.render();

        if (cpu.keyboard.isExit) {
          timer.cancel();
          shutdown();
        }
      } catch (e, st) {
        timer.cancel();
        shutdown();
        print(e);
        print(st);
        exit(exitSuccessCode);
      }
    });
  }

  void shutdown() {
    Hal().shutdown();
  }
}
