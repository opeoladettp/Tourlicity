// Temporarily disabled flutter_secure_storage import
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Abstract interface for token storage
abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
}

/// Secure token storage implementation using SharedPreferences (Stub implementation)
class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      debugPrint('TokenStorage (Stub): Failed to get access token - $e');
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      debugPrint('TokenStorage (Stub): Failed to get refresh token - $e');
      return null;
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_accessTokenKey, accessToken),
        prefs.setString(_refreshTokenKey, refreshToken),
      ]);
      debugPrint('TokenStorage (Stub): Tokens saved');
    } catch (e) {
      debugPrint('TokenStorage (Stub): Failed to save tokens - $e');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_accessTokenKey),
        prefs.remove(_refreshTokenKey),
      ]);
      debugPrint('TokenStorage (Stub): Tokens cleared');
    } catch (e) {
      debugPrint('TokenStorage (Stub): Failed to clear tokens - $e');
    }
  }
}
