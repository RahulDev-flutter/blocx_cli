import '../utils/project_validator.dart';

class AuthTemplates {
  static String authScreenTemplate(String screenName, String title) => """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../models/auth_request.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';

class ${ProjectValidator.toPascalCase(screenName)} extends StatefulWidget {
  const ${ProjectValidator.toPascalCase(screenName)}({super.key});

  @override
  State<${ProjectValidator.toPascalCase(screenName)}> createState() => _${ProjectValidator.toPascalCase(screenName)}State();
}

class _${ProjectValidator.toPascalCase(screenName)}State extends State<${ProjectValidator.toPascalCase(screenName)}> {
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
                  ),
                  validator: (value) => Validators.validateEmail(value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) => Validators.validatePassword(value),
                ),
                ${screenName.contains('register') ? '''
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
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
          ${screenName.contains('login') ? 'LoginRequest(email: email, password: password)' : 'RegisterRequest(email: email, password: password)'}
        ),
      );
    }
  }
}
""";

  static const String authRepositoryTemplate = """
import 'dart:convert';
import '../../core/network/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/helpers.dart';
import '../models/user_model.dart';
import '../models/auth_request.dart';

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
        final refreshToken = response.data['refresh_token'];
        
        // Save auth data securely
        await SecureStorageHelper.saveUserSession(
          accessToken: token,
          userId: userModel.id,
          userData: jsonEncode(userModel.toJson()),
          refreshToken: refreshToken,
        );
        
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
        final refreshToken = response.data['refresh_token'];
        
        // Save auth data securely
        await SecureStorageHelper.saveUserSession(
          accessToken: token,
          userId: userModel.id,
          userData: jsonEncode(userModel.toJson()),
          refreshToken: refreshToken,
        );
        
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
      final token = await SecureStorageHelper.getAuthToken();
      if (token != null) {
        await _apiService.post(ApiConstants.logout);
      }
    } catch (e) {
      print('Server logout failed: \$e');
    }
    
    await SecureStorageHelper.logout();
    return const Right(null);
  }
  
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await SecureStorageHelper.getUserData();
      if (userData != null) {
        return UserModel.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      print('Error parsing user data: \$e');
    }
    return null;
  }
  
  Future<bool> isLoggedIn() async {
    return await SecureStorageHelper.hasValidSession();
  }
  
  Future<Either<Failure, UserModel>> refreshToken() async {
    try {
      final refreshToken = await SecureStorageHelper.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthFailure('No refresh token available'));
      }
      
      final response = await _apiService.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      
      if (response.success) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refresh_token'];
        final userModel = UserModel.fromJson(response.data['user']);
        
        await SecureStorageHelper.saveAuthToken(newToken);
        if (newRefreshToken != null) {
          await SecureStorageHelper.saveRefreshToken(newRefreshToken);
        }
        
        return Right(userModel);
      } else {
        await SecureStorageHelper.logout();
        return const Left(AuthFailure('Session expired. Please login again.'));
      }
    } on ServerException catch (e) {
      await SecureStorageHelper.logout();
      return Left(ServerFailure(e.message));
    } catch (e) {
      await SecureStorageHelper.logout();
      return Left(UnknownFailure('Session refresh failed: \$e'));
    }
  }
}
""";

  static const String userModelTemplate = """
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

  static const String authRequestTemplate = """
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

  const RegisterRequest({
    required this.email,
    required this.password,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (name != null) 'name': name,
    };
  }

  @override
  List<Object?> get props => [email, password, name];
}

class ForgotPasswordRequest extends Equatable {
  final String email;

  const ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  @override
  List<Object> get props => [email];
}

class ResetPasswordRequest extends Equatable {
  final String token;
  final String password;
  final String confirmPassword;

  const ResetPasswordRequest({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
      'password_confirmation': confirmPassword,
    };
  }

  @override
  List<Object> get props => [token, password, confirmPassword];
}

class ChangePasswordRequest extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    };
  }

  @override
  List<Object> get props => [currentPassword, newPassword, confirmPassword];
}
""";

  // Auth Bloc State
  static const String authStateTemplate = """
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

class AuthSuccess extends AuthState {
  final String message;
  final UserModel? user;
  
  const AuthSuccess(this.message, {this.user});
  
  @override
  List<Object?> get props => [message, user];
}
""";

  // Auth Bloc Event
  static const String authEventTemplate = """
import 'package:equatable/equatable.dart';
import '../models/auth_request.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final LoginRequest request;
  
  const AuthLoginRequested(this.request);
  
  @override
  List<Object> get props => [request];
}

class AuthRegisterRequested extends AuthEvent {
  final RegisterRequest request;
  
  const AuthRegisterRequested(this.request);
  
  @override
  List<Object> get props => [request];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final ForgotPasswordRequest request;
  
  const AuthForgotPasswordRequested(this.request);
  
  @override
  List<Object> get props => [request];
}

class AuthResetPasswordRequested extends AuthEvent {
  final ResetPasswordRequest request;
  
  const AuthResetPasswordRequested(this.request);
  
  @override
  List<Object> get props => [request];
}

class AuthChangePasswordRequested extends AuthEvent {
  final ChangePasswordRequest request;
  
  const AuthChangePasswordRequested(this.request);
  
  @override
  List<Object> get props => [request];
}

class AuthRefreshTokenRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}
""";

  // Auth Bloc
  static const String authBlocTemplate = """
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';
import '../../core/errors/failures.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthChangePasswordRequested>(_onChangePasswordRequested);
    on<AuthRefreshTokenRequested>(_onRefreshTokenRequested);
    on<AuthCheckStatus>(_onCheckStatus);
  }

  Future<void> _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await _authRepository.login(event.request);
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await _authRepository.register(event.request);
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await _authRepository.logout();
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onForgotPasswordRequested(AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    // Implement forgot password logic here
    // final result = await _authRepository.forgotPassword(event.request);
    // Handle result...
    
    emit(const AuthSuccess('Password reset email sent!'));
  }

  Future<void> _onResetPasswordRequested(AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    // Implement reset password logic here
    // final result = await _authRepository.resetPassword(event.request);
    // Handle result...
    
    emit(const AuthSuccess('Password reset successful!'));
  }

  Future<void> _onChangePasswordRequested(AuthChangePasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    // Implement change password logic here
    // final result = await _authRepository.changePassword(event.request);
    // Handle result...
    
    emit(const AuthSuccess('Password changed successfully!'));
  }

  Future<void> _onRefreshTokenRequested(AuthRefreshTokenRequested event, Emitter<AuthState> emit) async {
    final result = await _authRepository.refreshToken();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case AuthFailure:
        return failure.message;
      case ValidationFailure:
        return failure.message;
      default:
        return 'An unexpected error occurred.';
    }
  }
}
""";
}
