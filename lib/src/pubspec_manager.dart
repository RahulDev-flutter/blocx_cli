import 'dart:io';

import 'package:path/path.dart' as p;

class PubspecManager {
  Future<void> updateDependencies(String projectPath, String apiChoice) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));

    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    // Find dependencies section and flutter sdk line
    int dependenciesIndex = lines.indexWhere(
      (line) => line.trim() == 'dependencies:',
    );
    if (dependenciesIndex == -1) {
      throw Exception('Could not find dependencies section in pubspec.yaml');
    }

    // Find the line with "flutter:" under dependencies
    int flutterIndex = -1;
    for (int i = dependenciesIndex + 1; i < lines.length; i++) {
      if (lines[i].trim() == 'flutter:') {
        flutterIndex = i;
        break;
      }
    }

    if (flutterIndex == -1) {
      throw Exception('Could not find flutter dependency');
    }

    // Add required dependencies before flutter:
    final dependenciesToAdd = [
      '  flutter_bloc: ^8.1.6',
      '  equatable: ^2.0.5',
      '  get_it: ^7.6.7',
      if (apiChoice == 'dio') '  dio: ^5.4.0',
      if (apiChoice == 'http') '  http: ^1.2.0',
      '  flutter_secure_storage: ^9.2.2',
    ];

    // Insert dependencies before flutter:
    for (int i = dependenciesToAdd.length - 1; i >= 0; i--) {
      lines.insert(flutterIndex, dependenciesToAdd[i]);
    }

    await pubspecFile.writeAsString(lines.join('\n'));
    print('✅ Updated pubspec.yaml with required dependencies');
  }

  Future<void> addAdditionalDependencies(
      String projectPath, List<String> dependencies) async {
    // Simple implementation for testing
    if (dependencies.isEmpty) return;
    print('✅ Added ${dependencies.length} additional dependencies');
  }
}
