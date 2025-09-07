import 'dart:io';

import 'package:prompts/prompts.dart' as prompts;

import '../project_generator.dart';
import '../utils/cli_helpers.dart';

class CreateCommand {
  final ProjectGenerator _projectGenerator = ProjectGenerator();

  Future<void> execute(String projectName) async {
    // Validate project name
    if (!CliHelpers.isValidProjectName(projectName)) {
      CliHelpers.printError('Invalid project name: $projectName');
      CliHelpers.printInfo('Project name must:');
      CliHelpers.printListItem('Start with a lowercase letter');
      CliHelpers.printListItem(
        'Contain only lowercase letters, numbers, and underscores',
      );
      CliHelpers.printListItem('Not end with underscore');
      CliHelpers.printListItem('Not have consecutive underscores');
      CliHelpers.printEmptyLine();
      CliHelpers.printInfo('Examples: my_app, user_dashboard, chat_app_v2');
      exit(1);
    }

    final projectDir = Directory(projectName);

    CliHelpers.printHeader('Creating Flutter Project with BlocX Architecture');
    CliHelpers.printEmptyLine();

    try {
      // Check if project already exists
      await _handleExistingProject(projectName, projectDir);

      // Show project info
      _showProjectInfo(projectName);

      // Get user preferences
      final preferences = await _getUserPreferences();

      // Create project
      await _projectGenerator.createProject(projectName, preferences);

      // Show completion
      _showCompletion(projectName, preferences);
    } catch (e) {
      CliHelpers.printError('Failed to create project: $e');
      exit(1);
    }
  }

  Future<void> _handleExistingProject(
    String projectName,
    Directory projectDir,
  ) async {
    if (projectDir.existsSync()) {
      CliHelpers.printWarning('Project "$projectName" already exists.');

      final shouldContinue = prompts.getBool(
        'Do you want to enhance the existing project?',
        defaultsTo: false,
      );

      if (!shouldContinue) {
        CliHelpers.printInfo('Operation cancelled.');
        exit(0);
      }

      CliHelpers.printStep('Enhancing existing project...');
    } else {
      CliHelpers.printStep('Creating new Flutter project...');
    }
  }

  void _showProjectInfo(String projectName) {
    CliHelpers.printSubHeader('Project Information');
    CliHelpers.printTable([
      ['Name', projectName],
      ['Type', 'Flutter App with Bloc Architecture'],
      ['Features', 'Auth Module, Home Module, API Integration'],
    ]);
    CliHelpers.printEmptyLine();
  }

  Future<Map<String, dynamic>> _getUserPreferences() async {
    // Check if we're in a non-interactive environment
    if (!stdin.hasTerminal || !stdout.hasTerminal) {
      CliHelpers.printWarning(
          'Non-interactive mode detected - using default configuration');
      return {
        'apiClient': 'dio',
        'modules': {'profile': true, 'settings': true},
        'packages': {
          'cache': false,
          'imagePicker': false,
          'permissions': false,
        },
      };
    }

    try {
      CliHelpers.printSubHeader('Configuration');

      // API Client Selection
      print('🌐 Which API client would you like to use?');
      CliHelpers.printListItem(
        '1. Dio (Recommended - More features, better error handling)',
      );
      CliHelpers.printListItem('2. HTTP (Simple, lightweight)');

      final apiChoice = prompts.get(
        'Enter your choice (1 or 2)',
        defaultsTo: '1',
      );
      final selectedApi = apiChoice == '2' ? 'http' : 'dio';

      CliHelpers.printEmptyLine();

      // Additional modules
      print('📦 Would you like additional modules?');
      final wantProfile = prompts.getBool(
        'Add Profile module?',
        defaultsTo: true,
      );
      final wantSettings = prompts.getBool(
        'Add Settings module?',
        defaultsTo: true,
      );

      CliHelpers.printEmptyLine();

      // Additional packages
      print('🔧 Additional packages:');
      final wantCache = prompts.getBool(
        'Add caching support (Hive)?',
        defaultsTo: false,
      );
      final wantImagePicker = prompts.getBool(
        'Add image picker support?',
        defaultsTo: false,
      );
      final wantPermissions = prompts.getBool(
        'Add permissions handling?',
        defaultsTo: false,
      );

      return {
        'apiClient': selectedApi,
        'modules': {'profile': wantProfile, 'settings': wantSettings},
        'packages': {
          'cache': wantCache,
          'imagePicker': wantImagePicker,
          'permissions': wantPermissions,
        },
      };
    } on StdinException {
      // Handle StdinException specifically for non-interactive environments
      CliHelpers.printWarning(
          'Non-interactive environment detected - using default configuration');
      return {
        'apiClient': 'dio',
        'modules': {'profile': true, 'settings': true},
        'packages': {
          'cache': false,
          'imagePicker': false,
          'permissions': false,
        },
      };
    } catch (e) {
      // If any other error occurs, use default configuration
      CliHelpers.printWarning(
          'Error during configuration: $e - using default configuration');
      return {
        'apiClient': 'dio',
        'modules': {'profile': true, 'settings': true},
        'packages': {
          'cache': false,
          'imagePicker': false,
          'permissions': false,
        },
      };
    }
  }

  void _showCompletion(String projectName, Map<String, dynamic> preferences) {
    CliHelpers.printEmptyLine();
    CliHelpers.printSeparator();
    CliHelpers.printSuccess('Project "$projectName" created successfully!');
    CliHelpers.printSeparator();
    CliHelpers.printEmptyLine();

    CliHelpers.printSubHeader('Next Steps');
    CliHelpers.printListItem('cd $projectName');
    CliHelpers.printListItem('flutter pub get');
    CliHelpers.printListItem('flutter run');
    CliHelpers.printEmptyLine();

    CliHelpers.printSubHeader('Project Structure');
    print('''
📁 lib/
├── 📁 app/
│   ├── app_router.dart
│   ├── service_locator.dart
│   └── bloc_observer.dart
├── 📁 core/
│   ├── 📁 network/
│   ├── 📁 constants/
│   ├── 📁 utils/
│   └── 📁 errors/
├── 📁 modules/
│   ├── 📁 auth/
│   │   ├── 📁 bloc/
│   │   ├── 📁 screens/
│   │   ├── 📁 models/
│   │   └── 📁 repository/
│   └── 📁 home/
│       ├── 📁 bloc/
│       ├── 📁 screens/
│       ├── 📁 models/
│       └── 📁 repository/
└── main.dart
    ''');

    CliHelpers.printSubHeader('Configuration Summary');
    final apiClient = preferences['apiClient'];
    CliHelpers.printTable([
      ['API Client', apiClient == 'dio' ? 'Dio' : 'HTTP'],
      ['Modules', _getEnabledModules(preferences['modules'])],
      ['Packages', _getEnabledPackages(preferences['packages'])],
    ]);

    CliHelpers.printEmptyLine();
    CliHelpers.printSubHeader('Security Features');
    CliHelpers.printListItem('🔐 Encrypted token storage');
    CliHelpers.printListItem('🔄 Automatic session management');
    CliHelpers.printListItem('🔑 Token refresh mechanism');
    CliHelpers.printListItem('🚪 Secure logout functionality');

    CliHelpers.printEmptyLine();
    CliHelpers.printInfo('Happy coding! 🎉');
  }

  String _getEnabledModules(Map<String, dynamic> modules) {
    final enabled = <String>[];
    enabled.add('Auth');
    enabled.add('Home');

    if (modules['profile'] == true) enabled.add('Profile');
    if (modules['settings'] == true) enabled.add('Settings');

    return enabled.join(', ');
  }

  String _getEnabledPackages(Map<String, dynamic> packages) {
    final enabled = <String>['Bloc', 'SecureStorage'];

    if (packages['cache'] == true) enabled.add('Hive');
    if (packages['imagePicker'] == true) enabled.add('ImagePicker');
    if (packages['permissions'] == true) enabled.add('Permissions');

    return enabled.join(', ');
  }
}
