import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_result.dart';
import '../../core/config/environment_config.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_model.dart';

/// Backend authentication service for Tourlicity API
class BackendAuthService {
  BackendAuthService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Initiate Google OAuth flow by opening browser
  Future<ApiResult<bool>> initiateGoogleAuth({String? state}) async {
    try {
      final authUrl = EnvironmentConfig.googleAuthUrl;
      final urlWithState = state != null ? '$authUrl?state=$state' : authUrl;

      debugPrint('BackendAuth: Initiating Google OAuth at $urlWithState');

      final uri = Uri.parse(urlWithState);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        return const ApiFailure(message: 'Could not launch OAuth URL');
      }

      return const ApiSuccess(data: true);
    } catch (e) {
      return ApiFailure(message: 'Failed to initiate OAuth: ${e.toString()}');
    }
  }

  /// Handle OAuth callback (for web/deep linking)
  Future<ApiResult<AuthUser>> handleOAuthCallback({
    required String code,
    String? state,
  }) async {
    try {
      debugPrint(
          'BackendAuth: Handling OAuth callback with code: ${code.substring(0, 10)}...');

      final response = await _dio.get(
        '/auth/google/callback',
        queryParameters: {
          'code': code,
          if (state != null) 'state': state,
        },
      );

      if (response.data['success'] == true) {
        final userData = response.data['data'];
        final userModel = AuthUserModel.fromJson(userData['user']);

        // Store tokens if provided
        final tokens = userData['tokens'];
        if (tokens != null) {
          // Tokens will be handled by the auth repository
          debugPrint('BackendAuth: Received tokens from backend');
        }

        return ApiSuccess(data: userModel.toEntity());
      } else {
        return ApiFailure(
            message:
                response.data['error']?['message'] ?? 'OAuth callback failed');
      }
    } on DioException catch (e) {
      return ApiFailure(message: _handleDioError(e));
    } catch (e) {
      return ApiFailure(message: 'OAuth callback error: ${e.toString()}');
    }
  }

  /// Refresh access token
  Future<ApiResult<Map<String, dynamic>>> refreshToken(
      String refreshToken) async {
    try {
      debugPrint('BackendAuth: Refreshing access token');

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.data['success'] == true) {
        final tokens = response.data['data']['tokens'];
        return ApiSuccess(data: tokens);
      } else {
        return ApiFailure(
            message:
                response.data['error']?['message'] ?? 'Token refresh failed');
      }
    } on DioException catch (e) {
      return ApiFailure(message: _handleDioError(e));
    } catch (e) {
      return ApiFailure(message: 'Token refresh error: ${e.toString()}');
    }
  }

  /// Complete user profile
  Future<ApiResult<AuthUser>> completeProfile({
    required String name,
    required String phone,
  }) async {
    try {
      debugPrint('BackendAuth: Completing user profile');

      final response = await _dio.post(
        '/auth/profile/complete',
        data: {
          'name': name,
          'phone': phone,
        },
      );

      if (response.data['success'] == true) {
        final userData = response.data['data']['user'];
        final userModel = AuthUserModel.fromJson(userData);
        return ApiSuccess(data: userModel.toEntity());
      } else {
        return ApiFailure(
            message: response.data['error']?['message'] ??
                'Profile completion failed');
      }
    } on DioException catch (e) {
      return ApiFailure(message: _handleDioError(e));
    } catch (e) {
      return ApiFailure(message: 'Profile completion error: ${e.toString()}');
    }
  }

  /// Logout user
  Future<ApiResult<bool>> logout() async {
    try {
      debugPrint('BackendAuth: Logging out user');

      final response = await _dio.post('/auth/logout');

      if (response.data['success'] == true) {
        return const ApiSuccess(data: true);
      } else {
        return ApiFailure(
            message: response.data['error']?['message'] ?? 'Logout failed');
      }
    } on DioException catch (e) {
      // Logout should succeed even if the server request fails
      debugPrint(
          'BackendAuth: Logout request failed, but continuing: ${_handleDioError(e)}');
      return const ApiSuccess(data: true);
    } catch (e) {
      debugPrint('BackendAuth: Logout error, but continuing: ${e.toString()}');
      return const ApiSuccess(data: true);
    }
  }

  /// Get current user profile
  Future<ApiResult<AuthUser>> getCurrentUser() async {
    try {
      debugPrint('BackendAuth: Getting current user profile');

      final response = await _dio.get('/users/profile');

      if (response.data['success'] == true) {
        final userData = response.data['data'];
        final userModel = AuthUserModel.fromJson(userData);
        return ApiSuccess(data: userModel.toEntity());
      } else {
        return ApiFailure(
            message: response.data['error']?['message'] ??
                'Failed to get user profile');
      }
    } on DioException catch (e) {
      return ApiFailure(message: _handleDioError(e));
    } catch (e) {
      return ApiFailure(message: 'Get user profile error: ${e.toString()}');
    }
  }

  /// Check backend health
  Future<ApiResult<Map<String, dynamic>>> checkHealth() async {
    try {
      final healthUrl = EnvironmentConfig.healthCheckUrl;
      debugPrint('BackendAuth: Checking backend health at $healthUrl');

      final response = await _dio.get('/health');

      if (response.statusCode == 200) {
        return ApiSuccess(data: response.data);
      } else {
        return const ApiFailure(message: 'Backend health check failed');
      }
    } on DioException catch (e) {
      return ApiFailure(
          message: 'Backend health check error: ${_handleDioError(e)}');
    } catch (e) {
      return ApiFailure(message: 'Health check error: ${e.toString()}');
    }
  }

  /// Handle Dio errors with proper error messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - please check your internet connection';
      case DioExceptionType.sendTimeout:
        return 'Request timeout - please try again';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout - please try again';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;

        if (errorData is Map && errorData['error'] != null) {
          return errorData['error']['message'] ?? 'Server error ($statusCode)';
        }

        switch (statusCode) {
          case 400:
            return 'Bad request - please check your input';
          case 401:
            return 'Authentication failed - please sign in again';
          case 403:
            return 'Access denied - insufficient permissions';
          case 404:
            return 'Resource not found';
          case 429:
            return 'Too many requests - please try again later';
          case 500:
            return 'Server error - please try again later';
          default:
            return 'Server error ($statusCode)';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error - please check your internet connection';
      case DioExceptionType.badCertificate:
        return 'Security certificate error';
      case DioExceptionType.unknown:
        return 'Network error - please try again';
    }
  }
}
