import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/provider.dart';

void main() {
  group('Provider Entity Tests', () {
    late Provider testProvider;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testProvider = Provider(
        id: 'provider123',
        name: 'Adventure Tours Inc',
        email: 'contact@adventuretours.com',
        phoneNumber: '+1-555-123-4567',
        description: 'Leading adventure tour provider',
        address: '123 Main St, City, State 12345',
        website: 'https://adventuretours.com',
        logoUrl: 'https://example.com/logo.png',
        isActive: true,
        rating: 4.5,
        totalReviews: 150,
        createdAt: testDate,
      );
    });

    test('should create Provider with all required fields', () {
      expect(testProvider.id, 'provider123');
      expect(testProvider.name, 'Adventure Tours Inc');
      expect(testProvider.email, 'contact@adventuretours.com');
      expect(testProvider.phoneNumber, '+1-555-123-4567');
      expect(testProvider.description, 'Leading adventure tour provider');
      expect(testProvider.address, '123 Main St, City, State 12345');
      expect(testProvider.website, 'https://adventuretours.com');
      expect(testProvider.logoUrl, 'https://example.com/logo.png');
      expect(testProvider.isActive, true);
      expect(testProvider.rating, 4.5);
      expect(testProvider.totalReviews, 150);
      expect(testProvider.createdAt, testDate);
    });

    test('should create Provider with minimal required fields', () {
      const minimalProvider = Provider(
        id: 'provider456',
        name: 'Simple Tours',
        email: 'info@simpletours.com',
        phoneNumber: '+1-555-987-6543',
      );

      expect(minimalProvider.id, 'provider456');
      expect(minimalProvider.name, 'Simple Tours');
      expect(minimalProvider.email, 'info@simpletours.com');
      expect(minimalProvider.phoneNumber, '+1-555-987-6543');
      expect(minimalProvider.isActive, true); // default value
      expect(minimalProvider.rating, 0.0); // default value
      expect(minimalProvider.totalReviews, 0); // default value
      expect(minimalProvider.description, isNull);
      expect(minimalProvider.address, isNull);
      expect(minimalProvider.website, isNull);
      expect(minimalProvider.logoUrl, isNull);
    });

    test('should provide backward compatibility getters', () {
      expect(testProvider.providerName, 'Adventure Tours Inc');
      expect(testProvider.emailAddress, 'contact@adventuretours.com');
      expect(testProvider.providerCode, 'provider123');
      expect(testProvider.createdDate, testDate);
      expect(
          testProvider.companyDescription, 'Leading adventure tour provider');
      expect(testProvider.corporateTaxId, 'provider123'); // placeholder
      expect(testProvider.country,
          '123 Main St, City, State 12345'); // uses address
    });

    test('should validate provider data', () {
      expect(testProvider.isValid, true);

      const invalidProvider = Provider(
        id: 'invalid',
        name: '',
        email: '',
        phoneNumber: '',
      );

      expect(invalidProvider.isValid, false);
    });

    test('should support copyWith method', () {
      final updatedProvider = testProvider.copyWith(
        name: 'Updated Tours Inc',
        email: 'new@updatedtours.com',
        rating: 5.0,
        totalReviews: 200,
      );

      expect(updatedProvider.id, testProvider.id); // unchanged
      expect(updatedProvider.name, 'Updated Tours Inc'); // changed
      expect(updatedProvider.email, 'new@updatedtours.com'); // changed
      expect(updatedProvider.rating, 5.0); // changed
      expect(updatedProvider.totalReviews, 200); // changed
      expect(
          updatedProvider.phoneNumber, testProvider.phoneNumber); // unchanged
      expect(updatedProvider.address, testProvider.address); // unchanged
    });

    test('should implement Equatable correctly', () {
      const provider1 = Provider(
        id: 'same_id',
        name: 'Same Name',
        email: 'same@example.com',
        phoneNumber: '+1-555-123-4567',
      );

      const provider2 = Provider(
        id: 'same_id',
        name: 'Same Name',
        email: 'same@example.com',
        phoneNumber: '+1-555-123-4567',
      );

      const provider3 = Provider(
        id: 'different_id',
        name: 'Same Name',
        email: 'same@example.com',
        phoneNumber: '+1-555-123-4567',
      );

      expect(provider1, equals(provider2));
      expect(provider1, isNot(equals(provider3)));
      expect(provider1.hashCode, equals(provider2.hashCode));
    });

    test('should handle inactive provider', () {
      final inactiveProvider = testProvider.copyWith(isActive: false);

      expect(inactiveProvider.isActive, false);
      expect(inactiveProvider.id, testProvider.id);
      expect(inactiveProvider.name, testProvider.name);
    });

    test('should handle provider with no reviews', () {
      const newProvider = Provider(
        id: 'new_provider',
        name: 'New Provider',
        email: 'new@provider.com',
        phoneNumber: '+1-555-000-0000',
      );

      expect(newProvider.rating, 0.0);
      expect(newProvider.totalReviews, 0);
    });

    test('should handle provider with high rating', () {
      final topProvider = testProvider.copyWith(
        rating: 4.9,
        totalReviews: 1000,
      );

      expect(topProvider.rating, 4.9);
      expect(topProvider.totalReviews, 1000);
    });
  });
}
