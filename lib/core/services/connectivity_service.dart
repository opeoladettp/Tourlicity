import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  Future<void> initialize() async {
    // Check initial connectivity
    await _updateConnectivityStatus();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectivityStatus();
    });
  }

  Future<void> _updateConnectivityStatus() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      final wasOnline = _isOnline;

      _isOnline = connectivityResults.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);

      // Only emit if status changed
      if (wasOnline != _isOnline) {
        _connectivityController?.add(_isOnline);
      }
    } catch (e) {
      // If we can't check connectivity, assume offline
      if (_isOnline) {
        _isOnline = false;
        _connectivityController?.add(_isOnline);
      }
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return connectivityResults.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _connectivityController?.close();
    _connectivityController = null;
  }
}
