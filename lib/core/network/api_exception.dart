/// Custom exceptions for API operations
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => 'ApiException: $message';
}

/// Network connectivity issues
class NetworkException extends ApiException {
  const NetworkException({
    required super.message,
    super.statusCode,
    super.errorCode,
  });
}

/// Authentication related errors
class AuthenticationException extends ApiException {
  const AuthenticationException({
    required super.message,
    super.statusCode,
    super.errorCode,
  });
}

/// Authorization related errors
class AuthorizationException extends ApiException {
  const AuthorizationException({
    required super.message,
    super.statusCode,
    super.errorCode,
  });
}

/// Server errors (5xx)
class ServerException extends ApiException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.errorCode,
  });
}

/// Client errors (4xx)
class ClientException extends ApiException {
  const ClientException({
    required super.message,
    super.statusCode,
    super.errorCode,
  });
}

/// Request timeout errors
class TimeoutException extends ApiException {
  const TimeoutException({
    required super.message,
    super.statusCode,
    super.errorCode,
  });
}

/// Rate limiting errors
class RateLimitException extends ApiException {
  const RateLimitException({
    required super.message,
    super.statusCode,
    super.errorCode,
  });
}

/// Validation errors
class ValidationException extends ApiException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.statusCode,
    super.errorCode,
    this.fieldErrors,
  });
}
