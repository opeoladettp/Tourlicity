import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'api_exception.dart';

/// Interceptor that handles authentication headers and token refresh
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  final String _refreshEndpoint;

  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio dio,
    String refreshEndpoint = '/auth/refresh',
  })  : _tokenStorage = tokenStorage,
        _dio = dio,
        _refreshEndpoint = refreshEndpoint;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login and refresh endpoints
    if (_shouldSkipAuth(options.path)) {
      return handler.next(options);
    }

    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors with token refresh
    if (err.response?.statusCode == 401 &&
        !_shouldSkipAuth(err.requestOptions.path)) {
      try {
        await _handleTokenRefresh();

        // Retry the original request with new token
        final accessToken = await _tokenStorage.getAccessToken();
        if (accessToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (refreshError) {
        // Token refresh failed, clear tokens and let the error propagate
        await _tokenStorage.clearTokens();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  /// Refresh the access token using the refresh token
  Future<void> _handleTokenRefresh() async {
    if (_isRefreshing) {
      // If already refreshing, wait for completion
      await _waitForRefresh();
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw const AuthenticationException(
          message: 'No refresh token available',
          statusCode: 401,
        );
      }

      final response = await _dio.post(
        _refreshEndpoint,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );

      final newAccessToken = response.data['access_token'] as String?;
      final newRefreshToken = response.data['refresh_token'] as String?;

      if (newAccessToken == null || newRefreshToken == null) {
        throw const AuthenticationException(
          message: 'Invalid token refresh response',
          statusCode: 401,
        );
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Process any pending requests
      _processPendingRequests();
    } finally {
      _isRefreshing = false;
    }
  }

  /// Wait for ongoing token refresh to complete
  Future<void> _waitForRefresh() async {
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Process requests that were queued during token refresh
  void _processPendingRequests() {
    for (final request in _pendingRequests) {
      _dio.fetch(request);
    }
    _pendingRequests.clear();
  }

  /// Check if authentication should be skipped for this endpoint
  bool _shouldSkipAuth(String path) {
    const skipAuthPaths = [
      '/auth/login',
      '/auth/refresh',
      '/auth/google',
    ];

    return skipAuthPaths.any((skipPath) => path.contains(skipPath));
  }
}
