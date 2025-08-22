import 'dart:io';

class FlutterService {
  Future<void> checkInstallation() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode != 0) {
        throw Exception('Flutter is not installed or not in PATH');
      }
    } catch (e) {
      print('❌ Flutter CLI not found. Please install Flutter first.');
      print('Visit: https://flutter.dev/docs/get-started/install');
      exit(1);
    }
  }

  Future<void> createProject(String projectName) async {
    final result = await Process.run('flutter', ['create', projectName]);

    if (result.exitCode != 0) {
      print('❌ Flutter project creation failed:');
      print(result.stderr);
      exit(1);
    }
  }
}
