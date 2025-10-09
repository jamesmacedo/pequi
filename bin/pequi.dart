import 'package:args/command_runner.dart';
import 'package:pequi/src/internal.dart';

Future<void> main(List<String> arguments) async {
  var runner = CommandRunner(
      "pequi", "A dart tool to help with flutter app whitelabeling")
    ..addCommand(EnvironmentCommand())
    ..addCommand(SyncCommand())
    ..run(arguments);
}
