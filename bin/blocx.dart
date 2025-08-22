#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';

import 'src/project_generator.dart';
import 'src/utils/project_validator.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()..addCommand('create');
  final argResults = parser.parse(arguments);

  if (argResults.command?.name == 'create') {
    final projectName = argResults.command?.rest.first;

    if (projectName == null) {
      print('❌ Please provide a project name.');
      print('Usage: blocx create <project_name>');
      exit(1);
    }

    // Validate project name
    if (!ProjectValidator.isValidProjectName(projectName)) {
      print(
        '❌ Invalid project name. Use lowercase letters, numbers, and underscores only.',
      );
      exit(1);
    }

    final generator = ProjectGenerator();
    await generator.createProject(projectName);
  } else {
    _showHelp();
  }
}

void _showHelp() {
  print('🚀 BlocX CLI - Flutter Project Generator with Bloc Architecture');
  print('Usage: blocx create <project_name>');
  print('');
  print('Features:');
  print('• Interactive API client selection (HTTP/Dio)');
  print('• Auto-generated Auth & Home modules');
  print('• Complete Bloc state management setup');
  print('• Secure storage with flutter_secure_storage');
  print('• Network layer with comprehensive error handling');
  print('• Repository pattern implementation');
  print('• Clean architecture with dependency injection');
  print('');
  print('Example:');
  print('  blocx create my_awesome_app');
}
