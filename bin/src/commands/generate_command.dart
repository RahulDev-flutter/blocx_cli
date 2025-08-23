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

    print('🏗️  Configure your module:');

    // Number of screens
    final screenCount =
        int.tryParse(
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
      final isLast = i == screens.length - 1;
      final prefix = isLast ? '└──' : '├──';
      print('│   $prefix ${CliHelpers.toSnakeCase(screens[i])}.dart');
    }

    if (config['repository'] == true) {
      print('├── 📁 repository/');
      print('│   └── ${CliHelpers.toSnakeCase(moduleName)}_repository.dart');
    }

    if (config['models'] == true) {
      print('└── 📁 models/');
      print('    └── ${CliHelpers.toSnakeCase(moduleName)}_model.dart');
    }

    CliHelpers.printEmptyLine();
    CliHelpers.printSubHeader('Next Steps');
    CliHelpers.printListItem('Add routes to your app_router.dart');
    CliHelpers.printListItem('Register bloc in service_locator.dart');
    CliHelpers.printListItem('Implement your business logic');
    CliHelpers.printListItem('Connect to API endpoints');
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
    CliHelpers.printSubHeader('Next Steps');
    CliHelpers.printListItem('Add route to app_router.dart');
    CliHelpers.printListItem('Implement screen logic');
    CliHelpers.printListItem('Connect to bloc if needed');
  }
}
