import 'dart:io';

import 'package:prompts/prompts.dart' as prompts;

import '../utils/cli_helpers.dart';

class AddPackageCommand {
  static const Map<String, String> popularPackages = {
    // State Management
    'flutter_bloc': 'State management with BLoC pattern',
    'provider': 'Simple state management solution',
    'riverpod': 'Modern state management framework',
    'get': 'High-performance state management and dependency injection',

    // Networking
    'dio': 'Powerful HTTP client for Dart',
    'http': 'Composable HTTP client',
    'retrofit': 'Type-safe HTTP client for Dio',

    // Storage
    'shared_preferences': 'Simple key-value storage',
    'hive': 'Lightweight and fast key-value database',
    'sqflite': 'SQLite plugin for Flutter',
    'flutter_secure_storage': 'Secure storage for sensitive data',

    // UI Components
    'cupertino_icons': 'Cupertino style icons',
    'font_awesome_flutter': 'Font Awesome icons',
    'cached_network_image': 'Cached network images',
    'shimmer': 'Shimmer loading effect',
    'lottie': 'Lottie animations',
    'flutter_svg': 'SVG rendering and widget library',

    // Navigation
    'go_router': 'Declarative routing solution',
    'auto_route': 'Code generation based route generation',

    // Forms & Validation
    'form_builder_validators': 'Form validation functions',
    'flutter_form_builder': 'Form builder with validation',

    // Device Features
    'image_picker': 'Pick images from gallery or camera',
    'camera': 'Camera plugin',
    'geolocator': 'Geolocation services',
    'permission_handler': 'Request and check permissions',
    'device_info_plus': 'Device information',
    'package_info_plus': 'App package information',

    // Utils
    'intl': 'Internationalization and localization',
    'url_launcher': 'Launch URLs in browser',
    'share_plus': 'Share content',
    'path_provider': 'File system path locations',
    'connectivity_plus': 'Network connectivity',
    'flutter_local_notifications': 'Local notifications',

    // Development
    'flutter_lints': 'Linting rules for Flutter',
    'json_annotation': 'JSON serialization annotations',
    'json_serializable': 'JSON serialization code generation',
    'build_runner': 'Build system for Dart code generation',

    // Testing
    'mockito': 'Mock library for testing',
    'bloc_test': 'Testing utilities for BLoC',
  };

  Future<void> addSinglePackage(String packageName) async {
    if (!CliHelpers.isFlutterProject()) {
      CliHelpers.printError(
        'Not a Flutter project. Run this command in a Flutter project directory.',
      );
      exit(1);
    }

    try {
      CliHelpers.printStep('Adding package: $packageName');

      // Check if package exists in popular packages
      final description = popularPackages[packageName];
      if (description != null) {
        CliHelpers.printInfo('📦 $packageName: $description');
      }

      // Add package using flutter pub add
      final result = await Process.run('flutter', ['pub', 'add', packageName]);

      if (result.exitCode == 0) {
        CliHelpers.printSuccess('Package "$packageName" added successfully!');

        // Show usage hint if available
        _showUsageHint(packageName);

        CliHelpers.printInfo('Run "flutter pub get" if needed.');
      } else {
        CliHelpers.printError('Failed to add package "$packageName"');
        CliHelpers.printError(result.stderr.toString());
        exit(1);
      }
    } catch (e) {
      CliHelpers.printError('Error adding package: $e');
      exit(1);
    }
  }

  Future<void> addMultiplePackages() async {
    if (!CliHelpers.isFlutterProject()) {
      CliHelpers.printError(
        'Not a Flutter project. Run this command in a Flutter project directory.',
      );
      exit(1);
    }

    CliHelpers.printHeader('Interactive Package Manager');
    CliHelpers.printEmptyLine();

    // Show categories
    final categories = _getPackageCategories();

    print('📋 Available package categories:');
    for (int i = 0; i < categories.keys.length; i++) {
      final category = categories.keys.elementAt(i);
      print('  ${i + 1}. $category');
    }

    CliHelpers.printEmptyLine();
    final categoryChoice = prompts.get(
      'Select a category (1-${categories.length}) or "all" to see all packages',
      defaultsTo: 'all',
    );

    List<MapEntry<String, String>> packagesToShow;

    if (categoryChoice.toLowerCase() == 'all') {
      packagesToShow = popularPackages.entries.toList();
    } else {
      final categoryIndex = int.tryParse(categoryChoice);
      if (categoryIndex != null &&
          categoryIndex > 0 &&
          categoryIndex <= categories.length) {
        final selectedCategory = categories.keys.elementAt(categoryIndex - 1);
        final categoryPackages = categories[selectedCategory]!;
        packagesToShow = popularPackages.entries
            .where((entry) => categoryPackages.contains(entry.key))
            .toList();
      } else {
        CliHelpers.printError('Invalid category selection.');
        return;
      }
    }

    CliHelpers.printEmptyLine();
    CliHelpers.printSubHeader('Available Packages');

    // Show packages with numbers
    for (int i = 0; i < packagesToShow.length; i++) {
      final package = packagesToShow[i];
      print('  ${i + 1}. ${package.key}');
      print('     ${package.value}');
    }

    CliHelpers.printEmptyLine();
    final selections = prompts.get(
      'Enter package numbers separated by commas (e.g., 1,3,5) or "q" to quit',
      defaultsTo: 'q',
    );

    if (selections.toLowerCase() == 'q') {
      CliHelpers.printInfo('Operation cancelled.');
      return;
    }

    // Parse selections
    final selectedNumbers = selections
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .where((n) => n != null && n > 0 && n <= packagesToShow.length)
        .cast<int>()
        .toList();

    if (selectedNumbers.isEmpty) {
      CliHelpers.printError('No valid packages selected.');
      return;
    }

    // Get selected packages
    final selectedPackages =
        selectedNumbers.map((index) => packagesToShow[index - 1].key).toList();

    CliHelpers.printEmptyLine();
    CliHelpers.printStep('Adding ${selectedPackages.length} packages...');

    // Add packages one by one
    final successfulPackages = <String>[];
    final failedPackages = <String>[];

    for (final packageName in selectedPackages) {
      try {
        print('  Adding $packageName...');
        final result = await Process.run('flutter', [
          'pub',
          'add',
          packageName,
        ]);

        if (result.exitCode == 0) {
          successfulPackages.add(packageName);
          CliHelpers.printSuccess('✓ $packageName added');
        } else {
          failedPackages.add(packageName);
          CliHelpers.printError('✗ Failed to add $packageName');
        }
      } catch (e) {
        failedPackages.add(packageName);
        CliHelpers.printError('✗ Error adding $packageName: $e');
      }
    }

    CliHelpers.printEmptyLine();
    CliHelpers.printSeparator();

    if (successfulPackages.isNotEmpty) {
      CliHelpers.printSuccess(
        'Successfully added ${successfulPackages.length} packages:',
      );
      for (final pkg in successfulPackages) {
        CliHelpers.printListItem(pkg);
        _showUsageHint(pkg);
      }
    }

    if (failedPackages.isNotEmpty) {
      CliHelpers.printError('Failed to add ${failedPackages.length} packages:');
      for (final pkg in failedPackages) {
        CliHelpers.printListItem(pkg);
      }
    }

    CliHelpers.printEmptyLine();
    CliHelpers.printInfo(
      'Run "flutter pub get" to ensure all dependencies are resolved.',
    );
  }

  Map<String, List<String>> _getPackageCategories() {
    return {
      'State Management': ['flutter_bloc', 'provider', 'riverpod', 'get'],
      'Networking': ['dio', 'http', 'retrofit'],
      'Storage': [
        'shared_preferences',
        'hive',
        'sqflite',
        'flutter_secure_storage',
      ],
      'UI Components': [
        'cupertino_icons',
        'font_awesome_flutter',
        'cached_network_image',
        'shimmer',
        'lottie',
        'flutter_svg',
      ],
      'Navigation': ['go_router', 'auto_route'],
      'Forms & Validation': ['form_builder_validators', 'flutter_form_builder'],
      'Device Features': [
        'image_picker',
        'camera',
        'geolocator',
        'permission_handler',
        'device_info_plus',
        'package_info_plus',
      ],
      'Utils': [
        'intl',
        'url_launcher',
        'share_plus',
        'path_provider',
        'connectivity_plus',
        'flutter_local_notifications',
      ],
      'Development': [
        'flutter_lints',
        'json_annotation',
        'json_serializable',
        'build_runner',
      ],
      'Testing': ['mockito', 'bloc_test'],
    };
  }

  void _showUsageHint(String packageName) {
    final hints = <String, String>{
      'flutter_bloc':
          'Import: import \'package:flutter_bloc/flutter_bloc.dart\';',
      'dio': 'Import: import \'package:dio/dio.dart\';',
      'shared_preferences':
          'Import: import \'package:shared_preferences/shared_preferences.dart\';',
      'hive': 'Import: import \'package:hive_flutter/hive_flutter.dart\';',
      'image_picker':
          'Import: import \'package:image_picker/image_picker.dart\';',
      'geolocator': 'Import: import \'package:geolocator/geolocator.dart\';',
      'permission_handler':
          'Import: import \'package:permission_handler/permission_handler.dart\';',
      'url_launcher':
          'Import: import \'package:url_launcher/url_launcher.dart\';',
      'go_router': 'Import: import \'package:go_router/go_router.dart\';',
      'cached_network_image':
          'Import: import \'package:cached_network_image/cached_network_image.dart\';',
    };

    final hint = hints[packageName];
    if (hint != null) {
      CliHelpers.printInfo('💡 $hint');
    }
  }
}
