import 'dart:io';

import 'package:path/path.dart' as p;

import '../templates/dynamic_templates.dart';
import '../utils/cli_helpers.dart';

class DynamicModuleGenerator {
  Future<void> generate(
    String projectPath,
    String moduleName,
    Map<String, dynamic> config,
  ) async {
    final moduleBase = p.join(
      projectPath,
      'lib',
      'modules',
      CliHelpers.toSnakeCase(moduleName),
    );

    CliHelpers.printStep('Creating module structure...');
    await _createModuleStructure(moduleBase, moduleName);

    CliHelpers.printStep('Generating Bloc files...');
    await _generateBlocFiles(moduleBase, moduleName);

    CliHelpers.printStep('Generating screens...');
    await _generateScreens(
      moduleBase,
      moduleName,
      config['screens'] as List<String>,
    );

    if (config['repository'] == true) {
      CliHelpers.printStep('Generating repository...');
      await _generateRepository(moduleBase, moduleName, config);
    }

    if (config['models'] == true) {
      CliHelpers.printStep('Generating models...');
      await _generateModels(moduleBase, moduleName);
    }

    if (config['apiEndpoints'] == true) {
      CliHelpers.printStep('Adding API endpoints...');
      await _addApiEndpoints(projectPath, moduleName);
    }

    CliHelpers.printStep('Updating service locator...');
    await _updateServiceLocator(projectPath, moduleName);
  }

  Future<void> _createModuleStructure(
    String moduleBase,
    String moduleName,
  ) async {
    final dirs = [
      Directory(p.join(moduleBase, 'bloc')),
      Directory(p.join(moduleBase, 'screens')),
      Directory(p.join(moduleBase, 'repository')),
      Directory(p.join(moduleBase, 'models')),
    ];

    for (final dir in dirs) {
      await dir.create(recursive: true);
    }
  }

  Future<void> _generateBlocFiles(String moduleBase, String moduleName) async {
    final blocBase = p.join(moduleBase, 'bloc');
    final snakeModuleName = CliHelpers.toSnakeCase(moduleName);
    final pascalModuleName = CliHelpers.toPascalCase(moduleName);

    // Generate event file
    final eventFile = File(p.join(blocBase, '${snakeModuleName}_event.dart'));
    await eventFile.writeAsString(
      DynamicTemplates.eventTemplate(pascalModuleName, snakeModuleName),
    );

    // Generate state file
    final stateFile = File(p.join(blocBase, '${snakeModuleName}_state.dart'));
    await stateFile.writeAsString(
      DynamicTemplates.stateTemplate(pascalModuleName, snakeModuleName),
    );

    // Generate bloc file
    final blocFile = File(p.join(blocBase, '${snakeModuleName}_bloc.dart'));
    await blocFile.writeAsString(
      DynamicTemplates.blocTemplate(pascalModuleName, snakeModuleName),
    );
  }

  Future<void> _generateScreens(
    String moduleBase,
    String moduleName,
    List<String> screenNames,
  ) async {
    final screensBase = p.join(moduleBase, 'screens');
    final pascalModuleName = CliHelpers.toPascalCase(moduleName);
    final snakeModuleName = CliHelpers.toSnakeCase(moduleName);

    for (final screenName in screenNames) {
      final snakeScreenName = CliHelpers.toSnakeCase(screenName);
      final pascalScreenName = CliHelpers.toPascalCase(screenName);

      final screenFile = File(p.join(screensBase, '$snakeScreenName.dart'));
      await screenFile.writeAsString(
        DynamicTemplates.screenTemplate(
          pascalScreenName,
          snakeScreenName,
          pascalModuleName,
          snakeModuleName,
        ),
      );
    }
  }

  Future<void> _generateRepository(
    String moduleBase,
    String moduleName,
    Map<String, dynamic> config,
  ) async {
    final repositoryBase = p.join(moduleBase, 'repository');
    final snakeModuleName = CliHelpers.toSnakeCase(moduleName);
    final pascalModuleName = CliHelpers.toPascalCase(moduleName);

    final repositoryFile = File(
      p.join(repositoryBase, '${snakeModuleName}_repository.dart'),
    );
    await repositoryFile.writeAsString(
      DynamicTemplates.repositoryTemplate(pascalModuleName, snakeModuleName),
    );
  }

  Future<void> _generateModels(String moduleBase, String moduleName) async {
    final modelsBase = p.join(moduleBase, 'models');
    final snakeModuleName = CliHelpers.toSnakeCase(moduleName);
    final pascalModuleName = CliHelpers.toPascalCase(moduleName);

    final modelFile = File(p.join(modelsBase, '${snakeModuleName}_model.dart'));
    await modelFile.writeAsString(
      DynamicTemplates.modelTemplate(pascalModuleName, snakeModuleName),
    );
  }

  Future<void> _addApiEndpoints(String projectPath, String moduleName) async {
    final apiConstantsFile = File(
      p.join(projectPath, 'lib', 'core', 'constants', 'api_constants.dart'),
    );

    if (!apiConstantsFile.existsSync()) {
      CliHelpers.printWarning(
        'api_constants.dart not found. Skipping API endpoints generation.',
      );
      return;
    }

    final content = await apiConstantsFile.readAsString();
    final snakeModuleName = CliHelpers.toSnakeCase(moduleName);

    // Add endpoints for the new module
    final newEndpoints =
        '''
  
  // $moduleName endpoints
  static const String ${snakeModuleName}List = '/$snakeModuleName';
  static const String ${snakeModuleName}Detail = '/$snakeModuleName/{id}';
  static const String ${snakeModuleName}Create = '/$snakeModuleName';
  static const String ${snakeModuleName}Update = '/$snakeModuleName/{id}';
  static const String ${snakeModuleName}Delete = '/$snakeModuleName/{id}';''';

    // Insert before the last closing brace
    final lines = content.split('\n');
    final lastBraceIndex = lines.lastIndexWhere((line) => line.trim() == '}');

    if (lastBraceIndex != -1) {
      lines.insert(lastBraceIndex, newEndpoints);
      await apiConstantsFile.writeAsString(lines.join('\n'));
    }
  }

  Future<void> _updateServiceLocator(
    String projectPath,
    String moduleName,
  ) async {
    final serviceLocatorFile = File(
      p.join(projectPath, 'lib', 'app', 'service_locator.dart'),
    );

    if (!serviceLocatorFile.existsSync()) {
      CliHelpers.printWarning(
        'service_locator.dart not found. Please manually register the new bloc.',
      );
      return;
    }

    final content = await serviceLocatorFile.readAsString();
    final snakeModuleName = CliHelpers.toSnakeCase(moduleName);
    final pascalModuleName = CliHelpers.toPascalCase(moduleName);

    // Add import
    final importStatement =
        "import '../modules/$snakeModuleName/bloc/${snakeModuleName}_bloc.dart';";
    final repositoryImport =
        "import '../modules/$snakeModuleName/repository/${snakeModuleName}_repository.dart';";

    // Add repository registration
    final repositoryRegistration =
        "  sl.registerLazySingleton<${pascalModuleName}Repository>(() => ${pascalModuleName}Repository(sl()));";

    // Add bloc registration
    final blocRegistration =
        "  sl.registerFactory<${pascalModuleName}Bloc>(() => ${pascalModuleName}Bloc(sl()));";

    var updatedContent = content;

    // Add imports after existing imports
    final lastImportIndex = updatedContent.lastIndexOf("import '../modules/");
    if (lastImportIndex != -1) {
      final endOfLastImport = updatedContent.indexOf('\n', lastImportIndex);
      updatedContent =
          updatedContent.substring(0, endOfLastImport) +
          '\n$repositoryImport' +
          '\n$importStatement' +
          updatedContent.substring(endOfLastImport);
    }

    // Add repository registration
    final repositoriesCommentIndex = updatedContent.indexOf('// Repositories');
    if (repositoriesCommentIndex != -1) {
      final nextBlankLine = updatedContent.indexOf(
        '\n\n',
        repositoriesCommentIndex,
      );
      if (nextBlankLine != -1) {
        updatedContent =
            updatedContent.substring(0, nextBlankLine) +
            '\n$repositoryRegistration' +
            updatedContent.substring(nextBlankLine);
      }
    }

    // Add bloc registration
    final blocsCommentIndex = updatedContent.indexOf('// Blocs');
    if (blocsCommentIndex != -1) {
      final nextClosingBrace = updatedContent.indexOf('\n}', blocsCommentIndex);
      if (nextClosingBrace != -1) {
        updatedContent =
            updatedContent.substring(0, nextClosingBrace) +
            '\n$blocRegistration' +
            updatedContent.substring(nextClosingBrace);
      }
    }

    await serviceLocatorFile.writeAsString(updatedContent);
  }
}
