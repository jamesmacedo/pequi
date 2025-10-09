import 'package:pequi/src/internal.dart';
import 'package:args/command_runner.dart';
import 'package:pequi/src/internal/environments.dart';
import 'package:barrel_files_annotation/barrel_files_annotation.dart';

@includeInBarrelFile
class EnvironmentCommand extends Command {
  final name = "environment";
  final description = "";

  EnvironmentCommand() {
    argParser.addFlag('prod',
        abbr: 'p', negatable: false, help: 'Set the current debug environment');
  }

  void run() {
    if (argResults!.rest.isEmpty) {
      print('❌ You need to pass the environment name.');
      print('Exemple: pequi environment company --prod');
      return;
    }

    final environment = argResults!.rest.first;
    final isProd = argResults!['prod'] as bool;

    EnvironmentService().run(environment, isProd);
    VariableService().run(environment, isProd); 
  }
}
