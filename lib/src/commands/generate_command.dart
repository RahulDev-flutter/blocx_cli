import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:prompts/prompts.dart' as prompts;

import '../generators/dynamic_module_generator.dart';
import '../generators/dynamic_screen_generator.dart';
import '../utils/cli_helpers.dart';

class GenerateCommand {
  final DynamicModuleGenerator _moduleGenerator = DynamicModuleGenerator();
  final DynamicScreenGenerator _screenGenerator = DynamicScreenGenerator();

  Future<void> generateModule(String moduleName) async {
    if (!CliHelpers.isFlutterProject()) {
      CliHelpers.printError(
        'Not a Flutter project. Run this command in a Flutter project directory.',
      );
      exit(1);
    }

    if (!CliHelpers.isValidModuleName(moduleName)) {
      CliHelpers.printError('Invalid module name: $moduleName');
      CliHelpers.printInfo(
        'Module name must start with a letter and contain only letters, numbers, underscores, or hyphens.',
      );
      exit(1);
    }

    try {
      CliHelpers.printHeader(
        'Generating Module: ${CliHelpers.toPascalCase(moduleName)}',
      );
      CliHelpers.printEmptyLine();

      // Get module configuration
      final config = await _getModuleConfiguration(moduleName);

      // Generate module
      await _moduleGenerator.generate(
        Directory.current.path,
        moduleName,
        config,
      );

      // Auto-generate routes for the module screens
      await _updateAppRouterWithModuleRoutes(moduleName, config);

      // Update service locator if repository is included
      if (config['repository'] == true) {
        await _updateServiceLocatorWithModule(moduleName);
      }

      // Show completion
      _showModuleCompletion(moduleName, config);
    } catch (e) {
      CliHelpers.printError('Failed to generate module: $e');
      exit(1);
    }
  }

  Future<void> generateScreen(String screenName) async {
    if (!CliHelpers.isFlutterProject()) {
      CliHelpers.printError(
        'Not a Flutter project. Run this command in a Flutter project directory.',
      );
      exit(1);
    }

    if (!CliHelpers.isValidModuleName(screenName)) {
      CliHelpers.printError('Invalid screen name: $screenName');
      CliHelpers.printInfo(
        'Screen name must start with a letter and contain only letters, numbers, underscores, or hyphens.',
      );
      exit(1);
    }

    try {
      CliHelpers.printHeader(
        'Generating Screen: ${CliHelpers.toPascalCase(screenName)}',
      );
      CliHelpers.printEmptyLine();

      // Get existing modules
      final modules = await _getExistingModules();

      if (modules.isEmpty) {
        CliHelpers.printWarning(
          'No modules found. Creating screen in new module...',
        );
        final moduleName = await _promptForModuleName(screenName);

        // Generate module first
        final moduleConfig = await _getModuleConfiguration(moduleName);
        await _moduleGenerator.generate(
          Directory.current.path,
          moduleName,
          moduleConfig,
        );

        // Update routes and service locator for new module
        await _updateAppRouterWithModuleRoutes(moduleName, moduleConfig);
        if (moduleConfig['repository'] == true) {
          await _updateServiceLocatorWithModule(moduleName);
        }

        CliHelpers.printSuccess(
          'Module "$moduleName" created with screen "${CliHelpers.toPascalCase(screenName)}"',
        );
        return;
      }

      // Select module for screen
      final selectedModule = await _selectModule(modules);

      // Get screen configuration
      final config = await _getScreenConfiguration(screenName);

      // Generate screen
      await _screenGenerator.generate(
        Directory.current.path,
        selectedModule,
        screenName,
        config,
      );

      // Auto-generate route for the new screen
      await _updateAppRouterWithScreenRoute(selectedModule, screenName);

      // Show completion
      _showScreenCompletion(screenName, selectedModule, config);
    } catch (e) {
      CliHelpers.printError('Failed to generate screen: $e');
      exit(1);
    }
  }

  Future<Map<String, dynamic>> _getModuleConfiguration(
    String moduleName,
  ) async {
    CliHelpers.printSubHeader('Module Configuration');

    print('🗂️ Configure your module:');

    // Number of screens
    final screenCount = int.tryParse(
          prompts.get('How many screens in this module?', defaultsTo: '2'),
        ) ??
        2;

    final screens = <String>[];
    for (int i = 0; i < screenCount; i++) {
      final screenName = prompts.get(
        'Screen ${i + 1} name',
        defaultsTo: i == 0 ? '${moduleName}_list' : '${moduleName}_detail',
      );
      screens.add(screenName);
    }

    // Repository
    final needsRepository = prompts.getBool(
      'Include repository?',
      defaultsTo: true,
    );

    // Models
    final needsModels = prompts.getBool('Include models?', defaultsTo: true);

    // API endpoints
    final needsApiEndpoints = prompts.getBool(
      'Generate API endpoint constants?',
      defaultsTo: true,
    );

    return {
      'screens': screens,
      'repository': needsRepository,
      'models': needsModels,
      'apiEndpoints': needsApiEndpoints,
    };
  }

  Future<Map<String, dynamic>> _getScreenConfiguration(
    String screenName,
  ) async {
    CliHelpers.printSubHeader('Screen Configuration');

    print('📱 Configure your screen:');

    // Screen type
    print('Screen type:');
    CliHelpers.printListItem('1. List Screen (displays items in a list)');
    CliHelpers.printListItem('2. Detail Screen (shows detailed information)');
    CliHelpers.printListItem('3. Form Screen (input form)');
    CliHelpers.printListItem('4. Basic Screen (simple content)');

    final typeChoice = prompts.get('Choose screen type (1-4)', defaultsTo: '4');
    final screenType = _getScreenType(typeChoice);

    // AppBar
    final hasAppBar = prompts.getBool('Include AppBar?', defaultsTo: true);

    // FloatingActionButton
    final hasFab = prompts.getBool(
      'Include FloatingActionButton?',
      defaultsTo: false,
    );

    // Bottom navigation
    final hasBottomNav = prompts.getBool(
      'Include BottomNavigationBar?',
      defaultsTo: false,
    );

    return {
      'type': screenType,
      'hasAppBar': hasAppBar,
      'hasFab': hasFab,
      'hasBottomNav': hasBottomNav,
    };
  }

  String _getScreenType(String choice) {
    switch (choice) {
      case '1':
        return 'list';
      case '2':
        return 'detail';
      case '3':
        return 'form';
      default:
        return 'basic';
    }
  }

  Future<List<String>> _getExistingModules() async {
    final modulesDir = Directory(p.join('lib', 'modules'));
    if (!modulesDir.existsSync()) {
      return [];
    }

    final modules = <String>[];
    await for (final entity in modulesDir.list()) {
      if (entity is Directory) {
        final moduleName = p.basename(entity.path);
        modules.add(moduleName);
      }
    }

    return modules;
  }

  Future<String> _selectModule(List<String> modules) async {
    CliHelpers.printSubHeader('Select Module');

    print('📦 Available modules:');
    for (int i = 0; i < modules.length; i++) {
      print('  ${i + 1}. ${CliHelpers.toPascalCase(modules[i])}');
    }

    final choice = int.tryParse(
      prompts.get('Select module (1-${modules.length})', defaultsTo: '1'),
    );

    if (choice == null || choice < 1 || choice > modules.length) {
      CliHelpers.printError('Invalid selection.');
      exit(1);
    }

    return modules[choice - 1];
  }

  Future<String> _promptForModuleName(String screenName) async {
    // Suggest module name based on screen name
    final suggestedModule = screenName.contains('_')
        ? screenName.split('_').first
        : screenName.toLowerCase();

    return prompts.get(
      'Module name for this screen',
      defaultsTo: suggestedModule,
    );
  }

  /// Updates app_router.dart with routes for module screens
  Future<void> _updateAppRouterWithModuleRoutes(
    String moduleName,
    Map<String, dynamic> config,
  ) async {
    final routerFile = File(p.join('lib', 'app', 'app_router.dart'));

    if (!routerFile.existsSync()) {
      CliHelpers.printWarning(
          'app_router.dart not found. Skipping route generation.');
      return;
    }

    try {
      final content = await routerFile.readAsString();
      final screens = config['screens'] as List<String>;

      // Generate import statements
      final imports = screens
          .map((screen) =>
              "import '../modules/${CliHelpers.toSnakeCase(moduleName)}/screens/${CliHelpers.toSnakeCase(screen)}.dart';")
          .join('\n');

      // Generate route constants
      final routeConstants = screens
          .map((screen) =>
              "  static const String ${CliHelpers.toCamelCase(screen)}Route = '/${CliHelpers.toSnakeCase(screen)}';")
          .join('\n');

      // Generate route cases
      final routeCases = screens
          .map((screen) =>
              """      case AppConstants.${CliHelpers.toCamelCase(screen)}Route:
        return MaterialPageRoute(builder: (_) => const ${CliHelpers.toPascalCase(screen)}Screen());""")
          .join('\n\n');

      // Add imports after existing imports
      String updatedContent = content;
      final importRegex =
          RegExp(r"import '../core/constants/app_constants.dart';");
      if (importRegex.hasMatch(content)) {
        updatedContent = content.replaceFirst(
          importRegex,
          "import '../core/constants/app_constants.dart';\n$imports",
        );
      }

      // Add routes before default case
      final defaultCaseRegex = RegExp(r'(\s+default:\s*)');
      if (defaultCaseRegex.hasMatch(updatedContent)) {
        updatedContent = updatedContent.replaceFirst(
          defaultCaseRegex,
          '\n$routeCases\n\n\$1',
        );
      }

      await routerFile.writeAsString(updatedContent);

      // Update app constants
      await _updateAppConstants(screens);

      CliHelpers.printSuccess('Routes added to app_router.dart');
    } catch (e) {
      CliHelpers.printWarning('Failed to update app_router.dart: $e');
    }
  }

  /// Updates app_router.dart with a single screen route
  Future<void> _updateAppRouterWithScreenRoute(
    String moduleName,
    String screenName,
  ) async {
    final routerFile = File(p.join('lib', 'app', 'app_router.dart'));

    if (!routerFile.existsSync()) {
      CliHelpers.printWarning(
          'app_router.dart not found. Skipping route generation.');
      return;
    }

    try {
      final content = await routerFile.readAsString();

      // Generate import statement
      final import =
          "import '../modules/${CliHelpers.toSnakeCase(moduleName)}/screens/${CliHelpers.toSnakeCase(screenName)}.dart';";

      // Generate route case
      final routeCase =
          """      case AppConstants.${CliHelpers.toCamelCase(screenName)}Route:
        return MaterialPageRoute(builder: (_) => const ${CliHelpers.toPascalCase(screenName)}Screen());""";

      // Add import after existing imports
      String updatedContent = content;
      final importRegex =
          RegExp(r"import '../core/constants/app_constants.dart';");
      if (importRegex.hasMatch(content)) {
        updatedContent = content.replaceFirst(
          importRegex,
          "import '../core/constants/app_constants.dart';\n$import",
        );
      }

      // Add route before default case
      final defaultCaseRegex = RegExp(r'(\s+default:\s*)');
      if (defaultCaseRegex.hasMatch(updatedContent)) {
        updatedContent = updatedContent.replaceFirst(
          defaultCaseRegex,
          '\n$routeCase\n\n\$1',
        );
      }

      await routerFile.writeAsString(updatedContent);

      // Update app constants
      await _updateAppConstants([screenName]);

      CliHelpers.printSuccess('Route added to app_router.dart');
    } catch (e) {
      CliHelpers.printWarning('Failed to update app_router.dart: $e');
    }
  }

  /// Updates app_constants.dart with route constants
  Future<void> _updateAppConstants(List<String> screens) async {
    final constantsFile =
        File(p.join('lib', 'core', 'constants', 'app_constants.dart'));

    if (!constantsFile.existsSync()) {
      // Create constants file if it doesn't exist
      await constantsFile.create(recursive: true);
      await constantsFile.writeAsString(_generateAppConstantsTemplate());
    }

    try {
      final content = await constantsFile.readAsString();

      // Generate route constants
      final routeConstants = screens
          .map((screen) =>
              "  static const String ${CliHelpers.toCamelCase(screen)}Route = '/${CliHelpers.toSnakeCase(screen)}';")
          .join('\n');

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
    } catch (e) {
      CliHelpers.printWarning('Failed to update app_constants.dart: $e');
    }
  }

  String _generateAppConstantsTemplate() {
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

  /// Updates service_locator.dart with module dependencies
  Future<void> _updateServiceLocatorWithModule(String moduleName) async {
    final serviceLocatorFile =
        File(p.join('lib', 'app', 'service_locator.dart'));

    if (!serviceLocatorFile.existsSync()) {
      CliHelpers.printWarning(
          'service_locator.dart not found. Skipping dependency registration.');
      return;
    }

    try {
      final content = await serviceLocatorFile.readAsString();

      // Generate imports
      final repositoryImport =
          "import '../modules/${CliHelpers.toSnakeCase(moduleName)}/repository/${CliHelpers.toSnakeCase(moduleName)}_repository.dart';";
      final blocImport =
          "import '../modules/${CliHelpers.toSnakeCase(moduleName)}/bloc/${CliHelpers.toSnakeCase(moduleName)}_bloc.dart';";

      // Generate registrations
      final repositoryRegistration =
          "  sl.registerLazySingleton<${CliHelpers.toPascalCase(moduleName)}Repository>(() => ${CliHelpers.toPascalCase(moduleName)}Repository(sl()));";
      final blocRegistration =
          "  sl.registerFactory<${CliHelpers.toPascalCase(moduleName)}Bloc>(() => ${CliHelpers.toPascalCase(moduleName)}Bloc(sl()));";

      String updatedContent = content;

      // Add imports
      final lastImportRegex =
          RegExp(r"import '../modules/home/bloc/home_bloc.dart';");
      if (lastImportRegex.hasMatch(content)) {
        updatedContent = content.replaceFirst(
          lastImportRegex,
          "import '../modules/home/bloc/home_bloc.dart';\n$repositoryImport\n$blocImport",
        );
      }

      // Add repository registration
      final repositoriesCommentRegex = RegExp(r'(\s*// Repositories\s*)');
      if (repositoriesCommentRegex.hasMatch(updatedContent)) {
        final homeRepoRegex = RegExp(
            r"(\s*sl\.registerLazySingleton<HomeRepository>\(\(\) => HomeRepository\(sl\(\)\)\);)");
        if (homeRepoRegex.hasMatch(updatedContent)) {
          updatedContent = updatedContent.replaceFirst(
            homeRepoRegex,
            '\$1\n$repositoryRegistration',
          );
        }
      }

      // Add bloc registration
      final blocsCommentRegex = RegExp(r'(\s*// Blocs\s*)');
      if (blocsCommentRegex.hasMatch(updatedContent)) {
        final homeBlocRegex = RegExp(
            r"(\s*sl\.registerFactory<HomeBloc>\(\(\) => HomeBloc\(sl\(\)\)\);)");
        if (homeBlocRegex.hasMatch(updatedContent)) {
          updatedContent = updatedContent.replaceFirst(
            homeBlocRegex,
            '\$1\n$blocRegistration',
          );
        }
      }

      await serviceLocatorFile.writeAsString(updatedContent);
      CliHelpers.printSuccess(
          'Module dependencies added to service_locator.dart');
    } catch (e) {
      CliHelpers.printWarning('Failed to update service_locator.dart: $e');
    }
  }

  void _showModuleCompletion(String moduleName, Map<String, dynamic> config) {
    CliHelpers.printEmptyLine();
    CliHelpers.printSeparator();
    CliHelpers.printSuccess(
      'Module "${CliHelpers.toPascalCase(moduleName)}" generated successfully!',
    );
    CliHelpers.printSeparator();
    CliHelpers.printEmptyLine();

    CliHelpers.printSubHeader('Generated Files');
    final moduleDir = 'lib/modules/${CliHelpers.toSnakeCase(moduleName)}';

    print('📁 $moduleDir/');
    print('├── 📁 bloc/');
    print('│   ├── ${CliHelpers.toSnakeCase(moduleName)}_bloc.dart');
    print('│   ├── ${CliHelpers.toSnakeCase(moduleName)}_event.dart');
    print('│   └── ${CliHelpers.toSnakeCase(moduleName)}_state.dart');
    print('├── 📁 screens/');

    final screens = config['screens'] as List<String>;
    for (int i = 0; i < screens.length; i++) {
      final isLast = i == screens.length - 1 &&
          config['repository'] != true &&
          config['models'] != true;
      final prefix = isLast ? '│   └──' : '│   ├──';
      print('$prefix ${CliHelpers.toSnakeCase(screens[i])}.dart');
    }

    if (config['repository'] == true) {
      final isLast = config['models'] != true;
      final prefix = isLast ? '└──' : '├──';
      print('$prefix 📁 repository/');
      print(
          '${isLast ? "    " : "│   "}└── ${CliHelpers.toSnakeCase(moduleName)}_repository.dart');
    }

    if (config['models'] == true) {
      print('└── 📁 models/');
      print('    └── ${CliHelpers.toSnakeCase(moduleName)}_model.dart');
    }

    CliHelpers.printEmptyLine();
    CliHelpers.printSubHeader('Auto-Generated Updates');
    CliHelpers.printListItem('✅ Routes added to app_router.dart');
    CliHelpers.printListItem('✅ Route constants added to app_constants.dart');
    if (config['repository'] == true) {
      CliHelpers.printListItem(
          '✅ Dependencies registered in service_locator.dart');
    }

    CliHelpers.printEmptyLine();
    CliHelpers.printSubHeader('Next Steps');
    CliHelpers.printListItem('Add module to main.dart MultiBlocProvider');
    CliHelpers.printListItem('Implement your business logic');
    if (config['repository'] == true) {
      CliHelpers.printListItem('Connect repository to API endpoints');
    }
    CliHelpers.printListItem('Test your generated screens');
  }

  void _showScreenCompletion(
    String screenName,
    String moduleName,
    Map<String, dynamic> config,
  ) {
    CliHelpers.printEmptyLine();
    CliHelpers.printSeparator();
    CliHelpers.printSuccess(
      'Screen "${CliHelpers.toPascalCase(screenName)}" generated successfully!',
    );
    CliHelpers.printSeparator();
    CliHelpers.printEmptyLine();

    CliHelpers.printSubHeader('Generated File');
    final screenFile =
        'lib/modules/${CliHelpers.toSnakeCase(moduleName)}/screens/${CliHelpers.toSnakeCase(screenName)}.dart';
    CliHelpers.printInfo('📄 $screenFile');

    CliHelpers.printEmptyLine();
    CliHelpers.printSubHeader('Screen Configuration');
    CliHelpers.printTable([
      ['Type', config['type']],
      ['Module', CliHelpers.toPascalCase(moduleName)],
      ['AppBar', config['hasAppBar'] ? 'Yes' : 'No'],
      ['FAB', config['hasFab'] ? 'Yes' : 'No'],
      ['Bottom Nav', config['hasBottomNav'] ? 'Yes' : 'No'],
    ]);

    CliHelpers.printEmptyLine();
    CliHelpers.printSubHeader('Auto-Generated Updates');
    CliHelpers.printListItem('✅ Route added to app_router.dart');
    CliHelpers.printListItem('✅ Route constant added to app_constants.dart');

    CliHelpers.printEmptyLine();
    CliHelpers.printSubHeader('Next Steps');
    CliHelpers.printListItem('Implement screen logic');
    CliHelpers.printListItem('Connect to bloc if needed');
    CliHelpers.printListItem('Test your new screen');
  }
}
