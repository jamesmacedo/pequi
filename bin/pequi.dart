import 'package:args/command_runner.dart';
import 'package:pequi/src/internal.dart';

Future<void> main(List<String> arguments) async {
  // final parser = ArgParser()
  //     ..addFlag('sync', abbr: 's', negatable: false, help: 'Sync the project build files with the environments')
  //     ..addFlag('clean', abbr: 'c', negatable: false, help: 'Clean the project');
  //
  // final ArgResults result = parser.parse(arguments);
  //
  // if(result['sync']){
  //     return;
  // }

  var runner = CommandRunner(
      "pequi", "A dart tool to help with flutter app whitelabeling")
    ..addCommand(EnvironmentCommand())
    ..addCommand(SyncCommand())
    ..run(arguments);
}
