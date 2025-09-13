import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/network/api_result.dart';
import '../../domain/entities/google_sign_in_result.dart';
import 'backend_auth_service.dart';

/// Service for handling Google Sign-In with Backend Integration
class GoogleSignInService {
  GoogleSignInService({BackendAuthService? backendAuthService})
      : _backendAuthService = backendAuthService;

  final BackendAuthService? _backendAuthService;

  // GoogleSignIn instance
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  /// Sign in with Google (Backend Integration)
  Future<ApiResult<GoogleSignInResult>> signIn() async {
    // For backend integration, use the backend OAuth flow
    if (_backendAuthService != null) {
      debugPrint('GoogleSignIn: Using backend OAuth flow');
      final result = await _backendAuthService.initiateGoogleAuth();

      if (result.isSuccess) {
        // Return a placeholder result - actual auth will be handled by backend callback
        const googleResult = GoogleSignInResult(
          idToken: 'backend_oauth_initiated',
          accessToken: 'backend_oauth_initiated',
          email: 'oauth@tourlicity.com',
          displayName: 'OAuth User',
          photoUrl: null,
        );
        return const ApiSuccess(data: googleResult);
      } else {
        return ApiFailure(
            message: result.error ?? 'Backend OAuth initiation failed');
      }
    }

    // Fallback to direct Google Sign-In (for testing)
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return const ApiFailure(message: 'Google sign-in was cancelled');
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      final accessToken = authentication.accessToken;

      if (idToken == null || accessToken == null) {
        return const ApiFailure(message: 'Failed to get authentication tokens');
      }

      final result = GoogleSignInResult(
        idToken: idToken,
        accessToken: accessToken,
        email: account.email,
        displayName: account.displayName ?? '',
        photoUrl: account.photoUrl,
      );

      return ApiSuccess(data: result);
    } catch (e) {
      return ApiFailure(message: 'Google sign-in failed: ${e.toString()}');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore sign out errors
    }
  }

  /// Check if user is signed in to Google
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// Get current Google account
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
