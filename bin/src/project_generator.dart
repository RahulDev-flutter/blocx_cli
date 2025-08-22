import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:prompts/prompts.dart' as prompts;

import 'flutter_service.dart';
import 'generators/app_setup_generator.dart';
import 'generators/auth_module_generator.dart';
import 'generators/core_generator.dart';
import 'generators/home_module_generator.dart';
import 'pubspec_manager.dart';

class ProjectGenerator {
  final FlutterService _flutterService = FlutterService();
  final PubspecManager _pubspecManager = PubspecManager();
  final CoreGenerator _coreGenerator = CoreGenerator();
  final AuthModuleGenerator _authGenerator = AuthModuleGenerator();
  final HomeModuleGenerator _homeGenerator = HomeModuleGenerator();
  final AppSetupGenerator _appSetupGenerator = AppSetupGenerator();

  Future<void> createProject(String projectName) async {
    try {
      final projectDir = Directory(projectName);

      // Check if Flutter is installed
      await _flutterService.checkInstallation();

      // Create or validate existing project
      await _handleProjectCreation(projectName, projectDir);

      print('\n🛠️  Setting up project architecture...');

      // Get API choice from user
      final apiChoice = await _getApiChoice();

      // Update pubspec.yaml with dependencies
      await _pubspecManager.updateDependencies(projectDir.path, apiChoice);

      // Generate project structure
      await _generateProjectStructure(projectDir.path, apiChoice);

      // Show completion message
      _showCompletionMessage(projectName, apiChoice);
    } catch (e) {
      print('❌ Error: $e');
      exit(1);
    }
  }

  Future<void> _handleProjectCreation(
    String projectName,
    Directory projectDir,
  ) async {
    if (!projectDir.existsSync()) {
      print('🚀 Creating new Flutter project "$projectName"...');
      await _flutterService.createProject(projectName);
      print('✅ Flutter project "$projectName" created successfully.');
    } else {
      print('📁 Project "$projectName" already exists.');
      final shouldContinue = prompts.getBool(
        'Continue to enhance it?',
        defaultsTo: true,
      );
      if (!shouldContinue) {
        print('Operation cancelled.');
        exit(0);
      }
    }
  }

  Future<String> _getApiChoice() async {
    print('👉 Which API package do you want to use?');
    print('1. dio (Recommended)');
    print('2. http');
    final choice = prompts.get('Enter your choice (1 or 2)', defaultsTo: '1');
    return choice == '2' ? 'http' : 'dio';
  }

  Future<void> _generateProjectStructure(
    String projectPath,
    String apiChoice,
  ) async {
    // Generate core structure
    await _coreGenerator.generate(projectPath, apiChoice);

    // Generate auth module
    await _authGenerator.generate(projectPath);

    // Generate home module
    await _homeGenerator.generate(projectPath);

    // Generate app setup
    await _appSetupGenerator.generate(projectPath, apiChoice);
  }

  void _showCompletionMessage(String projectName, String apiChoice) {
    print('\n🎉 Project "$projectName" is ready!');
    print('\nNext steps:');
    print('1. cd $projectName');
    print('2. flutter pub get');
    print('3. flutter run');
    print('\n📁 Generated structure:');
    print('├── lib/');
    print('│   ├── core/');
    print('│   │   ├── network/');
    print('│   │   ├── constants/');
    print('│   │   ├── utils/');
    print('│   │   └── errors/');
    print('│   ├── modules/');
    print('│   │   ├── auth/');
    print('│   │   └── home/');
    print('│   └── app/');
    print('└── API: $apiChoice with secure storage');
    print('\n🔐 Security Features:');
    print('• Encrypted token storage');
    print('• Automatic session management');
    print('• Token refresh mechanism');
    print('• Secure logout functionality');
  }
}
