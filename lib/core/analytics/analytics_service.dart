// Temporarily disabled Firebase import
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../firebase/firebase_config.dart';

/// Service for tracking user analytics and behavior (Stub implementation)
class AnalyticsService {
  static AnalyticsService? _instance;
  late final dynamic _analytics;

  AnalyticsService._() {
    _analytics = FirebaseConfig.analytics;
  }

  /// Get singleton instance
  static AnalyticsService get instance {
    _instance ??= AnalyticsService._();
    return _instance!;
  }

  /// Check if analytics is available
  bool get isAvailable => _analytics != null;

  /// Track user login (Stub implementation)
  Future<void> trackLogin(String method, String userId) async {
    debugPrint('Analytics (Stub): Login tracked - Method: $method, User: $userId');
  }

  /// Track user logout (Stub implementation)
  Future<void> trackLogout() async {
    debugPrint('Analytics (Stub): Logout tracked');
  }

  /// Track screen view (Stub implementation)
  Future<void> trackScreenView(String screenName, String screenClass) async {
    debugPrint('Analytics (Stub): Screen view tracked - $screenName ($screenClass)');
  }

  /// Track tour registration (Stub implementation)
  Future<void> trackTourRegistration({
    required String tourId,
    required String tourName,
    required String providerId,
  }) async {
    debugPrint('Analytics (Stub): Tour registration tracked - $tourName');
  }

  /// Track tour creation (Stub implementation)
  Future<void> trackTourCreation({
    required String tourId,
    required String tourName,
    required String templateId,
  }) async {
    debugPrint('Analytics (Stub): Tour creation tracked - $tourName');
  }

  /// Track document upload (Stub implementation)
  Future<void> trackDocumentUpload({
    required String documentType,
    required String fileSize,
    required bool success,
  }) async {
    debugPrint('Analytics (Stub): Document upload tracked - $documentType ($success)');
  }

  /// Track message sent (Stub implementation)
  Future<void> trackMessageSent({
    required String messageType,
    required String recipientType,
    required int recipientCount,
  }) async {
    debugPrint('Analytics (Stub): Message sent tracked - $messageType to $recipientCount recipients');
  }

  /// Track user engagement (Stub implementation)
  Future<void> trackUserEngagement({
    required String action,
    required String category,
    String? label,
    int? value,
  }) async {
    debugPrint('Analytics (Stub): User engagement tracked - $action in $category');
  }

  /// Track error occurrence (Stub implementation)
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    debugPrint('Analytics (Stub): Error tracked - $errorType: $errorMessage');
  }

  /// Track performance metrics (Stub implementation)
  Future<void> trackPerformance({
    required String metricName,
    required double value,
    String? unit,
  }) async {
    debugPrint('Analytics (Stub): Performance tracked - $metricName: $value${unit ?? ''}');
  }

  /// Set user properties (Stub implementation)
  Future<void> setUserProperties({
    required String userType,
    String? providerId,
    String? country,
  }) async {
    debugPrint('Analytics (Stub): User properties set - Type: $userType');
  }
}