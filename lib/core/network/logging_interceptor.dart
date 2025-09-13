import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// Interceptor for logging HTTP requests and responses in debug mode
class LoggingInterceptor extends Interceptor {
  final bool logRequests;
  final bool logResponses;
  final bool logErrors;

  const LoggingInterceptor({
    this.logRequests = true,
    this.logResponses = true,
    this.logErrors = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequests) {
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponses) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logErrors) {
      _logError(err);
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final uri = options.uri;
    final method = options.method.toUpperCase();

    developer.log(
      '🚀 REQUEST [$method] $uri',
      name: 'API_CLIENT',
    );

    if (options.headers.isNotEmpty) {
      final headers = Map<String, dynamic>.from(options.headers);
      // Mask sensitive headers
      if (headers.containsKey('Authorization')) {
        headers['Authorization'] = '***MASKED***';
      }

      developer.log(
        '📋 Headers: $headers',
        name: 'API_CLIENT',
      );
    }

    if (options.data != null) {
      developer.log(
        '📦 Body: ${options.data}',
        name: 'API_CLIENT',
      );
    }

    if (options.queryParameters.isNotEmpty) {
      developer.log(
        '🔍 Query: ${options.queryParameters}',
        name: 'API_CLIENT',
      );
    }
  }

  void _logResponse(Response response) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method.toUpperCase();
    final statusCode = response.statusCode;

    developer.log(
      '✅ RESPONSE [$method] $uri [$statusCode]',
      name: 'API_CLIENT',
    );

    if (response.headers.map.isNotEmpty) {
      developer.log(
        '📋 Headers: ${response.headers.map}',
        name: 'API_CLIENT',
      );
    }

    if (response.data != null) {
      final dataString = response.data.toString();
      // Truncate very long responses
      final truncatedData = dataString.length > 1000
          ? '${dataString.substring(0, 1000)}...[TRUNCATED]'
          : dataString;

      developer.log(
        '📦 Data: $truncatedData',
        name: 'API_CLIENT',
      );
    }
  }

  void _logError(DioException err) {
    final uri = err.requestOptions.uri;
    final method = err.requestOptions.method.toUpperCase();
    final statusCode = err.response?.statusCode;

    developer.log(
      '❌ ERROR [$method] $uri ${statusCode != null ? '[$statusCode]' : ''}',
      name: 'API_CLIENT',
      error: err.message,
    );

    if (err.response?.data != null) {
      developer.log(
        '📦 Error Data: ${err.response?.data}',
        name: 'API_CLIENT',
      );
    }
  }
}
