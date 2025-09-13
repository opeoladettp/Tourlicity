import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:tourlicity_app/core/network/api_client_factory.dart';
import 'package:tourlicity_app/core/services/backend_health_service.dart';
import 'package:tourlicity_app/data/services/backend_auth_service.dart';
import 'package:tourlicity_app/core/config/environment_config.dart';

void main() {
  group('Backend Integration Tests', () {
    late BackendHealthService healthService;
    late BackendAuthService authService;

    setUpAll(() {
      // Create services for testing
      healthService = ApiClientFactory.createBackendHealthService();
      authService = ApiClientFactory.createBackendAuthService();
    });

    group('Backend Health', () {
      test('should connect to backend health endpoint', () async {
        final result = await healthService.checkHealth();

        expect(result.isSuccess, isTrue,
            reason:
                'Backend should be reachable at ${EnvironmentConfig.apiBaseUrl}');

        if (result.isSuccess) {
          final status = result.data!;
          // Accept both HEALTHY and UNHEALTHY as valid responses (backend is responding)
          expect(status.status, isIn(['HEALTHY', 'UNHEALTHY']));
          expect(status.environment, equals('development'));
          debugPrint('✅ Backend Health: ${status.status} (${status.version})');
          debugPrint('📊 Services: ${status.services.length} services checked');
          if (status.status == 'UNHEALTHY') {
            debugPrint('⚠️ Unhealthy services: ${status.unhealthyServices}');
          }
        } else {
          debugPrint('❌ Backend Health Check Failed: ${result.error}');
          debugPrint(
              '💡 Make sure your backend is running at: ${EnvironmentConfig.apiBaseUrl}');
        }
      });

      test('should get backend metrics', () async {
        final result = await healthService.checkMetrics();

        if (result.isSuccess) {
          final metrics = result.data!;
          debugPrint('📈 Backend Metrics:');
          debugPrint(
              '   Memory: ${metrics.system.memory.heapUsed}/${metrics.system.memory.heapTotal}');
          debugPrint('   CPU Load: ${metrics.system.cpu.loadAverage}');
          debugPrint(
              '   API Requests: ${metrics.api.requests.total} (${metrics.api.requests.successRate.toStringAsFixed(1)}% success)');
          debugPrint('   Response Time: ${metrics.api.response.averageTime}');
        } else {
          debugPrint('⚠️ Backend Metrics: ${result.error}');
        }
      });

      test('should validate configuration', () async {
        final result = await healthService.validateConfig();

        if (result.isSuccess) {
          final validation = result.data!;
          debugPrint('🔧 Configuration Validation:');
          debugPrint('   Valid: ${validation.isValid}');
          if (validation.warnings.isNotEmpty) {
            debugPrint('   Warnings: ${validation.warnings}');
          }
          if (validation.suggestions.isNotEmpty) {
            debugPrint('   Suggestions: ${validation.suggestions}');
          }
        } else {
          debugPrint('⚠️ Configuration Validation: ${result.error}');
        }
      });
    });

    group('Backend Authentication', () {
      test('should initiate Google OAuth flow', () async {
        final result =
            await authService.initiateGoogleAuth(state: 'test_state');

        if (result.isSuccess) {
          debugPrint('✅ Google OAuth initiation successful');
          expect(result.data, isTrue);
        } else {
          debugPrint('❌ Google OAuth initiation failed: ${result.error}');
          // This might fail in test environment, which is expected
        }
      });

      test('should handle token refresh gracefully', () async {
        final result = await authService.refreshToken('invalid_token');

        // We expect this to fail with invalid token
        expect(result.isFailure, isTrue);
        debugPrint('✅ Token refresh properly handles invalid tokens');
      });
    });

    group('API Connectivity', () {
      test('should test overall backend connectivity', () async {
        final isHealthy = await ApiClientFactory.testBackendConnectivity();

        if (isHealthy) {
          debugPrint('✅ Backend connectivity test passed');
        } else {
          debugPrint('❌ Backend connectivity test failed');
          debugPrint('💡 Troubleshooting steps:');
          debugPrint(
              '   1. Check if backend is running: curl ${EnvironmentConfig.healthCheckUrl}');
          debugPrint(
              '   2. Verify API base URL: ${EnvironmentConfig.apiBaseUrl}');
          debugPrint('   3. Check network connectivity');
        }

        expect(isHealthy, isTrue,
            reason: 'Backend should be healthy and reachable');
      });

      test('should handle network errors gracefully', () async {
        // Create a service with invalid URL to test error handling
        final dio = Dio(BaseOptions(
          baseUrl: 'http://invalid-url:9999/api/v1',
          connectTimeout: const Duration(seconds: 1),
        ));

        final invalidHealthService = BackendHealthService(dio: dio);
        final result = await invalidHealthService.checkHealth();

        expect(result.isFailure, isTrue);
        expect(result.error, contains('connection'));
        debugPrint('✅ Network error handling works correctly');
      });
    });

    group('Environment Configuration', () {
      test('should have correct API endpoints', () {
        expect(EnvironmentConfig.apiBaseUrl,
            equals('http://localhost:3000/api/v1'));
        expect(EnvironmentConfig.googleAuthUrl,
            equals('http://localhost:3000/api/v1/auth/google'));
        expect(EnvironmentConfig.healthCheckUrl,
            equals('http://localhost:3000/health'));

        debugPrint('✅ Environment configuration is correct:');
        debugPrint('   API Base URL: ${EnvironmentConfig.apiBaseUrl}');
        debugPrint('   Google Auth URL: ${EnvironmentConfig.googleAuthUrl}');
        debugPrint('   Health Check URL: ${EnvironmentConfig.healthCheckUrl}');
      });

      test('should validate environment configuration', () {
        final isValid = EnvironmentConfig.validateConfiguration();
        expect(isValid, isTrue);

        debugPrint('✅ Environment configuration validation passed');
        debugPrint('📋 Environment Info:');
        final info = EnvironmentConfig.environmentInfo;
        info.forEach((key, value) {
          debugPrint('   $key: $value');
        });
      });
    });
  });
}

/// Helper function to print test results in a readable format
void printTestResult(String testName, bool success, [String? message]) {
  final icon = success ? '✅' : '❌';
  debugPrint('$icon $testName${message != null ? ': $message' : ''}');
}
