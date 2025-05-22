import 'dart:io';
import 'package:yaml/yaml.dart';
import 'dart:isolate';
import '../../config/files.dart';

Map<String, dynamic> feedbackColors = {
    'disabled': '#E7E7E7',
    'success':  '#66BD50',
    'warning':  '#EBBC46',
    'error':    '#DE4841',
};

Map<String, dynamic> typoColors = {
    'title':        '#070707',
    'titleLight':   '#FFFFFF',
    'subTitle':     '#313131',
    'subTitleLight':'#808080', 
};

Map<String, dynamic> defaultColors = {
    'background':       '#FFFFFF',
    'container':        '#F6F6F6',
    'border':           '#E7E7E7',
    'neutral40':        '#CECECE',
    'neutral20':        '#F1F1F1',
    'transparency20':   '#00000020',
    'transparency50':   '#00000050',
};

Future<void> generateColorsStatic({required Map<String, dynamic> colors, required String type, required String className}) async{

  final outputResolved = await Isolate.resolvePackageUri(
    Uri.parse('package:pequi/theme/$type.dart'),
  );

  if (outputResolved == null) {
    print('Not found: package:pequi/theme/$type.dart');
    exit(1);
  }

  final outputFile = File(outputResolved.toFilePath());

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED FILE - DO NOT MODIFY BY HAND');
  buffer.writeln('// Generated from environments.yaml');
  buffer.writeln();
  buffer.writeln('import \'package:flutter/material.dart\';');
  buffer.writeln();
  buffer.writeln('class $className {');

  var i = 0;
  for (final color in colors.entries) {
    buffer.writeln('  static const ${color.key} = Color(0xFF${_hex(color.value)});');
    if (i == 3) {
        break;
    }
  }
  buffer.writeln('}');

  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(buffer.toString());

  // print('Generated: ${outputFile.path}');
}

Future<void> generateColorsFromYAML() async{

  final yamlFile = File(filePath);

  final outputResolved = await Isolate.resolvePackageUri(
    Uri.parse('package:pequi/theme/brand.dart'),
  );

  if (outputResolved == null) {
    print('Not found: package:pequi/theme/brand.dart');
    exit(1);
  }

  final outputFile = File(outputResolved.toFilePath());

  final content = yamlFile.readAsStringSync();
  final doc = loadYaml(content);

  final env = doc['environments']['guild'];
  final colors = env['colors'];

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED FILE - DO NOT MODIFY BY HAND');
  buffer.writeln('// Generated from environments.yaml');
  buffer.writeln();
  buffer.writeln('import \'package:flutter/material.dart\';');
  buffer.writeln();
  buffer.writeln('class BrandColors {');
  buffer.writeln('  static const primary = Color(0xFF${_hex(colors['primary'])});');
  buffer.writeln('  static const secondary = Color(0xFF${_hex(colors['secondary'])});');
  buffer.writeln('  static const accent = Color(0xFF${_hex(colors['accent'])});');
  buffer.writeln('}');

  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(buffer.toString());

  // print('Generated: ${outputFile.path}');
}

String _hex(String hexColor) {
  return hexColor.replaceFirst('#', '').padLeft(6, '0').toUpperCase();
}

void generateColors(){
    // Generation colors from the YAML file
    generateColorsFromYAML();

    // Generation colors from the static files
    generateColorsStatic(colors: defaultColors, type: 'default', className: 'DefaultColors');
    generateColorsStatic(colors: typoColors, type: 'typo', className: 'TypoColors');
    generateColorsStatic(colors: feedbackColors, type: 'feedback', className: 'FeedbackColors');

    

}
