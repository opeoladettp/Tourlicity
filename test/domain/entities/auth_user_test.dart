import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/auth_user.dart';
import 'package:tourlicity_app/domain/entities/user.dart';
import 'package:tourlicity_app/domain/entities/user_type.dart';

void main() {
  group('AuthUser', () {
    late User testUser;
    late AuthUser authUser;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testUser = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        profilePicture: 'https://example.com/photo.jpg',
        role: UserRole.tourist,
        isProfileComplete: true,
        createdAt: testDate,
      );

      authUser = AuthUser(
        user: testUser,
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        expiresAt: testDate.add(const Duration(hours: 1)),
      );
    });

    test('should create AuthUser with all properties', () {
      expect(authUser.user, equals(testUser));
      expect(authUser.accessToken, 'access_token_123');
      expect(authUser.refreshToken, 'refresh_token_456');
      expect(authUser.expiresAt, testDate.add(const Duration(hours: 1)));
    });

    test('should provide backward compatibility getters', () {
      expect(authUser.id, '1');
      expect(authUser.email, 'test@example.com');
      expect(authUser.name, 'Test User');
      expect(authUser.photoUrl, 'https://example.com/photo.jpg');
      expect(authUser.userType, UserType.tourist);
      expect(authUser.profileCompleted, true);
    });

    test('should create AuthUser without expiration date', () {
      final authUserNoExpiry = AuthUser(
        user: testUser,
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );

      expect(authUserNoExpiry.user, equals(testUser));
      expect(authUserNoExpiry.accessToken, 'access_token');
      expect(authUserNoExpiry.refreshToken, 'refresh_token');
      expect(authUserNoExpiry.expiresAt, isNull);
    });

    test('should support equality comparison', () {
      final authUser1 = AuthUser(
        user: testUser,
        accessToken: 'same_token',
        refreshToken: 'same_refresh',
      );

      final authUser2 = AuthUser(
        user: testUser,
        accessToken: 'same_token',
        refreshToken: 'same_refresh',
      );

      final authUser3 = AuthUser(
        user: testUser,
        accessToken: 'different_token',
        refreshToken: 'same_refresh',
      );

      expect(authUser1, equals(authUser2));
      expect(authUser1, isNot(equals(authUser3)));
      expect(authUser1.hashCode, equals(authUser2.hashCode));
    });

    test('should support copyWith method', () {
      const newUser = User(
        id: '2',
        email: 'new@example.com',
        name: 'New User',
      );

      final updatedAuthUser = authUser.copyWith(
        user: newUser,
        accessToken: 'new_access_token',
      );

      expect(updatedAuthUser.user, equals(newUser));
      expect(updatedAuthUser.accessToken, 'new_access_token');
      expect(updatedAuthUser.refreshToken, authUser.refreshToken); // unchanged
      expect(updatedAuthUser.expiresAt, authUser.expiresAt); // unchanged
    });

    test('should work with different user roles', () {
      const providerUser = User(
        id: '2',
        email: 'provider@example.com',
        name: 'Provider User',
        role: UserRole.provider,
        providerId: 'provider123',
      );

      const providerAuthUser = AuthUser(
        user: providerUser,
        accessToken: 'provider_token',
        refreshToken: 'provider_refresh',
      );

      expect(providerAuthUser.userType, UserType.providerAdmin);
      expect(providerAuthUser.user.providerId, 'provider123');
    });

    test('should handle system admin user', () {
      const adminUser = User(
        id: '3',
        email: 'admin@example.com',
        name: 'Admin User',
        role: UserRole.systemAdmin,
        isProfileComplete: true,
      );

      const adminAuthUser = AuthUser(
        user: adminUser,
        accessToken: 'admin_token',
        refreshToken: 'admin_refresh',
      );

      expect(adminAuthUser.userType, UserType.systemAdmin);
      expect(adminAuthUser.profileCompleted, true);
    });

    test('should implement Equatable correctly', () {
      expect(authUser.props, [
        authUser.user,
        authUser.accessToken,
        authUser.refreshToken,
        authUser.expiresAt,
      ]);
    });
  });
}
