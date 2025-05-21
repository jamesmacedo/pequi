import 'dart:io';
import 'package:yaml/yaml.dart';
import 'dart:isolate';
import '../../config/files.dart';

Future<void> generateColors() async{

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
  buffer.writeln('// Generated from colors.yaml');
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
