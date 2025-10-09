import 'dart:io';
import 'package:yaml/yaml.dart';
import 'dart:isolate';
import 'package:pequi/src/config/files.dart';
import 'package:barrel_files_annotation/barrel_files_annotation.dart';

@includeInBarrelFile
class VariableService {
  Future<void> run(String environment, bool isProd) async {
    final yamlFile = File(filePath);

    final outputResolved = await Isolate.resolvePackageUri(
      Uri.parse('package:pequi/src/generated/variables/internal.dart'),
    );

    if (outputResolved == null) {
      print('Not found: package:pequi/src/generated/variables/internal.dart');
      exit(1);
    }

    final outputFile = File(outputResolved.toFilePath());

    final content = yamlFile.readAsStringSync();
    final config = loadYaml(content);

    final buffer = StringBuffer();

    final selectedEnv = isProd ? 'prod' : 'dev';

    void defineVariables(dynamic variables, String selectedEnv, var buffer) {
      if (variables == null) return;

      for (var key in variables.keys) {
        final envMap = variables[key];
        if (envMap is Map && envMap.containsKey(selectedEnv)) {
          buffer.writeln('  static const $key = "${envMap[selectedEnv]}";');
        } else {
          buffer.writeln('  static const $key = "$envMap";');
        }
      }
    }

    buffer.writeln('// GENERATED FILE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated from environments.yaml');
    buffer.writeln();
    buffer.writeln('class PequiVariables {');
    buffer.writeln('  static const isProd = ${isProd};');
    defineVariables(config['global']['variables'], selectedEnv, buffer);
    defineVariables(config['environments']?[environment]?['variables'],
        selectedEnv, buffer);
    buffer.writeln('}');
    outputFile.createSync(recursive: true);
    outputFile.writeAsStringSync(buffer.toString());
  }
}
