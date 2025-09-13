import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../network/api_client.dart';
import 'connectivity_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  ApiClient? _apiClient;
  Timer? _syncTimer;

  void initialize(ApiClient apiClient) {
    _apiClient = apiClient;
    
    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        _processSyncQueue();
      }
    });

    // Start periodic sync (every 5 minutes when online)
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_connectivityService.isOnline) {
        _processSyncQueue();
      }
    });
  }

  Future<void> addToSyncQueue({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
  }) async {
    if (kIsWeb) {
      // On web, execute immediately if online
      if (_connectivityService.isOnline && _apiClient != null) {
        try {
          await _processSyncItem({
            'endpoint': endpoint,
            'method': method,
            'data': data != null ? jsonEncode(data) : null,
          });
        } catch (e) {
          debugPrint('Immediate sync failed on web: $e');
        }
      }
      return;
    }
    
    final db = await _databaseHelper.database;
    
    await db.insert('sync_queue', {
      'endpoint': endpoint,
      'method': method,
      'data': data != null ? jsonEncode(data) : null,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    });
  }

  Future<void> _processSyncQueue() async {
    if (_apiClient == null || !_connectivityService.isOnline) {
      return;
    }

    if (kIsWeb) {
      return; // No sync queue to process on web
    }

    final db = await _databaseHelper.database;
    
    // Get pending sync items (max 10 at a time)
    final pendingItems = await db.query(
      'sync_queue',
      orderBy: 'timestamp ASC',
      limit: 10,
    );

    for (final item in pendingItems) {
      try {
        await _processSyncItem(item);
        
        // Remove successful item from queue
        await db.delete(
          'sync_queue',
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      } catch (e) {
        // Increment retry count
        final retryCount = (item['retry_count'] as int) + 1;
        
        if (retryCount >= 3) {
          // Remove after 3 failed attempts
          await db.delete(
            'sync_queue',
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } else {
          // Update retry count
          await db.update(
            'sync_queue',
            {'retry_count': retryCount},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      }
    }
  }

  Future<void> _processSyncItem(Map<String, Object?> item) async {
    final endpoint = item['endpoint'] as String;
    final method = item['method'] as String;
    final dataString = item['data'] as String?;
    
    Map<String, dynamic>? data;
    if (dataString != null) {
      data = jsonDecode(dataString) as Map<String, dynamic>;
    }

    switch (method.toUpperCase()) {
      case 'POST':
        await _apiClient!.post(endpoint, data: data ?? {});
        break;
      case 'PUT':
        await _apiClient!.put(endpoint, data: data ?? {});
        break;
      case 'PATCH':
        await _apiClient!.patch(endpoint, data: data ?? {});
        break;
      case 'DELETE':
        await _apiClient!.delete(endpoint);
        break;
      default:
        throw Exception('Unsupported sync method: $method');
    }
  }

  Future<int> getPendingSyncCount() async {
    if (kIsWeb) {
      return 0; // No sync queue on web
    }
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearSyncQueue() async {
    if (kIsWeb) {
      return; // No sync queue on web
    }
    final db = await _databaseHelper.database;
    await db.delete('sync_queue');
  }

  Future<void> forcSync() async {
    if (_connectivityService.isOnline) {
      await _processSyncQueue();
    }
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}