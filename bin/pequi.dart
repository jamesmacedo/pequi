import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:args/args.dart';

const String filePath = 'environments.yaml';
const String baseDirectory = 'environments';
const Map<String, String> neededFolders = {
    'assets': 'assets', 'config': 'lib/config', 
    'build/res': 'android/app/src/main/res',
    'build/AppIcon.appiconset': 'ios/Runner/Assets.xcassets/AppIcon.appiconset',
    //build files
    'build/AndroidManifest.xml': 'android/app/src/main/AndroidManifest.xml',
    'build/project.pbxproj': 'ios/Runner.xcodeproj/project.pbxproj',
    'build/build.gradle': 'android/app/build.gradle',
};

Future<bool> checkDirectory(String path) async {
  final dir = Directory(path);
  return await dir.exists();
}

Future<void> clean() async {
  for (var targ in neededFolders.values.toList()) {
    var targetFile = File(targ);
    var target = Directory(targ);

    print('Trying to remove the target: $targ');

    if (await target.exists() || await targetFile.exists()) {
        try {
            await target.delete(recursive: true);
            print('Target removed with success');
        } catch (e) {
            print('Error while trying to remove the target: $e');
        }
    } else {
        print('Target does not exist.');
    }      
  }  
}

Future<void> createSymbolicLink(String targetPath, String linkPath) async {
  try {
    final absoluteTargetPath = Directory(targetPath).absolute.path;
    final link = Link(linkPath);

    if (!await Directory(targetPath).exists() && !await File(targetPath).exists()) {
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

Future<void> runCommand(List<String> command) async {
  try {
    print('Running command: ${command.join(' ')}');
    final result = await Process.run(command[0], command.sublist(1));

    if (result.exitCode == 0) {
      print('Command executed successfully:\n${result.stdout}');
    } else {
      print('Command failed with exit code ${result.exitCode}:\n${result.stderr}');
    }
  } catch (e) {
    print('Error executing command: $e');
  }
}

runEnvironment(List<String> arguments) async {

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
    // await createSymbolicLink('$baseDirectory/$configPath/$folderKey', neededFolders[folderKey]!);
    await copyFileOrDirectory('$baseDirectory/$configPath/$folderKey', neededFolders[folderKey]!);
  }

  if (arguments.contains('--icons')){
    print('Changing the icons with flutter_launcher_icons');
    await runCommand(['dart', 'pub', 'run', 'flutter_launcher_icons:main']);
  }

}

Future<void> copyFileOrDirectory(String sourcePath, String destinationPath) async {
  final sourceFile = File(sourcePath); 
  final sourceDir = Directory(sourcePath); 

  try {
    final destination = Directory(destinationPath);

    if (await sourceFile.exists()) {
      print('Target file found: $sourcePath');
      await copyFile(sourceFile, destinationPath);
    } else if (await sourceDir.exists()) {
      print('Target directory found: $sourcePath');
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
        final targetPath = '${destination.path}/${entity.uri.pathSegments[entity.uri.pathSegments.length-2]}';
      await copyDirectory(entity, Directory(targetPath));
    } else if (entity is File) {
        final targetPath = '${destination.path}/${entity.uri.pathSegments.last}';
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
  print('Arquivo copiado: ${source.path} -> $destinationPath');
}

Future<void> main(List<String> arguments) async {
    switch(arguments[0]) {
        case "clean":
            clean();
            return;
        case "-e":
            clean();
            runEnvironment(arguments); 
            return;
    }

  // // to run android package rename
  // await runCommand([
  //   'dart',
  //   'run',
  //   'change_app_package_name:main',
  //   data['environments'][environment]['packages']['android'],
  //   '--android'
  // ]);
  //
  // // to run ios package rename
  // await runCommand([
  //   'dart',
  //   'run',
  //   'change_app_package_name:main',
  //   data['environments'][environment]['packages']['ios'],
  //   '--ios'
  // ]);
}
