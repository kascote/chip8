import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';

import 'package:chip8/chip8_cli.dart';

Future<void> main(List<String> arguments) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  final cmd = CommandRunner<int>('chip8', 'Yet another chip8 emulator')..addCommand(RomCmd());

  await cmd.run(arguments).catchError((Object error, StackTrace stackTrace) {
    // ignore: only_throw_errors
    if (error is! UsageException && error is! ArgumentError) {
      stderr
        ..writeln('$error (${error.runtimeType})')
        ..writeln(stackTrace);
    } else {
      stderr.writeln('Error: $error');
    }
    exit(128);
  });
}
