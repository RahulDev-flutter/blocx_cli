class ConditionalModuleTemplates {
  /// Repository template that handles cases when models are not included
  static String repositoryTemplate(
    String moduleName, {
    bool hasModels = true,
  }) {
    final modelImport = hasModels
        ? "import '../models/${CliHelpers2.toSnakeCase(moduleName)}_model.dart';"
        : '';

    final modelType = hasModels
        ? '${CliHelpers2.toPascalCase(moduleName)}Model'
        : 'Map<String, dynamic>';

    final listReturnType = hasModels
        ? 'List<${CliHelpers2.toPascalCase(moduleName)}Model>'
        : 'List<Map<String, dynamic>>';

    return """
import '../../../core/network/api_service.dart';
$modelImport

class ${CliHelpers2.toPascalCase(moduleName)}Repository {
  final ApiService _apiService;
  
  ${CliHelpers2.toPascalCase(moduleName)}Repository(this._apiService);
  
  Future<$listReturnType> get${CliHelpers2.toPascalCase(moduleName)}List() async {
    try {
      final response = await _apiService.get('/api/${CliHelpers2.toSnakeCase(moduleName)}/list');
      ${hasModels ? '''
      if (response.data is List) {
        return (response.data as List)
            .map((item) => ${CliHelpers2.toPascalCase(moduleName)}Model.fromJson(item))
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
      throw Exception('Failed to fetch ${CliHelpers2.toSnakeCase(moduleName)} list: \$e');
    }
  }
  
  Future<$modelType> get${CliHelpers2.toPascalCase(moduleName)}ById(String id) async {
    try {
      final response = await _apiService.get('/api/${CliHelpers2.toSnakeCase(moduleName)}/\$id');
      ${hasModels ? '''
      return ${CliHelpers2.toPascalCase(moduleName)}Model.fromJson(response.data);''' : '''
      return response.data as Map<String, dynamic>;'''}
    } catch (e) {
      throw Exception('Failed to fetch ${CliHelpers2.toSnakeCase(moduleName)}: \$e');
    }
  }
  
  Future<$modelType> create${CliHelpers2.toPascalCase(moduleName)}($modelType ${CliHelpers2.toCamelCase(moduleName)}) async {
    try {
      ${hasModels ? '''
      final response = await _apiService.post(
        '/api/${CliHelpers2.toSnakeCase(moduleName)}',
        data: ${CliHelpers2.toCamelCase(moduleName)}.toJson(),
      );
      return ${CliHelpers2.toPascalCase(moduleName)}Model.fromJson(response.data);''' : '''
      final response = await _apiService.post(
        '/api/${CliHelpers2.toSnakeCase(moduleName)}',
        data: ${CliHelpers2.toCamelCase(moduleName)},
      );
      return response.data as Map<String, dynamic>;'''}
    } catch (e) {
      throw Exception('Failed to create ${CliHelpers2.toSnakeCase(moduleName)}: \$e');
    }
  }
  
  Future<$modelType> update${CliHelpers2.toPascalCase(moduleName)}(String id, $modelType ${CliHelpers2.toCamelCase(moduleName)}) async {
    try {
      ${hasModels ? '''
      final response = await _apiService.put(
        '/api/${CliHelpers2.toSnakeCase(moduleName)}/\$id',
        data: ${CliHelpers2.toCamelCase(moduleName)}.toJson(),
      );
      return ${CliHelpers2.toPascalCase(moduleName)}Model.fromJson(response.data);''' : '''
      final response = await _apiService.put(
        '/api/${CliHelpers2.toSnakeCase(moduleName)}/\$id',
        data: ${CliHelpers2.toCamelCase(moduleName)},
      );
      return response.data as Map<String, dynamic>;'''}
    } catch (e) {
      throw Exception('Failed to update ${CliHelpers2.toSnakeCase(moduleName)}: \$e');
    }
  }
  
  Future<bool> delete${CliHelpers2.toPascalCase(moduleName)}(String id) async {
    try {
      await _apiService.delete('/api/${CliHelpers2.toSnakeCase(moduleName)}/\$id');
      return true;
    } catch (e) {
      throw Exception('Failed to delete ${CliHelpers2.toSnakeCase(moduleName)}: \$e');
    }
  }
}
""";
  }

  /// Bloc template that handles conditional repository imports
  static String blocTemplate(
    String moduleName, {
    bool hasRepository = true,
    bool hasModels = true,
  }) {
    final repositoryImport = hasRepository
        ? "import '../repository/${CliHelpers2.toSnakeCase(moduleName)}_repository.dart';"
        : '';

    final repositoryField = hasRepository
        ? 'final ${CliHelpers2.toPascalCase(moduleName)}Repository _repository;'
        : '';

    final constructorParam = hasRepository ? 'this._repository' : '';

    final repositoryCall = hasRepository
        ? '_repository.get${CliHelpers2.toPascalCase(moduleName)}List()'
        : 'Future.delayed(Duration(seconds: 1), () => <Map<String, dynamic>>[])';

    return """
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
$repositoryImport
${hasModels ? "import '../models/${CliHelpers2.toSnakeCase(moduleName)}_model.dart';" : ''}

import '${CliHelpers2.toSnakeCase(moduleName)}_event.dart';
import '${CliHelpers2.toSnakeCase(moduleName)}_state.dart';

class ${CliHelpers2.toPascalCase(moduleName)}Bloc extends Bloc<${CliHelpers2.toPascalCase(moduleName)}Event, ${CliHelpers2.toPascalCase(moduleName)}State> {
  $repositoryField

  ${CliHelpers2.toPascalCase(moduleName)}Bloc($constructorParam) : super(${CliHelpers2.toPascalCase(moduleName)}Initial()) {
    on<Load${CliHelpers2.toPascalCase(moduleName)}List>(_onLoad${CliHelpers2.toPascalCase(moduleName)}List);
    on<Refresh${CliHelpers2.toPascalCase(moduleName)}List>(_onRefresh${CliHelpers2.toPascalCase(moduleName)}List);
  }

  Future<void> _onLoad${CliHelpers2.toPascalCase(moduleName)}List(
    Load${CliHelpers2.toPascalCase(moduleName)}List event,
    Emitter<${CliHelpers2.toPascalCase(moduleName)}State> emit,
  ) async {
    emit(${CliHelpers2.toPascalCase(moduleName)}Loading());
    try {
      final items = await $repositoryCall;
      emit(${CliHelpers2.toPascalCase(moduleName)}Loaded(items));
    } catch (e) {
      emit(${CliHelpers2.toPascalCase(moduleName)}Error(e.toString()));
    }
  }

  Future<void> _onRefresh${CliHelpers2.toPascalCase(moduleName)}List(
    Refresh${CliHelpers2.toPascalCase(moduleName)}List event,
    Emitter<${CliHelpers2.toPascalCase(moduleName)}State> emit,
  ) async {
    try {
      final items = await $repositoryCall;
      emit(${CliHelpers2.toPascalCase(moduleName)}Loaded(items));
    } catch (e) {
      emit(${CliHelpers2.toPascalCase(moduleName)}Error(e.toString()));
    }
  }
}
""";
  }

  /// State template that handles conditional model types
  static String stateTemplate(
    String moduleName, {
    bool hasModels = true,
  }) {
    final modelImport = hasModels
        ? "import '../models/${CliHelpers2.toSnakeCase(moduleName)}_model.dart';"
        : '';

    final itemType = hasModels
        ? '${CliHelpers2.toPascalCase(moduleName)}Model'
        : 'Map<String, dynamic>';

    final listType = hasModels
        ? 'List<${CliHelpers2.toPascalCase(moduleName)}Model>'
        : 'List<Map<String, dynamic>>';

    return """
import 'package:equatable/equatable.dart';
$modelImport

abstract class ${CliHelpers2.toPascalCase(moduleName)}State extends Equatable {
  const ${CliHelpers2.toPascalCase(moduleName)}State();
  
  @override
  List<Object?> get props => [];
}

class ${CliHelpers2.toPascalCase(moduleName)}Initial extends ${CliHelpers2.toPascalCase(moduleName)}State {}

class ${CliHelpers2.toPascalCase(moduleName)}Loading extends ${CliHelpers2.toPascalCase(moduleName)}State {}

class ${CliHelpers2.toPascalCase(moduleName)}Loaded extends ${CliHelpers2.toPascalCase(moduleName)}State {
  final $listType items;
  
  const ${CliHelpers2.toPascalCase(moduleName)}Loaded(this.items);
  
  @override
  List<Object?> get props => [items];
}

class ${CliHelpers2.toPascalCase(moduleName)}Error extends ${CliHelpers2.toPascalCase(moduleName)}State {
  final String message;
  
  const ${CliHelpers2.toPascalCase(moduleName)}Error(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ${CliHelpers2.toPascalCase(moduleName)}ItemSelected extends ${CliHelpers2.toPascalCase(moduleName)}State {
  final $itemType item;
  
  const ${CliHelpers2.toPascalCase(moduleName)}ItemSelected(this.item);
  
  @override
  List<Object?> get props => [item];
}
""";
  }

  /// Event template
  static String eventTemplate(String moduleName) {
    return """
import 'package:equatable/equatable.dart';

abstract class ${CliHelpers2.toPascalCase(moduleName)}Event extends Equatable {
  const ${CliHelpers2.toPascalCase(moduleName)}Event();
  
  @override
  List<Object?> get props => [];
}

class Load${CliHelpers2.toPascalCase(moduleName)}List extends ${CliHelpers2.toPascalCase(moduleName)}Event {}

class Refresh${CliHelpers2.toPascalCase(moduleName)}List extends ${CliHelpers2.toPascalCase(moduleName)}Event {}

class Select${CliHelpers2.toPascalCase(moduleName)}Item extends ${CliHelpers2.toPascalCase(moduleName)}Event {
  final String id;
  
  const Select${CliHelpers2.toPascalCase(moduleName)}Item(this.id);
  
  @override
  List<Object?> get props => [id];
}

class Create${CliHelpers2.toPascalCase(moduleName)}Event extends ${CliHelpers2.toPascalCase(moduleName)}Event {
  final Map<String, dynamic> data;
  
  const Create${CliHelpers2.toPascalCase(moduleName)}Event(this.data);
  
  @override
  List<Object?> get props => [data];
}

class Update${CliHelpers2.toPascalCase(moduleName)}Event extends ${CliHelpers2.toPascalCase(moduleName)}Event {
  final String id;
  final Map<String, dynamic> data;
  
  const Update${CliHelpers2.toPascalCase(moduleName)}Event(this.id, this.data);
  
  @override
  List<Object?> get props => [id, data];
}

class Delete${CliHelpers2.toPascalCase(moduleName)}Event extends ${CliHelpers2.toPascalCase(moduleName)}Event {
  final String id;
  
  const Delete${CliHelpers2.toPascalCase(moduleName)}Event(this.id);
  
  @override
  List<Object?> get props => [id];
}
""";
  }

  /// Screen template that handles conditional bloc and model imports
  static String screenTemplate(
    String screenName,
    String moduleName, {
    required String screenType,
    required bool hasAppBar,
    required bool hasFab,
    required bool hasBottomNav,
    required bool hasModels,
    required bool hasRepository,
  }) {
    final blocImport = hasRepository
        ? """import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${CliHelpers2.toSnakeCase(moduleName)}_bloc.dart';
import '../bloc/${CliHelpers2.toSnakeCase(moduleName)}_event.dart';
import '../bloc/${CliHelpers2.toSnakeCase(moduleName)}_state.dart';"""
        : '';

    final modelImport = hasModels
        ? "import '../models/${CliHelpers2.toSnakeCase(moduleName)}_model.dart';"
        : '';

    final itemType = hasModels
        ? '${CliHelpers2.toPascalCase(moduleName)}Model'
        : 'Map<String, dynamic>';

    final screenContent = _generateScreenContent(
      screenName,
      moduleName,
      screenType,
      hasRepository,
      hasModels,
      itemType,
    );

    final fabWidget = hasFab
        ? """
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement FAB action
        },
        child: const Icon(Icons.add),
      ),"""
        : '';

    final bottomNavWidget = hasBottomNav
        ? """
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),"""
        : '';

    return """
import 'package:flutter/material.dart';
$blocImport
$modelImport

class ${CliHelpers2.toPascalCase(screenName)}Screen extends StatelessWidget {
  const ${CliHelpers2.toPascalCase(screenName)}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return ${hasRepository ? """BlocProvider(
      create: (context) => ${CliHelpers2.toPascalCase(moduleName)}Bloc()..add(Load${CliHelpers2.toPascalCase(moduleName)}List()),
      child: """ : ""}Scaffold(${hasAppBar ? """
      appBar: AppBar(
        title: Text('${CliHelpers2.toTitleCase(screenName)}'),
      ),""" : ''}
      body: $screenContent,$fabWidget$bottomNavWidget
    )${hasRepository ? ')' : ''};
  }
}
""";
  }

  static String _generateScreenContent(
    String screenName,
    String moduleName,
    String screenType,
    bool hasRepository,
    bool hasModels,
    String itemType,
  ) {
    if (!hasRepository) {
      return _getStaticContent(screenType, screenName);
    }

    switch (screenType) {
      case 'list':
        return """BlocBuilder<${CliHelpers2.toPascalCase(moduleName)}Bloc, ${CliHelpers2.toPascalCase(moduleName)}State>(
        builder: (context, state) {
          if (state is ${CliHelpers2.toPascalCase(moduleName)}Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ${CliHelpers2.toPascalCase(moduleName)}Error) {
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
          } else if (state is ${CliHelpers2.toPascalCase(moduleName)}Loaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<${CliHelpers2.toPascalCase(moduleName)}Bloc>()
                    .add(Refresh${CliHelpers2.toPascalCase(moduleName)}List());
              },
              child: ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ListTile(
                    title: Text(${hasModels ? 'item.title ?? \'No Title\'' : 'item[\'title\'] ?? \'No Title\''}),
                    subtitle: Text(${hasModels ? 'item.description ?? \'No Description\'' : 'item[\'description\'] ?? \'No Description\''}),
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

      case 'detail':
        return """BlocBuilder<${CliHelpers2.toPascalCase(moduleName)}Bloc, ${CliHelpers2.toPascalCase(moduleName)}State>(
        builder: (context, state) {
          if (state is ${CliHelpers2.toPascalCase(moduleName)}Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ${CliHelpers2.toPascalCase(moduleName)}Error) {
            return Center(child: Text('Error: \${state.message}'));
          } else if (state is ${CliHelpers2.toPascalCase(moduleName)}ItemSelected) {
            final item = state.item;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ${hasModels ? 'item.title ?? \'No Title\'' : 'item[\'title\'] ?? \'No Title\''},
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(${hasModels ? 'item.description ?? \'No Description\'' : 'item[\'description\'] ?? \'No Description\''}),
                  const SizedBox(height: 16),
                  // TODO: Add more details
                ],
              ),
            );
          }
          return const Center(child: Text('Select an item to view details'));
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

  static String _getStaticContent(String screenType, String screenName) {
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

      case 'detail':
        return """const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sample Detail',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('This is a sample detail screen. Add your content here.'),
            SizedBox(height: 16),
            // TODO: Add more details
          ],
        ),
      )""";

      case 'form':
        return """Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter title',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement form submission
              },
              child: Text('Submit'),
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

  /// Basic model template
  static String modelTemplate(String moduleName) {
    return """
class ${CliHelpers2.toPascalCase(moduleName)}Model {
  final String? id;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ${CliHelpers2.toPascalCase(moduleName)}Model({
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ${CliHelpers2.toPascalCase(moduleName)}Model.fromJson(Map<String, dynamic> json) {
    return ${CliHelpers2.toPascalCase(moduleName)}Model(
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

  ${CliHelpers2.toPascalCase(moduleName)}Model copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${CliHelpers2.toPascalCase(moduleName)}Model(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return '${CliHelpers2.toPascalCase(moduleName)}Model(id: \$id, title: \$title, description: \$description, createdAt: \$createdAt, updatedAt: \$updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ${CliHelpers2.toPascalCase(moduleName)}Model &&
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

  /// API endpoints constants template
  static String apiEndpointsTemplate(String moduleName) {
    return """
class ${CliHelpers2.toPascalCase(moduleName)}ApiEndpoints {
  static const String baseUrl = '/api/${CliHelpers2.toSnakeCase(moduleName)}';
  
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

// Helper extension for CLI utilities (assuming these methods exist)
extension CliHelpers2 on String {
  static String toPascalCase(String input) {
    return input
        .split(RegExp(r'[_\-\s]+'))
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join();
  }

  static String toCamelCase(String input) {
    final pascal = toPascalCase(input);
    return pascal.isNotEmpty
        ? pascal[0].toLowerCase() + pascal.substring(1)
        : '';
  }

  static String toSnakeCase(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}')
        .replaceAll(RegExp(r'^_'), '')
        .replaceAll(RegExp(r'[_\-\s]+'), '_')
        .toLowerCase();
  }

  static String toTitleCase(String input) {
    return input
        .split(RegExp(r'[_\-\s]+'))
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }
}
