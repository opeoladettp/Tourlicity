import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/core/services/offline_manager.dart';
import 'package:tourlicity_app/core/network/api_client.dart';

import 'offline_manager_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late OfflineManager offlineManager;
  late MockApiClient mockApiClient;

  setUp(() {
    offlineManager = OfflineManager();
    mockApiClient = MockApiClient();
  });

  tearDown(() {
    offlineManager.dispose();
  });

  group('OfflineManager', () {
    test('should be singleton', () {
      // Act
      final instance1 = OfflineManager();
      final instance2 = OfflineManager();

      // Assert
      expect(identical(instance1, instance2), isTrue);
    });

    test('should initialize successfully', () async {
      // Act & Assert - should not throw
      expect(
        () async => await offlineManager.initialize(mockApiClient),
        returnsNormally,
      );

      expect(offlineManager.isInitialized, isTrue);
    });

    test('should provide access to services', () async {
      // Arrange
      await offlineManager.initialize(mockApiClient);

      // Assert
      expect(offlineManager.cacheService, isNotNull);
      expect(offlineManager.connectivityService, isNotNull);
      expect(offlineManager.syncService, isNotNull);
    });

    test('should provide status stream', () async {
      // Arrange
      await offlineManager.initialize(mockApiClient);

      // Act
      final statusStream = offlineManager.statusStream;

      // Assert
      expect(statusStream, isNotNull);
    });

    test('should get online status', () async {
      // Arrange
      await offlineManager.initialize(mockApiClient);

      // Act
      final isOnline = offlineManager.isOnline;

      // Assert
      expect(isOnline, isA<bool>());
    });

    test('should clear all cache', () async {
      // Arrange
      await offlineManager.initialize(mockApiClient);

      // Act & Assert - should not throw
      expect(
        () async => await offlineManager.clearAllCache(),
        returnsNormally,
      );
    });

    test('should clear expired cache', () async {
      // Arrange
      await offlineManager.initialize(mockApiClient);

      // Act & Assert - should not throw
      expect(
        () async => await offlineManager.clearExpiredCache(),
        returnsNormally,
      );
    });

    test('should get pending sync count', () async {
      // Arrange
      await offlineManager.initialize(mockApiClient);

      // Act
      final count = await offlineManager.getPendingSyncCount();

      // Assert
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('should clear sync queue', () async {
      // Arrange
      await offlineManager.initialize(mockApiClient);

      // Act & Assert - should not throw
      expect(
        () async => await offlineManager.clearSyncQueue(),
        returnsNormally,
      );
    });

    test('should dispose properly', () {
      // Act & Assert - should not throw
      expect(
        () => offlineManager.dispose(),
        returnsNormally,
      );

      expect(offlineManager.isInitialized, isFalse);
    });
  });

  group('OfflineStatus', () {
    test('should create status object', () {
      // Act
      final status = OfflineStatus(
        isOnline: true,
        pendingSyncCount: 5,
        lastSyncTime: DateTime.now(),
      );

      // Assert
      expect(status.isOnline, isTrue);
      expect(status.pendingSyncCount, equals(5));
      expect(status.lastSyncTime, isA<DateTime>());
    });

    test('should compare status objects correctly', () {
      // Arrange
      final now = DateTime.now();
      final status1 = OfflineStatus(
        isOnline: true,
        pendingSyncCount: 5,
        lastSyncTime: now,
      );
      final status2 = OfflineStatus(
        isOnline: true,
        pendingSyncCount: 5,
        lastSyncTime: now,
      );
      final status3 = OfflineStatus(
        isOnline: false,
        pendingSyncCount: 5,
        lastSyncTime: now,
      );

      // Assert
      expect(status1, equals(status2));
      expect(status1, isNot(equals(status3)));
    });

    test('should have proper string representation', () {
      // Arrange
      final now = DateTime.now();
      final status = OfflineStatus(
        isOnline: true,
        pendingSyncCount: 3,
        lastSyncTime: now,
      );

      // Act
      final string = status.toString();

      // Assert
      expect(string, contains('isOnline: true'));
      expect(string, contains('pendingSyncCount: 3'));
      expect(string, contains('lastSyncTime: $now'));
    });
  });
}