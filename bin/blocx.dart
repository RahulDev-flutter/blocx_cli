#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:prompts/prompts.dart' as prompts;

void main(List<String> arguments) async {
  final parser = ArgParser()..addCommand('create');
  final argResults = parser.parse(arguments);

  if (argResults.command?.name == 'create') {
    final projectName = argResults.command?.rest.first;

    if (projectName == null) {
      print('❌ Please provide a project name.');
      exit(1);
    }

    await createOrUpdateProject(projectName);
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

  // Step 1: Ask which API client
  final apiChoice = prompts.choose<String>(
    '👉 Which API package do you want to use?',
    ['http', 'dio'],
  );

  // Step 2: Generate network layer
  final networkPath = p.join(projectDir.path, 'lib', 'core', 'network');
  createNetworkLayer(networkPath, apiChoice);

  // Step 3: Create default modules (Auth & Home)
  createModule(projectDir.path, 'auth');
  createModule(projectDir.path, 'home');

  print('🎉 Project "$name" is ready with $apiChoice setup + Auth & Home modules!');
}

void createNetworkLayer(String basePath, String apiChoice) {
  final dir = Directory(basePath);
  dir.createSync(recursive: true);

  final file = File(p.join(basePath, '${apiChoice}_client.dart'));

  String content = '';
  if (apiChoice == 'dio') {
    content = dioClientTemplate;
  } else {
    content = httpClientTemplate;
  }

  file.writeAsStringSync(content);
  print('✅ Network layer created with $apiChoice');
}

void createModule(String projectPath, String moduleName) {
  final moduleBase = p.join(projectPath, 'lib', 'modules', moduleName);

  final dirs = [
    Directory(p.join(moduleBase, 'bloc')),
    Directory(p.join(moduleBase, 'screens')),
    Directory(p.join(moduleBase, 'repository')),
  ];

  for (final dir in dirs) {
    dir.createSync(recursive: true);
  }

  // Create repository file
  File(p.join(moduleBase, 'repository', '${moduleName}_repository.dart'))
      .writeAsStringSync(repositoryTemplate(moduleName));

  // Create 2 screens
  File(p.join(moduleBase, 'screens', '${moduleName}_screen1.dart'))
      .writeAsStringSync(screenTemplate('${moduleName} Screen 1'));
  File(p.join(moduleBase, 'screens', '${moduleName}_screen2.dart'))
      .writeAsStringSync(screenTemplate('${moduleName} Screen 2'));

  print('✅ Module "$moduleName" created with 2 screens & repository');
}
