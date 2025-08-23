import '../utils/project_validator.dart';

class BlocTemplates {
  static String eventTemplate(String name) =>
      """
import 'package:equatable/equatable.dart';

abstract class ${ProjectValidator.capitalize(name)}Event extends Equatable {
  const ${ProjectValidator.capitalize(name)}Event();

  @override
  List<Object?> get props => [];
}

class ${ProjectValidator.capitalize(name)}Started extends ${ProjectValidator.capitalize(name)}Event {}

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

class AuthRefreshToken extends AuthEvent {}
''' : ''}
""";

  static String stateTemplate(String name) =>
      """
import 'package:equatable/equatable.dart';
${name == 'auth' ? "import '../models/user_model.dart';" : ''}

abstract class ${ProjectValidator.capitalize(name)}State extends Equatable {
  const ${ProjectValidator.capitalize(name)}State();

  @override
  List<Object?> get props => [];
}

class ${ProjectValidator.capitalize(name)}Initial extends ${ProjectValidator.capitalize(name)}State {}

class ${ProjectValidator.capitalize(name)}Loading extends ${ProjectValidator.capitalize(name)}State {}

class ${ProjectValidator.capitalize(name)}Loaded extends ${ProjectValidator.capitalize(name)}State {
  ${name == 'home' ? 'final Map<String, dynamic> data;' : ''}
  
  ${name == 'home' ? 'const ${ProjectValidator.capitalize(name)}Loaded(this.data);' : ''}
  
  ${name == 'home' ? '@override\n  List<Object> get props => [data];' : ''}
}

class ${ProjectValidator.capitalize(name)}Error extends ${ProjectValidator.capitalize(name)}State {
  final String message;
  const ${ProjectValidator.capitalize(name)}Error(this.message);

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

  static String blocTemplate(String name) =>
      """
import 'package:flutter_bloc/flutter_bloc.dart';
import '${name}_event.dart';
import '${name}_state.dart';
import '../repository/${name}_repository.dart';
${name == 'auth' ? "import '../models/auth_request.dart';" : ''}

class ${ProjectValidator.capitalize(name)}Bloc extends Bloc<${ProjectValidator.capitalize(name)}Event, ${ProjectValidator.capitalize(name)}State> {
  final ${ProjectValidator.capitalize(name)}Repository _repository;

  ${ProjectValidator.capitalize(name)}Bloc(this._repository) : super(${ProjectValidator.capitalize(name)}Initial()) {
    on<${ProjectValidator.capitalize(name)}Started>(_onStarted);
    ${name == 'auth' ? '''
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthRefreshToken>(_onRefreshToken);
    ''' : ''}
  }

  Future<void> _onStarted(${ProjectValidator.capitalize(name)}Started event, Emitter<${ProjectValidator.capitalize(name)}State> emit) async {
    emit(${ProjectValidator.capitalize(name)}Loading());
    try {
      ${name == 'auth'
          ? '''
      // Check if user is already logged in
      if (await _repository.isLoggedIn()) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
      '''
          : name == 'home'
          ? '''
      final result = await _repository.getDashboardData();
      result.fold(
        (failure) => emit(${ProjectValidator.capitalize(name)}Error(failure.message)),
        (data) => emit(${ProjectValidator.capitalize(name)}Loaded(data)),
      );
      '''
          : '''
      await Future.delayed(const Duration(seconds: 1)); // mock fetch
      emit(${ProjectValidator.capitalize(name)}Loaded());
      '''}
    } catch (e) {
      emit(${ProjectValidator.capitalize(name)}Error(e.toString()));
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
    try {
      if (await _repository.isLoggedIn()) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          emit(AuthSuccess(user));
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
          emit(AuthError(failure.message));
          emit(AuthUnauthenticated());
        },
        (user) => emit(AuthSuccess(user)),
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
