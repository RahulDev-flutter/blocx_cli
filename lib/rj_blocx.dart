/// RJ BlocX CLI - Enhanced Flutter Project Generator
///
/// Created with ❤️ by Rahul Verma
///
/// A powerful command-line tool for creating Flutter applications with
/// BLoC architecture, clean code structure, and industry best practices.
library rj_blocx;

// Version information
const String version = '2.0.0';
const String author = 'Rahul Verma';
const String description =
    'Enhanced Flutter Project Generator with BLoC architecture';
const String repository = 'https://github.com/RahulDev-flutter/blocx_cli';

// Basic CLI information
class RJBlocXInfo {
  static const String name = 'RJ BlocX CLI';
  static const String command = 'rj_blocx';
  static const String tagline = 'Enhanced Flutter Project Generator';

  static String get fullVersion =>
      '$name version $version - Created by $author';

  static List<String> get availableCommands => [
        'create <project_name>',
        'add package <package_name>',
        'add packages',
        'generate module <module_name>',
        'generate screen <screen_name>',
        'generate page <page_name>',
      ];

  static List<String> get features => [
        'Interactive API client selection (HTTP/Dio)',
        'Auto-generated Auth & Home modules',
        'Complete Bloc state management setup',
        'Secure storage with flutter_secure_storage',
        'Network layer with comprehensive error handling',
        'Repository pattern implementation',
        'Clean architecture with dependency injection',
        'CamelCase formatting for class names',
        'Package management',
        'Dynamic module/screen generation',
      ];
}
