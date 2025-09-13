import 'package:flutter/foundation.dart';
import '../firebase/firebase_config.dart';
import '../analytics/analytics_service.dart';
import '../monitoring/crash_reporting_service.dart';
import '../monitoring/performance_monitoring_service.dart';
import '../logging/error_logger.dart';
import '../feedback/feedback_service.dart';

/// Central monitoring service that coordinates all monitoring and analytics
class MonitoringService {
  static MonitoringService? _instance;
  
  late final AnalyticsService _analytics;
  late final CrashReportingService _crashReporting;
  late final PerformanceMonitoringService _performance;
  late final ErrorLogger _errorLogger;
  late final FeedbackService _feedback;
  
  bool _isInitialized = false;

  MonitoringService._();

  /// Get singleton instance
  static MonitoringService get instance {
    _instance ??= MonitoringService._();
    return _instance!;
  }

  /// Initialize all monitoring services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase first
      await FirebaseConfig.initialize();
      
      // Initialize all services with stub implementations for development
      if (kDebugMode) {
        debugPrint('Using stub monitoring services for development');
        _isInitialized = true;
        return;
      }
      
      // Initialize real services for production
      _analytics = AnalyticsService.instance;
      _crashReporting = CrashReportingService.instance;
      _performance = PerformanceMonitoringService.instance;
      _errorLogger = ErrorLogger.instance;
      _feedback = FeedbackService.instance;
      
      _isInitialized = true;
      
      debugPrint('Monitoring services initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize monitoring services: $e');
      // Don't rethrow in development
      if (!kDebugMode) {
        rethrow;
      }
      _isInitialized = true; // Mark as initialized even if failed
    }
  }

  /// Set user context across all monitoring services
  Future<void> setUserContext({
    required String userId,
    required String userType,
    String? providerId,
    String? email,
    String? country,
  }) async {
    if (!_isInitialized) return;

    try {
      await _errorLogger.setUserContext(
        userId: userId,
        userType: userType,
        providerId: providerId,
        email: email,
      );

      await _analytics.setUserProperties(
        userType: userType,
        providerId: providerId,
        country: country,
      );

      await _crashReporting.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Failed to set user context: $e');
    }
  }

  /// Clear user context from all monitoring services
  Future<void> clearUserContext() async {
    if (!_isInitialized) return;

    try {
      await _errorLogger.clearUserContext();
      await _analytics.trackLogout();
    } catch (e) {
      debugPrint('Failed to clear user context: $e');
    }
  }

  /// Track user login across all services
  Future<void> trackLogin({
    required String method,
    required String userId,
    required String userType,
    String? providerId,
  }) async {
    if (!_isInitialized) return;

    try {
      await _analytics.trackLogin(method, userId);
      await setUserContext(
        userId: userId,
        userType: userType,
        providerId: providerId,
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to track login',
        exception: e,
        category: 'monitoring_error',
      );
    }
  }

  /// Track screen navigation with performance monitoring
  Future<void> trackScreenNavigation({
    required String screenName,
    required String screenClass,
  }) async {
    if (!_isInitialized) return;

    try {
      await _analytics.trackScreenView(screenName, screenClass);
      await _performance.trackScreenLoad(screenName);
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to track screen navigation',
        exception: e,
        category: 'monitoring_error',
        additionalData: {
          'screen_name': screenName,
          'screen_class': screenClass,
        },
      );
    }
  }

  /// Complete screen loading tracking
  Future<void> completeScreenLoad(String screenName) async {
    if (!_isInitialized) return;

    try {
      await _performance.completeScreenLoad(screenName);
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to complete screen load tracking',
        exception: e,
        category: 'monitoring_error',
        additionalData: {'screen_name': screenName},
      );
    }
  }

  /// Track API call with comprehensive monitoring
  Future<T> trackApiCall<T>({
    required String endpoint,
    required String method,
    required Future<T> Function() apiCall,
    Map<String, dynamic>? requestData,
  }) async {
    if (!_isInitialized) {
      return await apiCall();
    }

    final requestId = '${method}_${endpoint.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      await _performance.startHttpMetric(
        url: endpoint,
        httpMethod: method,
        requestId: requestId,
      );

      final result = await apiCall();

      await _performance.stopHttpMetric(
        url: endpoint,
        httpMethod: method,
        responseCode: 200,
        requestId: requestId,
      );

      return result;
    } catch (e, stackTrace) {
      await _performance.stopHttpMetric(
        url: endpoint,
        httpMethod: method,
        responseCode: 500,
        requestId: requestId,
      );

      await _errorLogger.logApiError(
        endpoint: endpoint,
        method: method,
        statusCode: 500,
        errorMessage: e.toString(),
        exception: e,
        stackTrace: stackTrace,
        requestData: requestData,
      );

      rethrow;
    }
  }

  /// Track user interaction with performance monitoring
  Future<void> trackUserInteraction({
    required String interaction,
    required String component,
    Map<String, String>? additionalAttributes,
  }) async {
    if (!_isInitialized) return;

    try {
      await _analytics.trackUserEngagement(
        action: interaction,
        category: 'user_interaction',
        label: component,
      );

      await _performance.trackUserInteraction(
        interaction: interaction,
        component: component,
        additionalAttributes: additionalAttributes,
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to track user interaction',
        exception: e,
        category: 'monitoring_error',
        additionalData: {
          'interaction': interaction,
          'component': component,
        },
      );
    }
  }

  /// Complete user interaction tracking
  Future<void> completeUserInteraction({
    required String interaction,
    required String component,
    bool success = true,
  }) async {
    if (!_isInitialized) return;

    try {
      await _performance.completeUserInteraction(
        interaction: interaction,
        component: component,
        success: success,
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to complete user interaction tracking',
        exception: e,
        category: 'monitoring_error',
      );
    }
  }

  /// Track business events with analytics
  Future<void> trackBusinessEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      switch (eventName) {
        case 'tour_registration':
          await _analytics.trackTourRegistration(
            tourId: parameters?['tour_id'] ?? '',
            tourName: parameters?['tour_name'] ?? '',
            providerId: parameters?['provider_id'] ?? '',
          );
          break;
        case 'tour_creation':
          await _analytics.trackTourCreation(
            tourId: parameters?['tour_id'] ?? '',
            tourName: parameters?['tour_name'] ?? '',
            templateId: parameters?['template_id'] ?? '',
          );
          break;
        case 'document_upload':
          await _analytics.trackDocumentUpload(
            documentType: parameters?['document_type'] ?? '',
            fileSize: parameters?['file_size']?.toString() ?? '',
            success: parameters?['success'] ?? false,
          );
          break;
        case 'message_sent':
          await _analytics.trackMessageSent(
            messageType: parameters?['message_type'] ?? '',
            recipientType: parameters?['recipient_type'] ?? '',
            recipientCount: parameters?['recipient_count'] ?? 0,
          );
          break;
        default:
          await _analytics.trackUserEngagement(
            action: eventName,
            category: 'business_event',
          );
      }
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to track business event',
        exception: e,
        category: 'monitoring_error',
        additionalData: {
          'event_name': eventName,
          'parameters': parameters,
        },
      );
    }
  }

  /// Track performance metrics
  Future<void> trackPerformanceMetric({
    required String metricName,
    required double value,
    String? unit,
  }) async {
    if (!_isInitialized) return;

    try {
      await _analytics.trackPerformance(
        metricName: metricName,
        value: value,
        unit: unit,
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to track performance metric',
        exception: e,
        category: 'monitoring_error',
        additionalData: {
          'metric_name': metricName,
          'value': value,
          'unit': unit,
        },
      );
    }
  }

  /// Get monitoring status
  Future<Map<String, bool>> getMonitoringStatus() async {
    return {
      'initialized': _isInitialized,
      'analytics_enabled': _isInitialized,
      'crash_reporting_enabled': _isInitialized ? _crashReporting.isCrashCollectionEnabled : false,
      'performance_monitoring_enabled': _isInitialized ? await _performance.isPerformanceCollectionEnabled : false,
    };
  }

  /// Enable or disable monitoring services
  Future<void> setMonitoringEnabled({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? performanceMonitoringEnabled,
  }) async {
    if (!_isInitialized) return;

    try {
      if (crashReportingEnabled != null) {
        await _crashReporting.setCrashCollectionEnabled(crashReportingEnabled);
      }
      
      if (performanceMonitoringEnabled != null) {
        await _performance.setPerformanceCollectionEnabled(performanceMonitoringEnabled);
      }
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to update monitoring settings',
        exception: e,
        category: 'monitoring_error',
      );
    }
  }

  /// Cleanup all monitoring services
  Future<void> cleanup() async {
    if (!_isInitialized) return;

    try {
      await _performance.cleanup();
      await clearUserContext();
    } catch (e) {
      debugPrint('Failed to cleanup monitoring services: $e');
    }
  }

  /// Get analytics service
  AnalyticsService get analytics => _analytics;

  /// Get crash reporting service
  CrashReportingService get crashReporting => _crashReporting;

  /// Get performance monitoring service
  PerformanceMonitoringService get performance => _performance;

  /// Get error logger
  ErrorLogger get errorLogger => _errorLogger;

  /// Get feedback service
  FeedbackService get feedback => _feedback;
}