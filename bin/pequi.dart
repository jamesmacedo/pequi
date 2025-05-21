import 'dart:io';
import 'package:args/args.dart';

import './internal/environments.dart';

Future<void> main(List<String> arguments) async {

    final parser = ArgParser()
        ..addOption('environment', abbr: 'e', help: 'Set the current label environment')
        ..addFlag('clean', abbr: 'c', negatable: false, help: 'Clean the project');

    final ArgResults result = parser.parse(arguments);

    if(result['clean']){
        clean();
        return;
    } 

    if(result['environment'] != null){
        runEnvironment(result); 
        return;
    }
}
