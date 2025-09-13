import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/core/network/dio_api_client.dart';
import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/core/security/secure_session_manager.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([Dio, SecureSessionManager])
void main() {
  group('DioApiClient', () {
    late MockDio mockDio;
    late MockSecureSessionManager mockSessionManager;
    late DioApiClient apiClient;

    setUp(() {
      mockDio = MockDio();
      mockSessionManager = MockSecureSessionManager();

      // Mock the options property
      when(mockDio.options).thenReturn(BaseOptions());
      when(mockDio.interceptors).thenReturn(Interceptors());

      // Mock session manager methods
      when(mockSessionManager.validateSession()).thenAnswer((_) async => SessionValidationResult.valid());
      when(mockSessionManager.getAccessToken()).thenAnswer((_) async => 'test_token');
      when(mockSessionManager.updateActivity()).thenAnswer((_) async {});

      apiClient = DioApiClient(
        sessionManager: mockSessionManager,
        dio: mockDio,
      );
    });

    group('GET requests', () {
      test('should return ApiSuccess for successful GET request', () async {
        // Arrange
        const endpoint = '/api/users';
        final responseData = {'users': []};
        final response = Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 200,
          data: responseData,
        );

        when(mockDio.get(
          endpoint,
          queryParameters: any,
          options: any,
        )).thenAnswer((_) async => response);

        // Act
        final result = await apiClient.get<Map<String, dynamic>>(endpoint);

        // Assert
        expect(result, isA<ApiSuccess<Map<String, dynamic>>>());
        expect(result.data, equals(responseData));
      });

      test('should return ApiFailure for failed GET request', () async {
        // Arrange
        const endpoint = '/api/users';
        final dioException = DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: Response(
            requestOptions: RequestOptions(path: endpoint),
            statusCode: 404,
            statusMessage: 'Not Found',
          ),
          type: DioExceptionType.badResponse,
        );

        when(mockDio.get(
          endpoint,
          queryParameters: any,
          options: any,
        )).thenThrow(dioException);

        // Act
        final result = await apiClient.get<Map<String, dynamic>>(endpoint);

        // Assert
        expect(result, isA<ApiFailure<Map<String, dynamic>>>());
      });
    });

    group('POST requests', () {
      test('should return ApiSuccess for successful POST request', () async {
        // Arrange
        const endpoint = '/api/users';
        final requestData = {'name': 'John Doe'};
        final responseData = {'id': '1', 'name': 'John Doe'};
        final response = Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 201,
          data: responseData,
        );

        when(mockDio.post(
          endpoint,
          data: any,
          queryParameters: any,
          options: any,
        )).thenAnswer((_) async => response);

        // Act
        final result = await apiClient.post<Map<String, dynamic>>(
          endpoint,
          data: requestData,
        );

        // Assert
        expect(result, isA<ApiSuccess<Map<String, dynamic>>>());
        expect(result.data, equals(responseData));
      });
    });

    group('File upload', () {
      test('should handle file upload successfully', () async {
        // Arrange
        const endpoint = '/api/upload';
        const filePath = '/path/to/file.jpg';
        final responseData = {'url': 'https://example.com/file.jpg'};
        final response = Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 200,
          data: responseData,
        );

        // Create a temporary file for testing
        final tempFile = File(filePath);
        await tempFile.create(recursive: true);
        await tempFile.writeAsString('test content');

        when(mockDio.post(
          endpoint,
          data: any,
          options: any,
        )).thenAnswer((_) async => response);

        // Act
        final result = await apiClient.uploadFile<Map<String, dynamic>>(
          endpoint,
          filePath,
        );

        // Assert
        expect(result, isA<ApiSuccess<Map<String, dynamic>>>());
        expect(result.data, equals(responseData));

        // Cleanup
        await tempFile.delete();
      });
    });
  });
}
