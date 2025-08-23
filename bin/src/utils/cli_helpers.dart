import 'dart:io';

class CliHelpers {
  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _bold = '\x1B[1m';

  static void printSuccess(String message) {
    print('$_green✅ $message$_reset');
  }

  static void printError(String message) {
    print('$_red❌ $message$_reset');
  }

  static void printWarning(String message) {
    print('$_yellow⚠️  $message$_reset');
  }

  static void printInfo(String message) {
    print('$_blue💡 $message$_reset');
  }

  static void printHeader(String message) {
    print('$_bold$_cyan🚀 $message$_reset');
  }

  static void printSubHeader(String message) {
    print('$_bold$_white📋 $message$_reset');
  }

  static void printStep(String message) {
    print('$_magenta🛠️  $message$_reset');
  }

  static void printListItem(String message) {
    print('  • $message');
  }

  static void printSeparator() {
    print('─' * 50);
  }

  static void printEmptyLine() {
    print('');
  }

  /// Convert snake_case or kebab-case to PascalCase
  static String toPascalCase(String input) {
    if (input.isEmpty) return input;

    return input
        .split(RegExp(r'[_-]'))
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join('');
  }

  /// Convert snake_case or kebab-case to camelCase
  static String toCamelCase(String input) {
    if (input.isEmpty) return input;

    final pascalCase = toPascalCase(input);
    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }

  /// Convert PascalCase or camelCase to snake_case
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();
  }

  /// Validate project name (Flutter naming convention)
  static bool isValidProjectName(String name) {
    if (name.isEmpty) return false;

    // Must start with lowercase letter
    if (!RegExp(r'^[a-z]').hasMatch(name)) return false;

    // Can contain only lowercase letters, numbers, and underscores
    if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) return false;

    // Cannot end with underscore
    if (name.endsWith('_')) return false;

    // Cannot have consecutive underscores
    if (name.contains('__')) return false;

    return true;
  }

  /// Validate module/screen name
  static bool isValidModuleName(String name) {
    if (name.isEmpty) return false;

    // Allow letters, numbers, underscores, hyphens
    return RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$').hasMatch(name);
  }

  /// Check if current directory is a Flutter project
  static bool isFlutterProject() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) return false;

    final content = pubspecFile.readAsStringSync();
    return content.contains('flutter:') && content.contains('sdk: flutter');
  }

  /// Get Flutter project name from pubspec.yaml
  static String? getProjectName() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) return null;

    final lines = pubspecFile.readAsLinesSync();
    for (final line in lines) {
      if (line.trim().startsWith('name:')) {
        return line.split(':')[1].trim();
      }
    }
    return null;
  }

  /// Create directory if it doesn't exist
  static Future<Directory> ensureDirectory(String path) async {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Write file with content
  static Future<File> writeFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
    return file;
  }

  /// Show loading spinner
  static void showLoading(String message) {
    stdout.write('$_yellow⏳ $message...$_reset');
  }

  /// Hide loading spinner and show result
  static void hideLoading({bool success = true, String? message}) {
    stdout.write('\r\x1B[K'); // Clear current line
    if (message != null) {
      if (success) {
        printSuccess(message);
      } else {
        printError(message);
      }
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get relative path from current directory
  static String getRelativePath(String fullPath) {
    final currentDir = Directory.current.path;
    if (fullPath.startsWith(currentDir)) {
      return fullPath.substring(currentDir.length + 1);
    }
    return fullPath;
  }

  /// Capitalize first letter
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Create a nicely formatted table
  static void printTable(List<List<String>> rows, {List<String>? headers}) {
    if (rows.isEmpty) return;

    final allRows = headers != null ? [headers, ...rows] : rows;
    final columnWidths = <int>[];

    // Calculate column widths
    for (final row in allRows) {
      for (int i = 0; i < row.length; i++) {
        if (i >= columnWidths.length) {
          columnWidths.add(0);
        }
        if (row[i].length > columnWidths[i]) {
          columnWidths[i] = row[i].length;
        }
      }
    }

    // Print rows
    for (int rowIndex = 0; rowIndex < allRows.length; rowIndex++) {
      final row = allRows[rowIndex];
      final formattedCells = <String>[];

      for (int i = 0; i < row.length; i++) {
        final width = columnWidths[i];
        formattedCells.add(row[i].padRight(width));
      }

      print('  ${formattedCells.join('  ')}');

      // Print separator after header
      if (headers != null && rowIndex == 0) {
        final separator = columnWidths.map((width) => '-' * width).join('  ');
        print('  $separator');
      }
    }
  }
}
