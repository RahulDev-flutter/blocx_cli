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
  final String apiChoice = prompts.choose(
    '👉 Which API package do you want to use?',
    ['http', 'dio'],
  );

  // Step 2: Generate network layer
  final networkPath = p.join(projectDir.path, 'lib', 'core', 'network');
  createNetworkLayer(networkPath, apiChoice);

  // Step 3: Create default modules (Auth & Home)
  createModule(projectDir.path, 'auth');
  createModule(projectDir.path, 'home');

  print('🎉 Project "$name" is ready with $apiChoice setup + Auth & Home modules + Bloc boilerplate!');
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

  // Create Bloc files
  final blocBase = p.join(moduleBase, 'bloc');
  File(p.join(blocBase, '${moduleName}_event.dart'))
      .writeAsStringSync(eventTemplate(moduleName));
  File(p.join(blocBase, '${moduleName}_state.dart'))
      .writeAsStringSync(stateTemplate(moduleName));
  File(p.join(blocBase, '${moduleName}_bloc.dart'))
      .writeAsStringSync(blocTemplate(moduleName));

  print('✅ Module "$moduleName" created with 2 screens, repository, and Bloc boilerplate');
}

//
// ===================== Templates =====================
//

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

String eventTemplate(String name) => """
import 'package:equatable/equatable.dart';

abstract class ${_capitalize(name)}Event extends Equatable {
  const ${_capitalize(name)}Event();

  @override
  List<Object?> get props => [];
}

class ${_capitalize(name)}Started extends ${_capitalize(name)}Event {}
""";

String stateTemplate(String name) => """
import 'package:equatable/equatable.dart';

abstract class ${_capitalize(name)}State extends Equatable {
  const ${_capitalize(name)}State();

  @override
  List<Object?> get props => [];
}

class ${_capitalize(name)}Initial extends ${_capitalize(name)}State {}

class ${_capitalize(name)}Loading extends ${_capitalize(name)}State {}

class ${_capitalize(name)}Loaded extends ${_capitalize(name)}State {}

class ${_capitalize(name)}Error extends ${_capitalize(name)}State {
  final String message;
  const ${_capitalize(name)}Error(this.message);

  @override
  List<Object?> get props => [message];
}
""";

String blocTemplate(String name) => """
import 'package:flutter_bloc/flutter_bloc.dart';
import '${name}_event.dart';
import '${name}_state.dart';

class ${_capitalize(name)}Bloc extends Bloc<${_capitalize(name)}Event, ${_capitalize(name)}State> {
  ${_capitalize(name)}Bloc() : super(${_capitalize(name)}Initial()) {
    on<${_capitalize(name)}Started>((event, emit) async {
      emit(${_capitalize(name)}Loading());
      try {
        await Future.delayed(const Duration(seconds: 1)); // mock fetch
        emit(${_capitalize(name)}Loaded());
      } catch (e) {
        emit(${_capitalize(name)}Error(e.toString()));
      }
    });
  }
}
""";

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

