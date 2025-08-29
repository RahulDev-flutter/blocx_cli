import 'dart:io';

import 'package:path/path.dart' as p;

class FileUpdaterUtility {
  /// Updates the main.dart file to include new module in MultiBlocProvider
  static Future<void> updateMainWithModule(
    String moduleName, {
    required bool hasRepository,
  }) async {
    final mainFile = File('lib/main.dart');
    if (!mainFile.existsSync()) return;

    try {
      final content = await mainFile.readAsString();

      if (!hasRepository) {
        print('⚠️  Repository not included, skipping main.dart update');
        return;
      }

      // Add import
      final import =
          "import 'modules/${_toSnakeCase(moduleName)}/bloc/${_toSnakeCase(moduleName)}_bloc.dart';";

      // Add BlocProvider
      final provider =
          """        BlocProvider<${_toPascalCase(moduleName)}Bloc>(
          create: (context) => sl<${_toPascalCase(moduleName)}Bloc>(),
        ),""";

      String updatedContent = content;

      // Add import after existing module imports
      final homeImportRegex =
          RegExp(r"import 'modules/home/bloc/home_bloc.dart';");
      if (homeImportRegex.hasMatch(content)) {
        updatedContent = content.replaceFirst(
          homeImportRegex,
          "import 'modules/home/bloc/home_bloc.dart';\n$import",
        );
      }

      // Add provider after HomeBlocProvider
      final homeBlocProviderRegex = RegExp(
        r'(BlocProvider<HomeBloc>\(\s*create: \(context\) => sl<HomeBloc>\(\),\s*\),)',
        multiLine: true,
        dotAll: true,
      );
      if (homeBlocProviderRegex.hasMatch(updatedContent)) {
        updatedContent = updatedContent.replaceFirst(
          homeBlocProviderRegex,
          '\$1\n$provider',
        );
      }

      await mainFile.writeAsString(updatedContent);
      print('✅ Module added to main.dart MultiBlocProvider');
    } catch (e) {
      print('⚠️  Failed to update main.dart: $e');
    }
  }

  /// Creates or updates app_constants.dart with route constants
  static Future<void> updateAppConstants(List<String> screens) async {
    final constantsFile =
        File(p.join('lib', 'core', 'constants', 'app_constants.dart'));

    if (!constantsFile.existsSync()) {
      await constantsFile.create(recursive: true);
      await constantsFile.writeAsString(_generateAppConstantsTemplate());
    }

    try {
      final content = await constantsFile.readAsString();

      // Generate route constants
      final routeConstants = screens
          .map((screen) =>
              "  static const String ${_toCamelCase(screen)}Route = '/${_toSnakeCase(screen)}';")
          .join('\n');

      // Check if constants already exist
      bool hasUpdates = false;
      for (final screen in screens) {
        if (!content.contains('${_toCamelCase(screen)}Route')) {
          hasUpdates = true;
          break;
        }
      }

      if (!hasUpdates) {
        print('✅ Route constants already exist in app_constants.dart');
        return;
      }

      // Add constants before closing brace
      String updatedContent = content;
      final closingBraceRegex = RegExp(r'(\s*})(\s*)$');
      if (closingBraceRegex.hasMatch(content)) {
        updatedContent = content.replaceFirst(
          closingBraceRegex,
          '\n$routeConstants\n\$1\$2',
        );
      }

      await constantsFile.writeAsString(updatedContent);
      print('✅ Route constants added to app_constants.dart');
    } catch (e) {
      print('⚠️  Failed to update app_constants.dart: $e');
    }
  }

  /// Updates app_router.dart with new routes
  static Future<void> updateAppRouter({
    required String moduleName,
    required List<String> screens,
  }) async {
    final routerFile = File(p.join('lib', 'app', 'app_router.dart'));

    if (!routerFile.existsSync()) {
      print('⚠️  app_router.dart not found. Please create it first.');
      return;
    }

    try {
      final content = await routerFile.readAsString();

      // Generate imports
      final imports = screens
          .map((screen) =>
              "import '../modules/${_toSnakeCase(moduleName)}/screens/${_toSnakeCase(screen)}_screen.dart';")
          .join('\n');

      // Generate route cases
      final routeCases = screens
          .map((screen) =>
              """      case AppConstants.${_toCamelCase(screen)}Route:
        return MaterialPageRoute(builder: (_) => const ${_toPascalCase(screen)}Screen());""")
          .join('\n\n');

      String updatedContent = content;

      // Check if imports already exist
      bool needsImportUpdate = false;
      for (final screen in screens) {
        if (!content.contains('${_toSnakeCase(screen)}_screen.dart')) {
          needsImportUpdate = true;
          break;
        }
      }

      // Add imports after app_constants import
      if (needsImportUpdate) {
        final appConstantsImportRegex =
            RegExp(r"import '../core/constants/app_constants.dart';");
        if (appConstantsImportRegex.hasMatch(content)) {
          updatedContent = content.replaceFirst(
            appConstantsImportRegex,
            "import '../core/constants/app_constants.dart';\n$imports",
          );
        }
      }

      // Check if routes already exist
      bool needsRouteUpdate = false;
      for (final screen in screens) {
        if (!content.contains('AppConstants.${_toCamelCase(screen)}Route')) {
          needsRouteUpdate = true;
          break;
        }
      }

      // Add routes before default case
      if (needsRouteUpdate) {
        final defaultCaseRegex = RegExp(r'(\s+default:\s*)');
        if (defaultCaseRegex.hasMatch(updatedContent)) {
          updatedContent = updatedContent.replaceFirst(
            defaultCaseRegex,
            '\n$routeCases\n\n\$1',
          );
        }
      }

      if (needsImportUpdate || needsRouteUpdate) {
        await routerFile.writeAsString(updatedContent);
        print('✅ Routes added to app_router.dart');
      } else {
        print('✅ Routes already exist in app_router.dart');
      }
    } catch (e) {
      print('⚠️  Failed to update app_router.dart: $e');
    }
  }

  /// Updates service_locator.dart with new module dependencies
  static Future<void> updateServiceLocator(String moduleName) async {
    final serviceLocatorFile =
        File(p.join('lib', 'app', 'service_locator.dart'));

    if (!serviceLocatorFile.existsSync()) {
      print('⚠️  service_locator.dart not found. Please create it first.');
      return;
    }

    try {
      final content = await serviceLocatorFile.readAsString();

      // Check if already registered
      if (content.contains('${_toPascalCase(moduleName)}Repository') ||
          content.contains('${_toPascalCase(moduleName)}Bloc')) {
        print('✅ Module dependencies already exist in service_locator.dart');
        return;
      }

      // Generate imports
      final repositoryImport =
          "import '../modules/${_toSnakeCase(moduleName)}/repository/${_toSnakeCase(moduleName)}_repository.dart';";
      final blocImport =
          "import '../modules/${_toSnakeCase(moduleName)}/bloc/${_toSnakeCase(moduleName)}_bloc.dart';";

      // Generate registrations
      final repositoryRegistration =
          "  sl.registerLazySingleton<${_toPascalCase(moduleName)}Repository>(() => ${_toPascalCase(moduleName)}Repository(sl()));";
      final blocRegistration =
          "  sl.registerFactory<${_toPascalCase(moduleName)}Bloc>(() => ${_toPascalCase(moduleName)}Bloc(sl()));";

      String updatedContent = content;

      // Add imports after existing imports
      final lastImportRegex =
          RegExp(r"import '../modules/home/bloc/home_bloc.dart';");
      if (lastImportRegex.hasMatch(content)) {
        updatedContent = content.replaceFirst(
          lastImportRegex,
          "import '../modules/home/bloc/home_bloc.dart';\n$repositoryImport\n$blocImport",
        );
      }

      // Add repository registration after HomeRepository
      final homeRepoRegex = RegExp(
          r"(\s*sl\.registerLazySingleton<HomeRepository>\(\(\) => HomeRepository\(sl\(\)\)\);)");
      if (homeRepoRegex.hasMatch(updatedContent)) {
        updatedContent = updatedContent.replaceFirst(
          homeRepoRegex,
          '\$1\n$repositoryRegistration',
        );
      }

      // Add bloc registration after HomeBloc
      final homeBlocRegex = RegExp(
          r"(\s*sl\.registerFactory<HomeBloc>\(\(\) => HomeBloc\(sl\(\)\)\);)");
      if (homeBlocRegex.hasMatch(updatedContent)) {
        updatedContent = updatedContent.replaceFirst(
          homeBlocRegex,
          '\$1\n$blocRegistration',
        );
      }

      await serviceLocatorFile.writeAsString(updatedContent);
      print('✅ Module dependencies added to service_locator.dart');
    } catch (e) {
      print('⚠️  Failed to update service_locator.dart: $e');
    }
  }

  /// Creates a backup of a file before modification
  static Future<void> createBackup(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) return;

    try {
      final backupPath = '$filePath.backup';
      final backupFile = File(backupPath);

      if (!backupFile.existsSync()) {
        await file.copy(backupPath);
        print('📁 Backup created: $backupPath');
      }
    } catch (e) {
      print('⚠️  Failed to create backup for $filePath: $e');
    }
  }

  /// Validates that required files exist before updating
  static Future<bool> validateProjectStructure() async {
    final requiredFiles = [
      'lib/app/app_router.dart',
      'lib/app/service_locator.dart',
      'lib/main.dart',
    ];

    final missingFiles = <String>[];

    for (final filePath in requiredFiles) {
      if (!File(filePath).existsSync()) {
        missingFiles.add(filePath);
      }
    }

    if (missingFiles.isNotEmpty) {
      print('⚠️  Missing required files:');
      for (final file in missingFiles) {
        print('   - $file');
      }
      print('Please run "flutter_cli init" to create the required files.');
      return false;
    }

    return true;
  }

  /// Updates pubspec.yaml dependencies if needed
  static Future<void> updatePubspecDependencies({
    required bool needsEquatable,
    required bool needsFlutterBloc,
  }) async {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) return;

    try {
      final content = await pubspecFile.readAsString();
      String updatedContent = content;
      bool hasChanges = false;

      // Check and add flutter_bloc if needed
      if (needsFlutterBloc && !content.contains('flutter_bloc:')) {
        final dependenciesRegex = RegExp(r'(dependencies:\s*)');
        if (dependenciesRegex.hasMatch(content)) {
          updatedContent = updatedContent.replaceFirst(
            dependenciesRegex,
            '\$1\n  flutter_bloc: ^8.1.3',
          );
          hasChanges = true;
        }
      }

      // Check and add equatable if needed
      if (needsEquatable && !content.contains('equatable:')) {
        final flutterBlocRegex = RegExp(r'(\s*flutter_bloc:.*\n)');
        if (flutterBlocRegex.hasMatch(updatedContent)) {
          updatedContent = updatedContent.replaceFirst(
            flutterBlocRegex,
            '\$1  equatable: ^2.0.5\n',
          );
        } else {
          final dependenciesRegex = RegExp(r'(dependencies:\s*)');
          if (dependenciesRegex.hasMatch(updatedContent)) {
            updatedContent = updatedContent.replaceFirst(
              dependenciesRegex,
              '\$1\n  equatable: ^2.0.5',
            );
          }
        }
        hasChanges = true;
      }

      if (hasChanges) {
        await pubspecFile.writeAsString(updatedContent);
        print('✅ Dependencies added to pubspec.yaml');
        print('💡 Run "flutter pub get" to install new dependencies');
      }
    } catch (e) {
      print('⚠️  Failed to update pubspec.yaml: $e');
    }
  }

  /// Generates a complete project summary after module generation
  static void showProjectSummary({
    required String moduleName,
    required List<String> screens,
    required bool hasRepository,
    required bool hasModels,
  }) {
    print('\n📊 PROJECT SUMMARY');
    print('═' * 50);

    print('\n📦 Module: ${_toPascalCase(moduleName)}');
    print('   Screens: ${screens.length}');
    print('   Repository: ${hasRepository ? '✅' : '❌'}');
    print('   Models: ${hasModels ? '✅' : '❌'}');

    print('\n📱 Generated Screens:');
    for (final screen in screens) {
      print('   • ${_toPascalCase(screen)}Screen');
    }

    print('\n🔄 Updated Files:');
    print('   • app_router.dart (routes added)');
    print('   • app_constants.dart (constants added)');
    if (hasRepository) {
      print('   • service_locator.dart (dependencies added)');
      print('   • main.dart (bloc providers suggested)');
    }

    print('\n🚀 Next Steps:');
    print('   1. Run "flutter pub get" if dependencies were added');
    if (hasRepository) {
      print(
          '   2. Add ${_toPascalCase(moduleName)}Bloc to main.dart MultiBlocProvider');
    }
    print('   3. Implement business logic in your bloc');
    print('   4. Connect screens with navigation');
    print('   5. Test your generated module');

    print('\n' + '═' * 50);
  }

  /// Helper method to generate app constants template
  static String _generateAppConstantsTemplate() {
    return """
class AppConstants {
  // App Info
  static const String appName = 'Flutter App';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
}
""";
  }

  // Helper methods for string transformations
  static String _toPascalCase(String input) {
    return input
        .split(RegExp(r'[_\-\s]+'))
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join();
  }

  static String _toCamelCase(String input) {
    final pascal = _toPascalCase(input);
    return pascal.isNotEmpty
        ? pascal[0].toLowerCase() + pascal.substring(1)
        : '';
  }

  static String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}')
        .replaceAll(RegExp(r'^_'), '')
        .replaceAll(RegExp(r'[_\-\s]+'), '_')
        .toLowerCase();
  }
}
