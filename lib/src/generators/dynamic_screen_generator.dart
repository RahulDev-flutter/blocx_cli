import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rj_blocx/src/templates/dynamic_templates.dart';
import 'package:rj_blocx/src/utils/cli_helpers.dart';

class DynamicScreenGenerator {
  Future<void> generate(
    String projectPath,
    String moduleName,
    String screenName,
    Map<String, dynamic> config,
  ) async {
    final moduleBase = p.join(
      projectPath,
      'lib',
      'modules',
      CliHelpers.toSnakeCase(moduleName),
    );
    final screensDir = Directory(p.join(moduleBase, 'screens'));

    // Ensure screens directory exists
    await screensDir.create(recursive: true);

    CliHelpers.printStep('Generating screen file...');
    await _generateScreenFile(moduleBase, moduleName, screenName, config);

    CliHelpers.printStep('Adding route suggestion...');
    _suggestRouteAddition(projectPath, moduleName, screenName);
  }

  Future<void> _generateScreenFile(
    String moduleBase,
    String moduleName,
    String screenName,
    Map<String, dynamic> config,
  ) async {
    final screensBase = p.join(moduleBase, 'screens');
    final snakeScreenName = CliHelpers.toSnakeCase(screenName);
    final pascalScreenName = CliHelpers.toPascalCase(screenName);
    final snakeModuleName = CliHelpers.toSnakeCase(moduleName);
    final pascalModuleName = CliHelpers.toPascalCase(moduleName);

    final screenFile = File(p.join(screensBase, '$snakeScreenName.dart'));

    String template;
    switch (config['type']) {
      case 'list':
        template = DynamicTemplates.listScreenTemplate(
          pascalScreenName,
          snakeScreenName,
          pascalModuleName,
          snakeModuleName,
          config,
        );
        break;
      case 'detail':
        template = DynamicTemplates.detailScreenTemplate(
          pascalScreenName,
          snakeScreenName,
          pascalModuleName,
          snakeModuleName,
          config,
        );
        break;
      case 'form':
        template = DynamicTemplates.formScreenTemplate(
          pascalScreenName,
          snakeScreenName,
          pascalModuleName,
          snakeModuleName,
          config,
        );
        break;
      default:
        template = DynamicTemplates.screenTemplate(
          pascalScreenName,
          snakeScreenName,
          pascalModuleName,
          snakeModuleName,
          config,
        );
    }

    await screenFile.writeAsString(template);
  }

  void _suggestRouteAddition(
    String projectPath,
    String moduleName,
    String screenName,
  ) {
    final routePath = p.join(projectPath, 'lib', 'app', 'app_router.dart');
    final snakeScreenName = CliHelpers.toSnakeCase(screenName);
    final snakeModuleName = CliHelpers.toSnakeCase(moduleName);
    final pascalScreenName = CliHelpers.toPascalCase(screenName);

    CliHelpers.printInfo('📋 Add this route to your app_router.dart:');
    CliHelpers.printEmptyLine();

    print('''// Import
import '../modules/$snakeModuleName/screens/$snakeScreenName.dart';

// Route constant (add to app_constants.dart)
static const String ${snakeScreenName}Route = '/$snakeScreenName';

// Route case (add to generateRoute switch)
case AppConstants.${snakeScreenName}Route:
  return MaterialPageRoute(builder: (_) => const $pascalScreenName());
    ''');

    CliHelpers.printEmptyLine();
  }
}
