
const String filePath = 'environments.yaml';
const String baseDirectory = 'environments';

const Map<String, String> neededFolders = {
    'assets': 'assets', 
    'shorebird.yaml': 'shorebird.yaml',
    'config': 'lib/config', 
    'build/res': 'android/app/src/main/res',
    'build/AppIcon.appiconset': 'ios/Runner/Assets.xcassets/AppIcon.appiconset',
    //build files
    'build/AndroidManifest.xml': 'android/app/src/main/AndroidManifest.xml',
    'build/project.pbxproj': 'ios/Runner.xcodeproj/project.pbxproj',
    'build/build.gradle': 'android/app/build.gradle',
};
