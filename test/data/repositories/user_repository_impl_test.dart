import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:tourlicity_app/core/network/api_client.dart';
import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/data/repositories/user_repository_impl.dart';
import 'package:tourlicity_app/domain/entities/user.dart';
import 'package:tourlicity_app/domain/entities/user_type.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('UserRepositoryImpl', () {
    late UserRepositoryImpl repository;
    late MockApiClient mockApiClient;

    final testUser = User(
      id: '1',
      email: 'test@example.com',
      name: 'John Doe',
      role: UserRole.tourist,
      isProfileComplete: true,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

    setUp(() {
      mockApiClient = MockApiClient();
      repository = UserRepositoryImpl(apiClient: mockApiClient);
    });

    group('getCurrentUser', () {
      test('should return current user when API call is successful', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/users/me',
        )).thenAnswer((_) async => const ApiSuccess(
              data: {
                'id': '1',
                'email': 'test@example.com',
                'name': 'John Doe',
                'role': 'tourist',
                'isProfileComplete': true,
                'createdAt': '2024-01-01T00:00:00Z',
              },
            ));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<ApiSuccess<User>>());
        final user = result.data!;
        expect(user.id, '1');
        expect(user.email, 'test@example.com');
        expect(user.name, 'John Doe');
        expect(user.role, UserRole.tourist);
      });

      test('should return failure when API call fails', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/users/me',
        )).thenAnswer((_) async => const ApiFailure(
              message: 'User not found',
              statusCode: 404,
            ));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<ApiFailure<User>>());
        expect(result.error, 'User not found');
      });
    });

    group('updateProfile', () {
      test('should return updated user when API call is successful', () async {
        // Arrange
        when(mockApiClient.patch<Map<String, dynamic>>(
          '/users/me',
          data: any,
        )).thenAnswer((_) async => const ApiSuccess(
              data: {
                'id': '1',
                'email': 'test@example.com',
                'name': 'John Updated',
                'role': 'tourist',
                'isProfileComplete': true,
                'createdAt': '2024-01-01T00:00:00Z',
              },
            ));

        // Act
        final result = await repository.updateProfile(
          firstName: 'John',
          lastName: 'Updated',
          phone: '+1234567890',
        );

        // Assert
        expect(result, isA<ApiSuccess<User>>());
        final user = result.data!;
        expect(user.name, 'John Updated');
      });

      test('should return failure when API call fails', () async {
        // Arrange
        when(mockApiClient.patch<Map<String, dynamic>>(
          '/users/me',
          data: any,
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Update failed',
              statusCode: 400,
            ));

        // Act
        final result = await repository.updateProfile(
          firstName: 'John',
          lastName: 'Updated',
        );

        // Assert
        expect(result, isA<ApiFailure<User>>());
        expect(result.error, 'Update failed');
      });
    });

    group('completeProfile', () {
      test('should return completed profile when API call is successful',
          () async {
        // Arrange
        when(mockApiClient.patch<Map<String, dynamic>>(
          '/users/me/complete-profile',
          data: any,
        )).thenAnswer((_) async => const ApiSuccess(
              data: {
                'id': '1',
                'email': 'test@example.com',
                'name': 'John Completed',
                'role': 'tourist',
                'isProfileComplete': true,
                'createdAt': '2024-01-01T00:00:00Z',
              },
            ));

        // Act
        final result = await repository.completeProfile(
          firstName: 'John',
          lastName: 'Completed',
          phone: '+1234567890',
        );

        // Assert
        expect(result, isA<ApiSuccess<User>>());
        final user = result.data!;
        expect(user.name, 'John Completed');
        expect(user.isProfileComplete, true);
      });
    });

    group('getUserProfile', () {
      test('should return user profile when API call is successful', () async {
        // Arrange
        const userId = '1';
        when(mockApiClient.get<Map<String, dynamic>>(
          '/users/$userId',
        )).thenAnswer((_) async => const ApiSuccess(
              data: {
                'id': '1',
                'email': 'test@example.com',
                'name': 'John Doe',
                'role': 'tourist',
                'isProfileComplete': true,
                'createdAt': '2024-01-01T00:00:00Z',
              },
            ));

        // Act
        final result = await repository.getUserProfile(userId);

        // Assert
        expect(result, isA<ApiSuccess<User>>());
        final user = result.data!;
        expect(user.id, '1');
        expect(user.name, 'John Doe');
      });
    });

    group('updateUserProfile', () {
      test('should return updated user when API call is successful', () async {
        // Arrange
        when(mockApiClient.put<Map<String, dynamic>>(
          '/users/${testUser.id}',
          data: any,
        )).thenAnswer((_) async => const ApiSuccess(
              data: {
                'id': '1',
                'email': 'test@example.com',
                'name': 'John Updated',
                'role': 'tourist',
                'isProfileComplete': true,
                'createdAt': '2024-01-01T00:00:00Z',
              },
            ));

        // Act
        final result = await repository.updateUserProfile(testUser);

        // Assert
        expect(result, isA<ApiSuccess<User>>());
        final user = result.data!;
        expect(user.name, 'John Updated');
      });
    });

    group('deleteUserAccount', () {
      test('should return success when API call is successful', () async {
        // Arrange
        const userId = '1';
        when(mockApiClient.delete<void>(
          '/users/$userId',
        )).thenAnswer((_) async => const ApiSuccess(data: null));

        // Act
        final result = await repository.deleteUserAccount(userId);

        // Assert
        expect(result, isA<ApiSuccess<void>>());
      });

      test('should return failure when API call fails', () async {
        // Arrange
        const userId = '1';
        when(mockApiClient.delete<void>(
          '/users/$userId',
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Delete failed',
              statusCode: 400,
            ));

        // Act
        final result = await repository.deleteUserAccount(userId);

        // Assert
        expect(result, isA<ApiFailure<void>>());
        expect(result.error, 'Delete failed');
      });
    });

    group('isProfileComplete', () {
      test('should return true when profile is complete', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/users/me',
        )).thenAnswer((_) async => const ApiSuccess(
              data: {
                'id': '1',
                'email': 'test@example.com',
                'name': 'John Doe',
                'role': 'tourist',
                'isProfileComplete': true,
                'createdAt': '2024-01-01T00:00:00Z',
              },
            ));

        // Act
        final result = await repository.isProfileComplete();

        // Assert
        expect(result, isA<ApiSuccess<bool>>());
        expect(result.data, true);
      });
    });
  });
}
