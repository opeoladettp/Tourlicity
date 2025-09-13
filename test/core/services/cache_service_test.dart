import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tourlicity_app/core/services/cache_service.dart';
import 'package:tourlicity_app/core/database/database_helper.dart';

void main() {
  late CacheService cacheService;
  late DatabaseHelper databaseHelper;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for unit testing
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    cacheService = CacheService();
    databaseHelper = DatabaseHelper();
    
    // Clear any existing data
    await databaseHelper.clearCache();
  });

  tearDown(() async {
    await databaseHelper.clearCache();
    await databaseHelper.close();
  });

  group('CacheService', () {
    test('should cache and retrieve data', () async {
      // Arrange
      const table = 'cache_tours';
      const key = 'test_tour_1';
      final data = {
        'id': key,
        'name': 'Test Tour',
        'description': 'A test tour',
      };

      // Act
      await cacheService.cacheData(
        table: table,
        key: key,
        data: data,
      );

      final cachedData = await cacheService.getCachedData(
        table: table,
        key: key,
      );

      // Assert
      expect(cachedData, isNotNull);
      expect(cachedData!['id'], equals(key));
      expect(cachedData['name'], equals('Test Tour'));
    });

    test('should return null for expired cache', () async {
      // Arrange
      const table = 'cache_tours';
      const key = 'test_tour_expired';
      final data = {
        'id': key,
        'name': 'Expired Tour',
      };

      // Act - cache with very short duration (1ms)
      await cacheService.cacheData(
        table: table,
        key: key,
        data: data,
        customDuration: 1,
      );

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 10));

      final cachedData = await cacheService.getCachedData(
        table: table,
        key: key,
      );

      // Assert
      expect(cachedData, isNull);
    });

    test('should cache and retrieve tours list', () async {
      // Arrange
      final tours = [
        {'id': '1', 'name': 'Tour 1'},
        {'id': '2', 'name': 'Tour 2'},
        {'id': '3', 'name': 'Tour 3'},
      ];

      // Act
      await cacheService.cacheTours(tours);
      final cachedTours = await cacheService.getCachedTours();

      // Assert
      expect(cachedTours, hasLength(3));
      expect(cachedTours.first['name'], equals('Tour 1'));
    });

    test('should remove cached data', () async {
      // Arrange
      const table = 'cache_tours';
      const key = 'test_tour_remove';
      final data = {'id': key, 'name': 'Tour to Remove'};

      await cacheService.cacheData(
        table: table,
        key: key,
        data: data,
      );

      // Act
      await cacheService.removeCachedData(
        table: table,
        key: key,
      );

      final cachedData = await cacheService.getCachedData(
        table: table,
        key: key,
      );

      // Assert
      expect(cachedData, isNull);
    });

    test('should check if data is cached', () async {
      // Arrange
      const table = 'cache_tours';
      const key = 'test_tour_check';
      final data = {'id': key, 'name': 'Tour to Check'};

      // Act & Assert - not cached initially
      expect(
        await cacheService.isCached(table: table, key: key),
        isFalse,
      );

      // Cache the data
      await cacheService.cacheData(
        table: table,
        key: key,
        data: data,
      );

      // Act & Assert - should be cached now
      expect(
        await cacheService.isCached(table: table, key: key),
        isTrue,
      );
    });

    test('should clear expired cache', () async {
      // Arrange
      const table = 'cache_tours';
      final validData = {'id': 'valid', 'name': 'Valid Tour'};
      final expiredData = {'id': 'expired', 'name': 'Expired Tour'};

      // Cache valid data (long duration)
      await cacheService.cacheData(
        table: table,
        key: 'valid',
        data: validData,
        customDuration: 60000, // 1 minute
      );

      // Cache expired data (short duration)
      await cacheService.cacheData(
        table: table,
        key: 'expired',
        data: expiredData,
        customDuration: 1, // 1ms
      );

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 10));

      // Act
      await cacheService.clearExpiredCache();

      // Assert
      expect(
        await cacheService.isCached(table: table, key: 'valid'),
        isTrue,
      );
      expect(
        await cacheService.isCached(table: table, key: 'expired'),
        isFalse,
      );
    });

    test('should clear all cache', () async {
      // Arrange
      await cacheService.cacheTours([
        {'id': '1', 'name': 'Tour 1'},
        {'id': '2', 'name': 'Tour 2'},
      ]);

      await cacheService.cacheRegistrations([
        {'id': '1', 'tour_id': '1', 'user_id': '1'},
      ]);

      // Act
      await cacheService.clearAllCache();

      // Assert
      final tours = await cacheService.getCachedTours();
      final registrations = await cacheService.getCachedRegistrations();

      expect(tours, isEmpty);
      expect(registrations, isEmpty);
    });
  });
}