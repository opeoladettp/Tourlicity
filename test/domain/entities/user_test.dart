import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/user.dart';
import 'package:tourlicity_app/domain/entities/user_type.dart';

void main() {
  group('User Entity Tests', () {
    late User testUser;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testUser = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'John Doe',
        phoneNumber: '+1234567890',
        role: UserRole.tourist,
        isProfileComplete: true,
        createdAt: testDate,
      );
    });

    test('should create User with all required fields', () {
      expect(testUser.id, 'user123');
      expect(testUser.email, 'test@example.com');
      expect(testUser.name, 'John Doe');
      expect(testUser.phoneNumber, '+1234567890');
      expect(testUser.role, UserRole.tourist);
      expect(testUser.isProfileComplete, true);
      expect(testUser.createdAt, testDate);
    });

    test('should create User with minimal required fields', () {
      const minimalUser = User(
        id: 'user456',
        email: 'minimal@example.com',
        name: 'Jane Smith',
      );

      expect(minimalUser.id, 'user456');
      expect(minimalUser.email, 'minimal@example.com');
      expect(minimalUser.name, 'Jane Smith');
      expect(minimalUser.role, UserRole.tourist); // default value
      expect(minimalUser.isProfileComplete, false); // default value
      expect(minimalUser.phoneNumber, isNull);
      expect(minimalUser.profilePicture, isNull);
      expect(minimalUser.providerId, isNull);
    });

    test('should provide backward compatibility getters', () {
      expect(testUser.firstName, 'John');
      expect(testUser.lastName, 'Doe');
      expect(testUser.phone, '+1234567890');
      expect(testUser.userType, UserType.tourist);
      expect(testUser.profileCompleted, true);
      expect(testUser.createdDate, testDate);
    });

    test('should handle single name for backward compatibility', () {
      const singleNameUser = User(
        id: 'user789',
        email: 'single@example.com',
        name: 'Madonna',
      );

      expect(singleNameUser.firstName, 'Madonna');
      expect(singleNameUser.lastName, '');
      expect(singleNameUser.fullName, 'Madonna');
    });

    test('should support copyWith method', () {
      final updatedUser = testUser.copyWith(
        name: 'John Updated',
        email: 'updated@example.com',
        isProfileComplete: false,
      );

      expect(updatedUser.id, testUser.id); // unchanged
      expect(updatedUser.name, 'John Updated'); // changed
      expect(updatedUser.email, 'updated@example.com'); // changed
      expect(updatedUser.isProfileComplete, false); // changed
      expect(updatedUser.phoneNumber, testUser.phoneNumber); // unchanged
    });

    test('should support different user roles', () {
      const touristUser = User(
        id: '1',
        email: 'tourist@example.com',
        name: 'Tourist User',
        role: UserRole.tourist,
      );

      const providerUser = User(
        id: '2',
        email: 'provider@example.com',
        name: 'Provider User',
        role: UserRole.provider,
        providerId: 'provider123',
      );

      const adminUser = User(
        id: '3',
        email: 'admin@example.com',
        name: 'Admin User',
        role: UserRole.systemAdmin,
      );

      expect(touristUser.role, UserRole.tourist);
      expect(touristUser.userType, UserType.tourist);

      expect(providerUser.role, UserRole.provider);
      expect(providerUser.userType, UserType.providerAdmin);
      expect(providerUser.providerId, 'provider123');

      expect(adminUser.role, UserRole.systemAdmin);
      expect(adminUser.userType, UserType.systemAdmin);
    });

    test('should implement Equatable correctly', () {
      const user1 = User(
        id: 'same_id',
        email: 'same@example.com',
        name: 'Same Name',
      );

      const user2 = User(
        id: 'same_id',
        email: 'same@example.com',
        name: 'Same Name',
      );

      const user3 = User(
        id: 'different_id',
        email: 'same@example.com',
        name: 'Same Name',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should handle provider user correctly', () {
      const providerUser = User(
        id: 'provider1',
        email: 'provider@example.com',
        name: 'Provider Name',
        role: UserRole.provider,
        providerId: 'provider_company_123',
        isProfileComplete: true,
      );

      expect(providerUser.role, UserRole.provider);
      expect(providerUser.providerId, 'provider_company_123');
      expect(providerUser.userType, UserType.providerAdmin);
    });
  });
}
