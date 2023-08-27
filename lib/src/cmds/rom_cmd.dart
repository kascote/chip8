import 'dart:io';

import '../chip8.dart';
import './base_cmd.dart';
import '../constants.dart';

class RomCmd extends BaseCommand {
  RomCmd() {
    argParser.addOption(
      'rom',
      abbr: 'r',
      help: 'path to the rom file',
      mandatory: true,
    );
  }

  @override
  final name = 'run';
  @override
  final description = 'execute a rom file';

  @override
  Future<int> run() async {
    await super.run();

    final args = argResults!;
    final romFilePath = args['rom'] as String;

    var romFile = File(romFilePath);
    if (!romFile.existsSync()) {
      stdout.writeln('rom file not found');
      return exitErrorCode;
    }

    final c8 = Chip8();
    c8.loadRomFromFile(romFile);
    c8.run();

    return exitSuccessCode;
  }
}
