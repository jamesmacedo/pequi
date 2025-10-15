import 'package:yaml/yaml.dart';
import 'package:pequi/src/config/files.dart';
import 'package:pequi/src/generated/variables/internal.dart';

import 'package:flutter/services.dart' show rootBundle;

class PequiFlags {
  static dynamic _flags;

  static Future<void> initialize() async {
    final content = await rootBundle.loadString(filePath);
    _flags = loadYaml(content);
  }

    static bool can(dynamic feature) {
    if (_flags == null) {
      throw Exception('Pequi not initialized. Call PequiFlags.init() first.');
    }

    final isProd = PequiVariables.isProd;
    final env = isProd ? 'prod' : 'dev';

    final prodFlags = List<String>.from(_flags!['features']['prod'] ?? []);
    final devFlags = List<String>.from(_flags!['features']['dev'] ?? []);

    final availableFlags = isProd ? prodFlags : [...prodFlags, ...devFlags];

    final envExcludes = List<String>.from(
      _flags!['environments']?[PequiVariables.environment]?['exclude'] ?? [],
    );

    bool checkFeature(String input) {
      if (isProd && envExcludes.contains(input)) {
        return false;
      }

      return availableFlags.contains(input);
    }

    return checkFeature(feature);
  }
}
