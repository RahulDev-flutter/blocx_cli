import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rj_blocx/src/templates/conditional_module_template.dart';

import '../utils/cli_helpers.dart';

class DynamicScreenGenerator {
  Future<void> generate(
    String projectPath,
    String moduleName,
    String screenName,
    Map<String, dynamic> config,
  ) async {
    final screensDir = Directory(p.join(
      projectPath,
      'lib',
      'modules',
      CliHelpers.toSnakeCase(moduleName),
      'screens',
    ));

    // Ensure screens directory exists
    await screensDir.create(recursive: true);

    // Determine if module has repository and models
    final moduleConfig = await _getModuleConfiguration(projectPath, moduleName);

    // Generate screen file
    final screenFile = File(p.join(
      screensDir.path,
      '${CliHelpers.toSnakeCase(screenName)}_screen.dart',
    ));

    await screenFile.writeAsString(_generateScreenTemplate(
      screenName,
      moduleName,
      config,
      moduleConfig,
    ));
  }

  /// Checks existing module configuration by examining generated files
  Future<Map<String, dynamic>> _getModuleConfiguration(
    String projectPath,
    String moduleName,
  ) async {
    final moduleDir = Directory(p.join(
      projectPath,
      'lib',
      'modules',
      CliHelpers.toSnakeCase(moduleName),
    ));

    final hasRepository =
        Directory(p.join(moduleDir.path, 'repository')).existsSync();
    final hasModels = Directory(p.join(moduleDir.path, 'models')).existsSync();
    final hasBloc = Directory(p.join(moduleDir.path, 'bloc')).existsSync();

    return {
      'repository': hasRepository,
      'models': hasModels,
      'bloc': hasBloc,
    };
  }

  String _generateScreenTemplate(
    String screenName,
    String moduleName,
    Map<String, dynamic> screenConfig,
    Map<String, dynamic> moduleConfig,
  ) {
    final hasRepository = moduleConfig['repository'] == true;
    final hasModels = moduleConfig['models'] == true;
    final hasBloc = moduleConfig['bloc'] == true;

    final screenType = screenConfig['type'] as String;
    final hasAppBar = screenConfig['hasAppBar'] == true;
    final hasFab = screenConfig['hasFab'] == true;
    final hasBottomNav = screenConfig['hasBottomNav'] == true;

    // Generate imports based on module configuration
    final blocImport = (hasRepository && hasBloc)
        ? """import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${CliHelpers.toSnakeCase(moduleName)}_bloc.dart';
import '../bloc/${CliHelpers.toSnakeCase(moduleName)}_event.dart';
import '../bloc/${CliHelpers.toSnakeCase(moduleName)}_state.dart';"""
        : '';

    final modelImport = hasModels
        ? "import '../models/${CliHelpers.toSnakeCase(moduleName)}_model.dart';"
        : '';

    // Generate screen content
    final screenContent = _generateScreenContent(
      screenName,
      moduleName,
      screenType,
      hasRepository && hasBloc,
      hasModels,
    );

    // Generate FAB if needed
    final fabWidget = hasFab
        ? """
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement FAB action
          ${_getFabAction(screenType)}
        },
        child: const Icon(${_getFabIcon(screenType)}),
      ),"""
        : '';

    // Generate bottom navigation if needed
    final bottomNavWidget = hasBottomNav
        ? """
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          // TODO: Handle bottom navigation
        },
      ),"""
        : '';

    // Generate AppBar if needed
    final appBarWidget = hasAppBar
        ? """
      appBar: AppBar(
        title: Text('${CliHelpers2.toTitleCase(screenName)}'),
        ${_getAppBarActions(screenType)}
      ),"""
        : '';

    // Generate complete screen
    final needsBlocProvider = hasRepository && hasBloc;

    return """
import 'package:flutter/material.dart';
$blocImport
$modelImport

class ${CliHelpers.toPascalCase(screenName)}Screen extends StatelessWidget {
  const ${CliHelpers.toPascalCase(screenName)}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return ${needsBlocProvider ? """BlocProvider(
      create: (context) => ${CliHelpers.toPascalCase(moduleName)}Bloc()..add(Load${CliHelpers.toPascalCase(moduleName)}List()),
      child: """ : ""}Scaffold($appBarWidget
      body: $screenContent,$fabWidget$bottomNavWidget
    )${needsBlocProvider ? ')' : ''};
  }
}
""";
  }

  String _generateScreenContent(
    String screenName,
    String moduleName,
    String screenType,
    bool hasBloc,
    bool hasModels,
  ) {
    if (!hasBloc) {
      return _getStaticContent(screenType, screenName);
    }

    switch (screenType) {
      case 'list':
        return _generateListContent(moduleName, hasModels);
      case 'detail':
        return _generateDetailContent(moduleName, hasModels);
      case 'form':
        return _generateFormContent(moduleName, hasModels, hasBloc);
      default: // basic
        return _generateBasicContent(screenName);
    }
  }

  String _generateListContent(String moduleName, bool hasModels) {
    return """BlocBuilder<${CliHelpers.toPascalCase(moduleName)}Bloc, ${CliHelpers.toPascalCase(moduleName)}State>(
        builder: (context, state) {
          if (state is ${CliHelpers.toPascalCase(moduleName)}Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ${CliHelpers.toPascalCase(moduleName)}Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: \${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<${CliHelpers.toPascalCase(moduleName)}Bloc>()
                          .add(Refresh${CliHelpers.toPascalCase(moduleName)}List());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is ${CliHelpers.toPascalCase(moduleName)}Loaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pull down to refresh',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<${CliHelpers.toPascalCase(moduleName)}Bloc>()
                    .add(Refresh${CliHelpers.toPascalCase(moduleName)}List());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('\${index + 1}'),
                      ),
                      title: Text(
                        ${hasModels ? 'item.title ?? \'No Title\'' : 'item[\'title\']?.toString() ?? \'No Title\''},
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        ${hasModels ? 'item.description ?? \'No Description\'' : 'item[\'description\']?.toString() ?? \'No Description\''},
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to detail screen
                        // Navigator.pushNamed(context, AppConstants.${CliHelpers.toCamelCase(moduleName)}DetailRoute, arguments: item);
                      },
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      )""";
  }

  String _generateDetailContent(String moduleName, bool hasModels) {
    return """BlocBuilder<${CliHelpers.toPascalCase(moduleName)}Bloc, ${CliHelpers.toPascalCase(moduleName)}State>(
        builder: (context, state) {
          if (state is ${CliHelpers.toPascalCase(moduleName)}Loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ${CliHelpers.toPascalCase(moduleName)}Error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: \${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          } else if (state is ${CliHelpers.toPascalCase(moduleName)}ItemSelected) {
            final item = state.item;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ${hasModels ? 'item.title ?? \'No Title\'' : 'item[\'title\']?.toString() ?? \'No Title\''},
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ${hasModels ? 'item.description ?? \'No Description\'' : 'item[\'description\']?.toString() ?? \'No Description\''},
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          ${hasModels ? '''
                          const SizedBox(height: 16),
                          if (item.createdAt != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Created: \${item.createdAt!.toLocal().toString().split(' ')[0]}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (item.updatedAt != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.update, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Updated: \${item.updatedAt!.toLocal().toString().split(' ')[0]}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],''' : ''}
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TODO: Add more detail sections
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit'),
                      subtitle: const Text('Modify this item'),
                      onTap: () {
                        // TODO: Navigate to edit screen
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Delete'),
                      subtitle: const Text('Remove this item'),
                      onTap: () {
                        // TODO: Show delete confirmation
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64),
                SizedBox(height: 16),
                Text('Select an item to view details'),
              ],
            ),
          );
        },
      )""";
  }

  String _generateFormContent(String moduleName, bool hasModels, bool hasBloc) {
    return """Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New ${CliHelpers2.toTitleCase(moduleName)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter title',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter description',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement form submission
                                ${hasBloc ? '''
                                // context.read<${CliHelpers.toPascalCase(moduleName)}Bloc>()
                                //     .add(Create${CliHelpers.toPascalCase(moduleName)}Event(data));''' : ''}
                              },
                              child: const Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )""";
  }

  String _generateBasicContent(String screenName) {
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
            SizedBox(height: 16),
            Text(
              'This is a basic screen template. You can customize it by adding your own widgets and logic.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      )""";
  }

  String _getStaticContent(String screenType, String screenName) {
    switch (screenType) {
      case 'list':
        return """ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 10, // Sample data
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('\${index + 1}'),
              ),
              title: Text('Sample Item \${index + 1}'),
              subtitle: Text('This is a sample description for item \${index + 1}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to detail screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped on item \${index + 1}')),
                );
              },
            ),
          );
        },
      )""";

      case 'detail':
        return """const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Detail',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('This is a sample detail screen. Add your content here.'),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16),
                        SizedBox(width: 8),
                        Text('Created: Today'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                subtitle: Text('Modify this item'),
                onTap: () {
                  // TODO: Navigate to edit screen
                },
              ),
            ),
          ],
        ),
      )""";

      case 'form':
        return """Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter title',
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter description',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement form submission
                              },
                              child: const Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  String _getFabAction(String screenType) {
    switch (screenType) {
      case 'list':
        return '// Navigate to create screen';
      case 'form':
        return '// Submit form or add new field';
      default:
        return '// Add your FAB action here';
    }
  }

  String _getFabIcon(String screenType) {
    switch (screenType) {
      case 'list':
        return 'Icons.add';
      case 'form':
        return 'Icons.save';
      case 'detail':
        return 'Icons.edit';
      default:
        return 'Icons.add';
    }
  }

  String _getAppBarActions(String screenType) {
    switch (screenType) {
      case 'list':
        return """actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],""";
      case 'detail':
        return """actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
        ],""";
      case 'form':
        return """actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // TODO: Save form
            },
          ),
        ],""";
      default:
        return '';
    }
  }
}
