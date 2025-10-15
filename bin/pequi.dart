import 'package:args/command_runner.dart';
import 'package:pequi/src/internal.dart';

Future<void> main(List<String> arguments) async {
  CommandRunner(
      "pequi", "Pequi is a enviroment manager package that allow you to white label your application as you like")
    ..addCommand(EnvironmentCommand())
    ..addCommand(SyncCommand())
    ..run(arguments);
}
