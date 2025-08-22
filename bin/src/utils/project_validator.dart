class ProjectValidator {
  static bool isValidProjectName(String name) {
    final regex = RegExp(r'^[a-z][a-z0-9_]*$');
    return regex.hasMatch(name) && name.length >= 2;
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
