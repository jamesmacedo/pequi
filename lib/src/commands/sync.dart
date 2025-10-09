import 'package:args/command_runner.dart';
import 'package:pequi/src/internal/environments.dart';
import 'package:barrel_files_annotation/barrel_files_annotation.dart';

@includeInBarrelFile
class SyncCommand extends Command {
  final name = "sync";
  final description = "";

  SyncCommand() {}

  void run() {
    if (argResults!.rest.isEmpty) {
      print('❌ You need to pass the environment name.');
      print('Exemple: pequi environment company');
      return;
    }
    final environment = argResults!.rest.first;
    sync(environment);
  }
}
