#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addCommand('create');

  final argResults = parser.parse(arguments);

  if (argResults.command?.name == 'create') {
    final featureName = argResults.command?.rest.firstOrNull;

    if (featureName == null) {
      print('❌ Please provide a feature name.');
      exit(1);
    }

    createFeature(featureName);
  } else {
    print('BlocX CLI - Usage: blocx create feature_name');
  }
}

void createFeature(String feature) {
  final baseDir = Directory('lib/features/$feature');

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

  print('✅ Feature "$feature" created with clean architecture folders.');
}
