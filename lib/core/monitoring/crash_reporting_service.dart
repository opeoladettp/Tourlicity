// Temporarily disabled Firebase import
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service for crash reporting and error tracking (Stub implementation)
class CrashReportingService {
  static CrashReportingService? _instance;

  CrashReportingService._();

  /// Check if crash reporting is available
  bool get isAvailable => false; // Always false for stub

  /// Get singleton instance
  static CrashReportingService get instance {
    _instance ??= CrashReportingService._();
    return _instance!;
  }

  /// Record a non-fatal error (Stub implementation)
  Future<void> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? customKeys,
  }) async {
    debugPrint('CrashReporting (Stub): Error recorded - $exception');
  }

  /// Record a Flutter error (Stub implementation)
  Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {
    debugPrint(
        'CrashReporting (Stub): Flutter error recorded - ${errorDetails.exception}');
  }

  /// Log a message (Stub implementation)
  Future<void> log(String message) async {
    debugPrint('CrashReporting (Stub): Log - $message');
  }

  /// Set user identifier (Stub implementation)
  Future<void> setUserIdentifier(String identifier) async {
    debugPrint('CrashReporting (Stub): User identifier set - $identifier');
  }

  /// Set custom key-value pair (Stub implementation)
  Future<void> setCustomKey(String key, dynamic value) async {
    debugPrint('CrashReporting (Stub): Custom key set - $key: $value');
  }

  /// Record API error (Stub implementation)
  Future<void> recordApiError({
    required String endpoint,
    required int statusCode,
    required String method,
    String? errorMessage,
    Map<String, dynamic>? requestData,
  }) async {
    debugPrint(
        'CrashReporting (Stub): API error recorded - $method $endpoint ($statusCode)');
  }

  /// Record authentication error (Stub implementation)
  Future<void> recordAuthError({
    required String authMethod,
    required String errorType,
    String? errorMessage,
  }) async {
    debugPrint(
        'CrashReporting (Stub): Auth error recorded - $authMethod: $errorType');
  }

  /// Record navigation error (Stub implementation)
  Future<void> recordNavigationError({
    required String route,
    required String errorType,
    String? errorMessage,
  }) async {
    debugPrint(
        'CrashReporting (Stub): Navigation error recorded - $route: $errorType');
  }

  /// Record data validation error (Stub implementation)
  Future<void> recordValidationError({
    required String fieldName,
    required String validationType,
    required dynamic value,
    String? errorMessage,
  }) async {
    debugPrint(
        'CrashReporting (Stub): Validation error recorded - $fieldName: $validationType');
  }

  /// Record performance issue (Stub implementation)
  Future<void> recordPerformanceIssue({
    required String operation,
    required Duration duration,
    required double threshold,
    Map<String, dynamic>? additionalData,
  }) async {
    debugPrint(
        'CrashReporting (Stub): Performance issue recorded - $operation: ${duration.inMilliseconds}ms');
  }

  /// Check if crash reporting is enabled (Stub implementation)
  bool get isCrashCollectionEnabled => false;

  /// Enable or disable crash collection (Stub implementation)
  Future<void> setCrashCollectionEnabled(bool enabled) async {
    debugPrint('CrashReporting (Stub): Crash collection enabled: $enabled');
  }
}
