import 'package:args/args.dart';

import './internal/environments.dart';
import './internal/variables.dart';

Future<void> main(List<String> arguments) async {

    final parser = ArgParser()
        ..addOption('environment', abbr: 'e', help: 'Set the current label environment')
        ..addFlag('sync', abbr: 's', negatable: false, help: 'Sync the project build files with the environments')
        ..addFlag('prod', abbr: 'p', negatable: false, help: 'Set the current debug environment')
        ..addFlag('clean', abbr: 'c', negatable: false, help: 'Clean the project');

    final ArgResults result = parser.parse(arguments);

    if(result['sync']){
        sync(result['environment']);
        return;
    } 

    if(result['clean']){
        clean();
        return;
    } 

    if(result['environment'] != null){
        runEnvironment(result['environment']); 
        runVariables(result['environment'], result['prod']); 
        return;
    }
}
