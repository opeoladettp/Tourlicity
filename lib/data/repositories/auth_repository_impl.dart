import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_type.dart';
import '../../domain/entities/google_sign_in_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/network/api_result.dart';
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../services/google_sign_in_service.dart';
import '../services/backend_auth_service.dart';
import '../models/auth_user_model.dart';
import '../models/google_auth_request_model.dart';

/// Implementation of AuthRepository with Backend Integration
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
    required GoogleSignInService googleSignInService,
    BackendAuthService? backendAuthService,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage,
        _googleSignInService = googleSignInService,
        _backendAuthService = backendAuthService;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final GoogleSignInService _googleSignInService;
  final BackendAuthService? _backendAuthService;

  @override
  Future<ApiResult<GoogleSignInResult>> signInWithGoogle() async {
    return await _googleSignInService.signIn();
  }

  @override
  Future<ApiResult<AuthUser>> authenticateWithGoogle({
    required String idToken,
    required String accessToken,
  }) async {
    try {
      // Use backend auth service if available
      if (_backendAuthService != null) {
        // For backend integration, initiate OAuth flow
        final result = await _backendAuthService.initiateGoogleAuth();
        if (result.isSuccess) {
          // Return a temporary user - actual auth will be completed via callback
          const tempUser = User(
            id: 'temp_oauth_user',
            email: 'oauth@tourlicity.com',
            name: 'OAuth User',
            role: UserRole.tourist,
            isProfileComplete: false,
          );
          const authUser = AuthUser(
            user: tempUser,
            accessToken: 'oauth_initiated',
            refreshToken: 'oauth_initiated',
          );
          return const ApiSuccess(data: authUser);
        } else {
          return ApiFailure(message: result.error ?? 'OAuth initiation failed');
        }
      }

      // Fallback to direct API call
      final request = GoogleAuthRequestModel(
        idToken: idToken,
        accessToken: accessToken,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/google',
        data: request.toJson(),
      );

      return response.fold(
        onSuccess: (data) async {
          final authUserModel = AuthUserModel.fromJson(data);
          final authUser = authUserModel.toEntity();

          // Store tokens securely
          await _tokenStorage.saveTokens(
            accessToken: authUser.accessToken,
            refreshToken: authUser.refreshToken,
          );

          return ApiSuccess(data: authUser);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Authentication failed: ${e.toString()}',
        statusCode: 401,
      );
    }
  }

  @override
  Future<ApiResult<AuthUser?>> getCurrentUser() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null) {
        return const ApiSuccess(data: null);
      }

      // Use backend auth service if available
      if (_backendAuthService != null) {
        final result = await _backendAuthService.getCurrentUser();
        return result.fold(
          onSuccess: (user) => ApiSuccess(data: user),
          onFailure: (error) {
            // If token is invalid, clear stored tokens
            _tokenStorage.clearTokens();
            return ApiFailure(message: error);
          },
        );
      }

      // Fallback to direct API call
      final response =
          await _apiClient.get<Map<String, dynamic>>('/users/profile');

      return response.fold(
        onSuccess: (data) {
          final authUserModel = AuthUserModel.fromJson(data);
          return ApiSuccess(data: authUserModel.toEntity());
        },
        onFailure: (error) {
          // If token is invalid, clear stored tokens
          _tokenStorage.clearTokens();
          return ApiFailure(message: error);
        },
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get current user: ${e.toString()}',
        statusCode: 401,
      );
    }
  }

  @override
  Future<ApiResult<AuthUser>> refreshTokens() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        return const ApiFailure(
          message: 'No refresh token available',
          statusCode: 401,
        );
      }

      // Use backend auth service if available
      if (_backendAuthService != null) {
        final result = await _backendAuthService.refreshToken(refreshToken);
        return result.fold(
          onSuccess: (tokens) async {
            // Store new tokens
            await _tokenStorage.saveTokens(
              accessToken: tokens['accessToken'],
              refreshToken: tokens['refreshToken'],
            );

            // Get updated user info
            final userResult = await _backendAuthService.getCurrentUser();
            return userResult.fold(
              onSuccess: (user) => ApiSuccess(data: user),
              onFailure: (error) => ApiFailure(message: error),
            );
          },
          onFailure: (error) async {
            // Clear tokens if refresh fails
            await _tokenStorage.clearTokens();
            return ApiFailure(message: error);
          },
        );
      }

      // Fallback to direct API call
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      return response.fold(
        onSuccess: (data) async {
          final tokens = data['tokens'];

          // Store new tokens
          await _tokenStorage.saveTokens(
            accessToken: tokens['accessToken'],
            refreshToken: tokens['refreshToken'],
          );

          // Get user info from response or make another call
          final userResult = await getCurrentUser();
          return userResult.fold(
            onSuccess: (user) => ApiSuccess(data: user!),
            onFailure: (error) => ApiFailure(message: error),
          );
        },
        onFailure: (error) async {
          // Clear tokens if refresh fails
          await _tokenStorage.clearTokens();
          return ApiFailure(message: error);
        },
      );
    } catch (e) {
      await _tokenStorage.clearTokens();
      return ApiFailure(
        message: 'Token refresh failed: ${e.toString()}',
        statusCode: 401,
      );
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      // Sign out from Google
      await _googleSignInService.signOut();

      // Clear stored tokens
      await _tokenStorage.clearTokens();

      // Optionally call backend logout endpoint
      try {
        await _apiClient.post('/auth/logout', data: {});
      } catch (e) {
        // Ignore backend logout errors as local cleanup is more important
      }

      return const ApiSuccess(data: null);
    } catch (e) {
      return ApiFailure(
        message: 'Sign out failed: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      return accessToken != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    await _tokenStorage.clearTokens();
    await _googleSignInService.signOut();
  }
}
