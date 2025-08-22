#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) async {
  final parser = ArgParser()..addCommand('create');

  final argResults = parser.parse(arguments);

  if (argResults.command?.name == 'create') {
    final featureName = argResults.command?.rest.first;

    if (featureName == null) {
      print('❌ Please provide a feature name.');
      exit(1);
    }

    await createOrUpdateProject(featureName);
  } else {
    print('BlocX CLI - Usage: blocx create <project_name>');
  }
}

Future<void> createOrUpdateProject(String name) async {
  final projectDir = Directory(name);

  if (!projectDir.existsSync()) {
    print('🚀 Creating new Flutter project "$name"...');
    final result = await Process.run('flutter', ['create', name]);

    if (result.exitCode != 0) {
      print('❌ Flutter project creation failed:\n${result.stderr}');
      exit(1);
    } else {
      print('✅ Flutter project "$name" created.');
    }
  } else {
    print('📁 Project "$name" already exists. Proceeding to update...');
  }

  // Now generate the feature structure
  final featurePath = p.join(projectDir.path, 'lib', 'features', name);

  createCleanArchitectureStructure(featurePath, name);
}

void createCleanArchitectureStructure(String basePath, String featureName) {
  final baseDir = Directory(basePath);

  final domainDir = Directory(p.join(baseDir.path, 'domain'));
  final dataDir = Directory(p.join(baseDir.path, 'data'));
  final presentationDir = Directory(p.join(baseDir.path, 'presentation'));

  final entitiesDir = Directory(p.join(domainDir.path, 'entities'));
  final usecasesDir = Directory(p.join(domainDir.path, 'usecases'));
  final repositoriesDir = Directory(p.join(domainDir.path, 'repositories'));

  final blocDir = Directory(p.join(presentationDir.path, 'bloc'));
  final screensDir = Directory(p.join(presentationDir.path, 'screens'));

  final repoImplDir = Directory(p.join(dataDir.path, 'repositories'));
  final datasourcesDir = Directory(p.join(dataDir.path, 'datasources'));
  final modelsDir = Directory(p.join(dataDir.path, 'models'));

  final dirs = [
    domainDir,
    entitiesDir,
    usecasesDir,
    repositoriesDir,
    dataDir,
    repoImplDir,
    datasourcesDir,
    modelsDir,
    presentationDir,
    blocDir,
    screensDir,
  ];

  for (final dir in dirs) {
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  print('✅ Feature "$featureName" added to project "$featureName" with clean architecture folders.');
}
