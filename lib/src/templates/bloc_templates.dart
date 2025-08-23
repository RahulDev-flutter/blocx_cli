import '../utils/cli_helpers.dart';

class BlocTemplates {
  static String eventTemplate(String name) => """
import 'package:equatable/equatable.dart';
import '../models/auth_request.dart';

abstract class ${CliHelpers.capitalize(name)}Event extends Equatable {
  const ${CliHelpers.capitalize(name)}Event();

  @override
  List<Object?> get props => [];
}

class ${CliHelpers.capitalize(name)}Started extends ${CliHelpers.capitalize(name)}Event {}

${name == 'auth' ? '''
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

class AuthCheckStatus extends AuthEvent {}

class AuthRefreshToken extends AuthEvent {}
''' : ''}
""";

  static String stateTemplate(String name) => """
import 'package:equatable/equatable.dart';
${name == 'auth' ? "import '../models/user_model.dart';" : ''}

abstract class ${CliHelpers.capitalize(name)}State extends Equatable {
  const ${CliHelpers.capitalize(name)}State();

  @override
  List<Object?> get props => [];
}

class ${CliHelpers.capitalize(name)}Initial extends ${CliHelpers.capitalize(name)}State {}

class ${CliHelpers.capitalize(name)}Loading extends ${CliHelpers.capitalize(name)}State {}

class ${CliHelpers.capitalize(name)}Loaded extends ${CliHelpers.capitalize(name)}State {
  ${name == 'home' ? 'final Map<String, dynamic> data;' : ''}
  
  ${name == 'home' ? 'const ${CliHelpers.capitalize(name)}Loaded(this.data);' : ''}
  
  ${name == 'home' ? '@override\n  List<Object> get props => [data];' : ''}
}

class ${CliHelpers.capitalize(name)}Error extends ${CliHelpers.capitalize(name)}State {
  final String message;
  const ${CliHelpers.capitalize(name)}Error(this.message);

  @override
  List<Object> get props => [message];
}

${name == 'auth' ? '''
class AuthAuthenticated extends AuthState {
  final UserModel user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}
''' : ''}
""";

  static String blocTemplate(String name) => """
import 'package:flutter_bloc/flutter_bloc.dart';
import '${name}_event.dart';
import '${name}_state.dart';
import '../repository/${name}_repository.dart';
${name == 'auth' ? "import '../models/auth_request.dart';" : ''}

class ${CliHelpers.capitalize(name)}Bloc extends Bloc<${CliHelpers.capitalize(name)}Event, ${CliHelpers.capitalize(name)}State> {
  final ${CliHelpers.capitalize(name)}Repository _repository;

  ${CliHelpers.capitalize(name)}Bloc(this._repository) : super(${CliHelpers.capitalize(name)}Initial()) {
    on<${CliHelpers.capitalize(name)}Started>(_onStarted);
    ${name == 'auth' ? '''
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthRefreshToken>(_onRefreshToken);
    ''' : ''}
  }

  Future<void> _onStarted(${CliHelpers.capitalize(name)}Started event, Emitter<${CliHelpers.capitalize(name)}State> emit) async {
    emit(${CliHelpers.capitalize(name)}Loading());
    try {
      ${name == 'auth' ? '''
      // Check if user is already logged in
      if (await _repository.isLoggedIn()) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
      ''' : name == 'home' ? '''
      final result = await _repository.getDashboardData();
      result.fold(
        (failure) => emit(${CliHelpers.capitalize(name)}Error(failure.message ?? 'Unknown error')),
        (data) => emit(${CliHelpers.capitalize(name)}Loaded(data)),
      );
      ''' : '''
      await Future.delayed(const Duration(seconds: 1)); // mock fetch
      emit(${CliHelpers.capitalize(name)}Loaded());
      '''}
    } catch (e) {
      emit(${CliHelpers.capitalize(name)}Error(e.toString()));
    }
  }

  ${name == 'auth' ? '''
  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _repository.login(event.request);
      
      result.fold(
        (failure) => emit(AuthError(failure.message ?? 'Login failed')),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Login failed: \$e'));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _repository.register(event.request);
      
      result.fold(
        (failure) => emit(AuthError(failure.message ?? 'Registration failed')),
        (user) => emit(AuthAuthenticated(user)),
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
    try {
      if (await _repository.isLoggedIn()) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshToken(AuthRefreshToken event, Emitter<AuthState> emit) async {
    try {
      final result = await _repository.refreshToken();
      result.fold(
        (failure) {
          emit(AuthError(failure.message ?? 'Token refresh failed'));
          emit(AuthUnauthenticated());
        },
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Token refresh failed: \$e'));
      emit(AuthUnauthenticated());
    }
  }
  ''' : ''}
}
""";
}
