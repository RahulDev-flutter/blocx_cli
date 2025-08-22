import 'dart:io';

import 'package:path/path.dart' as p;

import '../templates/app_templates.dart';

class AppSetupGenerator {
  Future<void> generate(String projectPath, String apiChoice) async {
    final appDir = Directory(p.join(projectPath, 'lib', 'app'));
    await appDir.create(recursive: true);

    final isDio = apiChoice == 'dio';

    // Create service locator
    final serviceLocator = File(p.join(appDir.path, 'service_locator.dart'));
    await serviceLocator.writeAsString(
      AppTemplates.serviceLocatorTemplate(isDio),
    );

    // Create app router
    final appRouter = File(p.join(appDir.path, 'app_router.dart'));
    await appRouter.writeAsString(AppTemplates.appRouterTemplate);

    // Create app bloc observer
    final blocObserver = File(p.join(appDir.path, 'bloc_observer.dart'));
    await blocObserver.writeAsString(AppTemplates.blocObserverTemplate);

    // Update main.dart
    final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
    await mainFile.writeAsString(AppTemplates.mainDartTemplate);

    print('✅ App setup created with service locator and routing');
    print('✅ main.dart updated with Bloc setup and routing');
  }
}
