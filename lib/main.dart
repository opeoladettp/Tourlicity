import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'core/config/app_config.dart';
import 'core/config/environment_config.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/app_router.dart';
import 'core/services/offline_manager.dart';
import 'core/performance/performance_monitor.dart';
import 'core/performance/bundle_optimizer.dart';
import 'core/monitoring/monitoring_service.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/registration/registration_bloc.dart';
import 'presentation/blocs/custom_tour/custom_tour_bloc.dart';
import 'presentation/blocs/document/document_bloc.dart';
import 'presentation/blocs/message/message_bloc.dart';
import 'presentation/widgets/common/offline_status_widget.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/registration_repository_impl.dart';

import 'data/repositories/offline_custom_tour_repository_impl.dart';
import 'data/repositories/document_repository_impl.dart';
import 'data/repositories/message_repository_impl.dart';
import 'data/services/google_sign_in_service.dart';
import 'core/network/api_client_factory.dart';
import 'core/network/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Validate environment configuration
    if (!EnvironmentConfig.validateConfiguration()) {
      debugPrint('Environment validation failed, using defaults');
    }

    // Initialize theme manager first (simplest)
    final themeManager = ThemeManager();
    await themeManager.initialize();

    // Skip complex initialization for now to test basic app
    debugPrint('Starting app with minimal initialization...');
    
    runApp(TourlicityApp(themeManager: themeManager));
  } catch (e, stackTrace) {
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Fallback to simple app
    runApp(const SimpleApp());
  }
}

class SimpleApp extends StatelessWidget {
  const SimpleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourlicity',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tourlicity App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Loading...'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class TourlicityApp extends StatelessWidget {
  final ThemeManager themeManager;

  const TourlicityApp({
    super.key,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return ListenableBuilder(
        listenable: themeManager,
        builder: (context, _) {
          return MaterialApp(
            title: 'Tourlicity',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              appBar: null,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.travel_explore,
                      size: 64,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome to Tourlicity',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your travel companion app',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 40),
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Initializing...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error building TourlicityApp: $e');
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text('Error loading app'),
                const SizedBox(height: 10),
                Text('$e'),
              ],
            ),
          ),
        ),
      );
    }
  }
}
