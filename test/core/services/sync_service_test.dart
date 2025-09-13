import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tourlicity_app/core/services/sync_service.dart';
import 'package:tourlicity_app/core/network/api_client.dart';
import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/core/database/database_helper.dart';

import 'sync_service_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late SyncService syncService;
  late MockApiClient mockApiClient;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    syncService = SyncService();
    mockApiClient = MockApiClient();
    databaseHelper = DatabaseHelper();

    // Clear any existing data
    final db = await databaseHelper.database;
    await db.delete('sync_queue');
  });

  tearDown(() async {
    syncService.dispose();
    await databaseHelper.close();
  });

  group('SyncService', () {
    test('should add item to sync queue', () async {
      // Arrange
      const endpoint = '/test-endpoint';
      const method = 'POST';
      final data = {'key': 'value'};

      // Act
      await syncService.addToSyncQueue(
        endpoint: endpoint,
        method: method,
        data: data,
      );

      // Assert
      final pendingCount = await syncService.getPendingSyncCount();
      expect(pendingCount, equals(1));
    });

    test('should get pending sync count', () async {
      // Arrange
      await syncService.addToSyncQueue(
        endpoint: '/endpoint1',
        method: 'POST',
      );
      await syncService.addToSyncQueue(
        endpoint: '/endpoint2',
        method: 'PUT',
      );

      // Act
      final count = await syncService.getPendingSyncCount();

      // Assert
      expect(count, equals(2));
    });

    test('should clear sync queue', () async {
      // Arrange
      await syncService.addToSyncQueue(
        endpoint: '/endpoint1',
        method: 'POST',
      );
      await syncService.addToSyncQueue(
        endpoint: '/endpoint2',
        method: 'PUT',
      );

      // Act
      await syncService.clearSyncQueue();

      // Assert
      final count = await syncService.getPendingSyncCount();
      expect(count, equals(0));
    });

    test('should initialize with api client', () {
      // Act & Assert - should not throw
      expect(
        () => syncService.initialize(mockApiClient),
        returnsNormally,
      );
    });

    test('should force sync when online', () async {
      // Arrange
      syncService.initialize(mockApiClient);
      when(mockApiClient.post('/test', data: anyNamed('data')))
          .thenAnswer((_) async => const ApiSuccess(data: {}));

      await syncService.addToSyncQueue(
        endpoint: '/test',
        method: 'POST',
        data: {'test': 'data'},
      );

      // Act & Assert - should not throw
      expect(
        () async => await syncService.forcSync(),
        returnsNormally,
      );
    });

    test('should handle sync errors gracefully', () async {
      // Arrange
      syncService.initialize(mockApiClient);
      when(mockApiClient.post('/test', data: anyNamed('data')))
          .thenAnswer((_) async => const ApiFailure(message: 'Network error'));

      await syncService.addToSyncQueue(
        endpoint: '/test',
        method: 'POST',
        data: {'test': 'data'},
      );

      // Act & Assert - should not throw
      expect(
        () async => await syncService.forcSync(),
        returnsNormally,
      );
    });
  });
}