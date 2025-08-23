class DynamicTemplates {
  // Bloc Event Template
  static String eventTemplate(
    String pascalModuleName,
    String snakeModuleName,
  ) =>
      '''
import 'package:equatable/equatable.dart';

abstract class ${pascalModuleName}Event extends Equatable {
  const ${pascalModuleName}Event();

  @override
  List<Object?> get props => [];
}

class ${pascalModuleName}Started extends ${pascalModuleName}Event {}

class ${pascalModuleName}LoadData extends ${pascalModuleName}Event {}

class ${pascalModuleName}RefreshData extends ${pascalModuleName}Event {}

class ${pascalModuleName}CreateItem extends ${pascalModuleName}Event {
  final Map<String, dynamic> data;
  
  const ${pascalModuleName}CreateItem(this.data);
  
  @override
  List<Object> get props => [data];
}

class ${pascalModuleName}UpdateItem extends ${pascalModuleName}Event {
  final String id;
  final Map<String, dynamic> data;
  
  const ${pascalModuleName}UpdateItem(this.id, this.data);
  
  @override
  List<Object> get props => [id, data];
}

class ${pascalModuleName}DeleteItem extends ${pascalModuleName}Event {
  final String id;
  
  const ${pascalModuleName}DeleteItem(this.id);
  
  @override
  List<Object> get props => [id];
}
''';

  // Bloc State Template
  static String stateTemplate(
    String pascalModuleName,
    String snakeModuleName,
  ) =>
      '''
import 'package:equatable/equatable.dart';
import '../models/${snakeModuleName}_model.dart';

abstract class ${pascalModuleName}State extends Equatable {
  const ${pascalModuleName}State();

  @override
  List<Object?> get props => [];
}

class ${pascalModuleName}Initial extends ${pascalModuleName}State {}

class ${pascalModuleName}Loading extends ${pascalModuleName}State {}

class ${pascalModuleName}Loaded extends ${pascalModuleName}State {
  final List<${pascalModuleName}Model> items;
  
  const ${pascalModuleName}Loaded(this.items);
  
  @override
  List<Object> get props => [items];
}

class ${pascalModuleName}ItemLoaded extends ${pascalModuleName}State {
  final ${pascalModuleName}Model item;
  
  const ${pascalModuleName}ItemLoaded(this.item);
  
  @override
  List<Object> get props => [item];
}

class ${pascalModuleName}Success extends ${pascalModuleName}State {
  final String message;
  
  const ${pascalModuleName}Success(this.message);
  
  @override
  List<Object> get props => [message];
}

class ${pascalModuleName}Error extends ${pascalModuleName}State {
  final String message;
  
  const ${pascalModuleName}Error(this.message);
  
  @override
  List<Object> get props => [message];
}
''';

  // Bloc Template
  static String blocTemplate(String pascalModuleName, String snakeModuleName) =>
      '''
import 'package:flutter_bloc/flutter_bloc.dart';
import '${snakeModuleName}_event.dart';
import '${snakeModuleName}_state.dart';
import '../repository/${snakeModuleName}_repository.dart';

class ${pascalModuleName}Bloc extends Bloc<${pascalModuleName}Event, ${pascalModuleName}State> {
  final ${pascalModuleName}Repository _repository;

  ${pascalModuleName}Bloc(this._repository) : super(${pascalModuleName}Initial()) {
    on<${pascalModuleName}Started>(_onStarted);
    on<${pascalModuleName}LoadData>(_onLoadData);
    on<${pascalModuleName}RefreshData>(_onRefreshData);
    on<${pascalModuleName}CreateItem>(_onCreateItem);
    on<${pascalModuleName}UpdateItem>(_onUpdateItem);
    on<${pascalModuleName}DeleteItem>(_onDeleteItem);
  }

  Future<void> _onStarted(${pascalModuleName}Started event, Emitter<${pascalModuleName}State> emit) async {
    emit(${pascalModuleName}Loading());
    try {
      final result = await _repository.getItems();
      result.fold(
        (failure) => emit(${pascalModuleName}Error(failure.message)),
        (items) => emit(${pascalModuleName}Loaded(items)),
      );
    } catch (e) {
      emit(${pascalModuleName}Error(e.toString()));
    }
  }

  Future<void> _onLoadData(${pascalModuleName}LoadData event, Emitter<${pascalModuleName}State> emit) async {
    emit(${pascalModuleName}Loading());
    try {
      final result = await _repository.getItems();
      result.fold(
        (failure) => emit(${pascalModuleName}Error(failure.message)),
        (items) => emit(${pascalModuleName}Loaded(items)),
      );
    } catch (e) {
      emit(${pascalModuleName}Error(e.toString()));
    }
  }

  Future<void> _onRefreshData(${pascalModuleName}RefreshData event, Emitter<${pascalModuleName}State> emit) async {
    try {
      final result = await _repository.getItems();
      result.fold(
        (failure) => emit(${pascalModuleName}Error(failure.message)),
        (items) => emit(${pascalModuleName}Loaded(items)),
      );
    } catch (e) {
      emit(${pascalModuleName}Error(e.toString()));
    }
  }

  Future<void> _onCreateItem(${pascalModuleName}CreateItem event, Emitter<${pascalModuleName}State> emit) async {
    try {
      final result = await _repository.createItem(event.data);
      result.fold(
        (failure) => emit(${pascalModuleName}Error(failure.message)),
        (item) {
          emit(${pascalModuleName}Success('Item created successfully'));
          add(${pascalModuleName}RefreshData());
        },
      );
    } catch (e) {
      emit(${pascalModuleName}Error(e.toString()));
    }
  }

  Future<void> _onUpdateItem(${pascalModuleName}UpdateItem event, Emitter<${pascalModuleName}State> emit) async {
    try {
      final result = await _repository.updateItem(event.id, event.data);
      result.fold(
        (failure) => emit(${pascalModuleName}Error(failure.message)),
        (item) {
          emit(${pascalModuleName}Success('Item updated successfully'));
          add(${pascalModuleName}RefreshData());
        },
      );
    } catch (e) {
      emit(${pascalModuleName}Error(e.toString()));
    }
  }

  Future<void> _onDeleteItem(${pascalModuleName}DeleteItem event, Emitter<${pascalModuleName}State> emit) async {
    try {
      final result = await _repository.deleteItem(event.id);
      result.fold(
        (failure) => emit(${pascalModuleName}Error(failure.message)),
        (_) {
          emit(${pascalModuleName}Success('Item deleted successfully'));
          add(${pascalModuleName}RefreshData());
        },
      );
    } catch (e) {
      emit(${pascalModuleName}Error(e.toString()));
    }
  }
}
''';

  // Repository Template
  static String repositoryTemplate(
    String pascalModuleName,
    String snakeModuleName,
  ) =>
      '''
import '../../core/network/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../models/${snakeModuleName}_model.dart';

// Either class for error handling
abstract class Either<L, R> {
  const Either();
  
  T fold<T>(T Function(L) left, T Function(R) right);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
  
  @override
  T fold<T>(T Function(L) left, T Function(R) right) => left(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
  
  @override
  T fold<T>(T Function(L) left, T Function(R) right) => right(value);
}

class ${pascalModuleName}Repository {
  final ApiService _apiService;
  
  ${pascalModuleName}Repository(this._apiService);
  
  Future<Either<Failure, List<${pascalModuleName}Model>>> getItems() async {
    try {
      final response = await _apiService.get(ApiConstants.${snakeModuleName}List);
      
      if (response.success) {
        final List<dynamic> data = response.data ?? [];
        final items = data.map((json) => ${pascalModuleName}Model.fromJson(json)).toList();
        return Right(items);
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to load ${snakeModuleName} items'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
  
  Future<Either<Failure, ${pascalModuleName}Model>> getItem(String id) async {
    try {
      final response = await _apiService.get(
        ApiConstants.${snakeModuleName}Detail.replaceAll('{id}', id),
      );
      
      if (response.success) {
        final item = ${pascalModuleName}Model.fromJson(response.data);
        return Right(item);
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to load ${snakeModuleName} item'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
  
  Future<Either<Failure, ${pascalModuleName}Model>> createItem(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        ApiConstants.${snakeModuleName}Create,
        data: data,
      );
      
      if (response.success) {
        final item = ${pascalModuleName}Model.fromJson(response.data);
        return Right(item);
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to create ${snakeModuleName} item'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
  
  Future<Either<Failure, ${pascalModuleName}Model>> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        ApiConstants.${snakeModuleName}Update.replaceAll('{id}', id),
        data: data,
      );
      
      if (response.success) {
        final item = ${pascalModuleName}Model.fromJson(response.data);
        return Right(item);
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to update ${snakeModuleName} item'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
  
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.${snakeModuleName}Delete.replaceAll('{id}', id),
      );
      
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to delete ${snakeModuleName} item'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
}
''';

  // Model Template
  static String modelTemplate(
    String pascalModuleName,
    String snakeModuleName,
  ) =>
      '''
import 'package:equatable/equatable.dart';

class ${pascalModuleName}Model extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ${pascalModuleName}Model({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ${pascalModuleName}Model.fromJson(Map<String, dynamic> json) {
    return ${pascalModuleName}Model(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ${pascalModuleName}Model copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ${pascalModuleName}Model(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, createdAt, updatedAt];
}
''';

  // Basic Screen Template
  static String screenTemplate(
    String pascalScreenName,
    String snakeScreenName,
    String pascalModuleName,
    String snakeModuleName, [
    Map<String, dynamic>? config,
  ]) =>
      '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${snakeModuleName}_bloc.dart';
import '../bloc/${snakeModuleName}_event.dart';
import '../bloc/${snakeModuleName}_state.dart';
import '../../../core/utils/helpers.dart';

class $pascalScreenName extends StatefulWidget {
  const $pascalScreenName({super.key});

  @override
  State<$pascalScreenName> createState() => _${pascalScreenName}State();
}

class _${pascalScreenName}State extends State<$pascalScreenName> {
  @override
  void initState() {
    super.initState();
    context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}Started());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ${config?['hasAppBar'] != false ? '''appBar: AppBar(
        title: const Text('$pascalScreenName'),
        centerTitle: true,
      ),''' : ''}
      body: BlocListener<${pascalModuleName}Bloc, ${pascalModuleName}State>(
        listener: (context, state) {
          if (state is ${pascalModuleName}Error) {
            AppHelpers.showSnackBar(context, state.message, isError: true);
          } else if (state is ${pascalModuleName}Success) {
            AppHelpers.showSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<${pascalModuleName}Bloc, ${pascalModuleName}State>(
          builder: (context, state) {
            if (state is ${pascalModuleName}Loading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ${pascalModuleName}Error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: \${state.message}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}RefreshData()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$pascalScreenName',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This is the $pascalScreenName screen. Customize it according to your needs.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}LoadData()),
                    child: const Text('Load Data'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ${config?['hasFab'] == true ? '''floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your FAB action here
          AppHelpers.showSnackBar(context, 'FAB pressed');
        },
        child: const Icon(Icons.add),
      ),''' : ''}
      ${config?['hasBottomNav'] == true ? '''bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation tap
        },
      ),''' : ''}
    );
  }
}
''';

  // List Screen Template
  static String listScreenTemplate(
    String pascalScreenName,
    String snakeScreenName,
    String pascalModuleName,
    String snakeModuleName,
    Map<String, dynamic> config,
  ) =>
      '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${snakeModuleName}_bloc.dart';
import '../bloc/${snakeModuleName}_event.dart';
import '../bloc/${snakeModuleName}_state.dart';
import '../models/${snakeModuleName}_model.dart';
import '../../../core/utils/helpers.dart';

class $pascalScreenName extends StatefulWidget {
  const $pascalScreenName({super.key});

  @override
  State<$pascalScreenName> createState() => _${pascalScreenName}State();
}

class _${pascalScreenName}State extends State<$pascalScreenName> {
  @override
  void initState() {
    super.initState();
    context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}LoadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ${config['hasAppBar'] != false ? '''appBar: AppBar(
        title: const Text('$pascalScreenName'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}RefreshData()),
          ),
        ],
      ),''' : ''}
      body: BlocListener<${pascalModuleName}Bloc, ${pascalModuleName}State>(
        listener: (context, state) {
          if (state is ${pascalModuleName}Error) {
            AppHelpers.showSnackBar(context, state.message, isError: true);
          } else if (state is ${pascalModuleName}Success) {
            AppHelpers.showSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<${pascalModuleName}Bloc, ${pascalModuleName}State>(
          builder: (context, state) {
            if (state is ${pascalModuleName}Loading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ${pascalModuleName}Error) {
              return _buildErrorWidget(context, state.message);
            }
            
            if (state is ${pascalModuleName}Loaded) {
              return _buildListWidget(state.items);
            }
            
            return const Center(child: Text('No data available'));
          },
        ),
      ),
      ${config['hasFab'] == true ? '''floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create screen
          AppHelpers.showSnackBar(context, 'Add new item');
        },
        child: const Icon(Icons.add),
      ),''' : ''}
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error: \$message',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}RefreshData()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildListWidget(List<${pascalModuleName}Model> items) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No items found'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}RefreshData());
      },
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(item.title),
              subtitle: item.description != null ? Text(item.description!) : null,
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) => _handleMenuAction(context, value.toString(), item),
              ),
              onTap: () {
                // Navigate to detail screen
                AppHelpers.showSnackBar(context, 'Tapped: \${item.title}');
              },
            ),
          );
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, ${pascalModuleName}Model item) {
    switch (action) {
      case 'edit':
        // Navigate to edit screen
        AppHelpers.showSnackBar(context, 'Edit: \${item.title}');
        break;
      case 'delete':
        AppHelpers.showConfirmDialog(
          context,
          'Delete Item',
          'Are you sure you want to delete "\${item.title}"?',
          () => context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}DeleteItem(item.id)),
        );
        break;
    }
  }
}
''';

  // Detail Screen Template
  static String detailScreenTemplate(
    String pascalScreenName,
    String snakeScreenName,
    String pascalModuleName,
    String snakeModuleName,
    Map<String, dynamic> config,
  ) =>
      '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${snakeModuleName}_bloc.dart';
import '../bloc/${snakeModuleName}_event.dart';
import '../bloc/${snakeModuleName}_state.dart';
import '../models/${snakeModuleName}_model.dart';
import '../../../core/utils/helpers.dart';

class $pascalScreenName extends StatefulWidget {
  final String itemId;
  
  const $pascalScreenName({
    super.key,
    required this.itemId,
  });

  @override
  State<$pascalScreenName> createState() => _${pascalScreenName}State();
}

class _${pascalScreenName}State extends State<$pascalScreenName> {
  @override
  void initState() {
    super.initState();
    // Load specific item - you'll need to add this event
    context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}LoadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ${config['hasAppBar'] != false ? '''appBar: AppBar(
        title: const Text('$pascalScreenName'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              AppHelpers.showSnackBar(context, 'Edit item');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteItem(),
          ),
        ],
      ),''' : ''}
      body: BlocListener<${pascalModuleName}Bloc, ${pascalModuleName}State>(
        listener: (context, state) {
          if (state is ${pascalModuleName}Error) {
            AppHelpers.showSnackBar(context, state.message, isError: true);
          } else if (state is ${pascalModuleName}Success) {
            AppHelpers.showSnackBar(context, state.message);
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<${pascalModuleName}Bloc, ${pascalModuleName}State>(
          builder: (context, state) {
            if (state is ${pascalModuleName}Loading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ${pascalModuleName}Error) {
              return _buildErrorWidget(context, state.message);
            }
            
            if (state is ${pascalModuleName}ItemLoaded) {
              return _buildDetailWidget(state.item);
            }
            
            // Fallback for loaded state with list
            if (state is ${pascalModuleName}Loaded && state.items.isNotEmpty) {
              final item = state.items.firstWhere(
                (item) => item.id == widget.itemId,
                orElse: () => state.items.first,
              );
              return _buildDetailWidget(item);
            }
            
            return const Center(child: Text('Item not found'));
          },
        ),
      ),
      ${config['hasFab'] == true ? '''floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppHelpers.showSnackBar(context, 'Share item');
        },
        child: const Icon(Icons.share),
      ),''' : ''}
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error: \$message',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailWidget(${pascalModuleName}Model item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (item.description != null) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('ID', item.id),
                  _buildDetailRow('Created', AppHelpers.formatDateTime(item.createdAt)),
                  _buildDetailRow('Updated', AppHelpers.formatDateTime(item.updatedAt)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppHelpers.showSnackBar(context, 'Edit item');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deleteItem,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _deleteItem() {
    AppHelpers.showConfirmDialog(
      context,
      'Delete Item',
      'Are you sure you want to delete this item?',
      () => context.read<${pascalModuleName}Bloc>().add(${pascalModuleName}DeleteItem(widget.itemId)),
    );
  }
}
''';

  // Form Screen Template
  static String formScreenTemplate(
    String pascalScreenName,
    String snakeScreenName,
    String pascalModuleName,
    String snakeModuleName,
    Map<String, dynamic> config,
  ) =>
      '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${snakeModuleName}_bloc.dart';
import '../bloc/${snakeModuleName}_event.dart';
import '../bloc/${snakeModuleName}_state.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';

class $pascalScreenName extends StatefulWidget {
  final String? itemId; // null for create, has value for edit
  
  const $pascalScreenName({
    super.key,
    this.itemId,
  });

  @override
  State<$pascalScreenName> createState() => _${pascalScreenName}State();
}

class _${pascalScreenName}State extends State<$pascalScreenName> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool get isEditing => widget.itemId != null;
  
  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Load existing item data
      // You'll need to implement loading specific item logic
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ${config['hasAppBar'] != false ? '''appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Create Item'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('Save'),
          ),
        ],
      ),''' : ''}
      body: BlocListener<${pascalModuleName}Bloc, ${pascalModuleName}State>(
        listener: (context, state) {
          if (state is ${pascalModuleName}Error) {
            AppHelpers.showSnackBar(context, state.message, isError: true);
          } else if (state is ${pascalModuleName}Success) {
            AppHelpers.showSnackBar(context, state.message);
            Navigator.pop(context, true);
          }
        },
        child: BlocBuilder<${pascalModuleName}Bloc, ${pascalModuleName}State>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Edit Item' : 'Create New Item',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Title *',
                                prefixIcon: Icon(Icons.title),
                              ),
                              validator: (value) => Validators.validateRequired(value, 'Title'),
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                prefixIcon: Icon(Icons.description),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 4,
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state is ${pascalModuleName}Loading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is ${pascalModuleName}Loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Update Item' : 'Create Item'),
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _resetForm,
                        child: const Text('Reset Form'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
      };

      if (isEditing) {
        context.read<${pascalModuleName}Bloc>().add(
          ${pascalModuleName}UpdateItem(widget.itemId!, data),
        );
      } else {
        context.read<${pascalModuleName}Bloc>().add(
          ${pascalModuleName}CreateItem(data),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
  }
}
''';
}
