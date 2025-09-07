import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rj_blocx/src/templates/conditional_module_template.dart';

import '../utils/cli_helpers.dart';

class DynamicModuleGenerator {
  Future<void> generate(
    String projectPath,
    String moduleName,
    Map<String, dynamic> config,
  ) async {
    final moduleDir = Directory(p.join(
      projectPath,
      'lib',
      'modules',
      CliHelpers.toSnakeCase(moduleName),
    ));

    // Create module directory structure
    await _createDirectoryStructure(moduleDir, config);

    // Generate files based on configuration
    await _generateBlocFiles(moduleDir, moduleName, config);
    await _generateScreenFiles(moduleDir, moduleName, config);

    if (config['repository'] == true) {
      await _generateRepository(moduleDir, moduleName, config);
    }

    if (config['models'] == true) {
      await _generateModel(moduleDir, moduleName);
    }

    if (config['apiEndpoints'] == true) {
      await _generateApiEndpoints(moduleDir, moduleName);
    }
  }

  Future<void> _createDirectoryStructure(
    Directory moduleDir,
    Map<String, dynamic> config,
  ) async {
    // Create main module directory
    await moduleDir.create(recursive: true);

    // Create subdirectories
    await Directory(p.join(moduleDir.path, 'bloc')).create();
    await Directory(p.join(moduleDir.path, 'screens')).create();

    if (config['repository'] == true) {
      await Directory(p.join(moduleDir.path, 'repository')).create();
    }

    if (config['models'] == true) {
      await Directory(p.join(moduleDir.path, 'models')).create();
    }
  }

  Future<void> _generateBlocFiles(
    Directory moduleDir,
    String moduleName,
    Map<String, dynamic> config,
  ) async {
    final blocDir = Directory(p.join(moduleDir.path, 'bloc'));

    // Generate bloc file
    final blocFile = File(p.join(
      blocDir.path,
      '${CliHelpers.toSnakeCase(moduleName)}_bloc.dart',
    ));
    await blocFile.writeAsString(_generateBlocTemplate(moduleName, config));

    // Generate event file
    final eventFile = File(p.join(
      blocDir.path,
      '${CliHelpers.toSnakeCase(moduleName)}_event.dart',
    ));
    await eventFile.writeAsString(_generateEventTemplate(moduleName));

    // Generate state file
    final stateFile = File(p.join(
      blocDir.path,
      '${CliHelpers.toSnakeCase(moduleName)}_state.dart',
    ));
    await stateFile.writeAsString(_generateStateTemplate(moduleName, config));
  }

  Future<void> _generateScreenFiles(
    Directory moduleDir,
    String moduleName,
    Map<String, dynamic> config,
  ) async {
    final screensDir = Directory(p.join(moduleDir.path, 'screens'));
    final screens = config['screens'] as List<String>;

    for (final screenName in screens) {
      final screenFile = File(p.join(
        screensDir.path,
        '${CliHelpers.toSnakeCase(screenName)}_screen.dart',
      ));

      // Determine screen type based on name or default to basic
      String screenType = 'basic';
      if (screenName.toLowerCase().contains('list')) {
        screenType = 'list';
      } else if (screenName.toLowerCase().contains('detail')) {
        screenType = 'detail';
      } else if (screenName.toLowerCase().contains('form')) {
        screenType = 'form';
      }

      await screenFile.writeAsString(_generateScreenTemplate(
        screenName,
        moduleName,
        screenType,
        config,
      ));
    }
  }

  Future<void> _generateRepository(
    Directory moduleDir,
    String moduleName,
    Map<String, dynamic> config,
  ) async {
    final repositoryDir = Directory(p.join(moduleDir.path, 'repository'));
    final repositoryFile = File(p.join(
      repositoryDir.path,
      '${CliHelpers.toSnakeCase(moduleName)}_repository.dart',
    ));

    await repositoryFile.writeAsString(_generateRepositoryTemplate(
      moduleName,
      config,
    ));
  }

  Future<void> _generateModel(Directory moduleDir, String moduleName) async {
    final modelsDir = Directory(p.join(moduleDir.path, 'models'));
    final modelFile = File(p.join(
      modelsDir.path,
      '${CliHelpers.toSnakeCase(moduleName)}_model.dart',
    ));

    await modelFile.writeAsString(_generateModelTemplate(moduleName));
  }

  Future<void> _generateApiEndpoints(
    Directory moduleDir,
    String moduleName,
  ) async {
    final constantsDir = Directory(p.join(moduleDir.path, 'constants'));
    await constantsDir.create();

    final endpointsFile = File(p.join(
      constantsDir.path,
      '${CliHelpers.toSnakeCase(moduleName)}_endpoints.dart',
    ));

    await endpointsFile
        .writeAsString(_generateApiEndpointsTemplate(moduleName));
  }

  // Template Generation Methods

  String _generateBlocTemplate(String moduleName, Map<String, dynamic> config) {
    final hasRepository = config['repository'] == true;
    final hasModels = config['models'] == true;

    final repositoryImport = hasRepository
        ? "import '../repository/${CliHelpers.toSnakeCase(moduleName)}_repository.dart';"
        : '';

    final modelImport = hasModels
        ? "import '../models/${CliHelpers.toSnakeCase(moduleName)}_model.dart';"
        : '';

    final repositoryField = hasRepository
        ? 'final ${CliHelpers.toPascalCase(moduleName)}Repository _repository;'
        : '';

    final constructorParam = hasRepository ? 'this._repository' : '';

    final repositoryCall = hasRepository
        ? '_repository.get${CliHelpers.toPascalCase(moduleName)}List()'
        : '_getMockData()';

    return """
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
$repositoryImport
$modelImport

import '${CliHelpers.toSnakeCase(moduleName)}_event.dart';
import '${CliHelpers.toSnakeCase(moduleName)}_state.dart';

class ${CliHelpers.toPascalCase(moduleName)}Bloc extends Bloc<${CliHelpers.toPascalCase(moduleName)}Event, ${CliHelpers.toPascalCase(moduleName)}State> {
  $repositoryField

  ${CliHelpers.toPascalCase(moduleName)}Bloc($constructorParam) : super(${CliHelpers.toPascalCase(moduleName)}Initial()) {
    on<Load${CliHelpers.toPascalCase(moduleName)}List>(_onLoad${CliHelpers.toPascalCase(moduleName)}List);
    on<Refresh${CliHelpers.toPascalCase(moduleName)}List>(_onRefresh${CliHelpers.toPascalCase(moduleName)}List);
  }

  Future<void> _onLoad${CliHelpers.toPascalCase(moduleName)}List(
    Load${CliHelpers.toPascalCase(moduleName)}List event,
    Emitter<${CliHelpers.toPascalCase(moduleName)}State> emit,
  ) async {
    emit(${CliHelpers.toPascalCase(moduleName)}Loading());
    try {
      final items = await $repositoryCall;
      emit(${CliHelpers.toPascalCase(moduleName)}Loaded(items));
    } catch (e) {
      emit(${CliHelpers.toPascalCase(moduleName)}Error(e.toString()));
    }
  }

  Future<void> _onRefresh${CliHelpers.toPascalCase(moduleName)}List(
    Refresh${CliHelpers.toPascalCase(moduleName)}List event,
    Emitter<${CliHelpers.toPascalCase(moduleName)}State> emit,
  ) async {
    try {
      final items = await $repositoryCall;
      emit(${CliHelpers.toPascalCase(moduleName)}Loaded(items));
    } catch (e) {
      emit(${CliHelpers.toPascalCase(moduleName)}Error(e.toString()));
    }
  }

  ${!hasRepository ? '''
  // Mock data method when no repository is used
  Future<List<Map<String, dynamic>>> _getMockData() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'id': '1', 'title': 'Sample Item 1', 'description': 'Description 1'},
      {'id': '2', 'title': 'Sample Item 2', 'description': 'Description 2'},
      {'id': '3', 'title': 'Sample Item 3', 'description': 'Description 3'},
    ];
  }''' : ''}
}
""";
  }

  String _generateEventTemplate(String moduleName) {
    return """
import 'package:equatable/equatable.dart';

abstract class ${CliHelpers.toPascalCase(moduleName)}Event extends Equatable {
  const ${CliHelpers.toPascalCase(moduleName)}Event();
  
  @override
  List<Object?> get props => [];
}

class Load${CliHelpers.toPascalCase(moduleName)}List extends ${CliHelpers.toPascalCase(moduleName)}Event {}

class Refresh${CliHelpers.toPascalCase(moduleName)}List extends ${CliHelpers.toPascalCase(moduleName)}Event {}

class Select${CliHelpers.toPascalCase(moduleName)}Item extends ${CliHelpers.toPascalCase(moduleName)}Event {
  final String id;
  
  const Select${CliHelpers.toPascalCase(moduleName)}Item(this.id);
  
  @override
  List<Object?> get props => [id];
}

class Create${CliHelpers.toPascalCase(moduleName)}Event extends ${CliHelpers.toPascalCase(moduleName)}Event {
  final Map<String, dynamic> data;
  
  const Create${CliHelpers.toPascalCase(moduleName)}Event(this.data);
  
  @override
  List<Object?> get props => [data];
}

class Update${CliHelpers.toPascalCase(moduleName)}Event extends ${CliHelpers.toPascalCase(moduleName)}Event {
  final String id;
  final Map<String, dynamic> data;
  
  const Update${CliHelpers.toPascalCase(moduleName)}Event(this.id, this.data);
  
  @override
  List<Object?> get props => [id, data];
}

class Delete${CliHelpers.toPascalCase(moduleName)}Event extends ${CliHelpers.toPascalCase(moduleName)}Event {
  final String id;
  
  const Delete${CliHelpers.toPascalCase(moduleName)}Event(this.id);
  
  @override
  List<Object?> get props => [id];
}
""";
  }

  String _generateStateTemplate(
      String moduleName, Map<String, dynamic> config) {
    final hasModels = config['models'] == true;
    final modelImport = hasModels
        ? "import '../models/${CliHelpers.toSnakeCase(moduleName)}_model.dart';"
        : '';

    final itemType = hasModels
        ? '${CliHelpers.toPascalCase(moduleName)}Model'
        : 'Map<String, dynamic>';

    final listType = hasModels
        ? 'List<${CliHelpers.toPascalCase(moduleName)}Model>'
        : 'List<Map<String, dynamic>>';

    return """
import 'package:equatable/equatable.dart';
$modelImport

abstract class ${CliHelpers.toPascalCase(moduleName)}State extends Equatable {
  const ${CliHelpers.toPascalCase(moduleName)}State();
  
  @override
  List<Object?> get props => [];
}

class ${CliHelpers.toPascalCase(moduleName)}Initial extends ${CliHelpers.toPascalCase(moduleName)}State {}

class ${CliHelpers.toPascalCase(moduleName)}Loading extends ${CliHelpers.toPascalCase(moduleName)}State {}

class ${CliHelpers.toPascalCase(moduleName)}Loaded extends ${CliHelpers.toPascalCase(moduleName)}State {
  final $listType items;
  
  const ${CliHelpers.toPascalCase(moduleName)}Loaded(this.items);
  
  @override
  List<Object?> get props => [items];
}

class ${CliHelpers.toPascalCase(moduleName)}Error extends ${CliHelpers.toPascalCase(moduleName)}State {
  final String message;
  
  const ${CliHelpers.toPascalCase(moduleName)}Error(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ${CliHelpers.toPascalCase(moduleName)}ItemSelected extends ${CliHelpers.toPascalCase(moduleName)}State {
  final $itemType item;
  
  const ${CliHelpers.toPascalCase(moduleName)}ItemSelected(this.item);
  
  @override
  List<Object?> get props => [item];
}
""";
  }

  String _generateRepositoryTemplate(
    String moduleName,
    Map<String, dynamic> config,
  ) {
    final hasModels = config['models'] == true;
    final modelImport = hasModels
        ? "import '../models/${CliHelpers.toSnakeCase(moduleName)}_model.dart';"
        : '';

    final modelType = hasModels
        ? '${CliHelpers.toPascalCase(moduleName)}Model'
        : 'Map<String, dynamic>';

    final listReturnType = hasModels
        ? 'List<${CliHelpers.toPascalCase(moduleName)}Model>'
        : 'List<Map<String, dynamic>>';

    return """
import '../../../core/network/api_service.dart';
$modelImport

class ${CliHelpers.toPascalCase(moduleName)}Repository {
  final ApiService _apiService;
  
  ${CliHelpers.toPascalCase(moduleName)}Repository(this._apiService);
  
  Future<$listReturnType> get${CliHelpers.toPascalCase(moduleName)}List() async {
    try {
      final response = await _apiService.get('/api/${CliHelpers.toSnakeCase(moduleName)}/list');
      ${hasModels ? '''
      if (response.data is List) {
        return (response.data as List)
            .map((item) => ${CliHelpers.toPascalCase(moduleName)}Model.fromJson(item))
            .toList();
      }
      return [];''' : '''
      if (response.data is List) {
        return (response.data as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
      return [];'''}
    } catch (e) {
      throw Exception('Failed to fetch ${CliHelpers.toSnakeCase(moduleName)} list: \$e');
    }
  }
  
  Future<$modelType> get${CliHelpers.toPascalCase(moduleName)}ById(String id) async {
    try {
      final response = await _apiService.get('/api/${CliHelpers.toSnakeCase(moduleName)}/\$id');
      ${hasModels ? '''
      return ${CliHelpers.toPascalCase(moduleName)}Model.fromJson(response.data);''' : '''
      return response.data as Map<String, dynamic>;'''}
    } catch (e) {
      throw Exception('Failed to fetch ${CliHelpers.toSnakeCase(moduleName)}: \$e');
    }
  }
  
  Future<$modelType> create${CliHelpers.toPascalCase(moduleName)}($modelType ${CliHelpers.toCamelCase(moduleName)}) async {
    try {
      ${hasModels ? '''
      final response = await _apiService.post(
        '/api/${CliHelpers.toSnakeCase(moduleName)}',
        data: ${CliHelpers.toCamelCase(moduleName)}.toJson(),
      );
      return ${CliHelpers.toPascalCase(moduleName)}Model.fromJson(response.data);''' : '''
      final response = await _apiService.post(
        '/api/${CliHelpers.toSnakeCase(moduleName)}',
        data: ${CliHelpers.toCamelCase(moduleName)},
      );
      return response.data as Map<String, dynamic>;'''}
    } catch (e) {
      throw Exception('Failed to create ${CliHelpers.toSnakeCase(moduleName)}: \$e');
    }
  }
  
  Future<$modelType> update${CliHelpers.toPascalCase(moduleName)}(String id, $modelType ${CliHelpers.toCamelCase(moduleName)}) async {
    try {
      ${hasModels ? '''
      final response = await _apiService.put(
        '/api/${CliHelpers.toSnakeCase(moduleName)}/\$id',
        data: ${CliHelpers.toCamelCase(moduleName)}.toJson(),
      );
      return ${CliHelpers.toPascalCase(moduleName)}Model.fromJson(response.data);''' : '''
      final response = await _apiService.put(
        '/api/${CliHelpers.toSnakeCase(moduleName)}/\$id',
        data: ${CliHelpers.toCamelCase(moduleName)},
      );
      return response.data as Map<String, dynamic>;'''}
    } catch (e) {
      throw Exception('Failed to update ${CliHelpers.toSnakeCase(moduleName)}: \$e');
    }
  }
  
  Future<bool> delete${CliHelpers.toPascalCase(moduleName)}(String id) async {
    try {
      await _apiService.delete('/api/${CliHelpers.toSnakeCase(moduleName)}/\$id');
      return true;
    } catch (e) {
      throw Exception('Failed to delete ${CliHelpers.toSnakeCase(moduleName)}: \$e');
    }
  }
}
""";
  }

  String _generateScreenTemplate(
    String screenName,
    String moduleName,
    String screenType,
    Map<String, dynamic> config,
  ) {
    final hasRepository = config['repository'] == true;
    final hasModels = config['models'] == true;

    final blocImport = hasRepository
        ? """import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${CliHelpers.toSnakeCase(moduleName)}_bloc.dart';
import '../bloc/${CliHelpers.toSnakeCase(moduleName)}_event.dart';
import '../bloc/${CliHelpers.toSnakeCase(moduleName)}_state.dart';"""
        : '';

    final modelImport = hasModels
        ? "import '../models/${CliHelpers.toSnakeCase(moduleName)}_model.dart';"
        : '';

    final screenContent = _generateScreenContent(
      screenName,
      moduleName,
      screenType,
      hasRepository,
      hasModels,
    );

    return """
import 'package:flutter/material.dart';
$blocImport
$modelImport

class ${CliHelpers.toPascalCase(screenName)}Screen extends StatelessWidget {
  const ${CliHelpers.toPascalCase(screenName)}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return ${hasRepository ? """BlocProvider(
      create: (context) => ${CliHelpers.toPascalCase(moduleName)}Bloc()..add(Load${CliHelpers.toPascalCase(moduleName)}List()),
      child: """ : ""}Scaffold(
      appBar: AppBar(
        title: Text('${CliHelpers2.toTitleCase(screenName)}'),
      ),
      body: $screenContent,
    )${hasRepository ? ')' : ''};
  }
}
""";
  }

  String _generateScreenContent(
    String screenName,
    String moduleName,
    String screenType,
    bool hasRepository,
    bool hasModels,
  ) {
    if (!hasRepository) {
      return _getStaticContent(screenType, screenName);
    }

    switch (screenType) {
      case 'list':
        return """BlocBuilder<${CliHelpers.toPascalCase(moduleName)}Bloc, ${CliHelpers.toPascalCase(moduleName)}State>(
        builder: (context, state) {
          if (state is ${CliHelpers.toPascalCase(moduleName)}Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ${CliHelpers.toPascalCase(moduleName)}Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: \${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<${CliHelpers2.toPascalCase(moduleName)}Bloc>()
                          .add(Refresh${CliHelpers2.toPascalCase(moduleName)}List());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ${CliHelpers.toPascalCase(moduleName)}Loaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<${CliHelpers.toPascalCase(moduleName)}Bloc>()
                    .add(Refresh${CliHelpers.toPascalCase(moduleName)}List());
              },
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ListTile(
                    title: Text(${hasModels ? 'item.title ?? \'No Title\'' : 'item[\'title\']?.toString() ?? \'No Title\''}),
                    subtitle: Text(${hasModels ? 'item.description ?? \'No Description\'' : 'item[\'description\']?.toString() ?? \'No Description\''}),
                    onTap: () {
                      // TODO: Navigate to detail screen
                    },
                  );
                },
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      )""";

      case 'form':
        return """Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement form submission
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      )""";

      default: // basic or detail
        return """const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 64),
            SizedBox(height: 16),
            Text(
              '${CliHelpers2.toTitleCase(screenName)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Welcome to your new screen!'),
          ],
        ),
      )""";
    }
  }

  String _getStaticContent(String screenType, String screenName) {
    switch (screenType) {
      case 'list':
        return """ListView.builder(
        itemCount: 10, // Sample data
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item \${index + 1}'),
            subtitle: Text('Description for item \${index + 1}'),
            onTap: () {
              // TODO: Navigate to detail screen
            },
          );
        },
      )""";

      case 'form':
        return """Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement form submission
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      )""";

      default: // basic
        return """const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 64),
            SizedBox(height: 16),
            Text(
              '${CliHelpers2.toTitleCase(screenName)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Welcome to your new screen!'),
          ],
        ),
      )""";
    }
  }

  String _generateModelTemplate(String moduleName) {
    return """
class ${CliHelpers.toPascalCase(moduleName)}Model {
  final String? id;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ${CliHelpers.toPascalCase(moduleName)}Model({
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ${CliHelpers.toPascalCase(moduleName)}Model.fromJson(Map<String, dynamic> json) {
    return ${CliHelpers.toPascalCase(moduleName)}Model(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  ${CliHelpers.toPascalCase(moduleName)}Model copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${CliHelpers.toPascalCase(moduleName)}Model(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return '${CliHelpers.toPascalCase(moduleName)}Model(id: \$id, title: \$title, description: \$description, createdAt: \$createdAt, updatedAt: \$updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ${CliHelpers.toPascalCase(moduleName)}Model &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, createdAt, updatedAt);
  }
}
""";
  }

  String _generateApiEndpointsTemplate(String moduleName) {
    return """
class ${CliHelpers.toPascalCase(moduleName)}ApiEndpoints {
  static const String baseUrl = '/api/${CliHelpers.toSnakeCase(moduleName)}';
  
  // GET endpoints
  static const String list = '\$baseUrl/list';
  static String detail(String id) => '\$baseUrl/\$id';
  
  // POST endpoints
  static const String create = baseUrl;
  
  // PUT endpoints
  static String update(String id) => '\$baseUrl/\$id';
  
  // DELETE endpoints
  static String delete(String id) => '\$baseUrl/\$id';
  
  // Additional endpoints
  static const String search = '\$baseUrl/search';
  static String filter(Map<String, String> params) {
    final queryString = params.entries
        .map((e) => '\${e.key}=\${e.value}')
        .join('&');
    return '\$baseUrl/filter?\$queryString';
  }
}
""";
  }
}
