import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_result.dart';
import '../security/certificate_pinning.dart';
import '../security/request_signer.dart';
import '../security/secure_session_manager.dart';

/// Dio implementation of ApiClient with enhanced security features
class DioApiClient implements ApiClient {
  DioApiClient({
    required Dio dio,
    required SecureSessionManager sessionManager,
    RequestSigner? requestSigner,
    RequestSigningConfig? signingConfig,
  })  : _dio = dio,
        _sessionManager = sessionManager,
        _requestSigner = requestSigner,
        _signingConfig = signingConfig {
    _setupInterceptors();
  }

  final Dio _dio;
  final SecureSessionManager _sessionManager;
  final RequestSigner? _requestSigner;
  final RequestSigningConfig? _signingConfig;

  void _setupInterceptors() {
    // Certificate pinning interceptor (only in production)
    _dio.interceptors
        .add(CertificatePinning.createCertificatePinningInterceptor());

    // Security and auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Validate session
        final sessionValidation = await _sessionManager.validateSession();
        if (!sessionValidation.isValid) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              message: 'Session invalid: ${sessionValidation.errorMessage}',
            ),
          );
          return;
        }

        // Add authentication header
        final token = await _sessionManager.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Add request signing for critical endpoints
        if (_requestSigner != null &&
            _signingConfig != null &&
            _signingConfig.requiresSigning(options.path)) {
          await _addRequestSignature(options);
        }

        // Update session activity
        await _sessionManager.updateActivity();

        handler.next(options);
      },
      onResponse: (response, handler) async {
        // Update session activity on successful response
        await _sessionManager.updateActivity();
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token might be expired, try to refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final token = await _sessionManager.getAccessToken();
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';

              // Re-sign request if needed
              if (_requestSigner != null &&
                  _signingConfig != null &&
                  _signingConfig.requiresSigning(error.requestOptions.path)) {
                await _addRequestSignature(error.requestOptions);
              }

              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            }
          }
          // If refresh failed, clear session
          await _sessionManager.clearSession();
        }
        handler.next(error);
      },
    ));
  }

  /// Adds request signature for critical operations
  Future<void> _addRequestSignature(RequestOptions options) async {
    if (_requestSigner == null || _signingConfig == null) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce =
        _signingConfig.includeNonce ? NonceGenerator.generate() : null;

    final body = options.data is Map<String, dynamic>
        ? options.data as Map<String, dynamic>
        : <String, dynamic>{};

    final signature = _requestSigner.signRequest(
      method: options.method,
      path: options.path,
      body: body,
      timestamp: timestamp,
      nonce: nonce,
    );

    options.headers['X-Signature'] = signature;
    options.headers['X-Timestamp'] = timestamp.toString();
    if (nonce != null) {
      options.headers['X-Nonce'] = nonce;
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _sessionManager.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _sessionManager.updateTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      await _sessionManager.clearSession();
    }
    return false;
  }

  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiSuccess(data: response.data as T);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiSuccess(data: response.data as T);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiSuccess(data: response.data as T);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiSuccess(data: response.data as T);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiSuccess(data: response.data as T);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (fields != null) ...fields,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: headers),
      );
      return ApiSuccess(data: response.data as T);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  ApiFailure<T> _handleDioError<T>(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;
    String? errorCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          message = data['message'] ?? data['error'] ?? 'Server error occurred';
          errorCode = data['code']?.toString();
        } else {
          message = 'Server error occurred';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate error';
        break;
      case DioExceptionType.unknown:
        message = error.message ?? 'An unexpected error occurred';
        break;
    }

    return ApiFailure(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }
}
