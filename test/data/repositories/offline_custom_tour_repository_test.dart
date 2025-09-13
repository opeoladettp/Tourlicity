import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/core/network/api_client.dart';
import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/core/services/cache_service.dart';
import 'package:tourlicity_app/core/services/connectivity_service.dart';
import 'package:tourlicity_app/core/services/sync_service.dart';
import 'package:tourlicity_app/data/repositories/offline_custom_tour_repository_impl.dart';
import 'package:tourlicity_app/domain/entities/custom_tour.dart';

import 'offline_custom_tour_repository_test.mocks.dart';

@GenerateMocks([ApiClient, CacheService, ConnectivityService, SyncService])
void main() {
  late OfflineCustomTourRepositoryImpl repository;
  late MockApiClient mockApiClient;
  late MockCacheService mockCacheService;
  late MockConnectivityService mockConnectivityService;
  late MockSyncService mockSyncService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockCacheService = MockCacheService();
    mockConnectivityService = MockConnectivityService();
    mockSyncService = MockSyncService();

    repository = OfflineCustomTourRepositoryImpl(
      apiClient: mockApiClient,
      cacheService: mockCacheService,
      connectivityService: mockConnectivityService,
      syncService: mockSyncService,
    );
  });

  group('OfflineCustomTourRepositoryImpl', () {
    final sampleTourData = <String, dynamic>{
      'id': '1',
      'provider_id': 'provider1',
      'tour_template_id': 'template1',
      'tour_name': 'Test Tour',
      'join_code': 'ABC123',
      'start_date': '2024-01-01T00:00:00.000Z',
      'end_date': '2024-01-07T00:00:00.000Z',
      'max_tourists': 10,
      'current_tourists': 5,
      'price_per_person': 100.0,
      'currency': 'USD',
      'status': 'published',
      'tags': ['adventure', 'nature'],
      'description': 'A test tour',
      'created_date': '2024-01-01T00:00:00.000Z',
    };

    final sampleTourList = <Map<String, dynamic>>[sampleTourData];

    group('getCustomTours', () {
      test('should return cached tours when offline', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockCacheService.getCachedTours())
            .thenAnswer((_) async => sampleTourList);

        // Act
        final result = await repository.getCustomTours();

        // Assert
        expect(result.isSuccess, isTrue);
        final tours = result.data!;
        expect(tours, hasLength(1));
        expect(tours.first.id, equals('1'));
        expect(tours.first.tourName, equals('Test Tour'));
      });

      test('should fetch from API and cache when online', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(true);
        when(mockCacheService.getCachedTours())
            .thenAnswer((_) async => <Map<String, dynamic>>[]);
        when(mockApiClient.get<List<dynamic>>(
          '/custom-tours',
          queryParameters: argThat(isA<Map<String, dynamic>>(), named: 'queryParameters'),
        )).thenAnswer((_) async => ApiSuccess(data: sampleTourList));
        when(mockCacheService.cacheTours(sampleTourList))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getCustomTours();

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockCacheService.cacheTours(sampleTourList)).called(1);
      });

      test('should return cached data when API fails', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(true);
        when(mockCacheService.getCachedTours())
            .thenAnswer((_) async => sampleTourList);
        when(mockApiClient.get<List<dynamic>>(
          '/custom-tours',
          queryParameters: argThat(isA<Map<String, dynamic>>(), named: 'queryParameters'),
        )).thenAnswer((_) async => const ApiFailure(message: 'Network error'));

        // Act
        final result = await repository.getCustomTours();

        // Assert
        expect(result.isSuccess, isTrue);
        final tours = result.data!;
        expect(tours, hasLength(1));
      });
    });

    group('getCustomTourById', () {
      test('should return cached tour when offline', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockCacheService.getCachedData(
          table: 'cache_tours',
          key: '1',
        )).thenAnswer((_) async => sampleTourData);

        // Act
        final result = await repository.getCustomTourById('1');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.id, equals('1'));
      });

      test('should fetch from API when online', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(true);
        when(mockCacheService.getCachedData(
          table: 'cache_tours',
          key: '1',
        )).thenAnswer((_) async => null);
        when(mockApiClient.get<Map<String, dynamic>>('/custom-tours/1'))
            .thenAnswer((_) async => ApiSuccess(data: sampleTourData));
        when(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.getCustomTourById('1');

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).called(1);
      });
    });

    group('getCustomTourByJoinCode', () {
      test('should search cached tours when offline', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockCacheService.getCachedTours())
            .thenAnswer((_) async => sampleTourList);

        // Act
        final result = await repository.getCustomTourByJoinCode('ABC123');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.joinCode, equals('ABC123'));
      });

      test('should fetch from API when online', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(true);
        when(mockApiClient.get<Map<String, dynamic>>('/custom-tours/join/ABC123'))
            .thenAnswer((_) async => ApiSuccess(data: sampleTourData));
        when(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.getCustomTourByJoinCode('ABC123');

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).called(1);
      });
    });

    group('createCustomTour', () {
      test('should add to sync queue when offline', () async {
        // Arrange
        final tour = CustomTour(
          id: '1',
          providerId: 'provider1',
          tourTemplateId: 'template1',
          tourName: 'Test Tour',
          joinCode: 'ABC123',
          startDate: DateTime.parse('2024-01-01'),
          endDate: DateTime.parse('2024-01-07'),
          maxTourists: 10,
          currentTourists: 0,
          pricePerPerson: 100.0,
          currency: 'USD',
          status: TourStatus.draft,
          tags: const ['adventure'],
          createdDate: DateTime.parse('2024-01-01'),
        );

        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockSyncService.addToSyncQueue(
          endpoint: '/custom-tours',
          method: 'POST',
          data: argThat(isA<Map<String, dynamic>?>(), named: 'data'),
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.createCustomTour(tour);

        // Assert
        expect(result.isFailure, isTrue);
        verify(mockSyncService.addToSyncQueue(
          endpoint: '/custom-tours',
          method: 'POST',
          data: argThat(isA<Map<String, dynamic>?>(), named: 'data'),
        )).called(1);
      });

      test('should create via API when online', () async {
        // Arrange
        final tour = CustomTour(
          id: '1',
          providerId: 'provider1',
          tourTemplateId: 'template1',
          tourName: 'Test Tour',
          joinCode: 'ABC123',
          startDate: DateTime.parse('2024-01-01'),
          endDate: DateTime.parse('2024-01-07'),
          maxTourists: 10,
          currentTourists: 0,
          pricePerPerson: 100.0,
          currency: 'USD',
          status: TourStatus.draft,
          tags: const ['adventure'],
          createdDate: DateTime.parse('2024-01-01'),
        );

        when(mockConnectivityService.isOnline).thenReturn(true);
        when(mockApiClient.post<Map<String, dynamic>>(
          '/custom-tours',
          data: argThat(isA<Map<String, dynamic>>(), named: 'data'),
        )).thenAnswer((_) async => ApiSuccess(data: sampleTourData));
        when(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.createCustomTour(tour);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).called(1);
      });
    });

    group('updateTourStatus', () {
      test('should update cache optimistically when offline', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).thenAnswer((_) async {});
        when(mockSyncService.addToSyncQueue(
          endpoint: '/custom-tours/1/status',
          method: 'PUT',
          data: argThat(isA<Map<String, dynamic>?>(), named: 'data'),
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.updateTourStatus('1', TourStatus.published);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockSyncService.addToSyncQueue(
          endpoint: '/custom-tours/1/status',
          method: 'PUT',
          data: argThat(isA<Map<String, dynamic>?>(), named: 'data'),
        )).called(1);
      });
    });

    group('generateNewJoinCode', () {
      test('should fail when offline', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(false);

        // Act
        final result = await repository.generateNewJoinCode('1');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.toString(), contains('internet connection'));
      });

      test('should generate new join code when online', () async {
        // Arrange
        when(mockConnectivityService.isOnline).thenReturn(true);
        when(mockApiClient.post<Map<String, dynamic>>(
          '/custom-tours/1/generate-join-code',
        )).thenAnswer((_) async => ApiSuccess(data: sampleTourData));
        when(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.generateNewJoinCode('1');

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockCacheService.cacheData(
          table: 'cache_tours',
          key: '1',
          data: sampleTourData,
        )).called(1);
      });
    });
  });
}