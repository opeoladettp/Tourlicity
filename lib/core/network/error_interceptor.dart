import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Interceptor that handles error responses and converts them to custom exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapDioExceptionToApiException(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: exception,
      message: exception.message,
    ));
  }

  /// Map Dio exceptions to custom API exceptions
  ApiException _mapDioExceptionToApiException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          message:
              'Request timeout. Please check your connection and try again.',
          statusCode: null,
          errorCode: 'TIMEOUT',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message:
              'Network connection failed. Please check your internet connection.',
          statusCode: null,
          errorCode: 'CONNECTION_ERROR',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException);

      case DioExceptionType.cancel:
        return const ClientException(
          message: 'Request was cancelled',
          statusCode: null,
          errorCode: 'CANCELLED',
        );

      case DioExceptionType.unknown:
        return NetworkException(
          message: 'An unexpected error occurred: ${dioException.message}',
          statusCode: null,
          errorCode: 'UNKNOWN',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Certificate verification failed',
          statusCode: null,
          errorCode: 'BAD_CERTIFICATE',
        );
    }
  }

  /// Handle bad response errors based on status code
  ApiException _handleBadResponse(DioException dioException) {
    final response = dioException.response;
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Extract error message from response
    String message = 'An error occurred';
    String? errorCode;
    Map<String, List<String>>? fieldErrors;

    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ?? data['error'] as String? ?? message;
      errorCode = data['error_code'] as String?;

      // Handle validation errors
      if (data['errors'] is Map<String, dynamic>) {
        fieldErrors = (data['errors'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => e.toString()).toList(),
          ),
        );
      }
    }

    switch (statusCode) {
      case 400:
        if (fieldErrors != null) {
          return ValidationException(
            message: message,
            statusCode: statusCode,
            errorCode: errorCode,
            fieldErrors: fieldErrors,
          );
        }
        return ClientException(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

      case 401:
        return AuthenticationException(
          message: message.isEmpty ? 'Authentication failed' : message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

      case 403:
        return AuthorizationException(
          message: message.isEmpty ? 'Access denied' : message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

      case 404:
        return ClientException(
          message: message.isEmpty ? 'Resource not found' : message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

      case 422:
        return ValidationException(
          message: message.isEmpty ? 'Validation failed' : message,
          statusCode: statusCode,
          errorCode: errorCode,
          fieldErrors: fieldErrors,
        );

      case 429:
        return RateLimitException(
          message: message.isEmpty
              ? 'Too many requests. Please try again later.'
              : message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

      case int code when code >= 500:
        return ServerException(
          message: message.isEmpty
              ? 'Server error. Please try again later.'
              : message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

      default:
        return ClientException(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );
    }
  }
}
