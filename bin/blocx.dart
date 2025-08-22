#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:prompts/prompts.dart' as prompts;
import 'dart:convert';

void main(List<String> arguments) async {
  final parser = ArgParser()..addCommand('create');
  final argResults = parser.parse(arguments);

  if (argResults.command?.name == 'create') {
    final projectName = argResults.command?.rest.first;

    if (projectName == null) {
      print('❌ Please provide a project name.');
      print('Usage: blocx create <project_name>');
      exit(1);
    }

    // Validate project name
    if (!_isValidProjectName(projectName)) {
      print('❌ Invalid project name. Use lowercase letters, numbers, and underscores only.');
      exit(1);
    }

    await createOrUpdateProject(projectName);
  } else {
    print('🚀 BlocX CLI - Flutter Project Generator with Bloc Architecture');
    print('Usage: blocx create <project_name>');
    print('');
    print('Features:');
    print('• Interactive API client selection (HTTP/Dio)');
    print('• Auto-generated Auth & Home modules');
    print('• Complete Bloc state management setup');
    print('• Network layer with error handling');
    print('• Repository pattern implementation');
  }
}

bool _isValidProjectName(String name) {
  final regex = RegExp(r'^[a-z][a-z0-9_]*$');
  return regex.hasMatch(name) && name.length >= 2;
}

Future<void> createOrUpdateProject(String name) async {
  try {
    final projectDir = Directory(name);

    // Check if Flutter is installed
    await _checkFlutterInstallation();

    if (!projectDir.existsSync()) {
      print('🚀 Creating new Flutter project "$name"...');
      final result = await Process.run('flutter', ['create', name]);

      if (result.exitCode != 0) {
        print('❌ Flutter project creation failed:');
        print(result.stderr);
        exit(1);
      }
      print('✅ Flutter project "$name" created successfully.');
    } else {
      final shouldContinue = prompts.confirm('📁 Project "$name" already exists. Continue to enhance it?');
      if (!shouldContinue) {
        print('Operation cancelled.');
        exit(0);
      }
    }

    print('\n🛠️  Setting up project architecture...');

    // Step 1: Ask which API client
    final String apiChoice = prompts.choose(
      '👉 Which API package do you want to use?',
      ['http', 'dio'],
      defaultsTo: 'dio',
    );

    // Step 2: Update pubspec.yaml with dependencies
    await _updatePubspecDependencies(projectDir.path, apiChoice);

    // Step 3: Create core structure
    await _createCoreStructure(projectDir.path, apiChoice);

    // Step 4: Create modules with repositories
    await _createAuthModule(projectDir.path);
    await _createHomeModule(projectDir.path);

    // Step 5: Update main.dart
    await _updateMainDart(projectDir.path);

    // Step 6: Create app-level bloc setup
    await _createAppSetup(projectDir.path);

    print('\n🎉 Project "$name" is ready!');
    print('\nNext steps:');
    print('1. cd $name');
    print('2. flutter pub get');
    print('3. flutter run');
    print('\n📁 Generated structure:');
    print('├── lib/');
    print('│   ├── core/');
    print('│   │   ├── network/');
    print('│   │   ├── constants/');
    print('│   │   └── utils/');
    print('│   ├── modules/');
    print('│   │   ├── auth/');
    print('│   │   └── home/');
    print('│   └── app/');
    print('└── API: $apiChoice with complete error handling');

  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

Future<void> _checkFlutterInstallation() async {
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

Future<void> _updatePubspecDependencies(String projectPath, String apiChoice) async {
  final pubspecFile = File(p.join(projectPath, 'pubspec.yaml'));

  if (!pubspecFile.existsSync()) {
    throw Exception('pubspec.yaml not found');
  }

  final content = await pubspecFile.readAsString();
  final lines = content.split('\n');

  // Find dependencies section
  int dependenciesIndex = lines.indexWhere((line) => line.trim() == 'dependencies:');
  if (dependenciesIndex == -1) {
    throw Exception('Could not find dependencies section in pubspec.yaml');
  }

  // Add required dependencies
  final dependenciesToAdd = [
    '  flutter_bloc: ^8.1.3',
    '  equatable: ^2.0.5',
    '  get_it: ^7.6.4',
    if (apiChoice == 'dio') '  dio: ^5.3.2',
    if (apiChoice == 'http') '  http: ^1.1.0',
    '  shared_preferences: ^2.2.2',
  ];

  // Insert after dependencies:
  lines.insertAll(dependenciesIndex + 2, dependenciesToAdd);

  await pubspecFile.writeAsString(lines.join('\n'));
  print('✅ Updated pubspec.yaml with required dependencies');
}

Future<void> _createCoreStructure(String projectPath, String apiChoice) async {
  // Create core directories
  final coreBase = p.join(projectPath, 'lib', 'core');
  final dirs = [
    Directory(p.join(coreBase, 'network')),
    Directory(p.join(coreBase, 'constants')),
    Directory(p.join(coreBase, 'utils')),
    Directory(p.join(coreBase, 'errors')),
  ];

  for (final dir in dirs) {
    await dir.create(recursive: true);
  }

  // Create network layer
  await _createNetworkLayer(coreBase, apiChoice);

  // Create constants
  await _createConstants(coreBase);

  // Create utilities
  await _createUtils(coreBase);

  // Create error handling
  await _createErrorHandling(coreBase);

  print('✅ Core structure created with $apiChoice network layer');
}

Future<void> _createNetworkLayer(String coreBase, String apiChoice) async {
  final networkPath = p.join(coreBase, 'network');

  if (apiChoice == 'dio') {
    // Dio implementation
    final dioClient = File(p.join(networkPath, 'dio_client.dart'));
    await dioClient.writeAsString(dioClientTemplate);

    final apiService = File(p.join(networkPath, 'api_service.dart'));
    await apiService.writeAsString(dioApiServiceTemplate);
  } else {
    // HTTP implementation
    final httpClient = File(p.join(networkPath, 'http_client.dart'));
    await httpClient.writeAsString(httpClientTemplate);

    final apiService = File(p.join(networkPath, 'api_service.dart'));
    await apiService.writeAsString(httpApiServiceTemplate);
  }

  // Create network response model
  final responseModel = File(p.join(networkPath, 'api_response.dart'));
  await responseModel.writeAsString(apiResponseTemplate);
}

Future<void> _createConstants(String coreBase) async {
  final constantsPath = p.join(coreBase, 'constants');

  final apiConstants = File(p.join(constantsPath, 'api_constants.dart'));
  await apiConstants.writeAsString(apiConstantsTemplate);

  final appConstants = File(p.join(constantsPath, 'app_constants.dart'));
  await appConstants.writeAsString(appConstantsTemplate);
}

Future<void> _createUtils(String coreBase) async {
  final utilsPath = p.join(coreBase, 'utils');

  final validators = File(p.join(utilsPath, 'validators.dart'));
  await validators.writeAsString(validatorsTemplate);

  final helpers = File(p.join(utilsPath, 'helpers.dart'));
  await helpers.writeAsString(helpersTemplate);
}

Future<void> _createErrorHandling(String coreBase) async {
  final errorsPath = p.join(coreBase, 'errors');

  final failures = File(p.join(errorsPath, 'failures.dart'));
  await failures.writeAsString(failuresTemplate);

  final exceptions = File(p.join(errorsPath, 'exceptions.dart'));
  await exceptions.writeAsString(exceptionsTemplate);
}

Future<void> _createAuthModule(String projectPath) async {
  final moduleBase = p.join(projectPath, 'lib', 'modules', 'auth');
  await _createModuleStructure(moduleBase, 'auth');

  // Create Auth-specific files
  final authScreens = [
    {'name': 'login_screen', 'title': 'Login'},
    {'name': 'register_screen', 'title': 'Register'},
  ];

  for (final screen in authScreens) {
    final screenFile = File(p.join(moduleBase, 'screens', '${screen['name']}.dart'));
    await screenFile.writeAsString(authScreenTemplate(screen['name']!, screen['title']!));
  }

  // Create auth repository
  final authRepo = File(p.join(moduleBase, 'repository', 'auth_repository.dart'));
  await authRepo.writeAsString(authRepositoryTemplate);

  // Create auth models
  final modelsDir = Directory(p.join(moduleBase, 'models'));
  await modelsDir.create(recursive: true);

  final userModel = File(p.join(moduleBase, 'models', 'user_model.dart'));
  await userModel.writeAsString(userModelTemplate);

  final authRequest = File(p.join(moduleBase, 'models', 'auth_request.dart'));
  await authRequest.writeAsString(authRequestTemplate);

  print('✅ Auth module created with login/register screens and user management');
}

Future<void> _createHomeModule(String projectPath) async {
  final moduleBase = p.join(projectPath, 'lib', 'modules', 'home');
  await _createModuleStructure(moduleBase, 'home');

  // Create Home-specific files
  final homeScreens = [
    {'name': 'home_screen', 'title': 'Home'},
    {'name': 'profile_screen', 'title': 'Profile'},
  ];

  for (final screen in homeScreens) {
    final screenFile = File(p.join(moduleBase, 'screens', '${screen['name']}.dart'));
    await screenFile.writeAsString(homeScreenTemplate(screen['name']!, screen['title']!));
  }

  // Create home repository
  final homeRepo = File(p.join(moduleBase, 'repository', 'home_repository.dart'));
  await homeRepo.writeAsString(homeRepositoryTemplate);

  print('✅ Home module created with home/profile screens');
}

Future<void> _createModuleStructure(String moduleBase, String moduleName) async {
  final dirs = [
    Directory(p.join(moduleBase, 'bloc')),
    Directory(p.join(moduleBase, 'screens')),
    Directory(p.join(moduleBase, 'repository')),
    Directory(p.join(moduleBase, 'models')),
  ];

  for (final dir in dirs) {
    await dir.create(recursive: true);
  }

  // Create Bloc files
  final blocBase = p.join(moduleBase, 'bloc');

  final eventFile = File(p.join(blocBase, '${moduleName}_event.dart'));
  await eventFile.writeAsString(eventTemplate(moduleName));

  final stateFile = File(p.join(blocBase, '${moduleName}_state.dart'));
  await stateFile.writeAsString(stateTemplate(moduleName));

  final blocFile = File(p.join(blocBase, '${moduleName}_bloc.dart'));
  await blocFile.writeAsString(blocTemplate(moduleName));
}

Future<void> _createAppSetup(String projectPath) async {
  final appDir = Directory(p.join(projectPath, 'lib', 'app'));
  await appDir.create(recursive: true);

  // Create service locator
  final serviceLocator = File(p.join(appDir.path, 'service_locator.dart'));
  await serviceLocator.writeAsString(serviceLocatorTemplate);

  // Create app router
  final appRouter = File(p.join(appDir.path, 'app_router.dart'));
  await appRouter.writeAsString(appRouterTemplate);

  // Create app bloc observer
  final blocObserver = File(p.join(appDir.path, 'bloc_observer.dart'));
  await blocObserver.writeAsString(blocObserverTemplate);

  print('✅ App setup created with service locator and routing');
}

Future<void> _updateMainDart(String projectPath) async {
  final mainFile = File(p.join(projectPath, 'lib', 'main.dart'));
  await mainFile.writeAsString(mainDartTemplate);
  print('✅ main.dart updated with Bloc setup and routing');
}

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

// ===================== TEMPLATES =====================

const dioClientTemplate = """
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio _dio;
  
  DioClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'https://api.example.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print(object),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        // final token = getAuthToken();
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer \$token';
        // }
        handler.next(options);
      },
      onError: (error, handler) {
        _handleDioError(error);
        handler.next(error);
      },
    ));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ServerException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Something went wrong';
        
        switch (statusCode) {
          case 400:
            return ServerException('Bad request: \$message');
          case 401:
            return ServerException('Unauthorized access');
          case 403:
            return ServerException('Access forbidden');
          case 404:
            return ServerException('Resource not found');
          case 500:
            return ServerException('Internal server error');
          default:
            return ServerException('Server error (\$statusCode): \$message');
        }
      
      case DioExceptionType.cancel:
        return ServerException('Request cancelled');
      
      case DioExceptionType.connectionError:
        return ServerException('No internet connection');
      
      default:
        return ServerException('Unexpected error occurred');
    }
  }
}
""";

const httpClientTemplate = """
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';

class HttpClient {
  final String baseUrl;
  final Duration timeout;
  
  HttpClient({
    this.baseUrl = 'https://api.example.com',
    this.timeout = const Duration(seconds: 30),
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add auth token if available
    // 'Authorization': 'Bearer \$token',
  };

  Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('\$baseUrl\$endpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('HTTP error occurred');
    } catch (e) {
      throw ServerException('Unexpected error: \$e');
    }
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse('\$baseUrl\$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: data != null ? jsonEncode(data) : null,
      ).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('HTTP error occurred');
    } catch (e) {
      throw ServerException('Unexpected error: \$e');
    }
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse('\$baseUrl\$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: data != null ? jsonEncode(data) : null,
      ).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('HTTP error occurred');
    } catch (e) {
      throw ServerException('Unexpected error: \$e');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final uri = Uri.parse('\$baseUrl\$endpoint');
      final response = await http.delete(uri, headers: _headers).timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ServerException('No internet connection');
    } on HttpException {
      throw ServerException('HTTP error occurred');
    } catch (e) {
      throw ServerException('Unexpected error: \$e');
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    
    String message = 'Something went wrong';
    try {
      final responseData = jsonDecode(response.body);
      message = responseData['message'] ?? message;
    } catch (e) {
      // Use default message if JSON parsing fails
    }
    
    switch (response.statusCode) {
      case 400:
        throw ServerException('Bad request: \$message');
      case 401:
        throw ServerException('Unauthorized access');
      case 403:
        throw ServerException('Access forbidden');
      case 404:
        throw ServerException('Resource not found');
      case 500:
        throw ServerException('Internal server error');
      default:
        throw ServerException('Server error (\${response.statusCode}): \$message');
    }
  }
}
""";

const dioApiServiceTemplate = """
import 'api_response.dart';
import 'dio_client.dart';

class ApiService {
  final DioClient _dioClient;
  
  ApiService(this._dioClient);
  
  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dioClient.get(endpoint, queryParameters: queryParams);
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }
  
  Future<ApiResponse<T>> post<T>(String endpoint, {dynamic data}) async {
    try {
      final response = await _dioClient.post(endpoint, data: data);
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }
  
  Future<ApiResponse<T>> put<T>(String endpoint, {dynamic data}) async {
    try {
      final response = await _dioClient.put(endpoint, data: data);
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }
  
  Future<ApiResponse<T>> delete<T>(String endpoint) async {
    try {
      final response = await _dioClient.delete(endpoint);
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }
}
""";

const httpApiServiceTemplate = """
import 'dart:convert';
import 'api_response.dart';
import 'http_client.dart';

class ApiService {
  final HttpClient _httpClient;
  
  ApiService(this._httpClient);
  
  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final response = await _httpClient.get(endpoint, queryParams: queryParams);
      return ApiResponse<T>.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }
  
  Future<ApiResponse<T>> post<T>(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _httpClient.post(endpoint, data: data);
      return ApiResponse<T>.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }
  
  Future<ApiResponse<T>> put<T>(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await _httpClient.put(endpoint, data: data);
      return ApiResponse<T>.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }
  
  Future<ApiResponse<T>> delete<T>(String endpoint) async {
    try {
      final response = await _httpClient.delete(endpoint);
      return ApiResponse<T>.fromHttpResponse(response);
    } catch (e) {
      return ApiResponse<T>.error(e.toString());
    }
  }
}
""";

const apiResponseTemplate = """
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse<T>(
      message: message,
      success: false,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromResponse(Response response) {
    final isSuccess = response.statusCode != null && 
                     response.statusCode! >= 200 && 
                     response.statusCode! < 300;
    
    if (isSuccess) {
      return ApiResponse<T>.success(
        response.data,
        message: 'Success',
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse<T>.error(
        response.data?['message'] ?? 'Something went wrong',
        statusCode: response.statusCode,
      );
    }
  }

  factory ApiResponse.fromHttpResponse(http.Response response) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    
    if (isSuccess) {
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        data = response.body;
      }
      
      return ApiResponse<T>.success(
        data,
        message: 'Success',
        statusCode: response.statusCode,
      );
    } else {
      String message = 'Something went wrong';
      try {
        final responseData = jsonDecode(response.body);
        message = responseData['message'] ?? message;
      } catch (e) {
        // Use default message
      }
      
      return ApiResponse<T>.error(
        message,
        statusCode: response.statusCode,
      );
    }
  }
}
""";

const apiConstantsTemplate = """
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  
  // Other endpoints
  static const String dashboard = '/dashboard';
}
""";

const appConstantsTemplate = """
class AppConstants {
  static const String appName = 'BlocX App';
  static const String appVersion = '1.0.0';
  
  // SharedPreferences keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  
  // Route names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
}
""";

const validatorsTemplate = """
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '\$fieldName is required';
    }
    return null;
  }
  
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
}
""";

const helpersTemplate = """
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SharedPrefsHelper {
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }
  
  static String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }
  
  static bool getBool(String key) {
    return _prefs?.getBool(key) ?? false;
  }
  
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
  
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
  
  // Auth specific helpers
  static Future<void> saveAuthToken(String token) async {
    await setString(AppConstants.keyAccessToken, token);
  }
  
  static String? getAuthToken() {
    return getString(AppConstants.keyAccessToken);
  }
  
  static Future<void> saveUserId(String userId) async {
    await setString(AppConstants.keyUserId, userId);
  }
  
  static String? getUserId() {
    return getString(AppConstants.keyUserId);
  }
  
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }
  
  static bool isLoggedIn() {
    return getBool(AppConstants.keyIsLoggedIn);
  }
  
  static Future<void> logout() async {
    await remove(AppConstants.keyAccessToken);
    await remove(AppConstants.keyRefreshToken);
    await remove(AppConstants.keyUserId);
    await remove(AppConstants.keyUserData);
    await setBool(AppConstants.keyIsLoggedIn, false);
  }
}

class AppHelpers {
  static void showSnackBar(dynamic context, String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  static String formatDate(DateTime date) {
    return '\${date.day}/\${date.month}/\${date.year}';
  }
  
  static bool isValidEmail(String email) {
    return RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\).hasMatch(email);
  }
}
""";

const failuresTemplate = """
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
""";

const exceptionsTemplate = """
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
  
  @override
  String toString() => 'ServerException: \$message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: \$message';
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: \$message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: \$message';
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: \$message';
}
""";

String authScreenTemplate(String screenName, String title) => """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';

class ${_capitalize(screenName.replaceAll('_', ''))} extends StatefulWidget {
  const ${_capitalize(screenName.replaceAll('_', ''))}({super.key});

  @override
  State<${_capitalize(screenName.replaceAll('_', ''))}> createState() => _${_capitalize(screenName.replaceAll('_', ''))}State();
}

class _${_capitalize(screenName.replaceAll('_', ''))}State extends State<${_capitalize(screenName.replaceAll('_', ''))}> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  ${screenName.contains('register') ? 'final _confirmPasswordController = TextEditingController();' : ''}
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    ${screenName.contains('register') ? '_confirmPasswordController.dispose();' : ''}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title'),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppHelpers.showSnackBar(context, state.message, isError: true);
          } else if (state is AuthSuccess) {
            AppHelpers.showSnackBar(context, '${title} successful!');
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Icon(
                  ${screenName.contains('login') ? 'Icons.login' : 'Icons.person_add'},
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 32),
                Text(
                  '$title',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validatePassword,
                ),
                ${screenName.contains('register') ? '''const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => Validators.validateConfirmPassword(
                    _passwordController.text,
                    value,
                  ),
                ),''' : ''}
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is AuthLoading ? null : _${screenName.contains('login') ? 'login' : 'register'},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator()
                          : Text('$title'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      ${screenName.contains('login') ? "'/register'" : "'/login'"},
                    );
                  },
                  child: Text(
                    ${screenName.contains('login') ? "'Don\\'t have an account? Register'" : "'Already have an account? Login'"},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _${screenName.contains('login') ? 'login' : 'register'}() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      context.read<AuthBloc>().add(
        ${screenName.contains('login') ? 'AuthLoginRequested' : 'AuthRegisterRequested'}(
          email: email,
          password: password,
        ),
      );
    }
  }
}
""";

String homeScreenTemplate(String screenName, String title) => """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../core/utils/helpers.dart';

class ${_capitalize(screenName.replaceAll('_', ''))} extends StatefulWidget {
  const ${_capitalize(screenName.replaceAll('_', ''))}({super.key});

  @override
  State<${_capitalize(screenName.replaceAll('_', ''))}> createState() => _${_capitalize(screenName.replaceAll('_', ''))}State();
}

class _${_capitalize(screenName.replaceAll('_', ''))}State extends State<${_capitalize(screenName.replaceAll('_', ''))}> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title'),
        centerTitle: true,
        ${screenName.contains('home') ? '''actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],''' : ''}
      ),
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            AppHelpers.showSnackBar(context, state.message, isError: true);
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is HomeError) {
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
                      onPressed: () => context.read<HomeBloc>().add(HomeStarted()),
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
                  ${screenName.contains('home') ? '''Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome!',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This is your home dashboard. You can customize this screen according to your needs.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      _buildActionCard(
                        context,
                        'Profile',
                        Icons.person,
                        () => Navigator.pushNamed(context, '/profile'),
                      ),
                      _buildActionCard(
                        context,
                        'Settings',
                        Icons.settings,
                        () => AppHelpers.showSnackBar(context, 'Settings clicked'),
                      ),
                      _buildActionCard(
                        context,
                        'Notifications',
                        Icons.notifications,
                        () => AppHelpers.showSnackBar(context, 'Notifications clicked'),
                      ),
                      _buildActionCard(
                        context,
                        'Help',
                        Icons.help,
                        () => AppHelpers.showSnackBar(context, 'Help clicked'),
                      ),
                    ],
                  ),''' : '''Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'User Profile',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'user@example.com',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => AppHelpers.showSnackBar(context, 'Edit profile clicked'),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                        ),'''
}
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ${screenName.contains('home') ? '''Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ''' : ''}void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SharedPrefsHelper.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
""";

const authRepositoryTemplate = """
import 'dart:convert';
import '../../core/network/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/helpers.dart';
import '../models/user_model.dart';
import '../models/auth_request.dart';

class AuthRepository {
  final ApiService _apiService;
  
  AuthRepository(this._apiService);
  
  Future<Either<Failure, UserModel>> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      
      if (response.success) {
        final userModel = UserModel.fromJson(response.data['user']);
        final token = response.data['token'];
        
        // Save auth data
        await SharedPrefsHelper.saveAuthToken(token);
        await SharedPrefsHelper.saveUserId(userModel.id);
        await SharedPrefsHelper.setLoggedIn(true);
        await SharedPrefsHelper.setString('user_data', jsonEncode(userModel.toJson()));
        
        return Right(userModel);
      } else {
        return Left(AuthFailure(response.message ?? 'Login failed'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
  
  Future<Either<Failure, UserModel>> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      
      if (response.success) {
        final userModel = UserModel.fromJson(response.data['user']);
        final token = response.data['token'];
        
        // Save auth data
        await SharedPrefsHelper.saveAuthToken(token);
        await SharedPrefsHelper.saveUserId(userModel.id);
        await SharedPrefsHelper.setLoggedIn(true);
        await SharedPrefsHelper.setString('user_data', jsonEncode(userModel.toJson()));
        
        return Right(userModel);
      } else {
        return Left(AuthFailure(response.message ?? 'Registration failed'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
  
  Future<Either<Failure, void>> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
      await SharedPrefsHelper.logout();
      return const Right(null);
    } catch (e) {
      // Even if API call fails, clear local data
      await SharedPrefsHelper.logout();
      return const Right(null);
    }
  }
  
  UserModel? getCurrentUser() {
    try {
      final userData = SharedPrefsHelper.getString('user_data');
      if (userData != null) {
        return UserModel.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      // Handle parsing error
    }
    return null;
  }
  
  bool isLoggedIn() {
    return SharedPrefsHelper.isLoggedIn() && SharedPrefsHelper.getAuthToken() != null;
  }
}

// Either class for error handling
abstract class Either<L, R> {
  const Either();
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
""";

const homeRepositoryTemplate = """
import '../../core/network/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

class HomeRepository {
  final ApiService _apiService;
  
  HomeRepository(this._apiService);
  
  Future<Either<Failure, Map<String, dynamic>>> getDashboardData() async {
    try {
      final response = await _apiService.get(ApiConstants.dashboard);
      
      if (response.success) {
        return Right(response.data ?? {});
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to load dashboard'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
  
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.profile);
      
      if (response.success) {
        return Right(response.data ?? {});
      } else {
        return Left(ServerFailure(response.message ?? 'Failed to load profile'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: \$e'));
    }
  }
}

// Either class for error handling
abstract class Either<L, R> {
  const Either();
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
""";

const userModelTemplate = """
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, phone, createdAt, updatedAt];
}
""";

const authRequestTemplate = """
import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object> get props => [email, password];
}

class RegisterRequest extends Equatable {
  final String email;
  final String password;
  final String? name;
  final String? phone;

  const RegisterRequest({
    required this.email,
    required this.password,
    this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
    };
  }

  @override
  List<Object?> get props => [email, password, name, phone];
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

${name == 'auth' ? '''
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const AuthLoginRequested({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    this.name,
  });
  
  @override
  List<Object?> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}
''' : ''}
""";

String stateTemplate(String name) => """
import 'package:equatable/equatable.dart';
${name == 'auth' ? "import '../models/user_model.dart';" : ''}

abstract class ${_capitalize(name)}State extends Equatable {
  const ${_capitalize(name)}State();

  @override
  List<Object?> get props => [];
}

class ${_capitalize(name)}Initial extends ${_capitalize(name)}State {}

class ${_capitalize(name)}Loading extends ${_capitalize(name)}State {}

class ${_capitalize(name)}Loaded extends ${_capitalize(name)}State {
  ${name == 'home' ? 'final Map<String, dynamic> data;' : ''}
  
  ${name == 'home' ? 'const ${_capitalize(name)}Loaded(this.data);' : ''}
  
  ${name == 'home' ? '@override\n  List<Object> get props => [data];' : ''}
}

class ${_capitalize(name)}Error extends ${_capitalize(name)}State {
  final String message;
  const ${_capitalize(name)}Error(this.message);

  @override
  List<Object> get props => [message];
}

${name == 'auth' ? '''
class AuthSuccess extends AuthState {
  final UserModel user;
  
  const AuthSuccess(this.user);
  
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}
''' : ''}
""";

String blocTemplate(String name) => """
import 'package:flutter_bloc/flutter_bloc.dart';
import '${name}_event.dart';
import '${name}_state.dart';
import '../repository/${name}_repository.dart';

class ${_capitalize(name)}Bloc extends Bloc<${_capitalize(name)}Event, ${_capitalize(name)}State> {
  final ${_capitalize(name)}Repository _repository;

  ${_capitalize(name)}Bloc(this._repository) : super(${_capitalize(name)}Initial()) {
    on<${_capitalize(name)}Started>(_onStarted);
    ${name == 'auth' ? '''
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    ''' : ''}
  }

  Future<void> _onStarted(${_capitalize(name)}Started event, Emitter<${_capitalize(name)}State> emit) async {
    emit(${_capitalize(name)}Loading());
    try {
      ${name == 'auth' ? '''
      // Check if user is already logged in
      if (_repository.isLoggedIn()) {
        final user = _repository.getCurrentUser();
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
      ''' : name == 'home' ? '''
      final result = await _repository.getDashboardData();
      result.fold(
        (failure) => emit(${_capitalize(name)}Error(failure.message)),
        (data) => emit(${_capitalize(name)}Loaded(data)),
      );
      ''' : '''
      await Future.delayed(const Duration(seconds: 1)); // mock fetch
      emit(${_capitalize(name)}Loaded());
      '''}
    } catch (e) {
      emit(${_capitalize(name)}Error(e.toString()));
    }
  }

  ${name == 'auth' ? '''
  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _repository.login(LoginRequest(
        email: event.email,
        password: event.password,
      ));
      
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (e) {
      emit(AuthError('Login failed: \$e'));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _repository.register(RegisterRequest(
        email: event.email,
        password: event.password,
        name: event.name,
      ));
      
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (e) {
      emit(AuthError('Registration failed: \$e'));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _repository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: \$e'));
    }
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    if (_repository.isLoggedIn()) {
      final user = _repository.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }
  ''' : ''}
}
""";

const serviceLocatorTemplate = """
import 'package:get_it/get_it.dart';
import '../core/network/dio_client.dart'; // Change to http_client.dart if using HTTP
import '../core/network/api_service.dart';
import '../modules/auth/repository/auth_repository.dart';
import '../modules/auth/bloc/auth_bloc.dart';
import '../modules/home/repository/home_repository.dart';
import '../modules/home/bloc/home_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient()); // Change to HttpClient() if using HTTP
  sl.registerLazySingleton<ApiService>(() => ApiService(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepository(sl()));

  // Blocs
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<HomeBloc>(() => HomeBloc(sl()));
}
""";

const appRouterTemplate = """
import 'package:flutter/material.dart';
import '../modules/auth/screens/login_screen.dart';
import '../modules/auth/screens/register_screen.dart';
import '../modules/home/screens/home_screen.dart';
import '../modules/home/screens/profile_screen.dart';
import '../core/constants/app_constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppConstants.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case AppConstants.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for \${settings.name}'),
            ),
          ),
        );
    }
  }
}
""";

const blocObserverTemplate = """
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- \${bloc.runtimeType}');
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    super.onEvent(bloc, event);
    print('onEvent -- \${bloc.runtimeType}, \$event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- \${bloc.runtimeType}, \$change');
  }

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- \${bloc.runtimeType}, \$transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- \${bloc.runtimeType}, \$error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- \${bloc.runtimeType}');
  }
}
""";

const mainDartTemplate = """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/service_locator.dart';
import 'app/app_router.dart';
import 'app/bloc_observer.dart';
import 'core/utils/helpers.dart';
import 'core/constants/app_constants.dart';
import 'modules/auth/bloc/auth_bloc.dart';
import 'modules/auth/bloc/auth_event.dart';
import 'modules/auth/bloc/auth_state.dart';
import 'modules/home/bloc/home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  await SharedPrefsHelper.init();
  
  // Setup service locator
  await setupServiceLocator();
  
  // Set up Bloc observer
  Bloc.observer = AppBlocObserver();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckStatus()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => sl<HomeBloc>(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        onGenerateRoute: AppRouter.generateRoute,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is AuthSuccess) {
              return const _HomeWrapper();
            } else {
              return const _AuthWrapper();
            }
          },
        ),
      ),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      },
    );
  }
}

class _HomeWrapper extends StatelessWidget {
  const _HomeWrapper();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      },
    );
  }
}
""";