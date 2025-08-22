#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:prompts/prompts.dart' as prompts;

void main(List<String> arguments) async {
  final parser = ArgParser()..addCommand('create');
  final argResults = parser.parse(arguments);

  if (argResults.command?.name == 'create') {
    final projectName = argResults.command?.rest.first;

    if (projectName == null) {
      print('❌ Please provide a project name.');
      exit(1);
    }

    await createOrUpdateProject(projectName);
  } else {
    print('BlocX CLI - Usage: blocx create <project_name>');
  }
}

Future<void> createOrUpdateProject(String name) async {
  final projectDir = Directory(name);

  if (!projectDir.existsSync()) {
    print('🚀 Creating new Flutter project "$name"...');
    final result = await Process.run('flutter', ['create', name]);

    if (result.exitCode != 0) {
      print('❌ Flutter project creation failed:\n${result.stderr}');
      exit(1);
    } else {
      print('✅ Flutter project "$name" created.');
    }
  } else {
    print('📁 Project "$name" already exists. Proceeding to update...');
  }

  // Step 1: Ask which API client
  final apiChoice = prompts.choose<String>(
    '👉 Which API package do you want to use?',
    ['http', 'dio'],
  );

  // Step 2: Generate network layer
  final networkPath = p.join(projectDir.path, 'lib', 'core', 'network');
  createNetworkLayer(networkPath, apiChoice);

  // Step 3: Create default modules (Auth & Home)
  createModule(projectDir.path, 'auth');
  createModule(projectDir.path, 'home');

  print('🎉 Project "$name" is ready with $apiChoice setup + Auth & Home modules!');
}

void createNetworkLayer(String basePath, String apiChoice) {
  final dir = Directory(basePath);
  dir.createSync(recursive: true);

  final file = File(p.join(basePath, '${apiChoice}_client.dart'));

  String content = '';
  if (apiChoice == 'dio') {
    content = dioClientTemplate;
  } else {
    content = httpClientTemplate;
  }

  file.writeAsStringSync(content);
  print('✅ Network layer created with $apiChoice');
}

void createModule(String projectPath, String moduleName) {
  final moduleBase = p.join(projectPath, 'lib', 'modules', moduleName);

  final dirs = [
    Directory(p.join(moduleBase, 'bloc')),
    Directory(p.join(moduleBase, 'screens')),
    Directory(p.join(moduleBase, 'repository')),
  ];

  for (final dir in dirs) {
    dir.createSync(recursive: true);
  }

  // Create repository file
  File(p.join(moduleBase, 'repository', '${moduleName}_repository.dart'))
      .writeAsStringSync(repositoryTemplate(moduleName));

  // Create 2 screens
  File(p.join(moduleBase, 'screens', '${moduleName}_screen1.dart'))
      .writeAsStringSync(screenTemplate('${moduleName} Screen 1'));
  File(p.join(moduleBase, 'screens', '${moduleName}_screen2.dart'))
      .writeAsStringSync(screenTemplate('${moduleName} Screen 2'));

  print('✅ Module "$moduleName" created with 2 screens & repository');
}

const dioClientTemplate = """
import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return "Connection timeout. Please try again.";
    } else if (error.response != null) {
      return "Error: \${error.response?.statusCode} \${error.response?.statusMessage}";
    } else {
      return "Unexpected error occurred.";
    }
  }
}
""";

const httpClientTemplate = """
import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  final String baseUrl;

  HttpClient({required this.baseUrl});

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl\$endpoint'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed: \${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: \$e');
    }
  }
}
""";

String repositoryTemplate(String name) => """
class ${_capitalize(name)}Repository {
  Future<void> fetchData() async {
    // TODO: implement repository logic
  }
}
""";

String screenTemplate(String title) => """
import 'package:flutter/material.dart';

class ${_capitalize(title.replaceAll(" ", ""))} extends StatelessWidget {
  const ${_capitalize(title.replaceAll(" ", ""))}({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$title')),
      body: const Center(child: Text('This is $title')),
    );
  }
}
""";

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
