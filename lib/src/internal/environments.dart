import 'dart:io';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

import 'package:pequi/src/internal.dart';
import 'package:pequi/src/tui/loading.dart';
import 'package:pequi/src/internal/colors.dart';
import 'package:pequi/src/config/files.dart';
import 'package:barrel_files_annotation/barrel_files_annotation.dart';

@includeInBarrelFile
class EnvironmentService {
  Future<bool> checkDirectory(String path) async {
    final dir = Directory(path);
    return await dir.exists();
  }

  Future<void> sync(String environment) async {
    print("Syncing...");
    if (await checkDirectory('environments') == false) {
      print(
          'The environments folder does not exist in this project, please create one');
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      print('Environment file "$filePath" not found.');
      return;
    }

    final content = await file.readAsString();
    final data = loadYaml(content);

    if (!data['environments'].containsKey(environment)) {
      print('Environment "$environment" does not exist.');
      return;
    }

    final configPath = environment;

    for (var folderKey in neededFolders.keys.toList()) {
      final loading = Loading(text: 'Copying $folderKey');
      loading.start();
      await copyFileOrDirectory(
          neededFolders[folderKey]!, '$baseDirectory/$configPath/$folderKey');
      loading.stop();
    }

    ColorService().generateColors(environment);
  }

  Future<void> clean() async {
    final loading = Loading(text: 'Cleaning project');
    loading.start();

    for (var targ in neededFolders.values.toList()) {
      var targetFile = File(targ);
      var target = Directory(targ);

      if (await target.exists() || await targetFile.exists()) {
        try {
          await target.delete(recursive: true);
        } catch (e) {
          print('Error while trying to remove the target: $e');
        }
      } else {
        print('Target does not exist.');
      }
    }
    loading.stop();
  }

  Future<void> createSymbolicLink(String targetPath, String linkPath) async {
    try {
      final absoluteTargetPath = Directory(targetPath).absolute.path;
      final link = Link(linkPath);

      if (!await Directory(targetPath).exists() &&
          !await File(targetPath).exists()) {
        throw Exception('The target path does not exist: $absoluteTargetPath');
      }

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

  copyInfoPlist(String fileOrigin, String fileDestination) {
    final File origin = File(fileOrigin);

    final content = origin.readAsStringSync();

    final document = XmlDocument.parse(content);
    final dict = document.findAllElements('dict').first;

    final keys = dict.findElements('key').toList();

    for (int i = 0; i < keys.length; i++) {
      if (keys[i].innerText == 'CFBundleDisplayName') {
        final valueNode = keys[i].nextElementSibling!;
        valueNode.innerText = '[Dev] ${valueNode.innerText}';
        break;
      }
    }

    final File destination = File(fileDestination);

    destination.createSync(recursive: true);

    destination
        .writeAsStringSync(document.toXmlString(pretty: true, indent: '  '));
  }

  Future<void> run(String label, bool isProd) async {
    if (await checkDirectory('environments') == false) {
      print(
          'The environments folder does not exist in this project, please create one');
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      print('Environment file "$filePath" not found.');
      return;
    }

    final content = await file.readAsString();
    final data = loadYaml(content);

    String keys = data['environments'].keys.toList().join(', ');

    if (label == null) {
      print(
          'Please enter one of the following available company codes using the -e flag: [$keys]');
      return;
    }

    if (!data['environments'].containsKey(label)) {
      print('Environment "$label" does not exist.');
      return;
    }

    final configPath = label;

    await clean();

    for (var folderKey in neededFolders.keys.toList()) {
      final loading = Loading(text: 'Copying $folderKey');
      loading.start();

      if (folderKey == 'build/Info.plist' && isProd == false) {
        copyInfoPlist(
            '$baseDirectory/$configPath/$folderKey', neededFolders[folderKey]!);
      } else {
        await copyFileOrDirectory(
            '$baseDirectory/$configPath/$folderKey', neededFolders[folderKey]!);
      }

      //[yan]: Not in use
      // await copyFileOrDirectory('$baseDirectory/$configPath/$folderKey', neededFolders[folderKey]!);
      loading.stop();
    }

    ColorService().generateColors(label);
  }

  Future<void> copyFileOrDirectory(
      String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    final sourceDir = Directory(sourcePath);

    try {
      final destination = Directory(destinationPath);

      if (await sourceFile.exists()) {
        await copyFile(sourceFile, destinationPath);
      } else if (await sourceDir.exists()) {
        await copyDirectory(sourceDir, destination);
      } else {
        throw Exception('File or directory not found: $sourcePath');
      }
    } catch (e) {
      print('Error while trying to copy: $e');
    }
  }

  Future<void> copyDirectory(Directory source, Directory destination) async {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    await for (var entity in source.list()) {
      if (entity is Directory) {
        final targetPath =
            '${destination.path}/${entity.uri.pathSegments[entity.uri.pathSegments.length - 2]}';
        await copyDirectory(entity, Directory(targetPath));
      } else if (entity is File) {
        final targetPath =
            '${destination.path}/${entity.uri.pathSegments.last}';
        await copyFile(entity, targetPath);
      }
    }
  }

  Future<void> copyFile(File source, String destinationPath) async {
    final destinationFile = File(destinationPath);

    if (await destinationFile.exists()) {
      await destinationFile.delete();
    }

    await source.copy(destinationPath);
  }
}
