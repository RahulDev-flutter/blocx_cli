import '../utils/project_validator.dart';

class HomeTemplates {
  static String homeScreenTemplate(String screenName, String title) => """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../core/utils/helpers.dart';

class ${ProjectValidator.toPascalCase(screenName)} extends StatefulWidget {
  const ${ProjectValidator.toPascalCase(screenName)}({super.key});

  @override
  State<${ProjectValidator.toPascalCase(screenName)}> createState() => _${ProjectValidator.toPascalCase(screenName)}State();
}

class _${ProjectValidator.toPascalCase(screenName)}State extends State<${ProjectValidator.toPascalCase(screenName)}> {
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
                        ),'''}
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
            onPressed: () async {
              Navigator.pop(context);
              await SecureStorageHelper.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
""";

  static const String homeRepositoryTemplate = """
import '../../core/network/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

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
""";
}
