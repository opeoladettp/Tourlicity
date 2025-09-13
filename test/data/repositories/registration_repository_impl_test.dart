import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:tourlicity_app/core/network/api_client.dart';
import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/data/repositories/registration_repository_impl.dart';
import 'package:tourlicity_app/domain/entities/registration.dart';

class MockApiClient extends Mock implements ApiClient {
  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#get, [path], {
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#post, [path], {
          #data: data,
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#patch, [path], {
          #data: data,
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#put, [path], {
          #data: data,
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#delete, [path], {
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#uploadFile, [path, filePath], {
          #fieldName: fieldName,
          #fields: fields,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );
}

void main() {
  group('RegistrationRepositoryImpl', () {
    late RegistrationRepositoryImpl repository;
    late MockApiClient mockApiClient;

    // Test registration data for API responses (used in test setup)

    final testRegistrationJson = {
      'id': '1',
      'custom_tour_id': 'tour-1',
      'tourist_id': 'tourist-1',
      'status': 'pending',
      'confirmation_code': 'CONF123',
      'special_requirements': 'Wheelchair accessible',
      'emergency_contact_name': 'Jane Doe',
      'emergency_contact_phone': '+1234567890',
      'registration_date': '2024-01-01T00:00:00.000Z',
      'approval_notes': null,
      'rejection_reason': null,
      'status_updated_date': null,
    };

    setUp(() {
      mockApiClient = MockApiClient();
      repository = RegistrationRepositoryImpl(apiClient: mockApiClient);
    });

    group('registerForTour', () {
      test('should return registration when API call is successful', () async {
        // Arrange
        when(mockApiClient.post<Map<String, dynamic>>(
          '/registrations',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: testRegistrationJson));

        // Act
        final result = await repository.registerForTour(
          joinCode: 'JOIN123',
          touristId: 'tourist-1',
          specialRequirements: 'Wheelchair accessible',
          emergencyContactName: 'Jane Doe',
          emergencyContactPhone: '+1234567890',
        );

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());
        final registration = result.data!;
        expect(registration.id, '1');
        expect(registration.customTourId, 'tour-1');
        expect(registration.touristId, 'tourist-1');
        expect(registration.status, RegistrationStatus.pending);
        expect(registration.confirmationCode, 'CONF123');
        expect(registration.specialRequirements, 'Wheelchair accessible');
        expect(registration.emergencyContactName, 'Jane Doe');
        expect(registration.emergencyContactPhone, '+1234567890');

        // Verify API call
        verify(mockApiClient.post<Map<String, dynamic>>(
          '/registrations',
          data: {
            'join_code': 'JOIN123',
            'tourist_id': 'tourist-1',
            'special_requirements': 'Wheelchair accessible',
            'emergency_contact_name': 'Jane Doe',
            'emergency_contact_phone': '+1234567890',
          },
        )).called(1);
      });

      test('should return failure when API call fails', () async {
        // Arrange
        when(mockApiClient.post<Map<String, dynamic>>(
          '/registrations',
          data: any,
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Invalid join code',
              statusCode: 400,
            ));

        // Act
        final result = await repository.registerForTour(
          joinCode: 'INVALID',
          touristId: 'tourist-1',
        );

        // Assert
        expect(result, isA<ApiFailure<Registration>>());
        expect(result.error, 'Invalid join code');
      });

      test('should handle minimal registration data', () async {
        // Arrange
        when(mockApiClient.post<Map<String, dynamic>>(
          '/registrations',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: testRegistrationJson));

        // Act
        final result = await repository.registerForTour(
          joinCode: 'JOIN123',
          touristId: 'tourist-1',
        );

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());

        // Verify API call with minimal data
        verify(mockApiClient.post<Map<String, dynamic>>(
          '/registrations',
          data: {
            'join_code': 'JOIN123',
            'tourist_id': 'tourist-1',
          },
        )).called(1);
      });
    });

    group('getRegistrationById', () {
      test('should return registration when API call is successful', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations/1',
        )).thenAnswer((_) async => ApiSuccess(data: testRegistrationJson));

        // Act
        final result = await repository.getRegistrationById('1');

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());
        final registration = result.data!;
        expect(registration.id, '1');
        expect(registration.customTourId, 'tour-1');
      });

      test('should return failure when registration not found', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations/999',
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Registration not found',
              statusCode: 404,
            ));

        // Act
        final result = await repository.getRegistrationById('999');

        // Assert
        expect(result, isA<ApiFailure<Registration>>());
        expect(result.error, 'Registration not found');
      });
    });

    group('getRegistrationsByTourist', () {
      test('should return list of registrations when API call is successful', () async {
        // Arrange
        final registrationsResponse = {
          'registrations': [testRegistrationJson],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: registrationsResponse));

        // Act
        final result = await repository.getRegistrationsByTourist(
          'tourist-1',
          status: RegistrationStatus.pending,
          limit: 10,
          offset: 0,
        );

        // Assert
        expect(result, isA<ApiSuccess<List<Registration>>>());
        final registrations = result.data!;
        expect(registrations.length, 1);
        expect(registrations.first.id, '1');

        // Verify API call with query parameters
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/registrations',
          queryParameters: {
            'tourist_id': 'tourist-1',
            'status': 'pending',
            'limit': 10,
            'offset': 0,
          },
        )).called(1);
      });

      test('should return empty list when no registrations found', () async {
        // Arrange
        final registrationsResponse = {
          'registrations': <Map<String, dynamic>>[],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: registrationsResponse));

        // Act
        final result = await repository.getRegistrationsByTourist('tourist-1');

        // Assert
        expect(result, isA<ApiSuccess<List<Registration>>>());
        final registrations = result.data!;
        expect(registrations.isEmpty, true);
      });
    });

    group('getRegistrationsByTour', () {
      test('should return list of registrations for tour', () async {
        // Arrange
        final registrationsResponse = {
          'registrations': [testRegistrationJson],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: registrationsResponse));

        // Act
        final result = await repository.getRegistrationsByTour('tour-1');

        // Assert
        expect(result, isA<ApiSuccess<List<Registration>>>());
        final registrations = result.data!;
        expect(registrations.length, 1);
        expect(registrations.first.customTourId, 'tour-1');

        // Verify API call
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/registrations',
          queryParameters: {
            'custom_tour_id': 'tour-1',
          },
        )).called(1);
      });
    });

    group('approveRegistration', () {
      test('should return approved registration when API call is successful', () async {
        // Arrange
        final approvedRegistrationJson = {
          ...testRegistrationJson,
          'status': 'approved',
          'approval_notes': 'Approved with conditions',
          'status_updated_date': '2024-01-02T00:00:00.000Z',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: approvedRegistrationJson));

        // Act
        final result = await repository.approveRegistration("registration-1");

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());
        final registration = result.data!;
        expect(registration.status, RegistrationStatus.approved);
        expect(registration.approvalNotes, 'Approved with conditions');

        // Verify API call
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: {
            'status': 'approved',
            'approval_notes': 'Approved with conditions',
          },
        )).called(1);
      });

      test('should approve without notes', () async {
        // Arrange
        final approvedRegistrationJson = {
          ...testRegistrationJson,
          'status': 'approved',
          'status_updated_date': '2024-01-02T00:00:00.000Z',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: approvedRegistrationJson));

        // Act
        final result = await repository.approveRegistration("registration-1");

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());

        // Verify API call without notes
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: {
            'status': 'approved',
          },
        )).called(1);
      });
    });

    group('rejectRegistration', () {
      test('should return rejected registration when API call is successful', () async {
        // Arrange
        final rejectedRegistrationJson = {
          ...testRegistrationJson,
          'status': 'rejected',
          'rejection_reason': 'Tour is full',
          'status_updated_date': '2024-01-02T00:00:00.000Z',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: rejectedRegistrationJson));

        // Act
        final result = await repository.rejectRegistration("registration-1", reason: "Tour is full");

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());
        final registration = result.data!;
        expect(registration.status, RegistrationStatus.rejected);
        expect(registration.rejectionReason, 'Tour is full');

        // Verify API call
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: {
            'status': 'rejected',
            'rejection_reason': 'Tour is full',
          },
        )).called(1);
      });
    });

    group('cancelRegistration', () {
      test('should return cancelled registration when API call is successful', () async {
        // Arrange
        final cancelledRegistrationJson = {
          ...testRegistrationJson,
          'status': 'cancelled',
          'status_updated_date': '2024-01-02T00:00:00.000Z',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: cancelledRegistrationJson));

        // Act
        final result = await repository.cancelRegistration("registration-1");

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());
        final registration = result.data!;
        expect(registration.status, RegistrationStatus.cancelled);

        // Verify API call
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: {
            'status': 'cancelled',
          },
        )).called(1);
      });
    });

    group('updateRegistration', () {
      test('should return updated registration when API call is successful', () async {
        // Arrange
        final updatedRegistrationJson = {
          ...testRegistrationJson,
          'special_requirements': 'Updated requirements',
          'emergency_contact_name': 'John Smith',
          'emergency_contact_phone': '+0987654321',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: updatedRegistrationJson));

        // Act
        final result = await repository.updateRegistration("registration-1");

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());
        final registration = result.data!;
        expect(registration.specialRequirements, 'Updated requirements');
        expect(registration.emergencyContactName, 'John Smith');
        expect(registration.emergencyContactPhone, '+0987654321');

        // Verify API call
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1',
          data: {
            'special_requirements': 'Updated requirements',
            'emergency_contact_name': 'John Smith',
            'emergency_contact_phone': '+0987654321',
          },
        )).called(1);
      });
    });

    group('getRegistrationByConfirmationCode', () {
      test('should return registration when API call is successful', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations/confirmation/CONF123',
        )).thenAnswer((_) async => ApiSuccess(data: testRegistrationJson));

        // Act
        final result = await repository.getRegistrationByConfirmationCode('CONF123');

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());
        final registration = result.data!;
        expect(registration.confirmationCode, 'CONF123');
      });

      test('should return failure when confirmation code not found', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations/confirmation/INVALID',
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Confirmation code not found',
              statusCode: 404,
            ));

        // Act
        final result = await repository.getRegistrationByConfirmationCode('INVALID');

        // Assert
        expect(result, isA<ApiFailure<Registration>>());
        expect(result.error, 'Confirmation code not found');
      });
    });

    group('completeRegistration', () {
      test('should return completed registration when API call is successful', () async {
        // Arrange
        final completedRegistrationJson = {
          ...testRegistrationJson,
          'status': 'completed',
          'status_updated_date': '2024-01-02T00:00:00.000Z',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: completedRegistrationJson));

        // Act
        final result = await repository.completeRegistration("registration-1");

        // Assert
        expect(result, isA<ApiSuccess<Registration>>());
        final registration = result.data!;
        expect(registration.status, RegistrationStatus.completed);

        // Verify API call
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/registrations/1/status',
          data: {
            'status': 'completed',
          },
        )).called(1);
      });
    });

    group('getRegistrationStats', () {
      test('should return registration statistics when API call is successful', () async {
        // Arrange
        final statsResponse = {
          'pending': 5,
          'approved': 10,
          'rejected': 2,
          'cancelled': 1,
          'completed': 8,
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations/stats/tour-1',
        )).thenAnswer((_) async => ApiSuccess(data: statsResponse));

        // Act
        final result = await repository.getRegistrationStats('tour-1');

        // Assert
        expect(result, isA<ApiSuccess<Map<String, int>>>());
        final stats = result.data!;
        expect(stats['pending'], 5);
        expect(stats['approved'], 10);
        expect(stats['rejected'], 2);
        expect(stats['cancelled'], 1);
        expect(stats['completed'], 8);
      });

      test('should return failure when API call fails', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/registrations/stats/tour-1',
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Tour not found',
              statusCode: 404,
            ));

        // Act
        final result = await repository.getRegistrationStats('tour-1');

        // Assert
        expect(result, isA<ApiFailure<Map<String, int>>>());
        expect(result.error, 'Tour not found');
      });
    });

    group('error handling', () {
      test('should handle exceptions and return failure', () async {
        // Arrange
        when(mockApiClient.post<Map<String, dynamic>>(
          '/registrations',
          data: any,
        )).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.registerForTour(
          joinCode: 'JOIN123',
          touristId: 'tourist-1',
        );

        // Assert
        expect(result, isA<ApiFailure<Registration>>());
        expect(result.error, contains('Failed to register for tour'));
      });
    });
  });
}