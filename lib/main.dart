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
  
  // Validate environment configuration
  if (!EnvironmentConfig.validateConfiguration()) {
    throw Exception('Invalid environment configuration for ${EnvironmentConfig.current.name}');
  }
  
  // Initialize bundle optimizations for production performance
  await BundleOptimizer().initialize();
  
  // Initialize monitoring and analytics services (optional for development)
  try {
    await MonitoringService.instance.initialize();
  } catch (e) {
    debugPrint('Monitoring services initialization failed (continuing without): $e');
  }
  
  // Initialize performance monitoring
  PerformanceMonitor.instance.startMonitoring();
  
  // Initialize offline support
  final apiClient = ApiClientFactory.create();
  await OfflineManager().initialize(apiClient);
  
  // Initialize theme manager
  final themeManager = ThemeManager();
  await themeManager.initialize();
  
  runApp(TourlicityApp(themeManager: themeManager));
}

class TourlicityApp extends StatelessWidget {
  final ThemeManager themeManager;
  
  const TourlicityApp({
    super.key,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    // Create API client and backend services
    final apiClient = ApiClientFactory.create();
    final backendAuthService = ApiClientFactory.createBackendAuthService();
    
    final authRepository = AuthRepositoryImpl(
      apiClient: apiClient,
      googleSignInService: GoogleSignInService(backendAuthService: backendAuthService),
      tokenStorage: const SecureTokenStorage(),
      backendAuthService: backendAuthService,
    );
    final userRepository = UserRepositoryImpl(apiClient: apiClient);
    final registrationRepository = RegistrationRepositoryImpl(apiClient: apiClient);
    // Use offline-aware repository for custom tours
    final customTourRepository = OfflineCustomTourRepositoryImpl(
      apiClient: apiClient,
      cacheService: OfflineManager().cacheService,
      connectivityService: OfflineManager().connectivityService,
      syncService: OfflineManager().syncService,
    );
    final documentRepository = DocumentRepositoryImpl(apiClient: apiClient);
    final messageRepository = MessageRepositoryImpl(apiClient);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: registrationRepository),
        RepositoryProvider.value(value: customTourRepository),
        RepositoryProvider.value(value: documentRepository),
        RepositoryProvider.value(value: messageRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
            )..add(const AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => UserBloc(
              userRepository: userRepository,
            ),
          ),
          BlocProvider(
            create: (context) => RegistrationBloc(
              registrationRepository: registrationRepository,
            ),
          ),
          BlocProvider(
            create: (context) => CustomTourBloc(
              customTourRepository: customTourRepository,
            ),
          ),
          BlocProvider(
            create: (context) => DocumentBloc(
              documentRepository: documentRepository,
            ),
          ),
          BlocProvider(
            create: (context) => MessageBloc(
              messageRepository,
            ),
          ),
        ],
        child: Builder(
          builder: (context) {
            final authBloc = context.read<AuthBloc>();
            final router = AppRouter.createRouter(authBloc);

            return ListenableBuilder(
              listenable: themeManager,
              builder: (context, _) {
                return MaterialApp.router(
                  title: AppConstants.appName,
                  theme: themeManager.isHighContrastMode 
                      ? AppTheme.highContrastLightTheme 
                      : AppTheme.lightTheme,
                  darkTheme: themeManager.isHighContrastMode 
                      ? AppTheme.highContrastDarkTheme 
                      : AppTheme.darkTheme,
                  themeMode: themeManager.themeMode,
                  debugShowCheckedModeBanner: AppConfig.isDebug,
                  routerConfig: router,
                  builder: (context, child) {
                    // Apply text scale factor
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(themeManager.textScaleFactor),
                      ),
                      child: OfflineStatusWidget(
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
