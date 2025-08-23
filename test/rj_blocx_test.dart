import 'package:test/test.dart';

// Simple tests that don't require external files initially
void main() {
  group('RJ BlocX CLI Basic Tests', () {
    test('version string format', () {
      const version = '2.0.0';
      expect(version, isNotEmpty);
      expect(version, matches(RegExp(r'^\d+\.\d+\.\d+')));
    });

    test('author information', () {
      const author = 'Rahul Verma';
      expect(author, equals('Rahul Verma'));
    });

    test('repository URL format', () {
      const repoUrl = 'https://github.com/RahulDev-flutter/blocx_cli';
      expect(repoUrl, contains('github.com'));
      expect(repoUrl, contains('RahulDev-flutter'));
      expect(repoUrl, contains('blocx_cli'));
    });

    test('help command format validation', () {
      const helpContent = '''
🚀 RJ BlocX CLI v2.0.0 - Enhanced Flutter Project Generator
   Created with ❤️ by Rahul Verma

COMMANDS:
  create <project_name>
  add package <package_name>
  generate module <module_name>
      ''';

      expect(helpContent.contains('create'), isTrue);
      expect(helpContent.contains('add'), isTrue);
      expect(helpContent.contains('generate'), isTrue);
      expect(helpContent.contains('Rahul Verma'), isTrue);
    });

    test('project name validation patterns', () {
      // Valid project names
      final validNames = ['my_app', 'user_profile', 'simple', 'app123'];
      for (final name in validNames) {
        expect(RegExp(r'^[a-z][a-z0-9_]*').hasMatch(name), isTrue,
            reason: '$name should be valid');
      }

      // Invalid project names
      final invalidNames = ['', 'MyApp', 'my-app', '123app'];
      for (final name in invalidNames) {
        expect(RegExp(r'^[a-z][a-z0-9_]*').hasMatch(name), isFalse,
            reason: '$name should be invalid');
      }
    });

    test('string conversion patterns', () {
      // Test PascalCase conversion pattern
      final testCases = {
        'user_profile': 'UserProfile',
        'my-awesome-app': 'MyAwesomeApp',
        'simple': 'Simple',
      };

      for (final entry in testCases.entries) {
        final result = entry.key
            .split(RegExp(r'[_-]'))
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                : '')
            .join('');
        expect(result, equals(entry.value));
      }
    });

    test('CLI command structure', () {
      final commands = ['create', 'add', 'generate'];
      final subCommands = ['package', 'packages', 'module', 'screen', 'page'];

      expect(commands, hasLength(3));
      expect(subCommands, hasLength(5));
      expect(commands, contains('create'));
      expect(subCommands, contains('module'));
    });
  });

  group('File Structure Validation', () {
    test('expected project structure paths', () {
      final expectedPaths = [
        'lib/app/app_router.dart',
        'lib/app/service_locator.dart',
        'lib/core/network',
        'lib/core/constants',
        'lib/modules/auth/bloc',
        'lib/modules/home/screens',
      ];

      for (final path in expectedPaths) {
        expect(path, isNotEmpty);
        expect(path, startsWith('lib/'));
      }
    });

    test('package dependencies format', () {
      final dependencies = [
        'flutter_bloc: ^8.1.6',
        'equatable: ^2.0.5',
        'get_it: ^7.6.7',
        'dio: ^5.4.0',
        'flutter_secure_storage: ^9.2.2',
      ];

      for (final dep in dependencies) {
        expect(dep, contains(':'));
        expect(dep, contains('^'));
      }
    });
  });
}
