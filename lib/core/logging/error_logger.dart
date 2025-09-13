import 'package:flutter/foundation.dart';
import '../analytics/analytics_service.dart';
import '../monitoring/crash_reporting_service.dart';

/// Comprehensive error logging and debugging service
class ErrorLogger {
  static ErrorLogger? _instance;
  late final AnalyticsService _analytics;
  late final CrashReportingService _crashReporting;

  ErrorLogger._() {
    _analytics = AnalyticsService.instance;
    _crashReporting = CrashReportingService.instance;
  }

  /// Get singleton instance
  static ErrorLogger get instance {
    _instance ??= ErrorLogger._();
    return _instance!;
  }

  /// Log a general error
  Future<void> logError({
    required String message,
    dynamic exception,
    StackTrace? stackTrace,
    String? category,
    Map<String, dynamic>? additionalData,
    bool fatal = false,
  }) async {
    try {
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('ERROR [$category]: $message');
        if (exception != null) {
          debugPrint('Exception: $exception');
        }
        if (stackTrace != null) {
          debugPrint('Stack trace: $stackTrace');
        }
      }

      // Track in analytics
      await _analytics.trackError(
        errorType: category ?? 'general_error',
        errorMessage: message,
        stackTrace: stackTrace?.toString(),
      );

      // Report to crash reporting
      await _crashReporting.recordError(
        exception: exception ?? message,
        stackTrace: stackTrace,
        reason: message,
        fatal: fatal,
        customKeys: {
          'category': category ?? 'general_error',
          'timestamp': DateTime.now().toIso8601String(),
          ...?additionalData,
        },
      );
    } catch (e) {
      debugPrint('Error logging failed: $e');
    }
  }

  /// Log authentication errors
  Future<void> logAuthError({
    required String authMethod,
    required String errorType,
    String? errorMessage,
    dynamic exception,
    StackTrace? stackTrace,
  }) async {
    await logError(
      message: errorMessage ?? 'Authentication failed',
      exception: exception,
      stackTrace: stackTrace,
      category: 'auth_error',
      additionalData: {
        'auth_method': authMethod,
        'auth_error_type': errorType,
      },
    );

    await _crashReporting.recordAuthError(
      authMethod: authMethod,
      errorType: errorType,
      errorMessage: errorMessage,
    );
  }

  /// Log API errors
  Future<void> logApiError({
    required String endpoint,
    required String method,
    required int statusCode,
    String? errorMessage,
    dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) async {
    await logError(
      message: errorMessage ?? 'API request failed',
      exception: exception,
      stackTrace: stackTrace,
      category: 'api_error',
      additionalData: {
        'endpoint': endpoint,
        'method': method,
        'status_code': statusCode,
        'request_data': requestData?.toString(),
        'response_data': responseData?.toString(),
      },
    );

    await _crashReporting.recordApiError(
      endpoint: endpoint,
      statusCode: statusCode,
      method: method,
      errorMessage: errorMessage,
      requestData: requestData,
    );
  }

  /// Log navigation errors
  Future<void> logNavigationError({
    required String route,
    required String errorType,
    String? errorMessage,
    dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? routeData,
  }) async {
    await logError(
      message: errorMessage ?? 'Navigation failed',
      exception: exception,
      stackTrace: stackTrace,
      category: 'navigation_error',
      additionalData: {
        'route': route,
        'navigation_error_type': errorType,
        'route_data': routeData?.toString(),
      },
    );

    await _crashReporting.recordNavigationError(
      route: route,
      errorType: errorType,
      errorMessage: errorMessage,
    );
  }

  /// Log validation errors
  Future<void> logValidationError({
    required String fieldName,
    required String validationType,
    required dynamic value,
    String? errorMessage,
    String? formName,
  }) async {
    await logError(
      message: errorMessage ?? 'Validation failed',
      category: 'validation_error',
      additionalData: {
        'field_name': fieldName,
        'validation_type': validationType,
        'invalid_value': value.toString(),
        'form_name': formName,
      },
    );

    await _crashReporting.recordValidationError(
      fieldName: fieldName,
      validationType: validationType,
      value: value,
      errorMessage: errorMessage,
    );
  }

  /// Log database errors
  Future<void> logDatabaseError({
    required String operation,
    required String table,
    String? errorMessage,
    dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? queryData,
  }) async {
    await logError(
      message: errorMessage ?? 'Database operation failed',
      exception: exception,
      stackTrace: stackTrace,
      category: 'database_error',
      additionalData: {
        'operation': operation,
        'table': table,
        'query_data': queryData?.toString(),
      },
    );
  }

  /// Log file operation errors
  Future<void> logFileError({
    required String operation,
    required String filePath,
    String? errorMessage,
    dynamic exception,
    StackTrace? stackTrace,
    int? fileSize,
    String? fileType,
  }) async {
    await logError(
      message: errorMessage ?? 'File operation failed',
      exception: exception,
      stackTrace: stackTrace,
      category: 'file_error',
      additionalData: {
        'operation': operation,
        'file_path': filePath,
        'file_size': fileSize,
        'file_type': fileType,
      },
    );
  }

  /// Log network errors
  Future<void> logNetworkError({
    required String operation,
    String? errorMessage,
    dynamic exception,
    StackTrace? stackTrace,
    String? url,
    int? statusCode,
  }) async {
    await logError(
      message: errorMessage ?? 'Network operation failed',
      exception: exception,
      stackTrace: stackTrace,
      category: 'network_error',
      additionalData: {
        'operation': operation,
        'url': url,
        'status_code': statusCode,
      },
    );
  }

  /// Log performance issues
  Future<void> logPerformanceIssue({
    required String operation,
    required Duration duration,
    required double thresholdMs,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    await logError(
      message: errorMessage ?? 'Performance threshold exceeded',
      category: 'performance_issue',
      additionalData: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'threshold_ms': thresholdMs,
        ...?additionalData,
      },
    );

    await _crashReporting.recordPerformanceIssue(
      operation: operation,
      duration: duration,
      threshold: thresholdMs,
      additionalData: additionalData,
    );
  }

  /// Log user action for debugging
  Future<void> logUserAction({
    required String action,
    required String screen,
    Map<String, dynamic>? actionData,
  }) async {
    if (kDebugMode) {
      debugPrint('USER ACTION [$screen]: $action');
      if (actionData != null) {
        debugPrint('Action data: $actionData');
      }
    }

    await _analytics.trackUserEngagement(
      action: action,
      category: 'user_action',
      label: screen,
    );
  }

  /// Log debug information
  void logDebug(String message, {String? category}) {
    if (kDebugMode) {
      debugPrint('DEBUG [${category ?? 'general'}]: $message');
    }
  }

  /// Log info message
  void logInfo(String message, {String? category}) {
    if (kDebugMode) {
      debugPrint('INFO [${category ?? 'general'}]: $message');
    }
  }

  /// Log warning message
  void logWarning(String message, {String? category}) {
    if (kDebugMode) {
      debugPrint('WARNING [${category ?? 'general'}]: $message');
    }
  }

  /// Set user context for error logging
  Future<void> setUserContext({
    required String userId,
    required String userType,
    String? providerId,
    String? email,
  }) async {
    try {
      await _crashReporting.setUserIdentifier(userId);
      await _crashReporting.setCustomKey('user_type', userType);
      
      if (providerId != null) {
        await _crashReporting.setCustomKey('provider_id', providerId);
      }
      
      if (email != null) {
        await _crashReporting.setCustomKey('user_email', email);
      }

      await _analytics.setUserProperties(
        userType: userType,
        providerId: providerId,
      );
    } catch (e) {
      debugPrint('Setting user context failed: $e');
    }
  }

  /// Clear user context
  Future<void> clearUserContext() async {
    try {
      await _crashReporting.setUserIdentifier('');
      await _crashReporting.setCustomKey('user_type', '');
      await _crashReporting.setCustomKey('provider_id', '');
      await _crashReporting.setCustomKey('user_email', '');
    } catch (e) {
      debugPrint('Clearing user context failed: $e');
    }
  }
}