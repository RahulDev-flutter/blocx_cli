class AppTemplates {
  static String serviceLocatorTemplate(bool isDio) => """
import 'package:get_it/get_it.dart';
${isDio ? "import '../core/network/dio_client.dart';" : "import '../core/network/http_client.dart';"}
import '../core/network/api_service.dart';
import '../modules/auth/repository/auth_repository.dart';
import '../modules/auth/bloc/auth_bloc.dart';
import '../modules/home/repository/home_repository.dart';
import '../modules/home/bloc/home_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  ${isDio ? "sl.registerLazySingleton<DioClient>(() => DioClient());" : "sl.registerLazySingleton<HttpClient>(() => HttpClient());"}
  sl.registerLazySingleton<ApiService>(() => ApiService(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepository(sl()));

  // Blocs
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<HomeBloc>(() => HomeBloc(sl()));
}
""";

  static const String appRouterTemplate = """
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

  static const String blocObserverTemplate = """
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- \${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) { // 👈 Bloc, not BlocBase
    super.onEvent(bloc, event);
    print('onEvent -- \${bloc.runtimeType}, \$event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('onChange -- \${bloc.runtimeType}, \$change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) { // 👈 Bloc, not BlocBase
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

  static const String mainDartTemplate = """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/service_locator.dart';
import 'app/app_router.dart';
import 'app/bloc_observer.dart';
import 'core/constants/app_constants.dart';
import 'modules/auth/bloc/auth_bloc.dart';
import 'modules/auth/bloc/auth_event.dart';
import 'modules/auth/bloc/auth_state.dart';
import 'modules/auth/screens/login_screen.dart';
import 'modules/home/bloc/home_bloc.dart';
import 'modules/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
            } else if (state is AuthAuthenticated) {
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
}
