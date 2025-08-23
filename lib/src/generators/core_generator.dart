import 'dart:io';

import 'package:path/path.dart' as p;

import '../templates/core_templates.dart';

class CoreGenerator {
  Future<void> generate(String projectPath, String apiChoice) async {
    // Create core directories
    final coreBase = p.join(projectPath, 'lib', 'core');
    final dirs = [
      Directory(p.join(coreBase, 'network')),
      Directory(p.join(coreBase, 'constants')),
      Directory(p.join(coreBase, 'utils')),
      Directory(p.join(coreBase, 'errors')),
    ];

    for (final dir in dirs) {
      await dir.create(recursive: true);
    }

    // Create network layer
    await _createNetworkLayer(coreBase, apiChoice);

    // Create constants
    await _createConstants(coreBase);

    // Create utilities
    await _createUtils(coreBase);

    // Create error handling
    await _createErrorHandling(coreBase);

    print('✅ Core structure created with $apiChoice network layer');
  }

  Future<void> _createNetworkLayer(String coreBase, String apiChoice) async {
    final networkPath = p.join(coreBase, 'network');

    if (apiChoice == 'dio') {
      // Dio implementation
      final dioClient = File(p.join(networkPath, 'dio_client.dart'));
      await dioClient.writeAsString(CoreTemplates.dioClientTemplate);

      final apiService = File(p.join(networkPath, 'api_service.dart'));
      await apiService.writeAsString(CoreTemplates.dioApiServiceTemplate);
    } else {
      // HTTP implementation
      final httpClient = File(p.join(networkPath, 'http_client.dart'));
      await httpClient.writeAsString(CoreTemplates.httpClientTemplate);

      final apiService = File(p.join(networkPath, 'api_service.dart'));
      await apiService.writeAsString(CoreTemplates.httpApiServiceTemplate);
    }

    // Create network response model
    final responseModel = File(p.join(networkPath, 'api_response.dart'));
    await responseModel.writeAsString(
      CoreTemplates.apiResponseTemplate(apiChoice),
    );
  }

  Future<void> _createConstants(String coreBase) async {
    final constantsPath = p.join(coreBase, 'constants');

    final apiConstants = File(p.join(constantsPath, 'api_constants.dart'));
    await apiConstants.writeAsString(CoreTemplates.apiConstantsTemplate);

    final appConstants = File(p.join(constantsPath, 'app_constants.dart'));
    await appConstants.writeAsString(CoreTemplates.appConstantsTemplate);
  }

  Future<void> _createUtils(String coreBase) async {
    final utilsPath = p.join(coreBase, 'utils');

    final validators = File(p.join(utilsPath, 'validators.dart'));
    await validators.writeAsString(CoreTemplates.validatorsTemplate);

    final helpers = File(p.join(utilsPath, 'helpers.dart'));
    await helpers.writeAsString(CoreTemplates.helpersTemplate);
  }

  Future<void> _createErrorHandling(String coreBase) async {
    final errorsPath = p.join(coreBase, 'errors');

    final failures = File(p.join(errorsPath, 'failures.dart'));
    await failures.writeAsString(CoreTemplates.failuresTemplate);

    final exceptions = File(p.join(errorsPath, 'exceptions.dart'));
    await exceptions.writeAsString(CoreTemplates.exceptionsTemplate);
  }
}
