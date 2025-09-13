import 'package:flutter/foundation.dart';

/// Stub implementation for development when Firebase is not available
class StubAnalyticsService {
  static StubAnalyticsService? _instance;
  
  static StubAnalyticsService get instance {
    _instance ??= StubAnalyticsService._();
    return _instance!;
  }
  
  StubAnalyticsService._();
  
  Future<void> trackLogin(String method, String userId) async {
    debugPrint('Analytics: Login tracked - method: $method, userId: $userId');
  }
  
  Future<void> trackLogout() async {
    debugPrint('Analytics: Logout tracked');
  }
  
  Future<void> trackScreenView(String screenName, String screenClass) async {
    debugPrint('Analytics: Screen view tracked - $screenName ($screenClass)');
  }
  
  Future<void> trackTourRegistration({
    required String tourId,
    required String tourName,
    required String providerId,
  }) async {
    debugPrint('Analytics: Tour registration tracked - $tourId');
  }
  
  Future<void> trackTourCreation({
    required String tourId,
    required String tourName,
    required String templateId,
  }) async {
    debugPrint('Analytics: Tour creation tracked - $tourId');
  }
  
  Future<void> trackDocumentUpload({
    required String documentType,
    required String fileSize,
    required bool success,
  }) async {
    debugPrint('Analytics: Document upload tracked - $documentType, success: $success');
  }
  
  Future<void> trackMessageSent({
    required String messageType,
    required String recipientType,
    required int recipientCount,
  }) async {
    debugPrint('Analytics: Message sent tracked - $messageType to $recipientCount recipients');
  }
  
  Future<void> trackUserEngagement({
    required String action,
    required String category,
    String? label,
    int? value,
  }) async {
    debugPrint('Analytics: User engagement tracked - $action in $category');
  }
  
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    debugPrint('Analytics: Error tracked - $errorType: $errorMessage');
  }
  
  Future<void> trackPerformance({
    required String metricName,
    required double value,
    String? unit,
  }) async {
    debugPrint('Analytics: Performance tracked - $metricName: $value ${unit ?? ''}');
  }
  
  Future<void> setUserProperties({
    required String userType,
    String? providerId,
    String? country,
  }) async {
    debugPrint('Analytics: User properties set - type: $userType');
  }
}

/// Stub implementation for crash reporting
class StubCrashReportingService {
  static StubCrashReportingService? _instance;
  
  static StubCrashReportingService get instance {
    _instance ??= StubCrashReportingService._();
    return _instance!;
  }
  
  StubCrashReportingService._();
  
  bool get isCrashCollectionEnabled => false;
  
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? customKeys,
  }) async {
    debugPrint('Crash Reporting: Error recorded - $exception');
  }
  
  Future<void> recordFlutterFatalError(dynamic errorDetails) async {
    debugPrint('Crash Reporting: Flutter fatal error recorded');
  }
  
  Future<void> log(String message) async {
    debugPrint('Crash Reporting: Log - $message');
  }
  
  Future<void> setUserIdentifier(String identifier) async {
    debugPrint('Crash Reporting: User identifier set - $identifier');
  }
  
  Future<void> setCustomKey(String key, dynamic value) async {
    debugPrint('Crash Reporting: Custom key set - $key: $value');
  }
  
  Future<void> setCrashCollectionEnabled(bool enabled) async {
    debugPrint('Crash Reporting: Collection enabled set to $enabled');
  }
}

/// Stub implementation for performance monitoring
class StubPerformanceMonitoringService {
  static StubPerformanceMonitoringService? _instance;
  
  static StubPerformanceMonitoringService get instance {
    _instance ??= StubPerformanceMonitoringService._();
    return _instance!;
  }
  
  StubPerformanceMonitoringService._();
  
  Future<bool> get isPerformanceCollectionEnabled async => false;
  
  Future<void> startTrace(String traceName) async {
    debugPrint('Performance: Trace started - $traceName');
  }
  
  Future<void> stopTrace(String traceName) async {
    debugPrint('Performance: Trace stopped - $traceName');
  }
  
  Future<void> startHttpMetric({
    required String url,
    required String httpMethod,
    required String requestId,
  }) async {
    debugPrint('Performance: HTTP metric started - $httpMethod $url');
  }
  
  Future<void> stopHttpMetric({
    required String url,
    required String httpMethod,
    required int responseCode,
    required String requestId,
  }) async {
    debugPrint('Performance: HTTP metric stopped - $httpMethod $url ($responseCode)');
  }
  
  Future<void> trackScreenLoad(String screenName) async {
    debugPrint('Performance: Screen load tracked - $screenName');
  }
  
  Future<void> completeScreenLoad(String screenName) async {
    debugPrint('Performance: Screen load completed - $screenName');
  }
  
  Future<void> trackUserInteraction({
    required String interaction,
    required String component,
    Map<String, String>? additionalAttributes,
  }) async {
    debugPrint('Performance: User interaction tracked - $interaction on $component');
  }
  
  Future<void> completeUserInteraction({
    required String interaction,
    required String component,
    bool success = true,
  }) async {
    debugPrint('Performance: User interaction completed - $interaction on $component (success: $success)');
  }
  
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    debugPrint('Performance: Collection enabled set to $enabled');
  }
  
  Future<void> cleanup() async {
    debugPrint('Performance: Cleanup completed');
  }
}