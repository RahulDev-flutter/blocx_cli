import 'dart:io';

import '../utils/cli_helpers.dart';
import 'add_package_command.dart';

class InitCommand {
  // Add these methods to your InitCommand class (after removing duplicates)

  Future<void> _generateApiConstants() async {
    final file = File('lib/core/constants/api_constants.dart');
    await file.writeAsString('''
class ApiConstants {
  static const String baseUrl = 'https://your-api-base-url.com';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Add your module endpoints here
  // Example:
  // static const String usersList = '/users';
  // static const String usersDetail = '/users/{id}';
}
''');
  }

  Future<void> _generateFailures() async {
    final file = File('lib/core/errors/failures.dart');
    await file.writeAsString('''
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
''');
  }

  Future<void> _generateExceptions() async {
    final file = File('lib/core/errors/exceptions.dart');
    await file.writeAsString('''
class ServerException implements Exception {
  final String message;
  
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
}
''');
  }

  Future<void> _generateEither() async {
    final file = File('lib/core/utils/either.dart');
    await file.writeAsString('''
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
''');
  }

  Future<void> _generateApiResponse() async {
    final file = File('lib/core/network/api_response.dart');
    await file.writeAsString('''
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final int statusCode;
  
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });
  
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'],
      statusCode: json['status_code'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'status_code': statusCode,
    };
  }
}
''');
  }

  Future<void> _generateDependencyInjection(Map<String, dynamic> config) async {
    final file = File('lib/core/di/dependency_injection.dart');
    await file.writeAsString('''
import 'package:get_it/get_it.dart';
import '../network/api_service.dart';
${config['includeAuthModule'] ? "import '../../modules/auth/repository/auth_repository.dart';" : ''}
${config['includeAuthModule'] ? "import '../../modules/auth/bloc/auth_bloc.dart';" : ''}

class DependencyInjection {
  static final GetIt getIt = GetIt.instance;
  
  static Future<void> init() async {
    // Core services
    getIt.registerSingleton<ApiService>(ApiService());
    
    ${config['includeAuthModule'] ? '''
    // Auth
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(getIt<ApiService>()),
    );
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(getIt<AuthRepository>()),
    );
    ''' : ''}
  }
}
''');
  }

  Future<void> _generateAppRouter(Map<String, dynamic> config) async {
    final file = File('lib/core/routing/app_router.dart');
    await file.writeAsString('''
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
${config['includeHomeModule'] ? "import '../../modules/home/screens/home_screen.dart';" : ''}
${config['includeAuthModule'] ? "import '../../modules/auth/screens/login_screen.dart';" : ''}

class AppRouter {
  GoRouter get router => _goRouter;
  
  final GoRouter _goRouter = GoRouter(
    initialLocation: '/',
    routes: [
      ${config['includeHomeModule'] ? '''
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      ''' : ''}
      ${config['includeAuthModule'] ? '''
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ''' : ''}
    ],
  );
}
''');
  }

  Future<void> _generateAuthRepository() async {
    final file = File('lib/modules/auth/repository/auth_repository.dart');
    await file.writeAsString('''
import '../../../core/network/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/either.dart';
import '../models/auth_model.dart';

class AuthRepository {
  final ApiService _apiService;
  
  AuthRepository(this._apiService);
  
  Future<Either<Failure, AuthModel>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      
      if (response.success) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final authModel = AuthModel.fromJson(data);
          return Right(authModel);
        } else {
          return Left(ServerFailure('Invalid response format'));
        }
      } else {
        return Left(ServerFailure(response.message ?? 'Login failed'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
}
''');
  }

  Future<void> _generateAuthModel() async {
    final file = File('lib/modules/auth/models/auth_model.dart');
    await file.writeAsString('''
import 'package:equatable/equatable.dart';

class AuthModel extends Equatable {
  final String token;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  
  const AuthModel({
    required this.token,
    this.refreshToken,
    this.user,
  });
  
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'] ?? '',
      refreshToken: json['refresh_token'],
      user: json['user'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user': user,
    };
  }
  
  @override
  List<Object?> get props => [token, refreshToken, user];
}
''');
  }

  Future<void> _generateAuthBloc() async {
    final file = File('lib/modules/auth/bloc/auth_bloc.dart');
    await file.writeAsString('''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/auth_repository.dart';
import '../models/auth_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({required this.email, required this.password});
  
  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthModel authModel;
  
  const AuthSuccess(this.authModel);
  
  @override
  List<Object> get props => [authModel];
}

class AuthFailure extends AuthState {
  final String message;
  
  const AuthFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await _authRepository.login(event.email, event.password);
    
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (authModel) => emit(AuthSuccess(authModel)),
    );
  }
  
  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }
}
''');
  }

  Future<void> _generateLoginScreen() async {
    final file = File('lib/modules/auth/screens/login_screen.dart');
    await file.writeAsString('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful!')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                                  LoginRequested(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                          },
                    child: state is AuthLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''');
  }

  Future<void> execute() async {
    try {
      // Check if we're in a Flutter project
      if (!await _isFlutterProject()) {
        CliHelpers.printError('❌ This is not a Flutter project directory.');
        CliHelpers.printInfo(
            'Please run this command from the root of a Flutter project.');
        return;
      }

      print('🔍 Detected Flutter project');

      // Check if RJ BlocX architecture already exists
      if (await _hasExistingArchitecture()) {
        print('⚠️  RJ BlocX architecture already exists.');
        stdout.write('Do you want to overwrite? (y/N): ');
        final input = stdin.readLineSync()?.toLowerCase().trim() ?? 'n';
        if (input != 'y' && input != 'yes') {
          print('✅ Initialization cancelled.');
          return;
        }
      }

      print('🏗️  Setting up RJ BlocX architecture...');

      // Get configuration
      final config = await _getInitConfiguration();

      // Add required packages
      await _addRequiredPackages(config);

      // Generate core structure
      await _generateCoreStructure(config);

      // Generate modules if requested
      if (config['includeAuthModule']) {
        await _generateAuthModule();
      }

      if (config['includeHomeModule']) {
        await _generateHomeModule();
      }

      // Update main.dart
      await _updateMainDart(config);

      // Update pubspec.yaml assets
      await _updatePubspecAssets();

      print('');
      CliHelpers.printSuccess(
          '🎉 RJ BlocX architecture initialized successfully!');
      print('');
      print('📋 Next steps:');
      print('   1. Run "flutter pub get" to install dependencies');
      print(
          '   2. Update your API base URL in lib/core/constants/api_constants.dart');
      print('   3. Customize authentication endpoints if needed');
      print(
          '   4. Start generating modules with "rj_blocx generate module <name>"');
      print('');
    } catch (e) {
      CliHelpers.printError('❌ Failed to initialize: $e');
      rethrow;
    }
  }

  Future<bool> _isFlutterProject() async {
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) return false;

    final content = await pubspecFile.readAsString();
    return content.contains('flutter:') && content.contains('sdk: flutter');
  }

  Future<bool> _hasExistingArchitecture() async {
    final coreDir = Directory('lib/core');
    final modulesDir = Directory('lib/modules');
    return await coreDir.exists() || await modulesDir.exists();
  }

  Future<Map<String, dynamic>> _getInitConfiguration() async {
    print('');
    print('🛠️  Configure your project:');

    try {
      // API Client selection
      print('Select API client:');
      print('  1. HTTP (dart:io)');
      print('  2. Dio');
      stdout.write('Choice (1): ');
      final apiChoice = stdin.readLineSync()?.trim() ?? '1';
      final apiClient = apiChoice == '2' ? 'Dio' : 'HTTP (dart:io)';

      // Include Auth module
      stdout.write('Include Auth module? (Y/n): ');
      final authInput = stdin.readLineSync()?.toLowerCase().trim() ?? 'y';
      final includeAuth = authInput != 'n' && authInput != 'no';

      // Include Home module
      stdout.write('Include Home module? (Y/n): ');
      final homeInput = stdin.readLineSync()?.toLowerCase().trim() ?? 'y';
      final includeHome = homeInput != 'n' && homeInput != 'no';

      // Include routing
      stdout.write('Setup routing (go_router)? (Y/n): ');
      final routingInput = stdin.readLineSync()?.toLowerCase().trim() ?? 'y';
      final includeRouting = routingInput != 'n' && routingInput != 'no';

      return {
        'apiClient': apiClient,
        'includeAuthModule': includeAuth,
        'includeHomeModule': includeHome,
        'includeRouting': includeRouting,
      };
    } catch (e) {
      // If interactive input fails, use default configuration
      print('Using default configuration (non-interactive mode)');
      return {
        'apiClient': 'HTTP (dart:io)',
        'includeAuthModule': true,
        'includeHomeModule': true,
        'includeRouting': true,
      };
    }
  }

  Future<void> _addRequiredPackages(Map<String, dynamic> config) async {
    print('📦 Adding required packages...');

    final addPackageCommand = AddPackageCommand();

    // Core packages
    final corePackages = [
      'flutter_bloc',
      'equatable',
      'flutter_secure_storage',
      'shared_preferences',
      'get_it',
    ];

    // API client packages
    if (config['apiClient'] == 'Dio') {
      corePackages.add('dio');
    }

    // Routing packages
    if (config['includeRouting']) {
      corePackages.add('go_router');
    }

    for (final package in corePackages) {
      try {
        await addPackageCommand.addSinglePackage(package);
      } catch (e) {
        CliHelpers.printWarning('⚠️  Could not add package $package: $e');
      }
    }
  }

  Future<void> _generateCoreStructure(Map<String, dynamic> config) async {
    print('🏗️  Generating core structure...');

    // Create directory structure
    final directories = [
      'lib/core/constants',
      'lib/core/errors',
      'lib/core/network',
      'lib/core/utils',
      'lib/core/di',
      'lib/modules',
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }

    // Generate core files
    await _generateApiConstants();
    await _generateFailures();
    await _generateExceptions();
    await _generateEither();
    await _generateApiResponse();
    await _generateApiService(config);
    await _generateDependencyInjection(config);

    if (config['includeRouting']) {
      await Directory('lib/core/routing').create(recursive: true);
      await _generateAppRouter(config);
    }
  }

  Future<void> _generateApiService(Map<String, dynamic> config) async {
    final isDio = config['apiClient'] == 'Dio';

    final file = File('lib/core/network/api_service.dart');
    await file
        .writeAsString(isDio ? _getDioApiService() : _getHttpApiService());
  }

  String _getHttpApiService() {
    return '''
import 'dart:convert';
import 'dart:io';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_response.dart';

class ApiService {
  final HttpClient _client = HttpClient();
  
  Future<ApiResponse> get(String endpoint) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final request = await _client.getUrl(uri);
      final response = await request.close();
      
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody);
      
      return ApiResponse(
        success: response.statusCode == 200,
        data: data,
        message: data['message'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw ServerException('Network error: \$e');
    }
  }
  
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final request = await _client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      
      if (data != null) {
        request.write(json.encode(data));
      }
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final responseData = json.decode(responseBody);
      
      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        data: responseData,
        message: responseData['message'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw ServerException('Network error: \$e');
    }
  }
  
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final request = await _client.openUrl('PUT', uri);
      request.headers.contentType = ContentType.json;
      
      if (data != null) {
        request.write(json.encode(data));
      }
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final responseData = json.decode(responseBody);
      
      return ApiResponse(
        success: response.statusCode == 200,
        data: responseData,
        message: responseData['message'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw ServerException('Network error: \$e');
    }
  }
  
  Future<ApiResponse> delete(String endpoint) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final request = await _client.deleteUrl(uri);
      final response = await request.close();
      
      final responseBody = await response.transform(utf8.decoder).join();
      final data = responseBody.isNotEmpty ? json.decode(responseBody) : null;
      
      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 204,
        data: data,
        message: data?['message'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      throw ServerException('Network error: \$e');
    }
  }
}
''';
  }

  String _getDioApiService() {
    return '''
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_response.dart';

class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }
  
  Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return ApiResponse(
        success: response.statusCode == 200,
        data: response.data,
        message: response.data?['message'],
        statusCode: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      throw ServerException('Network error: \${e.message}');
    }
  }
  
  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 201,
        data: response.data,
        message: response.data?['message'],
        statusCode: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      throw ServerException('Network error: \${e.message}');
    }
  }
  
  Future<ApiResponse> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return ApiResponse(
        success: response.statusCode == 200,
        data: response.data,
        message: response.data?['message'],
        statusCode: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      throw ServerException('Network error: \${e.message}');
    }
  }
  
  Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return ApiResponse(
        success: response.statusCode == 200 || response.statusCode == 204,
        data: response.data,
        message: response.data?['message'],
        statusCode: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      throw ServerException('Network error: \${e.message}');
    }
  }
}
''';
  }

  Future<void> _generateAuthModule() async {
    print('🔐 Generating Auth module...');

    // Create auth module directories
    final authDirs = [
      'lib/modules/auth/bloc',
      'lib/modules/auth/models',
      'lib/modules/auth/repository',
      'lib/modules/auth/screens',
    ];

    for (final dir in authDirs) {
      await Directory(dir).create(recursive: true);
    }

    // Generate basic auth files (you can expand these)
    await _generateAuthRepository();
    await _generateAuthModel();
    await _generateAuthBloc();
    await _generateLoginScreen();
  }

  Future<void> _generateHomeModule() async {
    print('🏠 Generating Home module...');

    // Create home module directories
    await Directory('lib/modules/home/screens').create(recursive: true);

    // Generate basic home screen
    final file = File('lib/modules/home/screens/home_screen.dart');
    await file.writeAsString('''
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to RJ BlocX!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your Flutter app with Bloc architecture is ready.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
''');
  }

  Future<void> _updateMainDart(Map<String, dynamic> config) async {
    print('📝 Updating main.dart...');

    final mainFile = File('lib/main.dart');

    final mainContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
${config['includeRouting'] ? "import 'core/routing/app_router.dart';" : "import 'modules/home/screens/home_screen.dart';"}
import 'core/di/dependency_injection.dart';
${config['includeAuthModule'] ? "import 'modules/auth/bloc/auth_bloc.dart';" : ''}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await DependencyInjection.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ${config['includeRouting'] ? '''
  final _appRouter = AppRouter();
  ''' : ''}

  @override
  Widget build(BuildContext context) {
    return ${config['includeAuthModule'] ? '''
    BlocProvider(
      create: (context) => DependencyInjection.getIt<AuthBloc>(),
      child: MaterialApp${config['includeRouting'] ? '.router' : ''}(
        title: 'RJ BlocX App',
        debugShowCheckedModeBanner: false,
        ${config['includeRouting'] ? 'routerConfig: _appRouter.router,' : 'home: const HomeScreen(),'}
      ),
    );''' : '''
    MaterialApp${config['includeRouting'] ? '.router' : ''}(
      title: 'RJ BlocX App',
      debugShowCheckedModeBanner: false,
      ${config['includeRouting'] ? 'routerConfig: _appRouter.router,' : 'home: const HomeScreen(),'}
    );'''}
  }
}
''';

    await mainFile.writeAsString(mainContent);
  }

  Future<void> _updatePubspecAssets() async {
    print('📦 Updating pubspec.yaml assets...');

    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) return;

    final content = await pubspecFile.readAsString();

    // Check if assets section already exists
    if (!content.contains('assets:')) {
      final lines = content.split('\n');
      final flutterIndex =
          lines.indexWhere((line) => line.trim() == 'flutter:');

      if (flutterIndex != -1) {
        // Find the end of the flutter section
        int insertIndex = lines.length;

        // Insert assets at the end of the flutter section, before any empty lines
        while (insertIndex > flutterIndex + 1 &&
            lines[insertIndex - 1].trim().isEmpty) {
          insertIndex--;
        }

        // Insert assets section at end of file (it will be properly indented under flutter)
        lines.insert(insertIndex, '  assets:');
        lines.insert(insertIndex + 1, '    - assets/images/');
        lines.insert(insertIndex + 2, '    - assets/icons/');

        await pubspecFile.writeAsString(lines.join('\n'));

        // Create assets directories
        await Directory('assets/images').create(recursive: true);
        await Directory('assets/icons').create(recursive: true);
      }
    }
  }
}
