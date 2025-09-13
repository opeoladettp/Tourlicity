import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// Temporarily disabled flutter_secure_storage import
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import 'dio_api_client.dart';
import '../config/environment_config.dart';
import '../security/secure_session_manager.dart';
import '../services/backend_health_service.dart';
import '../../data/services/backend_auth_service.dart';

/// Factory for creating API client instances with Backend Integration
class ApiClientFactory {
  static ApiClient create({
    SecureSessionManager? sessionManager,
  }) {
    final dio = _createDio();

    return DioApiClient(
      dio: dio,
      sessionManager: sessionManager ?? SecureSessionManager.stub(),
    );
  }

  /// Create Backend Auth Service
  static BackendAuthService createBackendAuthService() {
    final dio = _createDio();
    return BackendAuthService(dio: dio);
  }

  /// Create Backend Health Service
  static BackendHealthService createBackendHealthService() {
    final dio = _createHealthDio();
    return BackendHealthService(dio: dio);
  }

  /// Create configured Dio instance
  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      connectTimeout: EnvironmentConfig.networkTimeout,
      receiveTimeout: EnvironmentConfig.networkTimeout,
      sendTimeout: EnvironmentConfig.networkTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Tourlicity-Flutter/${EnvironmentConfig.current.name}',
      },
    ));

    _addInterceptors(dio);
    return dio;
  }

  /// Create Dio instance for health checks (uses different base URL)
  static Dio _createHealthDio() {
    // Extract base URL without /api/v1 for health endpoints
    final baseUrl = EnvironmentConfig.apiBaseUrl.replaceAll('/api/v1', '');

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: EnvironmentConfig.networkTimeout,
      receiveTimeout: EnvironmentConfig.networkTimeout,
      sendTimeout: EnvironmentConfig.networkTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Tourlicity-Flutter/${EnvironmentConfig.current.name}',
      },
    ));

    _addInterceptors(dio);
    return dio;
  }

  /// Add common interceptors to Dio instance
  static void _addInterceptors(Dio dio) {
    // Add logging interceptor
    if (EnvironmentConfig.enableDebugLogging) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint('🌐 API: $obj'),
      ));
    }

    // Add error handling interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        debugPrint('🚨 API Error: ${error.message}');
        if (error.response != null) {
          debugPrint('🚨 Response: ${error.response?.data}');
        }
        handler.next(error);
      },
    ));
  }

  /// Test backend connectivity
  static Future<bool> testBackendConnectivity() async {
    try {
      final healthService = createBackendHealthService();
      final result = await healthService.checkHealth();

      return result.fold(
        onSuccess: (status) {
          debugPrint('✅ Backend connectivity test passed: ${status.status}');
          // Consider backend reachable if it responds, regardless of health status
          return true;
        },
        onFailure: (error) {
          debugPrint('❌ Backend connectivity test failed: $error');
          return false;
        },
      );
    } catch (e) {
      debugPrint('❌ Backend connectivity test error: $e');
      return false;
    }
  }
}
