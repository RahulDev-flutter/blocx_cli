class CoreTemplates {
  static const String dioClientTemplate = """
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

  static const String httpClientTemplate = """
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

  static const String dioApiServiceTemplate = """
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

  static const String httpApiServiceTemplate = """
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

  static String apiResponseTemplate(String apiChoice) => """
import 'dart:convert';
${apiChoice == 'dio' ? "import 'package:dio/dio.dart';" : "import 'package:http/http.dart' as http;"}

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

  ${apiChoice == 'dio' ? '''
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
  ''' : '''
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
  '''}
}
""";

  static const String apiConstantsTemplate = """
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String deleteAccount = '/user/delete';
  
  // Other endpoints
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}
""";

  static const String appConstantsTemplate = """
class AppConstants {
  static const String appName = 'BlocX App';
  static const String appVersion = '1.0.0';
  
  // Secure Storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // Route names
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String resetPasswordRoute = '/reset-password';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const int defaultAnimationDurationMs = 300;
}
""";

  static const String validatorsTemplate = """
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
    
    if (value.length > 50) {
      return 'Password must be less than 50 characters';
    }
    
    // Check for at least one letter and one number
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\\d)').hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
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
  
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    // Only allow letters, spaces, and common name characters
    if (!RegExp(r'^[a-zA-Z\\s\\-\\.\\\']+\$').hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional in most cases
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\\d]'), '');
    
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '\$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '\$fieldName must be at least \$minLength characters';
    }
    
    return null;
  }
  
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '\$fieldName must be less than \$maxLength characters';
    }
    
    return null;
  }
  
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is often optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)\$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
}
""";

  static const String helpersTemplate = """
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainItemAccessibility.first_unlock_this_device,
    ),
  );
  
  // Generic methods
  static Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print('Error writing to secure storage: \$e');
    }
  }
  
  static Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print('Error reading from secure storage: \$e');
      return null;
    }
  }
  
  static Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }
  
  static Future<bool> getBool(String key) async {
    final value = await getString(key);
    return value?.toLowerCase() == 'true';
  }
  
  static Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('Error removing from secure storage: \$e');
    }
  }
  
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing secure storage: \$e');
    }
  }
  
  // Auth specific helpers
  static Future<void> saveAuthToken(String token) async {
    await setString(AppConstants.keyAccessToken, token);
  }
  
  static Future<String?> getAuthToken() async {
    return await getString(AppConstants.keyAccessToken);
  }
  
  static Future<void> saveRefreshToken(String token) async {
    await setString(AppConstants.keyRefreshToken, token);
  }
  
  static Future<String?> getRefreshToken() async {
    return await getString(AppConstants.keyRefreshToken);
  }
  
  static Future<void> saveUserId(String userId) async {
    await setString(AppConstants.keyUserId, userId);
  }
  
  static Future<String?> getUserId() async {
    return await getString(AppConstants.keyUserId);
  }
  
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }
  
  static Future<bool> isLoggedIn() async {
    return await getBool(AppConstants.keyIsLoggedIn);
  }
  
  static Future<void> saveUserData(String userData) async {
    await setString(AppConstants.keyUserData, userData);
  }
  
  static Future<String?> getUserData() async {
    return await getString(AppConstants.keyUserData);
  }
  
  // Theme and settings
  static Future<void> saveThemeMode(String themeMode) async {
    await setString(AppConstants.keyThemeMode, themeMode);
  }
  
  static Future<String?> getThemeMode() async {
    return await getString(AppConstants.keyThemeMode);
  }
  
  static Future<void> saveLanguage(String language) async {
    await setString(AppConstants.keyLanguage, language);
  }
  
  static Future<String?> getLanguage() async {
    return await getString(AppConstants.keyLanguage);
  }
  
  // Complete logout - clears all auth data
  static Future<void> logout() async {
    await remove(AppConstants.keyAccessToken);
    await remove(AppConstants.keyRefreshToken);
    await remove(AppConstants.keyUserId);
    await remove(AppConstants.keyUserData);
    await setBool(AppConstants.keyIsLoggedIn, false);
  }
  
  // Check if user has valid session
  static Future<bool> hasValidSession() async {
    final isLoggedIn = await getBool(AppConstants.keyIsLoggedIn);
    final token = await getAuthToken();
    return isLoggedIn && token != null && token.isNotEmpty;
  }
  
  // Save complete user session
  static Future<void> saveUserSession({
    required String accessToken,
    required String userId,
    required String userData,
    String? refreshToken,
  }) async {
    await saveAuthToken(accessToken);
    await saveUserId(userId);
    await saveUserData(userData);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
    await setLoggedIn(true);
  }
}

class AppHelpers {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  static void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  static void showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }
  
  static String formatDate(DateTime date) {
    return '\${date.day.toString().padLeft(2, '0')}/\${date.month.toString().padLeft(2, '0')}/\${date.year}';
  }
  
  static String formatDateTime(DateTime dateTime) {
    return '\${formatDate(dateTime)} \${dateTime.hour.toString().padLeft(2, '0')}:\${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  static String formatTime(DateTime time) {
    return '\${time.hour.toString().padLeft(2, '0')}:\${time.minute.toString().padLeft(2, '0')}';
  }
  
  static String formatCurrency(double amount, {String symbol = '\\\$'}) {
    return '\$symbol\${amount.toStringAsFixed(2)}';
  }
  
  static bool isValidEmail(String email) {
    return RegExp(r'^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}\$').hasMatch(email);
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '\${text.substring(0, maxLength)}...';
  }
  
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '\${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '\${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'success':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'warning':
        return Colors.orange;
      case 'error':
      case 'failed':
      case 'cancelled':
        return Colors.red;
      case 'inactive':
      case 'disabled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
  
  static void copyToClipboard(BuildContext context, String text) {
    // Note: You'll need to add clipboard package
    // Clipboard.setData(ClipboardData(text: text));
    showSnackBar(context, 'Copied to clipboard');
  }
  
  static void openUrl(String url) {
    // Note: You'll need to add url_launcher package
    // launchUrl(Uri.parse(url));
  }
}
""";

  static const String failuresTemplate = """
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

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
""";

  static const String exceptionsTemplate = """
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

class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: \$message';
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: \$message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  
  @override
  String toString() => 'NotFoundException: \$message';
}
""";

  // Additional utility templates

  static const String routeGeneratorTemplate = """
import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../core/constants/app_constants.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppConstants.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case AppConstants.forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case AppConstants.resetPasswordRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] as String?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token),
        );
      
      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case AppConstants.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case AppConstants.settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      default:
        return _errorRoute(settings.name);
    }
  }
  
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Route not found: \$routeName'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  _,
                  AppConstants.homeRoute,
                  (route) => false,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
""";

  static const String themeConfigTemplate = """
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
""";

  static const String dependencyInjectionTemplate = """
import 'package:get_it/get_it.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<ApiService>(() => ApiService(sl()));
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl()));
  
  // Blocs
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
}
""";

  static const String splashScreenTemplate = """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  void _checkAuthStatus() {
    Future.delayed(const Duration(seconds: 2), () {
      context.read<AuthBloc>().add(AuthStarted());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
          } else if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.flutter_dash,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Version AppConstants.appVersion',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
""";
}
