import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/navigation/app_routes.dart';
import 'package:tourlicity_app/core/navigation/role_based_home.dart';
import 'package:tourlicity_app/domain/entities/user.dart';
import 'package:tourlicity_app/domain/entities/user_type.dart';

void main() {
  group('Navigation Integration Tests', () {
    testWidgets('AppRoutes contains all required routes', (tester) async {
      // Test that all essential routes are defined
      expect(AppRoutes.login, isNotEmpty);
      expect(AppRoutes.home, isNotEmpty);
      expect(AppRoutes.profileCompletion, isNotEmpty);
      expect(AppRoutes.tourTemplates, isNotEmpty);
    });

    testWidgets('RoleBasedHome can be instantiated', (tester) async {
      // Test that RoleBasedHome widget can be created
      const roleBasedHome = RoleBasedHome();

      expect(roleBasedHome, isA<Widget>());
      expect(roleBasedHome, isA<RoleBasedHome>());
    });

    testWidgets('User entity supports all user roles', (tester) async {
      // Test System Admin User
      final systemAdminUser = User(
        id: '1',
        email: 'admin@example.com',
        name: 'System Admin',
        role: UserRole.systemAdmin,
        isProfileComplete: true,
        createdAt: DateTime.now(),
      );

      expect(systemAdminUser.role, UserRole.systemAdmin);
      expect(systemAdminUser.userType, UserType.systemAdmin);
      expect(systemAdminUser.isProfileComplete, true);

      // Test Provider User
      final providerUser = User(
        id: '2',
        email: 'provider@example.com',
        name: 'Provider User',
        role: UserRole.provider,
        providerId: 'provider123',
        isProfileComplete: true,
        createdAt: DateTime.now(),
      );

      expect(providerUser.role, UserRole.provider);
      expect(providerUser.userType, UserType.providerAdmin);
      expect(providerUser.providerId, 'provider123');

      // Test Tourist User
      final touristUser = User(
        id: '3',
        email: 'tourist@example.com',
        name: 'Tourist User',
        role: UserRole.tourist,
        isProfileComplete: false,
        createdAt: DateTime.now(),
      );

      expect(touristUser.role, UserRole.tourist);
      expect(touristUser.userType, UserType.tourist);
      expect(touristUser.isProfileComplete, false);
    });

    testWidgets('UserType and UserRole enums work correctly', (tester) async {
      // Test UserType enum
      expect(UserType.values, hasLength(3));
      expect(UserType.values, contains(UserType.tourist));
      expect(UserType.values, contains(UserType.providerAdmin));
      expect(UserType.values, contains(UserType.systemAdmin));

      // Test UserRole enum
      expect(UserRole.values, hasLength(3));
      expect(UserRole.values, contains(UserRole.tourist));
      expect(UserRole.values, contains(UserRole.provider));
      expect(UserRole.values, contains(UserRole.systemAdmin));

      // Test conversions
      expect(UserType.tourist.toUserRole(), UserRole.tourist);
      expect(UserType.providerAdmin.toUserRole(), UserRole.provider);
      expect(UserType.systemAdmin.toUserRole(), UserRole.systemAdmin);

      expect(UserRole.tourist.toUserType(), UserType.tourist);
      expect(UserRole.provider.toUserType(), UserType.providerAdmin);
      expect(UserRole.systemAdmin.toUserType(), UserType.systemAdmin);
    });

    testWidgets('Navigation routes are properly defined', (tester) async {
      // Test that route constants are strings and not empty
      expect(AppRoutes.login, isA<String>());
      expect(AppRoutes.login, isNotEmpty);

      expect(AppRoutes.home, isA<String>());
      expect(AppRoutes.home, isNotEmpty);

      expect(AppRoutes.profileCompletion, isA<String>());
      expect(AppRoutes.profileCompletion, isNotEmpty);

      expect(AppRoutes.tourTemplates, isA<String>());
      expect(AppRoutes.tourTemplates, isNotEmpty);

      // Test that routes start with '/'
      expect(AppRoutes.login.startsWith('/'), true);
      expect(AppRoutes.home.startsWith('/'), true);
      expect(AppRoutes.profileCompletion.startsWith('/'), true);
    });

    testWidgets('User backward compatibility works', (tester) async {
      final user = User(
        id: 'test_id',
        email: 'test@example.com',
        name: 'John Doe',
        role: UserRole.tourist,
        isProfileComplete: true,
        createdAt: DateTime.now(),
      );

      // Test backward compatibility getters
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.profileCompleted, true);
      expect(user.userType, UserType.tourist);
      expect(user.fullName, 'John Doe');
    });
  });
}
