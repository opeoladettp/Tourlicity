/// Base class for API results
sealed class ApiResult<T> {
  const ApiResult();

  /// Check if the result is successful
  bool get isSuccess => this is ApiSuccess<T>;

  /// Check if the result is a failure
  bool get isFailure => this is ApiFailure<T>;

  /// Get data if successful, null otherwise
  T? get data => switch (this) {
        ApiSuccess<T>(data: final data) => data,
        ApiFailure<T>() => null,
      };

  /// Get error message if failed, null otherwise
  String? get error => switch (this) {
        ApiSuccess<T>() => null,
        ApiFailure<T>(message: final message) => message,
      };

  /// Fold the result into a single value
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onFailure,
  }) {
    return switch (this) {
      ApiSuccess<T>(data: final data) => onSuccess(data),
      ApiFailure<T>(message: final message) => onFailure(message),
    };
  }
}

/// Successful API result
class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess({required this.data});

  @override
  final T data;

  @override
  String toString() => 'ApiSuccess(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiSuccess<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Failed API result
class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'ApiFailure(message: $message, statusCode: $statusCode, errorCode: $errorCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiFailure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(message, statusCode, errorCode);
}
