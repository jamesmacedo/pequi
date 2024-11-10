import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:args/args.dart';

const String filePath = 'environments.yaml';
const String baseDirectory = 'environments';
const Map<String, String> neededFolders = {'assets': 'assets', 'config': 'lib/config'};

Future<bool> checkDirectory(String path) async {
  final dir = Directory(path);
  return await dir.exists();
}

Future<void> createSymbolicLink(String targetPath, String linkPath) async {
  try {
    final absoluteTargetPath = Directory(targetPath).absolute.path;
    final link = Link(linkPath);

    if (!await Directory(targetPath).exists() && !await File(targetPath).exists()) {
      throw Exception('The target path does not exist: $absoluteTargetPath');
    }

    //check if the symbolic link exists
    if (await link.exists()) {
      await link.delete();
      print('Removed existing symbolic link: $linkPath');
    }

    await link.create(absoluteTargetPath);
    print('Created symbolic link: $linkPath -> $absoluteTargetPath');
  } catch (e) {
    print('Error while trying to create the symbolic link: $e');
  }
}

Future<void> main(List<String> arguments) async {
  if (await checkDirectory('environments') == false) {
    print('The environments folder does not exist in this project, please create one');
    return;
  }

  final file = File(filePath);
  if (!await file.exists()) {
    print('Environment file "$filePath" not found.');
    return;
  }

  final content = await file.readAsString();
  final data = loadYaml(content);

  final parser = ArgParser();

  String keys = data['environments'].keys.toList().join(', ');

  parser.addOption('environment', abbr: 'e', help: 'Enter the available company codes: [$keys]');

  final args = parser.parse(arguments);
  final environment = args['environment'];

  if (arguments.isEmpty) {
    print('Please enter one of the following available company codes: [$keys]');
    return;
  }

  if (environment == null) {
    print('Please enter one of the following available company codes using the -e flag: [$keys]');
    return;
  }

  if (!data['environments'].containsKey(environment)) {
    print('Environment "$environment" does not exist.');
    return;
  }

  final configPath = data['environments'][environment]['config'];

  for (var folderKey in neededFolders.keys.toList()) {
    await createSymbolicLink('$baseDirectory/$configPath/$folderKey', neededFolders[folderKey]!);
  }
}

