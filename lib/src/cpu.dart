import 'dart:typed_data';
import 'dart:math';

import './keyboard.dart';
import './render.dart';
import './shared/stack.dart';

// 4kb of memory
final memorySize = 4096;
final registersLength = 16;
final initialPC = 0x200;

// final log = Logger('PlanetLogger');

class Cpu {
  late Render render;
  late Keyboard keyboard;
  final memory = Uint8List(memorySize);
  // 16 8-bit registers
  final registers = Uint8List(registersLength);
  // Timers
  int delayTimer = 0;
  int soundTimer = 0;
  // PC
  int pc = initialPC;
  Stack<int> stack = Stack<int>();
  bool paused = false;
  int speed = 50;
  // Stores memory addresses.
  int i = 0;

  Cpu({
    required this.render,
    required this.keyboard,
  }) {
    _loadSpritesIntoMemory();
  }

  void cycle() {
    keyboard.senseKey();

    // speed is the number of instructions to execute per cycle
    for (var o = 0; o < speed; o++) {
      if (!paused) {
        final opcode = memory[pc] << 8 | memory[pc + 1];
        _executeOpcode(opcode);
      }
    }

    if (!paused) {
      if (delayTimer > 0) delayTimer--;
      if (soundTimer > 0) soundTimer--;
    }

    render.render();
    keyboard.senseEnd();
  }

  void loadProgramIntoMemory(Uint8List program) {
    if (program.length > memorySize - initialPC) {
      throw Exception('Program too large to fit in memory');
    }
    memory.fillRange(initialPC, memorySize - initialPC, 0);
    // Load the program into memory
    memory.setRange(initialPC, initialPC + program.length, program);
  }

  // According to the technical reference, sprites are stored in the
  // interpreter section of memory starting at hex 0x000
  void _loadSpritesIntoMemory() {
    const sprites = [
      0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
      0x20, 0x60, 0x20, 0x20, 0x70, // 1
      0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
      0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
      0x90, 0x90, 0xF0, 0x10, 0x10, // 4
      0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
      0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
      0xF0, 0x10, 0x20, 0x40, 0x40, // 7
      0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
      0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
      0xF0, 0x90, 0xF0, 0x90, 0x90, // A
      0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
      0xF0, 0x80, 0x80, 0x80, 0xF0, // C
      0xE0, 0x90, 0x90, 0x90, 0xE0, // D
      0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
      0xF0, 0x80, 0xF0, 0x80, 0x80 // F
    ];

    for (var o = 0; o < sprites.length; o++) {
      memory[o] = sprites[o];
    }
  }

  // nnn or addr - A 12-bit value, the lowest 12 bits of the instruction
  // n or nibble - A 4-bit value, the lowest 4 bits of the instruction
  // x - A 4-bit value, the lower 4 bits of the high byte of the instruction
  // y - A 4-bit value, the upper 4 bits of the low byte of the instruction
  // kk or byte - An 8-bit value, the lowest 8 bits of the instruction
  void _executeOpcode(int opcode) {
    // Increment the program counter to prepare it for the next instruction.
    // Each instruction is 2 bytes long, so increment it by 2.
    pc += 2;
    // We only need the 2nd nibble, so grab the value of the 2nd nibble
    // and shift it right 8 bits to get rid of everything but that 2nd nibble.
    final x = (opcode & 0x0F00) >> 8;

    // We only need the 3rd nibble, so grab the value of the 3rd nibble
    // and shift it right 4 bits to get rid of everything but that 3rd nibble.
    final y = (opcode & 0x00F0) >> 4;

    switch (opcode & 0xF000) {
      case 0x0000:
        switch (opcode) {
          case 0x00E0: // CLS
            render.clear();
            break;
          case 0x00EE: // RET
            if (stack.isNotEmpty) {
              pc = stack.pop()!;
            }
            break;
        }
        break;
      case 0x1000: // JP addr
        pc = (opcode & 0xFFF);

        break;
      case 0x2000: // CALL addr
        stack.push(pc);
        pc = (opcode & 0xFFF);
        break;
      case 0x3000: // SE Vx, byte
        if (registers[x] == (opcode & 0xFF)) {
          pc += 2;
        }
        break;
      case 0x4000: // SNE Vx, byte
        if (registers[x] != (opcode & 0xFF)) {
          pc += 2;
        }
        break;
      case 0x5000: // SE Vx, Vy
        if (registers[x] == registers[y]) {
          pc += 2;
        }
        break;
      case 0x6000: // LD Vx, byte
        registers[x] = (opcode & 0xFF);
        break;
      case 0x7000: // ADD Vx, byte
        registers[x] += (opcode & 0xFF);
        break;
      case 0x8000:
        switch (opcode & 0xF) {
          case 0x0: // LD Vx, Vy
            registers[x] = registers[y];
            break;
          case 0x1: // OR Vx, Vy
            registers[x] |= registers[y];
            break;
          case 0x2: // AND Vx, Vy
            registers[x] &= registers[y];
            break;
          case 0x3: // XOR Vx, Vy
            registers[x] ^= registers[y];
            break;
          case 0x4: // ADD Vx, Vy
            final sum = (registers[x] += registers[y]);
            registers[0xF] = 0;
            if (sum > 0xFF) {
              registers[0xF] = 1;
            }
            registers[x] = sum;
            break;
          case 0x5: // SUB Vx, Vy
            registers[0xF] = 0;
            if (registers[x] > registers[y]) {
              registers[0xF] = 1;
            }
            registers[x] -= registers[y];
            break;
          case 0x6: // SHR Vx {, Vy}
            registers[0xF] = (registers[x] & 0x1);
            registers[x] >>= 1;
            break;
          case 0x7: // SUBN Vx, Vy
            registers[0xF] = 0;
            if (registers[y] > registers[x]) {
              registers[0xF] = 1;
            }
            registers[x] = registers[y] - registers[x];
            break;
          case 0xE: // SHL Vx {, Vy}
            registers[0xF] = (registers[x] & 0x80);
            registers[x] <<= 1;
            break;
        }

        break;
      case 0x9000: // SNE Vx, Vy
        if (registers[x] != registers[y]) {
          pc += 2;
        }
        break;
      case 0xA000: // Annn - LD I, addr
        i = (opcode & 0xFFF);
        break;
      case 0xB000: // JP V0, addr
        pc = (opcode & 0xFFF) + registers[0];
        break;
      case 0xC000: // RND Vx, byte
        final rand = Random().nextInt(0xFF);
        registers[x] = rand & (opcode & 0xFF);
        break;
      case 0xD000: // DRW Vx, Vy, nibble
        final width = 8;
        final height = (opcode & 0xF);
        registers[0xF] = 0;

        for (var row = 0; row < height; row++) {
          var sprite = memory[i + row];

          for (var col = 0; col < width; col++) {
            // If the bit (sprite) is not 0, render/erase the pixel
            if ((sprite & 0x80) > 0) {
              // If setPixel returns 1, which means a pixel was erased, set VF to 1
              // if (render.setPixel(registers[x] + col, registers[y] + row)) {
              if (render.setPixel(registers[y] + row, registers[x] + col)) {
                registers[0xF] = 1;
              }
            }

            // Shift the sprite left 1. This will move the next next col/bit of the sprite into the first position.
            // Ex. 10010000 << 1 will become 0010000
            sprite <<= 1;
          }
        }
        break;
      case 0xE000:
        switch (opcode & 0xFF) {
          case 0x9E: // SKP Vx
            if (keyboard.isKeyPressed(registers[x])) {
              pc += 2;
            }
            break;
          case 0xA1: // SKNP Vx
            if (!keyboard.isKeyPressed(registers[x])) {
              pc += 2;
            }
            break;
        }
        break;
      case 0xF000:
        switch (opcode & 0xFF) {
          case 0x07: // LD Vx, DT
            registers[x] = delayTimer;
            break;
          case 0x0A: // LD Vx, K
            paused = true;
            keyboard.onNextKeyPress = (key) {
              registers[x] = key;
              paused = false;
            };
            break;
          case 0x15: // LD DT, Vx
            delayTimer = registers[x];
            break;
          case 0x18: // LD ST, Vx
            soundTimer = registers[x];
            break;
          case 0x1E: // ADD I, Vx
            i += registers[x];
            break;
          case 0x29: // LD F, Vx - ADD I, Vx
            i = registers[x] * 5;
            break;
          case 0x33: // LD B, Vx
            // Get the hundreds digit and place it in I.
            memory[i] = registers[x] ~/ 100;

            // Get tens digit and place it in I+1. Gets a value between 0 and 99,
            // then divides by 10 to give us a value between 0 and 9.
            memory[i + 1] = (registers[x] % 100) ~/ 10;

            // Get the value of the ones (last) digit and place it in I+2.
            memory[i + 2] = registers[x] % 10;
            break;
          case 0x55: // LD [I], Vx
            for (var registerIndex = 0; registerIndex <= x; registerIndex++) {
              memory[i + registerIndex] = registers[registerIndex];
            }
            break;
          case 0x65: // LD Vx, [I]
            for (var registerIndex = 0; registerIndex <= x; registerIndex++) {
              registers[registerIndex] = memory[i + registerIndex];
            }
            break;
        }

        break;

      default:
        throw Exception('Unknown opcode: $opcode');
    }
  }
}
