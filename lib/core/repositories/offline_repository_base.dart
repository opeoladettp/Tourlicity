import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../network/api_client.dart';

abstract class OfflineRepositoryBase {
  final ApiClient apiClient;
  final CacheService cacheService;
  final ConnectivityService connectivityService;
  final SyncService syncService;

  OfflineRepositoryBase({
    required this.apiClient,
    required this.cacheService,
    required this.connectivityService,
    required this.syncService,
  });

  /// Get cache table name for this repository
  String get cacheTableName;

  /// Get data from API or cache
  Future<List<Map<String, dynamic>>> getDataWithCache({
    required String endpoint,
    required Future<List<Map<String, dynamic>>> Function() apiCall,
    bool forceRefresh = false,
  }) async {
    // If offline, return cached data
    if (!connectivityService.isOnline) {
      return await _getCachedData();
    }

    // If online and not forcing refresh, try cache first
    if (!forceRefresh) {
      final cachedData = await _getCachedData();
      if (cachedData.isNotEmpty) {
        // Return cached data and refresh in background
        _refreshDataInBackground(apiCall);
        return cachedData;
      }
    }

    // Fetch from API
    try {
      final data = await apiCall();
      await _cacheData(data);
      return data;
    } catch (e) {
      // If API fails, return cached data as fallback
      return await _getCachedData();
    }
  }

  /// Get single item from API or cache
  Future<Map<String, dynamic>?> getItemWithCache({
    required String id,
    required String endpoint,
    required Future<Map<String, dynamic>?> Function() apiCall,
    bool forceRefresh = false,
  }) async {
    // If offline, return cached data
    if (!connectivityService.isOnline) {
      return await cacheService.getCachedData(
        table: cacheTableName,
        key: id,
      );
    }

    // If online and not forcing refresh, try cache first
    if (!forceRefresh) {
      final cachedItem = await cacheService.getCachedData(
        table: cacheTableName,
        key: id,
      );
      if (cachedItem != null) {
        // Return cached data and refresh in background
        _refreshItemInBackground(id, apiCall);
        return cachedItem;
      }
    }

    // Fetch from API
    try {
      final data = await apiCall();
      if (data != null) {
        await cacheService.cacheData(
          table: cacheTableName,
          key: id,
          data: data,
        );
      }
      return data;
    } catch (e) {
      // If API fails, return cached data as fallback
      return await cacheService.getCachedData(
        table: cacheTableName,
        key: id,
      );
    }
  }

  /// Create item with offline support
  Future<Map<String, dynamic>?> createItemWithSync({
    required String endpoint,
    required Map<String, dynamic> data,
    required Future<Map<String, dynamic>?> Function() apiCall,
  }) async {
    if (connectivityService.isOnline) {
      try {
        final result = await apiCall();
        if (result != null) {
          await cacheService.cacheData(
            table: cacheTableName,
            key: result['id'].toString(),
            data: result,
          );
        }
        return result;
      } catch (e) {
        // Add to sync queue for later
        await syncService.addToSyncQueue(
          endpoint: endpoint,
          method: 'POST',
          data: data,
        );
        rethrow;
      }
    } else {
      // Add to sync queue for when online
      await syncService.addToSyncQueue(
        endpoint: endpoint,
        method: 'POST',
        data: data,
      );
      throw Exception('Offline: Item will be created when connection is restored');
    }
  }

  /// Update item with offline support
  Future<Map<String, dynamic>?> updateItemWithSync({
    required String id,
    required String endpoint,
    required Map<String, dynamic> data,
    required Future<Map<String, dynamic>?> Function() apiCall,
  }) async {
    if (connectivityService.isOnline) {
      try {
        final result = await apiCall();
        if (result != null) {
          await cacheService.cacheData(
            table: cacheTableName,
            key: id,
            data: result,
          );
        }
        return result;
      } catch (e) {
        // Add to sync queue for later
        await syncService.addToSyncQueue(
          endpoint: endpoint,
          method: 'PUT',
          data: data,
        );
        rethrow;
      }
    } else {
      // Update cache optimistically
      await cacheService.cacheData(
        table: cacheTableName,
        key: id,
        data: data,
      );
      
      // Add to sync queue for when online
      await syncService.addToSyncQueue(
        endpoint: endpoint,
        method: 'PUT',
        data: data,
      );
      
      return data;
    }
  }

  /// Delete item with offline support
  Future<void> deleteItemWithSync({
    required String id,
    required String endpoint,
    required Future<void> Function() apiCall,
  }) async {
    if (connectivityService.isOnline) {
      try {
        await apiCall();
        await cacheService.removeCachedData(
          table: cacheTableName,
          key: id,
        );
      } catch (e) {
        // Add to sync queue for later
        await syncService.addToSyncQueue(
          endpoint: endpoint,
          method: 'DELETE',
        );
        rethrow;
      }
    } else {
      // Remove from cache optimistically
      await cacheService.removeCachedData(
        table: cacheTableName,
        key: id,
      );
      
      // Add to sync queue for when online
      await syncService.addToSyncQueue(
        endpoint: endpoint,
        method: 'DELETE',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getCachedData() async {
    switch (cacheTableName) {
      case 'cache_tours':
        return await cacheService.getCachedTours();
      case 'cache_registrations':
        return await cacheService.getCachedRegistrations();
      case 'cache_documents':
        return await cacheService.getCachedDocuments();
      case 'cache_messages':
        return await cacheService.getCachedMessages();
      case 'cache_providers':
        return await cacheService.getCachedProviders();
      case 'cache_tour_templates':
        return await cacheService.getCachedTourTemplates();
      default:
        return [];
    }
  }

  Future<void> _cacheData(List<Map<String, dynamic>> data) async {
    switch (cacheTableName) {
      case 'cache_tours':
        await cacheService.cacheTours(data);
        break;
      case 'cache_registrations':
        await cacheService.cacheRegistrations(data);
        break;
      case 'cache_documents':
        await cacheService.cacheDocuments(data);
        break;
      case 'cache_messages':
        await cacheService.cacheMessages(data);
        break;
      case 'cache_providers':
        await cacheService.cacheProviders(data);
        break;
      case 'cache_tour_templates':
        await cacheService.cacheTourTemplates(data);
        break;
    }
  }

  void _refreshDataInBackground(Future<List<Map<String, dynamic>>> Function() apiCall) {
    // Don't await - run in background
    apiCall().then((data) {
      _cacheData(data);
    }).catchError((e) {
      // Silently handle background refresh errors
    });
  }

  void _refreshItemInBackground(String id, Future<Map<String, dynamic>?> Function() apiCall) {
    // Don't await - run in background
    apiCall().then((data) {
      if (data != null) {
        cacheService.cacheData(
          table: cacheTableName,
          key: id,
          data: data,
        );
      }
    }).catchError((e) {
      // Silently handle background refresh errors
    });
  }
}