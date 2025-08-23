import 'cli_helpers.dart';

class ProjectValidator {
  /// Validates if a project name follows Flutter naming conventions
  static bool isValidProjectName(String name) {
    return CliHelpers.isValidProjectName(name);
  }

  /// Validates module or screen name
  static bool isValidModuleName(String name) {
    return CliHelpers.isValidModuleName(name);
  }

  /// Capitalizes the first letter of a string
  static String capitalize(String input) {
    return CliHelpers.capitalize(input);
  }

  /// Converts string to PascalCase
  static String toPascalCase(String input) {
    return CliHelpers.toPascalCase(input);
  }

  /// Converts string to camelCase
  static String toCamelCase(String input) {
    return CliHelpers.toCamelCase(input);
  }

  /// Converts PascalCase or camelCase to snake_case
  static String toSnakeCase(String input) {
    return CliHelpers.toSnakeCase(input);
  }
}
