import '../entities/auth_user.dart';
import '../entities/google_sign_in_result.dart';
import '../../core/network/api_result.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with Google
  Future<ApiResult<GoogleSignInResult>> signInWithGoogle();

  /// Authenticate with backend using Google tokens
  Future<ApiResult<AuthUser>> authenticateWithGoogle({
    required String idToken,
    required String accessToken,
  });

  /// Get current authenticated user
  Future<ApiResult<AuthUser?>> getCurrentUser();

  /// Refresh authentication tokens
  Future<ApiResult<AuthUser>> refreshTokens();

  /// Sign out user
  Future<ApiResult<void>> signOut();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Clear all authentication data
  Future<void> clearAuthData();
}
