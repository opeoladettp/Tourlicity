import 'package:flutter/foundation.dart';
import '../analytics/analytics_service.dart';
import '../logging/error_logger.dart';
import '../network/api_client.dart';
import '../network/api_client_factory.dart';

/// Service for collecting user feedback and ratings
class FeedbackService {
  static FeedbackService? _instance;
  late final AnalyticsService _analytics;
  late final ErrorLogger _errorLogger;
  late final ApiClient _apiClient;

  FeedbackService._() {
    _analytics = AnalyticsService.instance;
    _errorLogger = ErrorLogger.instance;
    _apiClient = ApiClientFactory.create();
  }

  /// Get singleton instance
  static FeedbackService get instance {
    _instance ??= FeedbackService._();
    return _instance!;
  }

  /// Submit app rating
  Future<void> submitAppRating({
    required double rating,
    String? comment,
    String? userId,
    String? userType,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        action: 'app_rating',
        category: 'feedback',
        label: 'rating_${rating.toInt()}',
        value: rating.toInt(),
      );

      _errorLogger.logInfo(
        'User submitted app rating: $rating${comment != null ? ' - $comment' : ''}',
        category: 'feedback',
      );

      // Send to backend API
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/feedback/app-rating',
        data: {
          'rating': rating,
          'comment': comment,
          'user_id': userId,
          'user_type': userType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      result.fold(
        onSuccess: (data) {
          debugPrint('App rating submitted successfully: $rating');
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to send app rating to backend: $error',
            category: 'feedback_api_error',
            additionalData: {'rating': rating, 'user_id': userId},
          );
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to submit app rating',
        exception: e,
        category: 'feedback_error',
        additionalData: {
          'rating': rating,
          'user_id': userId,
          'user_type': userType,
        },
      );
    }
  }

  /// Submit tour rating
  Future<void> submitTourRating({
    required String tourId,
    required String tourName,
    required double rating,
    String? comment,
    String? userId,
    List<String>? categories,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        action: 'tour_rating',
        category: 'feedback',
        label: tourName,
        value: rating.toInt(),
      );

      _errorLogger.logInfo(
        'User submitted tour rating: $rating for tour $tourName',
        category: 'feedback',
      );

      // Send to backend API
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/feedback/tour-rating',
        data: {
          'tour_id': tourId,
          'tour_name': tourName,
          'rating': rating,
          'comment': comment,
          'user_id': userId,
          'categories': categories,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      result.fold(
        onSuccess: (data) {
          debugPrint(
              'Tour rating submitted successfully: $rating for $tourName');
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to send tour rating to backend: $error',
            category: 'feedback_api_error',
            additionalData: {
              'tour_id': tourId,
              'tour_name': tourName,
              'rating': rating,
              'user_id': userId,
            },
          );
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to submit tour rating',
        exception: e,
        category: 'feedback_error',
        additionalData: {
          'tour_id': tourId,
          'tour_name': tourName,
          'rating': rating,
          'user_id': userId,
          'categories': categories,
        },
      );
    }
  }

  /// Submit provider rating
  Future<void> submitProviderRating({
    required String providerId,
    required String providerName,
    required double rating,
    String? comment,
    String? userId,
    List<String>? categories,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        action: 'provider_rating',
        category: 'feedback',
        label: providerName,
        value: rating.toInt(),
      );

      _errorLogger.logInfo(
        'User submitted provider rating: $rating for provider $providerName',
        category: 'feedback',
      );

      // Send to backend API
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/feedback/provider-rating',
        data: {
          'provider_id': providerId,
          'provider_name': providerName,
          'rating': rating,
          'comment': comment,
          'user_id': userId,
          'categories': categories,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      result.fold(
        onSuccess: (data) {
          debugPrint(
              'Provider rating submitted successfully: $rating for $providerName');
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to send provider rating to backend: $error',
            category: 'feedback_api_error',
            additionalData: {
              'provider_id': providerId,
              'provider_name': providerName,
              'rating': rating,
              'user_id': userId,
            },
          );
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to submit provider rating',
        exception: e,
        category: 'feedback_error',
        additionalData: {
          'provider_id': providerId,
          'provider_name': providerName,
          'rating': rating,
          'user_id': userId,
          'categories': categories,
        },
      );
    }
  }

  /// Submit general feedback
  Future<void> submitGeneralFeedback({
    required String category,
    required String message,
    String? userId,
    String? userType,
    String? contactEmail,
    List<String>? attachments,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        action: 'general_feedback',
        category: 'feedback',
        label: category,
      );

      _errorLogger.logInfo(
        'User submitted general feedback: $category - $message',
        category: 'feedback',
      );

      // Send to backend API
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/feedback/general',
        data: {
          'category': category,
          'message': message,
          'user_id': userId,
          'user_type': userType,
          'contact_email': contactEmail,
          'attachments': attachments,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      result.fold(
        onSuccess: (data) {
          debugPrint(
              'General feedback submitted successfully: $category - $message');
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to send general feedback to backend: $error',
            category: 'feedback_api_error',
            additionalData: {
              'feedback_category': category,
              'user_id': userId,
              'user_type': userType,
            },
          );
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to submit general feedback',
        exception: e,
        category: 'feedback_error',
        additionalData: {
          'feedback_category': category,
          'user_id': userId,
          'user_type': userType,
          'contact_email': contactEmail,
        },
      );
    }
  }

  /// Submit bug report
  Future<void> submitBugReport({
    required String title,
    required String description,
    required String stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
    String? userId,
    String? userType,
    String? deviceInfo,
    String? appVersion,
    List<String>? attachments,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        action: 'bug_report',
        category: 'feedback',
        label: 'bug_report',
      );

      await _errorLogger.logError(
        message: 'User reported bug: $title',
        category: 'user_reported_bug',
        additionalData: {
          'title': title,
          'description': description,
          'steps_to_reproduce': stepsToReproduce,
          'expected_behavior': expectedBehavior,
          'actual_behavior': actualBehavior,
          'user_id': userId,
          'user_type': userType,
          'device_info': deviceInfo,
          'app_version': appVersion,
        },
      );

      // Send to backend API
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/feedback/bug-report',
        data: {
          'title': title,
          'description': description,
          'steps_to_reproduce': stepsToReproduce,
          'expected_behavior': expectedBehavior,
          'actual_behavior': actualBehavior,
          'user_id': userId,
          'user_type': userType,
          'device_info': deviceInfo,
          'app_version': appVersion,
          'attachments': attachments,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      result.fold(
        onSuccess: (data) {
          debugPrint('Bug report submitted successfully: $title');
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to send bug report to backend: $error',
            category: 'feedback_api_error',
            additionalData: {
              'bug_title': title,
              'user_id': userId,
            },
          );
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to submit bug report',
        exception: e,
        category: 'feedback_error',
        additionalData: {
          'bug_title': title,
          'user_id': userId,
        },
      );
    }
  }

  /// Submit feature request
  Future<void> submitFeatureRequest({
    required String title,
    required String description,
    required String justification,
    String? userId,
    String? userType,
    int? priority,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        action: 'feature_request',
        category: 'feedback',
        label: 'feature_request',
        value: priority,
      );

      _errorLogger.logInfo(
        'User submitted feature request: $title',
        category: 'feedback',
      );

      // Send to backend API
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/feedback/feature-request',
        data: {
          'title': title,
          'description': description,
          'justification': justification,
          'user_id': userId,
          'user_type': userType,
          'priority': priority,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      result.fold(
        onSuccess: (data) {
          debugPrint('Feature request submitted successfully: $title');
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to send feature request to backend: $error',
            category: 'feedback_api_error',
            additionalData: {
              'feature_title': title,
              'user_id': userId,
              'priority': priority,
            },
          );
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to submit feature request',
        exception: e,
        category: 'feedback_error',
        additionalData: {
          'feature_title': title,
          'user_id': userId,
          'priority': priority,
        },
      );
    }
  }

  /// Track user satisfaction survey response
  Future<void> submitSatisfactionSurvey({
    required Map<String, dynamic> responses,
    required String surveyId,
    String? userId,
    String? userType,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        action: 'satisfaction_survey',
        category: 'feedback',
        label: surveyId,
      );

      _errorLogger.logInfo(
        'User completed satisfaction survey: $surveyId',
        category: 'feedback',
      );

      // Send to backend API
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/feedback/satisfaction-survey',
        data: {
          'survey_id': surveyId,
          'responses': responses,
          'user_id': userId,
          'user_type': userType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      result.fold(
        onSuccess: (data) {
          debugPrint('Satisfaction survey submitted successfully: $surveyId');
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to send satisfaction survey to backend: $error',
            category: 'feedback_api_error',
            additionalData: {
              'survey_id': surveyId,
              'user_id': userId,
              'responses_count': responses.length,
            },
          );
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to submit satisfaction survey',
        exception: e,
        category: 'feedback_error',
        additionalData: {
          'survey_id': surveyId,
          'user_id': userId,
          'responses_count': responses.length,
        },
      );
    }
  }

  /// Track NPS (Net Promoter Score) response
  Future<void> submitNpsScore({
    required int score,
    String? reason,
    String? userId,
    String? userType,
    String? context,
  }) async {
    try {
      await _analytics.trackUserEngagement(
        action: 'nps_score',
        category: 'feedback',
        label: context ?? 'general',
        value: score,
      );

      _errorLogger.logInfo(
        'User submitted NPS score: $score${reason != null ? ' - $reason' : ''}',
        category: 'feedback',
      );

      // Send to backend API
      final result = await _apiClient.post<Map<String, dynamic>>(
        '/feedback/nps-score',
        data: {
          'score': score,
          'reason': reason,
          'user_id': userId,
          'user_type': userType,
          'context': context,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      result.fold(
        onSuccess: (data) {
          debugPrint('NPS score submitted successfully: $score');
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to send NPS score to backend: $error',
            category: 'feedback_api_error',
            additionalData: {
              'nps_score': score,
              'user_id': userId,
              'context': context,
            },
          );
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to submit NPS score',
        exception: e,
        category: 'feedback_error',
        additionalData: {
          'nps_score': score,
          'user_id': userId,
          'context': context,
        },
      );
    }
  }

  /// Get feedback statistics (for analytics)
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final result = await _apiClient.get<Map<String, dynamic>>(
        '/feedback/statistics',
      );

      return result.fold(
        onSuccess: (data) {
          return data;
        },
        onFailure: (error) {
          _errorLogger.logError(
            message: 'Failed to get feedback statistics from backend: $error',
            category: 'feedback_api_error',
          );
          return {
            'total_ratings': 0,
            'average_rating': 0.0,
            'total_feedback': 0,
            'bug_reports': 0,
            'feature_requests': 0,
          };
        },
      );
    } catch (e) {
      await _errorLogger.logError(
        message: 'Failed to get feedback statistics',
        exception: e,
        category: 'feedback_error',
      );
      return {};
    }
  }
}
