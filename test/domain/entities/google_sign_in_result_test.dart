import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/google_sign_in_result.dart';

void main() {
  group('GoogleSignInResult', () {
    const googleSignInResult = GoogleSignInResult(
      idToken: 'id_token',
      accessToken: 'access_token',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
    );

    test('should create GoogleSignInResult with all properties', () {
      expect(googleSignInResult.idToken, 'id_token');
      expect(googleSignInResult.accessToken, 'access_token');
      expect(googleSignInResult.email, 'test@example.com');
      expect(googleSignInResult.displayName, 'Test User');
      expect(googleSignInResult.photoUrl, 'https://example.com/photo.jpg');
    });

    test('should support equality comparison', () {
      const result1 = GoogleSignInResult(
        idToken: 'id_token',
        accessToken: 'access_token',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      const result2 = GoogleSignInResult(
        idToken: 'id_token',
        accessToken: 'access_token',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      expect(result1, equals(result2));
    });

    test('should handle null photoUrl', () {
      const resultWithoutPhoto = GoogleSignInResult(
        idToken: 'id_token',
        accessToken: 'access_token',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      expect(resultWithoutPhoto.photoUrl, isNull);
    });
  });
}
