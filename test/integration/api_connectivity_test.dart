import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dio/dio.dart';
import 'package:tourlicity_app/core/config/environment_config.dart';
import 'dart:developer' as developer;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('API Connectivity Tests', () {
    late Dio dio;

    setUpAll(() {
      dio = Dio();
    });

    testWidgets('Backend API is accessible', (WidgetTester tester) async {
      final baseUrl = EnvironmentConfig.apiBaseUrl;

      try {
        // Test basic connectivity
        final response = await dio.get('$baseUrl/health');
        expect(response.statusCode, equals(200));
        developer.log('✅ API Health Check: ${response.statusCode}',
            name: 'APITest');
      } catch (e) {
        developer.log('❌ API Health Check Failed: $e', name: 'APITest');
        developer.log('   Make sure your backend is running at $baseUrl',
            name: 'APITest');
        fail('Backend API is not accessible at $baseUrl');
      }
    });

    testWidgets('API returns proper error for invalid endpoint',
        (WidgetTester tester) async {
      final baseUrl = EnvironmentConfig.apiBaseUrl;

      try {
        await dio.get('$baseUrl/invalid-endpoint');
        fail('Expected 404 error for invalid endpoint');
      } on DioException catch (e) {
        expect(e.response?.statusCode, equals(404));
        developer.log('✅ API Error Handling: ${e.response?.statusCode}',
            name: 'APITest');
      }
    });

    testWidgets('Environment configuration is correct',
        (WidgetTester tester) async {
      expect(EnvironmentConfig.apiBaseUrl, contains('localhost:3000'));
      expect(EnvironmentConfig.apiBaseUrl, contains('/api/v1'));
      expect(EnvironmentConfig.isDevelopment, isTrue);
      developer.log('✅ Environment Config: ${EnvironmentConfig.apiBaseUrl}',
          name: 'APITest');
    });
  });
}
