class ProjectValidator {
  /// Validates if a project name follows Flutter naming conventions
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

  /// Validates module or screen name
  static bool isValidModuleName(String name) {
    if (name.isEmpty) return false;

    // Allow letters, numbers, underscores, hyphens
    return RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$').hasMatch(name);
  }

  /// Capitalizes the first letter of a string
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Converts string to PascalCase
  static String toPascalCase(String input) {
    if (input.isEmpty) return input;

    return input
        .split(RegExp(r'[_-]'))
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join('');
  }

  /// Converts string to camelCase
  static String toCamelCase(String input) {
    if (input.isEmpty) return input;

    final pascalCase = toPascalCase(input);
    return pascalCase[0].toLowerCase() + pascalCase.substring(1);
  }

  /// Converts PascalCase or camelCase to snake_case
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]}_${match[2]}')
        .toLowerCase();
  }
}
