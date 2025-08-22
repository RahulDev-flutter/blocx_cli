import 'dart:io';

import 'package:path/path.dart' as p;

import '../templates/bloc_templates.dart';
import '../templates/home_templates.dart';
import 'base_module_generator.dart';

class HomeModuleGenerator extends BaseModuleGenerator {
  Future<void> generate(String projectPath) async {
    final moduleBase = p.join(projectPath, 'lib', 'modules', 'home');
    await createModuleStructure(moduleBase, 'home');

    // Create Home-specific files
    final homeScreens = [
      {'name': 'home_screen', 'title': 'Home'},
      {'name': 'profile_screen', 'title': 'Profile'},
    ];

    for (final screen in homeScreens) {
      final screenFile = File(
        p.join(moduleBase, 'screens', '${screen['name']}.dart'),
      );
      await screenFile.writeAsString(
        HomeTemplates.homeScreenTemplate(screen['name']!, screen['title']!),
      );
    }

    // Create home repository
    final homeRepo = File(
      p.join(moduleBase, 'repository', 'home_repository.dart'),
    );
    await homeRepo.writeAsString(HomeTemplates.homeRepositoryTemplate);

    print('✅ Home module created with home/profile screens');
  }

  @override
  String getEventTemplate(String moduleName) {
    return BlocTemplates.eventTemplate(moduleName);
  }

  @override
  String getStateTemplate(String moduleName) {
    return BlocTemplates.stateTemplate(moduleName);
  }

  @override
  String getBlocTemplate(String moduleName) {
    return BlocTemplates.blocTemplate(moduleName);
  }
}
