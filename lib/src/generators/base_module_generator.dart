import 'dart:io';

import 'package:path/path.dart' as p;

abstract class BaseModuleGenerator {
  Future<void> createModuleStructure(
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

    // Create Bloc files
    final blocBase = p.join(moduleBase, 'bloc');

    final eventFile = File(p.join(blocBase, '${moduleName}_event.dart'));
    await eventFile.writeAsString(getEventTemplate(moduleName));

    final stateFile = File(p.join(blocBase, '${moduleName}_state.dart'));
    await stateFile.writeAsString(getStateTemplate(moduleName));

    final blocFile = File(p.join(blocBase, '${moduleName}_bloc.dart'));
    await blocFile.writeAsString(getBlocTemplate(moduleName));
  }

  String getEventTemplate(String moduleName);
  String getStateTemplate(String moduleName);
  String getBlocTemplate(String moduleName);
}
