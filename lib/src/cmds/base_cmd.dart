import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';

import '../constants.dart';

class BaseCommand extends Command<int> {
  BaseCommand() {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Verbose output',
    );
  }

  @override
  String get description => throw UnimplementedError();

  @override
  String get name => throw UnimplementedError();

  @override
  Future<int> run() async {
    if (argResults!['verbose'] as bool) {
      Logger.root.level = Level.ALL;
    }
    return Future.value(exitSuccessCode);
  }
}
