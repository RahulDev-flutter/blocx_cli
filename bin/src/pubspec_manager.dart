import 'dart:io';
import 'package:path/path.dart' as p;

import 'utils/cli_helpers.dart';

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

    // Define core dependencies based on API choice
    final coreDependencies = [
      '  # State Management',
      '  flutter_bloc: ^8.1.6',
      '  equatable: ^2.0.5',
      '',
      '  # Dependency Injection',
      '  get_it: ^7.6.7',
      '',
      '  # Network',
      if (apiChoice == 'dio') '  dio: ^5.4.0',
      if (apiChoice == 'http') '  http: ^1.2.0',
      '',
      '  # Storage',
      '  flutter_secure_storage: ^9.2.2',
      '',
      '  # Utils',
      '  path: ^1.8.3',
      '',
    ];

    // Remove empty strings and add proper spacing
    final dependenciesToAdd = coreDependencies.where((dep) => dep.isNotEmpty).toList();

    // Insert dependencies before flutter:
    for (int i = dependenciesToAdd.length - 1; i >= 0; i--) {
      lines.insert(flutterIndex, dependenciesToAdd[i]);
    }

    // Add dev_dependencies if not present
    await _addDevDependencies(lines);

    await pubspecFile.writeAsString(lines.join('\n'));
    CliHelpers.printSuccess('Updated pubspec.yaml with core dependencies');
  }

  Future<void> addAdditionalDependencies(String projectPath, List<String> dependencies) async {
    if (dependencies.isEmpty) return;

    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    // Find dependencies section
    int dependenciesIndex = lines.indexWhere(
          (line) => line.trim() == 'dependencies:',
    );
    if (dependenciesIndex == -1) {
      throw Exception('Could not find dependencies section in pubspec.yaml');
    }

    // Find dev_dependencies section or insert point
    int devDependenciesIndex = lines.indexWhere(
          (line) => line.trim() == 'dev_dependencies:',
    );

    // Insert additional dependencies before dev_dependencies
    int insertIndex = devDependenciesIndex != -1 ? devDependenciesIndex : lines.length;

    // Add a comment for additional dependencies
    lines.insert(insertIndex, '');
    lines.insert(insertIndex + 1, '  # Additional Dependencies');

    int currentInsertIndex = insertIndex + 2;
    for (final dependency in dependencies) {
      lines.insert(currentInsertIndex, '  $dependency');
      currentInsertIndex++;
    }

    await pubspecFile.writeAsString(lines.join('\n'));
    CliHelpers.printSuccess('Added ${dependencies.length} additional dependencies');
  }

  Future<void> _addDevDependencies(List<String> lines) async {
    // Check if dev_dependencies already exists
    final hasDevDependencies = lines.any((line) => line.trim() == 'dev_dependencies:');

    if (!hasDevDependencies) {
      // Add dev_dependencies section
      final devDeps = [
        '',
        'dev_dependencies:',
        '  flutter_test:',
        '    sdk: flutter',
        '',
        '  # Linting',
        '  flutter_lints: ^3.0.0',
        '',
        '  # Testing',
        '  bloc_test: ^9.1.5',
        '  mockito: ^5.4.4',
        '  build_runner: ^2.4.7',
        '',
        '  # Code Generation',
        '  json_annotation: ^4.8.1',
        '  json_serializable: ^6.7.1',
      ];

      lines.addAll(devDeps);
    }
  }

  Future<void> addSingleDependency(String projectPath, String packageName, {bool isDev = false}) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    final sectionName = isDev ? 'dev_dependencies:' : 'dependencies:';
    int sectionIndex = lines.indexWhere((line) => line.trim() == sectionName);

    if (sectionIndex == -1) {
      throw Exception('Could not find $sectionName section in pubspec.yaml');
    }

    // Find the next section or end of file to determine where to insert
    int nextSectionIndex = lines.length;
    for (int i = sectionIndex + 1; i < lines.length; i++) {
      if (lines[i].trim().endsWith(':') && !lines[i].trim().startsWith(' ')) {
        nextSectionIndex = i;
        break;
      }
    }

    // Insert the new dependency before the next section
    lines.insert(nextSectionIndex, '  $packageName: ^latest');

    await pubspecFile.writeAsString(lines.join('\n'));
    CliHelpers.printSuccess('Added $packageName to ${isDev ? 'dev_dependencies' : 'dependencies'}');
  }

  Future<List<String>> getInstalledPackages(String projectPath) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return [];
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');
    final packages = <String>[];

    bool inDependencies = false;
    for (final line in lines) {
      if (line.trim() == 'dependencies:') {
        inDependencies = true;
        continue;
      }

      if (line.trim() == 'dev_dependencies:' ||
          (line.trim().endsWith(':') && !line.trim().startsWith(' '))) {
        inDependencies = false;
        continue;
      }

      if (inDependencies && line.trim().isNotEmpty && line.startsWith('  ')) {
        final packageName = line.trim().split(':')[0];
        if (packageName != 'flutter') {
          packages.add(packageName);
        }
      }
    }

    return packages;
  }

  Future<bool> hasPackage(String projectPath, String packageName) async {
    final packages = await getInstalledPackages(projectPath);
    return packages.contains(packageName);
  }

  Future<void> removePackage(String projectPath, String packageName) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    // Find and remove the package line
    lines.removeWhere((line) =>
    line.trim().startsWith('$packageName:') && line.startsWith('  '));

    await pubspecFile.writeAsString(lines.join('\n'));
    CliHelpers.printSuccess('Removed $packageName from pubspec.yaml');
  }

  Future<Map<String, String>> getPackageVersions(String projectPath) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return {};
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');
    final versions = <String, String>{};

    bool inDependencies = false;
    for (final line in lines) {
      if (line.trim() == 'dependencies:' || line.trim() == 'dev_dependencies:') {
        inDependencies = true;
        continue;
      }

      if (line.trim().endsWith(':') && !line.trim().startsWith(' ')) {
        inDependencies = false;
        continue;
      }

      if (inDependencies && line.trim().isNotEmpty && line.startsWith('  ') && line.contains(':')) {
        final parts = line.trim().split(':');
        if (parts.length >= 2) {
          final packageName = parts[0].trim();
          final version = parts[1].trim();
          if (packageName != 'flutter' && packageName != 'sdk') {
            versions[packageName] = version;
          }
        }
      }
    }

    return versions;
  }

  Future<void> updatePackageVersion(String projectPath, String packageName, String version) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    // Find and update the package version
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('$packageName:') && lines[i].startsWith('  ')) {
        lines[i] = '  $packageName: $version';
        break;
      }
    }

    await pubspecFile.writeAsString(lines.join('\n'));
    CliHelpers.printSuccess('Updated $packageName to version $version');
  }

  Future<String> getProjectName(String projectPath) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return 'unknown';
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.trim().startsWith('name:')) {
        return line.split(':')[1].trim();
      }
    }

    return 'unknown';
  }

  Future<String> getProjectVersion(String projectPath) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return '1.0.0';
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.trim().startsWith('version:')) {
        return line.split(':')[1].trim();
      }
    }

    return '1.0.0';
  }

  Future<void> updateProjectVersion(String projectPath, String newVersion) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');

    // Find and update version
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('version:')) {
        lines[i] = 'version: $newVersion';
        break;
      }
    }

    await pubspecFile.writeAsString(lines.join('\n'));
    CliHelpers.printSuccess('Updated project version to $newVersion');
  }

  /// Validates pubspec.yaml syntax
  Future<bool> validatePubspec(String projectPath) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return false;
    }

    try {
      final content = await pubspecFile.readAsString();

      // Basic validation checks
      if (!content.contains('name:')) return false;
      if (!content.contains('dependencies:')) return false;
      if (!content.contains('flutter:')) return false;

      // Check for proper YAML structure
      final lines = content.split('\n');
      int dependenciesIndent = -1;

      for (final line in lines) {
        if (line.trim() == 'dependencies:') {
          dependenciesIndent = line.indexOf('dependencies:');
          continue;
        }

        if (dependenciesIndent >= 0 && line.trim().isNotEmpty &&
            !line.startsWith(' ' * (dependenciesIndent + 2)) &&
            line.trim() != 'dev_dependencies:' &&
            !line.trim().endsWith(':')) {
          // Found a line that's not properly indented
          if (line.contains(':') && !line.trim().endsWith(':')) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Formats pubspec.yaml with proper spacing and organization
  Future<void> formatPubspec(String projectPath) async {
    final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');
    final formattedLines = <String>[];

    String? currentSection;

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Detect section changes
      if (trimmedLine.endsWith(':') && !trimmedLine.startsWith(' ')) {
        if (currentSection != null && formattedLines.isNotEmpty &&
            formattedLines.last.trim().isNotEmpty) {
          formattedLines.add(''); // Add blank line between sections
        }
        currentSection = trimmedLine;
      }

      formattedLines.add(line);
    }

    await pubspecFile.writeAsString(formattedLines.join('\n'));
    CliHelpers.printSuccess('Formatted pubspec.yaml');
  }

  /// Gets suggested packages based on project type and existing dependencies
  List<String> getSuggestedPackages(List<String> existingPackages) {
    final suggestions = <String>[];

    // Basic utility packages
    if (!existingPackages.contains('intl')) {
      suggestions.add('intl');
    }
    if (!existingPackages.contains('path_provider')) {
      suggestions.add('path_provider');
    }

    // If has bloc, suggest bloc_test
    if (existingPackages.contains('flutter_bloc') && !existingPackages.contains('bloc_test')) {
      suggestions.add('bloc_test');
    }

    // If has network packages, suggest cached_network_image
    if ((existingPackages.contains('dio') || existingPackages.contains('http')) &&
        !existingPackages.contains('cached_network_image')) {
      suggestions.add('cached_network_image');
    }

    // Common UI packages
    if (!existingPackages.contains('font_awesome_flutter')) {
      suggestions.add('font_awesome_flutter');
    }

    return suggestions;
  }
}