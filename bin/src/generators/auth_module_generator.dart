import 'dart:io';

import 'package:path/path.dart' as p;

import '../templates/auth_templates.dart';
import '../templates/bloc_templates.dart';
import 'base_module_generator.dart';

class AuthModuleGenerator extends BaseModuleGenerator {
  Future<void> generate(String projectPath) async {
    final moduleBase = p.join(projectPath, 'lib', 'modules', 'auth');
    await createModuleStructure(moduleBase, 'auth');

    // Create Auth-specific files
    final authScreens = [
      {'name': 'login_screen', 'title': 'Login'},
      {'name': 'register_screen', 'title': 'Register'},
    ];

    for (final screen in authScreens) {
      final screenFile = File(
        p.join(moduleBase, 'screens', '${screen['name']}.dart'),
      );
      await screenFile.writeAsString(
        AuthTemplates.authScreenTemplate(screen['name']!, screen['title']!),
      );
    }

    // Create auth repository
    final authRepo = File(
      p.join(moduleBase, 'repository', 'auth_repository.dart'),
    );
    await authRepo.writeAsString(AuthTemplates.authRepositoryTemplate);

    // Create auth models
    final modelsDir = Directory(p.join(moduleBase, 'models'));
    await modelsDir.create(recursive: true);

    final userModel = File(p.join(moduleBase, 'models', 'user_model.dart'));
    await userModel.writeAsString(AuthTemplates.userModelTemplate);

    final authRequest = File(p.join(moduleBase, 'models', 'auth_request.dart'));
    await authRequest.writeAsString(AuthTemplates.authRequestTemplate);

    print(
      '✅ Auth module created with login/register screens and user management',
    );
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
