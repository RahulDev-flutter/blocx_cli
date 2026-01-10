#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';
// FIXED: Change 'blocx' to your actual package name
// Based on the error, this should likely be 'rj_blocx' or similar
import 'package:rj_blocx/src/commands/add_package_command.dart';
import 'package:rj_blocx/src/commands/create_command.dart';
import 'package:rj_blocx/src/commands/generate_command.dart';
import 'package:rj_blocx/src/commands/init_command.dart';
import 'package:rj_blocx/src/utils/cli_helpers.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('create')
    ..addCommand('init')
    ..addCommand('add')
    ..addCommand('generate')
    ..addFlag('help',
        abbr: 'h', help: 'Show help information', negatable: false)
    ..addFlag('version',
        abbr: 'v', help: 'Show version information', negatable: false);

  final argResults = parser.parse(arguments);

  // Handle help flag
  if (argResults['help'] || arguments.isEmpty) {
    _showHelp();
    exit(0);
  }

  // Handle version flag
  if (argResults['version']) {
    print('RJ BlocX CLI version 1.0.1 - Created by Rahul Verma');
    exit(0);
  }

  try {
    switch (argResults.command?.name) {
      case 'create':
        await _handleCreateCommand(argResults.command!);
        break;
      case 'init':
        await _handleInitCommand(argResults.command!);
        break;
      case 'add':
        await _handleAddCommand(argResults.command!);
        break;
      case 'generate':
        await _handleGenerateCommand(argResults.command!);
        break;
      default:
        print('❌ Unknown command. Use --help for available commands.');
        exit(1);
    }
  } catch (e) {
    CliHelpers.printError('Error: $e');
    exit(1);
  }
}

Future<void> _handleCreateCommand(ArgResults command) async {
  if (command.rest.isEmpty) {
    CliHelpers.printError('Please provide a project name.');
    print('Usage: rj_blocx create <project_name>');
    exit(1);
  }

  final projectName = command.rest.first;
  final createCommand = CreateCommand();
  await createCommand.execute(projectName);
}

Future<void> _handleInitCommand(ArgResults command) async {
  print('🏗️  Initializing RJ BlocX architecture in existing project...');
  final initCommand = InitCommand();
  await initCommand.execute();
}

Future<void> _handleAddCommand(ArgResults command) async {
  if (command.rest.isEmpty) {
    CliHelpers.printError('Please specify what to add.');
    print('Available options:');
    print('  rj_blocx add package <package_name>  # Add a Flutter package');
    print(
        '  rj_blocx add packages                # Add multiple packages interactively');
    exit(1);
  }

  final subCommand = command.rest.first;
  final addPackageCommand = AddPackageCommand();

  switch (subCommand) {
    case 'package':
      if (command.rest.length < 2) {
        CliHelpers.printError('Please specify package name.');
        print('Usage: rj_blocx add package <package_name>');
        exit(1);
      }
      final packageName = command.rest[1];
      await addPackageCommand.addSinglePackage(packageName);
      break;
    case 'packages':
      await addPackageCommand.addMultiplePackages();
      break;
    default:
      CliHelpers.printError('Unknown add command: $subCommand');
      print('Available options: package, packages');
      exit(1);
  }
}

Future<void> _handleGenerateCommand(ArgResults command) async {
  if (command.rest.isEmpty) {
    CliHelpers.printError('Please specify what to generate.');
    print('Available options:');
    print('  rj_blocx generate module <module_name>   # Generate a new module');
    print('  rj_blocx generate screen <screen_name>   # Generate a new screen');
    print(
        '  rj_blocx generate page <page_name>       # Generate a new page (alias for screen)');
    exit(1);
  }

  final subCommand = command.rest.first;
  final generateCommand = GenerateCommand();

  switch (subCommand) {
    case 'module':
      if (command.rest.length < 2) {
        CliHelpers.printError('Please specify module name.');
        print('Usage: rj_blocx generate module <module_name>');
        exit(1);
      }
      final moduleName = command.rest[1];
      await generateCommand.generateModule(moduleName);
      break;
    case 'screen':
    case 'page':
      if (command.rest.length < 2) {
        CliHelpers.printError('Please specify $subCommand name.');
        print('Usage: rj_blocx generate $subCommand <${subCommand}_name>');
        exit(1);
      }
      final screenName = command.rest[1];
      await generateCommand.generateScreen(screenName);
      break;
    default:
      CliHelpers.printError('Unknown generate command: $subCommand');
      print('Available options: module, screen, page');
      exit(1);
  }
}

void _showHelp() {
  print('🚀 RJ BlocX CLI v1.0.1 - Enhanced Flutter Project Generator');
  print('   Created with ❤️ by Rahul Verma ');
  print('');
  print('COMMANDS:');
  print('');
  print(
      '  create <project_name>              Create a new Flutter project with Bloc architecture');
  print(
      '  init                               Initialize RJ BlocX architecture in existing project');
  print('  add package <package_name>         Add a single Flutter package');
  print(
      '  add packages                       Add multiple packages interactively');
  print(
      '  generate module <module_name>      Generate a new module with Bloc structure');
  print('  generate screen <screen_name>      Generate a new screen');
  print(
      '  generate page <page_name>          Generate a new page (alias for screen)');
  print('');
  print('OPTIONS:');
  print('  -h, --help                         Show this help information');
  print('  -v, --version                      Show version information');
  print('');
  print('FEATURES:');
  print('  ✅ Interactive API client selection (HTTP/Dio)');
  print('  ✅ Auto-generated Auth & Home modules');
  print('  ✅ Complete Bloc state management setup');
  print('  ✅ Secure storage with flutter_secure_storage');
  print('  ✅ Network layer with comprehensive error handling');
  print('  ✅ Repository pattern implementation');
  print('  ✅ Clean architecture with dependency injection');
  print('  ✅ CamelCase formatting for class names');
  print('  ✅ Package management');
  print('  ✅ Dynamic module/screen generation');
  print('  ✅ Initialize architecture in existing projects');
  print('');
  print('EXAMPLES:');
  print('  rj_blocx create my_awesome_app');
  print('  rj_blocx init');
  print('  rj_blocx add package shared_preferences');
  print('  rj_blocx add packages');
  print('  rj_blocx generate module profile');
  print('  rj_blocx generate screen settings');
  print('  rj_blocx generate page user_dashboard');
  print('');
  print(
      'For more information, visit: https://github.com/RahulDev-flutter/blocx_cli');
}
