// Temporarily disabled Firebase import
// import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Service for performance monitoring and alerting (Stub implementation)
class PerformanceMonitoringService {
  static PerformanceMonitoringService? _instance;
  final Map<String, dynamic> _activeTraces = {};
  final Map<String, dynamic> _activeHttpMetrics = {};

  PerformanceMonitoringService._() {
    // Stub implementation - no Firebase performance initialization needed
    debugPrint(
        'Performance (Stub): Initialized stub performance monitoring service');
  }

  /// Get singleton instance
  static PerformanceMonitoringService get instance {
    _instance ??= PerformanceMonitoringService._();
    return _instance!;
  }

  /// Check if performance monitoring is available
  bool get isAvailable => false; // Always false for stub

  /// Start a custom trace (Stub implementation)
  Future<void> startTrace(String traceName) async {
    debugPrint('Performance (Stub): Started trace - $traceName');
    _activeTraces[traceName] = DateTime.now();
  }

  /// Stop a custom trace (Stub implementation)
  Future<void> stopTrace(String traceName) async {
    final startTime = _activeTraces.remove(traceName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime as DateTime);
      debugPrint(
          'Performance (Stub): Stopped trace - $traceName (${duration.inMilliseconds}ms)');
    }
  }

  /// Add attribute to a trace (Stub implementation)
  Future<void> setTraceAttribute(
    String traceName,
    String attributeName,
    String value,
  ) async {
    debugPrint(
        'Performance (Stub): Set trace attribute - $traceName.$attributeName = $value');
  }

  /// Increment a metric for a trace (Stub implementation)
  Future<void> incrementTraceMetric(
    String traceName,
    String metricName,
    int value,
  ) async {
    debugPrint(
        'Performance (Stub): Increment trace metric - $traceName.$metricName += $value');
  }

  /// Start HTTP metric tracking (Stub implementation)
  Future<void> startHttpMetric({
    required String url,
    required String httpMethod,
    String? requestId,
  }) async {
    final metricId = requestId ?? '${httpMethod}_${url.hashCode}';
    debugPrint('Performance (Stub): Started HTTP metric - $httpMethod $url');
    _activeHttpMetrics[metricId] = DateTime.now();
  }

  /// Stop HTTP metric tracking (Stub implementation)
  Future<void> stopHttpMetric({
    required String url,
    required String httpMethod,
    required int responseCode,
    int? responsePayloadSize,
    int? requestPayloadSize,
    String? requestId,
  }) async {
    final metricId = requestId ?? '${httpMethod}_${url.hashCode}';
    final startTime = _activeHttpMetrics.remove(metricId);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime as DateTime);
      debugPrint(
          'Performance (Stub): Stopped HTTP metric - $httpMethod $url ($responseCode) (${duration.inMilliseconds}ms)');
    }
  }

  /// Track screen loading time (Stub implementation)
  Future<void> trackScreenLoad(String screenName) async {
    await startTrace('screen_load_$screenName');
  }

  /// Complete screen loading tracking (Stub implementation)
  Future<void> completeScreenLoad(String screenName) async {
    await stopTrace('screen_load_$screenName');
  }

  /// Track API call performance (Stub implementation)
  Future<void> trackApiCall({
    required String endpoint,
    required String method,
    required Future<void> Function() apiCall,
    String? requestId,
  }) async {
    await startHttpMetric(
      url: endpoint,
      httpMethod: method,
      requestId: requestId,
    );

    try {
      await apiCall();
      await stopHttpMetric(
        url: endpoint,
        httpMethod: method,
        responseCode: 200,
        requestId: requestId,
      );
    } catch (e) {
      await stopHttpMetric(
        url: endpoint,
        httpMethod: method,
        responseCode: 500,
        requestId: requestId,
      );
      rethrow;
    }
  }

  /// Track database operation performance (Stub implementation)
  Future<T> trackDatabaseOperation<T>({
    required String operation,
    required String table,
    required Future<T> Function() dbOperation,
  }) async {
    final traceName = 'db_${operation}_$table';
    await startTrace(traceName);

    try {
      final result = await dbOperation();
      await stopTrace(traceName);
      return result;
    } catch (e) {
      await stopTrace(traceName);
      rethrow;
    }
  }

  /// Track file operation performance (Stub implementation)
  Future<T> trackFileOperation<T>({
    required String operation,
    required String fileType,
    int? fileSize,
    required Future<T> Function() fileOperation,
  }) async {
    final traceName = 'file_${operation}_$fileType';
    await startTrace(traceName);

    try {
      final result = await fileOperation();
      await stopTrace(traceName);
      return result;
    } catch (e) {
      await stopTrace(traceName);
      rethrow;
    }
  }

  /// Track user interaction performance (Stub implementation)
  Future<void> trackUserInteraction({
    required String interaction,
    required String component,
    Map<String, String>? additionalAttributes,
  }) async {
    final traceName = 'interaction_${interaction}_$component';
    await startTrace(traceName);

    // Auto-complete after 5 seconds for user interactions
    Future.delayed(const Duration(seconds: 5), () {
      stopTrace(traceName);
    });
  }

  /// Complete user interaction tracking (Stub implementation)
  Future<void> completeUserInteraction({
    required String interaction,
    required String component,
    bool success = true,
  }) async {
    final traceName = 'interaction_${interaction}_$component';
    await stopTrace(traceName);
  }

  /// Check if performance monitoring is enabled (Stub implementation)
  Future<bool> get isPerformanceCollectionEnabled async => false;

  /// Enable or disable performance collection (Stub implementation)
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    debugPrint('Performance (Stub): Performance collection enabled: $enabled');
  }

  /// Clean up all active traces and metrics (Stub implementation)
  Future<void> cleanup() async {
    debugPrint('Performance (Stub): Cleanup completed');
    _activeTraces.clear();
    _activeHttpMetrics.clear();
  }
}
