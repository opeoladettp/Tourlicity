import 'dart:async';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';
import '../network/api_client.dart';

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  OfflineManager._internal();

  final CacheService _cacheService = CacheService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncService _syncService = SyncService();

  bool _isInitialized = false;
  StreamController<OfflineStatus>? _statusController;

  CacheService get cacheService => _cacheService;
  ConnectivityService get connectivityService => _connectivityService;
  SyncService get syncService => _syncService;

  bool get isOnline => _connectivityService.isOnline;
  bool get isInitialized => _isInitialized;

  Stream<OfflineStatus> get statusStream {
    _statusController ??= StreamController<OfflineStatus>.broadcast();
    return _statusController!.stream;
  }

  Future<void> initialize(ApiClient apiClient) async {
    if (_isInitialized) return;

    // Initialize connectivity service
    await _connectivityService.initialize();

    // Initialize sync service
    _syncService.initialize(apiClient);

    // Listen to connectivity changes and emit status updates
    _connectivityService.connectivityStream.listen((isOnline) async {
      final pendingSync = await _syncService.getPendingSyncCount();
      _statusController?.add(OfflineStatus(
        isOnline: isOnline,
        pendingSyncCount: pendingSync,
        lastSyncTime: DateTime.now(),
      ));
    });

    // Clear expired cache on startup
    await _cacheService.clearExpiredCache();

    _isInitialized = true;

    // Emit initial status
    final pendingSync = await _syncService.getPendingSyncCount();
    _statusController?.add(OfflineStatus(
      isOnline: _connectivityService.isOnline,
      pendingSyncCount: pendingSync,
      lastSyncTime: DateTime.now(),
    ));
  }

  Future<void> forceSync() async {
    if (!_connectivityService.isOnline) {
      throw Exception('Cannot sync while offline');
    }

    await _syncService.forcSync();
    
    final pendingSync = await _syncService.getPendingSyncCount();
    _statusController?.add(OfflineStatus(
      isOnline: true,
      pendingSyncCount: pendingSync,
      lastSyncTime: DateTime.now(),
    ));
  }

  Future<void> clearAllCache() async {
    await _cacheService.clearAllCache();
  }

  Future<void> clearExpiredCache() async {
    await _cacheService.clearExpiredCache();
  }

  Future<int> getPendingSyncCount() async {
    return await _syncService.getPendingSyncCount();
  }

  Future<void> clearSyncQueue() async {
    await _syncService.clearSyncQueue();
  }

  void dispose() {
    _connectivityService.dispose();
    _syncService.dispose();
    _statusController?.close();
    _statusController = null;
    _isInitialized = false;
  }
}

class OfflineStatus {
  final bool isOnline;
  final int pendingSyncCount;
  final DateTime lastSyncTime;

  const OfflineStatus({
    required this.isOnline,
    required this.pendingSyncCount,
    required this.lastSyncTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineStatus &&
          runtimeType == other.runtimeType &&
          isOnline == other.isOnline &&
          pendingSyncCount == other.pendingSyncCount;

  @override
  int get hashCode => isOnline.hashCode ^ pendingSyncCount.hashCode;

  @override
  String toString() {
    return 'OfflineStatus{isOnline: $isOnline, pendingSyncCount: $pendingSyncCount, lastSyncTime: $lastSyncTime}';
  }
}