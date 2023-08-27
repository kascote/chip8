import 'hal/hal.dart';

class Render {
  final cols = 64;
  final rows = 32;
  late final int screenSize;
  late List<int> pixels;
  late Hal hal;
  final colOffset = 1;
  final rowOffset = 1;

  Render() {
    hal = Hal();
    screenSize = cols * rows; // 2048
    pixels = List.filled(screenSize, 0);
  }

  void setup() {
    final roundedBorders = ["╭", "─", "╮", "│", "╯", "─", "╰", "│"];
    final finalCols = cols + colOffset;
    final finalRows = rows + rowOffset;
    hal.render(0, 0, roundedBorders[0]);
    hal.render(0, finalCols, roundedBorders[2]);
    hal.render(finalRows, 0, roundedBorders[6]);
    hal.render(finalRows, finalCols, roundedBorders[4]);
    for (var i = colOffset; i < finalCols; i++) {
      hal.render(0, i, roundedBorders[1]);
      hal.render(finalRows, i, roundedBorders[1]);
    }
    for (var i = rowOffset; i < finalRows; i++) {
      hal.render(i, 0, roundedBorders[3]);
      hal.render(i, finalCols, roundedBorders[7]);
    }
  }

  // According to the technical reference, if a pixel is positioned outside of
  // the bounds of the display, it should wrap around to the opposite side
  bool setPixel(int row, int col) {
    if (row > rows - 1) {
      row -= rows;
    } else if (row < 0) {
      row += rows;
    }

    if (col > cols - 1) {
      col -= cols;
    } else if (col < 0) {
      col += cols;
    }

    final pixelLoc = col + (row * cols);
    pixels[pixelLoc] ^= 1;

    // returns true if a pixel was erased
    return pixels[pixelLoc] == 0;
  }

  void resetScreen() => hal.clearScreen();

  void clear() {
    pixels = List.filled(screenSize, 0);
    setup();
  }

  void render() {
    for (var i = 0; i < screenSize; i++) {
      // Grabs the x position of the pixel based off of `i`
      final col = (i % cols);
      // Grabs the y position of the pixel based off of `i`
      final row = (i ~/ cols);

      hal.render(row + rowOffset, col + colOffset, pixels[i] == 0 ? ' ' : '█');
    }
  }

  void testRender() {
    setPixel(0, 0);
    setPixel(5, 0);
    setPixel(5, 63);
    setPixel(31, 63);
    setPixel(32, 64);
  }
}
