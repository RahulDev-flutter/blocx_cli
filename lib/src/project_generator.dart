import 'dart:io';

import 'package:path/path.dart' as p;

import 'flutter_service.dart';
import 'generators/app_setup_generator.dart';
import 'generators/auth_module_generator.dart';
import 'generators/core_generator.dart';
import 'generators/dynamic_module_generator.dart';
import 'generators/home_module_generator.dart';
import 'pubspec_manager.dart';
import 'utils/cli_helpers.dart';

class ProjectGenerator {
  final FlutterService _flutterService = FlutterService();
  final PubspecManager _pubspecManager = PubspecManager();
  final CoreGenerator _coreGenerator = CoreGenerator();
  final AuthModuleGenerator _authGenerator = AuthModuleGenerator();
  final HomeModuleGenerator _homeGenerator = HomeModuleGenerator();
  final DynamicModuleGenerator _moduleGenerator = DynamicModuleGenerator();
  final AppSetupGenerator _appSetupGenerator = AppSetupGenerator();

  Future<void> createProject(
    String projectName,
    Map<String, dynamic> preferences,
  ) async {
    try {
      final projectDir = Directory(projectName);

      // Check if Flutter is installed
      await _flutterService.checkInstallation();

      // Create or validate existing project
      await _handleProjectCreation(projectName, projectDir);

      // Update pubspec.yaml with dependencies
      await _updateDependencies(projectDir.path, preferences);

      // Generate project structure
      await _generateProjectStructure(projectDir.path, preferences);

      CliHelpers.printSuccess('Project setup completed successfully!');
    } catch (e) {
      CliHelpers.printError('Failed to create project: $e');
      rethrow;
    }
  }

  Future<void> _handleProjectCreation(
    String projectName,
    Directory projectDir,
  ) async {
    if (!projectDir.existsSync()) {
      CliHelpers.printStep('Creating new Flutter project "$projectName"...');
      await _flutterService.createProject(projectName);
      CliHelpers.printSuccess(
        'Flutter project "$projectName" created successfully.',
      );
    } else {
      CliHelpers.printStep('Enhancing existing project...');
    }
  }

  Future<void> _updateDependencies(
    String projectPath,
    Map<String, dynamic> preferences,
  ) async {
    CliHelpers.printStep('Updating dependencies...');

    final apiChoice = preferences['apiClient'] as String;
    await _pubspecManager.updateDependencies(projectPath, apiChoice);

    // Add additional packages based on preferences
    final packages = preferences['packages'] as Map<String, dynamic>;
    final additionalDeps = <String>[];

    if (packages['cache'] == true) {
      additionalDeps.add('hive_flutter: ^1.1.0');
    }
    if (packages['imagePicker'] == true) {
      additionalDeps.add('image_picker: ^1.0.4');
    }
    if (packages['permissions'] == true) {
      additionalDeps.add('permission_handler: ^11.0.1');
    }

    if (additionalDeps.isNotEmpty) {
      await _pubspecManager.addAdditionalDependencies(
        projectPath,
        additionalDeps,
      );
    }
  }

  Future<void> _generateProjectStructure(
    String projectPath,
    Map<String, dynamic> preferences,
  ) async {
    final apiChoice = preferences['apiClient'] as String;

    // Generate core structure
    CliHelpers.printStep('Generating core structure...');
    await _coreGenerator.generate(projectPath, apiChoice);

    // Generate auth module
    CliHelpers.printStep('Generating authentication module...');
    await _authGenerator.generate(projectPath);

    // Generate home module
    CliHelpers.printStep('Generating home module...');
    await _homeGenerator.generate(projectPath);

    // Generate additional modules based on preferences
    final modules = preferences['modules'] as Map<String, dynamic>;

    if (modules['profile'] == true) {
      CliHelpers.printStep('Generating profile module...');
      await _moduleGenerator.generate(projectPath, 'profile', {
        'screens': ['profile_screen', 'edit_profile_screen'],
        'repository': true,
        'models': true,
        'apiEndpoints': true,
      });
    }

    if (modules['settings'] == true) {
      CliHelpers.printStep('Generating settings module...');
      await _moduleGenerator.generate(projectPath, 'settings', {
        'screens': ['settings_screen', 'theme_settings_screen'],
        'repository': false,
        'models': true,
        'apiEndpoints': false,
      });
    }

    // Generate app setup (service locator, routing, etc.)
    CliHelpers.printStep('Setting up application architecture...');
    await _appSetupGenerator.generate(projectPath, apiChoice);

    // Generate additional configuration files
    await _generateAdditionalFiles(projectPath, preferences);
  }

  Future<void> _generateAdditionalFiles(
    String projectPath,
    Map<String, dynamic> preferences,
  ) async {
    // Generate analysis_options.yaml for better code quality
    await _generateAnalysisOptions(projectPath);

    // Generate .gitignore additions
    await _enhanceGitignore(projectPath);

    // Generate README with project information
    await _generateReadme(projectPath, preferences);
  }

  Future<void> _generateAnalysisOptions(String projectPath) async {
    final analysisOptionsFile = File(
      p.join(projectPath, 'analysis_options.yaml'),
    );
    const content = '''
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Additional rules for better code quality
    always_declare_return_types: true
    avoid_empty_else: true
    avoid_print: true
    avoid_relative_lib_imports: true
    avoid_returning_null_for_future: true
    avoid_slow_async_io: true
    cancel_subscriptions: true
    close_sinks: true
    comment_references: true
    directives_ordering: true
    package_api_docs: false
    prefer_single_quotes: true
    sort_constructors_first: true
    sort_unnamed_constructors_first: true
    unawaited_futures: true
    use_key_in_widget_constructors: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
''';

    await analysisOptionsFile.writeAsString(content);
  }

  Future<void> _enhanceGitignore(String projectPath) async {
    final gitignoreFile = File(p.join(projectPath, '.gitignore'));

    if (gitignoreFile.existsSync()) {
      final content = await gitignoreFile.readAsString();
      const additions = '''

# BlocX CLI additions
*.env
.vscode/
.idea/
*.iml
*.log
coverage/
.dart_tool/packages
.packages
*.lock
pubspec.lock

# Generated files
*.g.dart
*.freezed.dart
*.config.dart

# Platform specific
.DS_Store
Thumbs.db

# IDE
*.swp
*.swo
*~
''';

      if (!content.contains('# BlocX CLI additions')) {
        await gitignoreFile.writeAsString(content + additions);
      }
    }
  }

  Future<void> _generateReadme(
    String projectPath,
    Map<String, dynamic> preferences,
  ) async {
    final readmeFile = File(p.join(projectPath, 'README.md'));
    final projectName = p.basename(projectPath);
    final apiClient = preferences['apiClient'];
    final modules = preferences['modules'] as Map<String, dynamic>;
    final packages = preferences['packages'] as Map<String, dynamic>;

    final enabledModules = <String>['Auth', 'Home'];
    if (modules['profile'] == true) enabledModules.add('Profile');
    if (modules['settings'] == true) enabledModules.add('Settings');

    final enabledPackages = <String>[
      'flutter_bloc',
      'get_it',
      'flutter_secure_storage',
    ];
    if (apiClient == 'dio') enabledPackages.add('dio');
    if (apiClient == 'http') enabledPackages.add('http');
    if (packages['cache'] == true) enabledPackages.add('hive_flutter');
    if (packages['imagePicker'] == true) enabledPackages.add('image_picker');
    if (packages['permissions'] == true)
      enabledPackages.add('permission_handler');

    final content =
        '''
# ${CliHelpers.toPascalCase(projectName)}

A Flutter application built with BlocX CLI - featuring clean architecture, state management with BLoC pattern, and secure API integration.

## 🚀 Generated with BlocX CLI

This project was scaffolded using BlocX CLI, which provides:
- ✅ Clean Architecture implementation
- ✅ BLoC state management
- ✅ Secure token storage
- ✅ Comprehensive error handling
- ✅ Repository pattern
- ✅ Dependency injection

## 📋 Features

### Modules
${enabledModules.map((module) => '- 🏗️ $module Module').join('\n')}

### Packages
${enabledPackages.map((pkg) => '- 📦 $pkg').join('\n')}

### API Integration
- 🌐 **API Client**: ${apiClient == 'dio' ? 'Dio' : 'HTTP'}
- 🔐 **Secure Storage**: Encrypted token storage with flutter_secure_storage
- 🔄 **Token Management**: Automatic token refresh and session handling
- ⚠️ **Error Handling**: Comprehensive network error handling

## 🏗️ Architecture

```
lib/
├── app/                 # App-level configuration
│   ├── app_router.dart         # Navigation routing
│   ├── service_locator.dart    # Dependency injection
│   └── bloc_observer.dart      # BLoC debugging
├── core/                # Core functionality
│   ├── network/               # API client and services
│   ├── constants/             # App and API constants
│   ├── utils/                 # Utilities and helpers
│   └── errors/                # Error handling
├── modules/             # Feature modules
${enabledModules.map((module) => '│   ├── ${module.toLowerCase()}/').join('\n')}
│       ├── bloc/              # State management
│       ├── screens/           # UI screens
│       ├── models/            # Data models
│       └── repository/        # Data layer
└── main.dart           # App entry point
```

## 🚦 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Run tests:**
   ```bash
   flutter test
   ```

### Configuration

1. **API Configuration:**
   - Update `lib/core/constants/api_constants.dart` with your API endpoints
   - Configure base URL and authentication requirements

2. **Environment Setup:**
   - Create `.env` files for different environments if needed
   - Update network configuration in core/network/

## 📱 Usage

### Authentication Flow
1. **Login/Register**: Handled by Auth module with secure token storage
2. **Session Management**: Automatic token refresh and validation
3. **Secure Logout**: Complete session cleanup

### State Management
- **BLoC Pattern**: Each module has its own BLoC for state management
- **Event-Driven**: UI events trigger business logic through BLoC events
- **Reactive**: UI rebuilds automatically based on state changes

### Navigation
- **Declarative Routing**: Centralized route management in `app_router.dart`
- **Type-Safe**: Route constants defined in `app_constants.dart`

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

## 📚 Documentation

### Adding New Modules
Use BlocX CLI to generate new modules:

```bash
blocx generate module user_profile
```

### Adding New Screens
```bash
blocx generate screen settings_screen
```

### Adding Packages
```bash
blocx add package shared_preferences
```

## 🛠️ Development

### Code Generation
If using json_serializable or other code generation:

```bash
flutter packages pub run build_runner build
```

### Code Quality
The project includes strict linting rules. Run:

```bash
flutter analyze
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [BlocX CLI](https://github.com/your-repo/blocx-cli)
- Powered by [Flutter](https://flutter.dev/)
- State management with [flutter_bloc](https://pub.dev/packages/flutter_bloc)

---

**Generated by BlocX CLI** - Accelerating Flutter development with best practices! 🚀
''';

    await readmeFile.writeAsString(content);
  }
}
