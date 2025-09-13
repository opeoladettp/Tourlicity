import 'api_result.dart';

/// Abstract API client interface
abstract class ApiClient {
  /// GET request
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// POST request
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// PUT request
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// DELETE request
  Future<ApiResult<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// PATCH request
  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  /// Upload file
  Future<ApiResult<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
  });
}
