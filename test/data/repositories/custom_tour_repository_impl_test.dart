import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:tourlicity_app/core/network/api_client.dart';
import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/data/repositories/custom_tour_repository_impl.dart';
import 'package:tourlicity_app/domain/entities/custom_tour.dart';

import 'custom_tour_repository_impl_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late CustomTourRepositoryImpl repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = CustomTourRepositoryImpl(mockApiClient);
  });

  group('CustomTourRepositoryImpl', () {
    final customTour = CustomTour(
      id: 'tour1',
      providerId: 'provider1',
      tourTemplateId: 'template1',
      tourName: 'Amazing Tour',
      joinCode: 'ABC123',
      startDate: DateTime.parse('2024-06-01T09:00:00Z'),
      endDate: DateTime.parse('2024-06-05T18:00:00Z'),
      maxTourists: 20,
      currentTourists: 5,
      pricePerPerson: 299.99,
      currency: 'USD',
      status: TourStatus.published,
      tags: const ['adventure', 'nature'],
      description: 'An amazing adventure tour',
      createdDate: DateTime.parse('2024-05-01T10:00:00Z'),
    );

    const customTourJson = {
      'id': 'tour1',
      'provider_id': 'provider1',
      'tour_template_id': 'template1',
      'tour_name': 'Amazing Tour',
      'join_code': 'ABC123',
      'start_date': '2024-06-01T09:00:00Z',
      'end_date': '2024-06-05T18:00:00Z',
      'max_tourists': 20,
      'current_tourists': 5,
      'price_per_person': 299.99,
      'currency': 'USD',
      'status': 'published',
      'tags': ['adventure', 'nature'],
      'description': 'An amazing adventure tour',
      'created_date': '2024-05-01T10:00:00Z',
    };

    group('getCustomTours', () {
      test('should return list of custom tours on success', () async {
        // Arrange
        when(mockApiClient.get<List<dynamic>>(
          '/custom-tours',
          queryParameters: any,
        )).thenAnswer((_) async => const ApiSuccess(data: [customTourJson]));

        // Act
        final result = await repository.getCustomTours();

        // Assert
        expect(result, isA<ApiSuccess<List<CustomTour>>>());
        final tours = (result as ApiSuccess<List<CustomTour>>).data;
        expect(tours, hasLength(1));
        expect(tours.first.id, 'tour1');
        expect(tours.first.tourName, 'Amazing Tour');
      });

      test('should pass query parameters correctly', () async {
        // Arrange
        when(mockApiClient.get<List<dynamic>>(
          '/custom-tours',
          queryParameters: any,
        )).thenAnswer((_) async => const ApiSuccess(data: []));

        // Act
        await repository.getCustomTours(
          providerId: 'provider1',
          status: TourStatus.published,
          page: 1,
          limit: 10,
        );

        // Assert
        verify(mockApiClient.get<List<dynamic>>(
          '/custom-tours',
          queryParameters: {
            'provider_id': 'provider1',
            'status': 'published',
            'page': 1,
            'limit': 10,
          },
        ));
      });
    });

    group('getCustomTourById', () {
      test('should return custom tour on success', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>('/custom-tours/tour1'))
            .thenAnswer((_) async => const ApiSuccess(data: customTourJson));

        // Act
        final result = await repository.getCustomTourById('tour1');

        // Assert
        expect(result, isA<ApiSuccess<CustomTour>>());
        final tour = (result as ApiSuccess<CustomTour>).data;
        expect(tour.id, 'tour1');
        expect(tour.tourName, 'Amazing Tour');
      });
    });

    group('getCustomTourByJoinCode', () {
      test('should return custom tour on success', () async {
        // Arrange
        when(mockApiClient
                .get<Map<String, dynamic>>('/custom-tours/join/ABC123'))
            .thenAnswer((_) async => const ApiSuccess(data: customTourJson));

        // Act
        final result = await repository.getCustomTourByJoinCode('ABC123');

        // Assert
        expect(result, isA<ApiSuccess<CustomTour>>());
        final tour = (result as ApiSuccess<CustomTour>).data;
        expect(tour.joinCode, 'ABC123');
      });
    });

    group('createCustomTour', () {
      test('should create custom tour successfully', () async {
        // Arrange
        when(mockApiClient.post<Map<String, dynamic>>(
          '/custom-tours',
          data: any,
        )).thenAnswer((_) async => const ApiSuccess(data: customTourJson));

        // Act
        final result = await repository.createCustomTour(customTour);

        // Assert
        expect(result, isA<ApiSuccess<CustomTour>>());
        verify(mockApiClient.post<Map<String, dynamic>>(
          '/custom-tours',
          data: any,
        ));
      });
    });

    group('updateCustomTour', () {
      test('should update custom tour successfully', () async {
        // Arrange
        when(mockApiClient.put<Map<String, dynamic>>(
          '/custom-tours/tour1',
          data: any,
        )).thenAnswer((_) async => const ApiSuccess(data: customTourJson));

        // Act
        final result = await repository.updateCustomTour(customTour);

        // Assert
        expect(result, isA<ApiSuccess<CustomTour>>());
        verify(mockApiClient.put<Map<String, dynamic>>(
          '/custom-tours/tour1',
          data: any,
        ));
      });
    });

    group('deleteCustomTour', () {
      test('should delete custom tour successfully', () async {
        // Arrange
        when(mockApiClient.delete('/custom-tours/tour1'))
            .thenAnswer((_) async => const ApiSuccess(data: null));

        // Act
        final result = await repository.deleteCustomTour('tour1');

        // Assert
        expect(result, isA<ApiSuccess<void>>());
        verify(mockApiClient.delete('/custom-tours/tour1'));
      });
    });

    group('updateTourStatus', () {
      test('should update tour status successfully', () async {
        // Arrange
        final updatedTourJson = Map<String, dynamic>.from(customTourJson);
        updatedTourJson['status'] = 'active';

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/custom-tours/tour1/status',
          data: {'status': 'active'},
        )).thenAnswer((_) async => ApiSuccess(data: updatedTourJson));

        // Act
        final result =
            await repository.updateTourStatus('tour1', TourStatus.active);

        // Assert
        expect(result, isA<ApiSuccess<CustomTour>>());
        final tour = (result as ApiSuccess<CustomTour>).data;
        expect(tour.status, TourStatus.active);
      });
    });

    group('publishTour', () {
      test('should publish tour successfully', () async {
        // Arrange
        final publishedTourJson = Map<String, dynamic>.from(customTourJson);
        publishedTourJson['status'] = 'published';

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/custom-tours/tour1/status',
          data: {'status': 'published'},
        )).thenAnswer((_) async => ApiSuccess(data: publishedTourJson));

        // Act
        final result = await repository.publishTour('tour1');

        // Assert
        expect(result, isA<ApiSuccess<CustomTour>>());
        final tour = (result as ApiSuccess<CustomTour>).data;
        expect(tour.status, TourStatus.published);
      });
    });

    group('updateTouristCount', () {
      test('should update tourist count successfully', () async {
        // Arrange
        final updatedTourJson = Map<String, dynamic>.from(customTourJson);
        updatedTourJson['current_tourists'] = 10;

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/custom-tours/tour1/tourist-count',
          data: {'current_tourists': 10},
        )).thenAnswer((_) async => ApiSuccess(data: updatedTourJson));

        // Act
        final result = await repository.updateTouristCount('tour1', 10);

        // Assert
        expect(result, isA<ApiSuccess<CustomTour>>());
        final tour = (result as ApiSuccess<CustomTour>).data;
        expect(tour.currentTourists, 10);
      });
    });

    group('generateNewJoinCode', () {
      test('should generate new join code successfully', () async {
        // Arrange
        final updatedTourJson = Map<String, dynamic>.from(customTourJson);
        updatedTourJson['join_code'] = 'XYZ789';

        when(mockApiClient.post<Map<String, dynamic>>(
          '/custom-tours/tour1/generate-join-code',
        )).thenAnswer((_) async => ApiSuccess(data: updatedTourJson));

        // Act
        final result = await repository.generateNewJoinCode('tour1');

        // Assert
        expect(result, isA<ApiSuccess<CustomTour>>());
        final tour = (result as ApiSuccess<CustomTour>).data;
        expect(tour.joinCode, 'XYZ789');
      });
    });

    group('searchTours', () {
      test('should search tours with all parameters', () async {
        // Arrange
        when(mockApiClient.get<List<dynamic>>(
          '/custom-tours/search',
          queryParameters: any,
        )).thenAnswer((_) async => const ApiSuccess(data: [customTourJson]));

        // Act
        final result = await repository.searchTours(
          query: 'adventure',
          tags: ['nature', 'hiking'],
          startDateFrom: DateTime.parse('2024-06-01T00:00:00Z'),
          startDateTo: DateTime.parse('2024-06-30T23:59:59Z'),
          minPrice: 100.0,
          maxPrice: 500.0,
          status: TourStatus.published,
          page: 1,
          limit: 20,
        );

        // Assert
        expect(result, isA<ApiSuccess<List<CustomTour>>>());
        verify(mockApiClient.get<List<dynamic>>(
          '/custom-tours/search',
          queryParameters: {
            'q': 'adventure',
            'tags': 'nature,hiking',
            'start_date_from': '2024-06-01T00:00:00.000Z',
            'start_date_to': '2024-06-30T23:59:59.000Z',
            'min_price': 100.0,
            'max_price': 500.0,
            'status': 'published',
            'page': 1,
            'limit': 20,
          },
        ));
      });

      test('should search tours with minimal parameters', () async {
        // Arrange
        when(mockApiClient.get<List<dynamic>>(
          '/custom-tours/search',
          queryParameters: any,
        )).thenAnswer((_) async => const ApiSuccess(data: [customTourJson]));

        // Act
        final result = await repository.searchTours(query: 'adventure');

        // Assert
        expect(result, isA<ApiSuccess<List<CustomTour>>>());
        verify(mockApiClient.get<List<dynamic>>(
          '/custom-tours/search',
          queryParameters: {'q': 'adventure'},
        ));
      });
    });
  });
}
