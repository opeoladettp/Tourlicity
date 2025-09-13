import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/entities.dart';

void main() {
  group('CustomTour Entity Tests', () {
    late CustomTour testCustomTour;
    late DateTime startDate;
    late DateTime endDate;
    late DateTime createdDate;

    setUp(() {
      startDate = DateTime(2024, 6, 1);
      endDate = DateTime(2024, 6, 7);
      createdDate = DateTime(2024, 1, 1);

      testCustomTour = CustomTour(
        id: 'tour123',
        providerId: 'provider123',
        tourTemplateId: 'template123',
        tourName: 'Amazing European Adventure',
        joinCode: 'EUR2024',
        startDate: startDate,
        endDate: endDate,
        maxTourists: 20,
        currentTourists: 5,
        pricePerPerson: 1500.0,
        currency: 'USD',
        status: TourStatus.published,
        tags: const ['adventure', 'europe', 'culture'],
        description: 'An amazing tour through Europe',
        createdDate: createdDate,
      );
    });

    test('should create CustomTour with all fields', () {
      expect(testCustomTour.id, 'tour123');
      expect(testCustomTour.providerId, 'provider123');
      expect(testCustomTour.tourTemplateId, 'template123');
      expect(testCustomTour.tourName, 'Amazing European Adventure');
      expect(testCustomTour.joinCode, 'EUR2024');
      expect(testCustomTour.startDate, startDate);
      expect(testCustomTour.endDate, endDate);
      expect(testCustomTour.maxTourists, 20);
      expect(testCustomTour.currentTourists, 5);
      expect(testCustomTour.pricePerPerson, 1500.0);
      expect(testCustomTour.currency, 'USD');
      expect(testCustomTour.status, TourStatus.published);
      expect(testCustomTour.tags, ['adventure', 'europe', 'culture']);
      expect(testCustomTour.description, 'An amazing tour through Europe');
      expect(testCustomTour.createdDate, createdDate);
    });

    test('should calculate duration correctly', () {
      expect(testCustomTour.durationDays, 7);

      // Test single day tour
      final singleDayTour = testCustomTour.copyWith(
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 1),
      );
      expect(singleDayTour.durationDays, 1);
    });

    test('should calculate available spots correctly', () {
      expect(testCustomTour.availableSpots, 15);
      expect(testCustomTour.hasAvailableSpots, true);

      // Test fully booked tour
      final fullTour = testCustomTour.copyWith(currentTourists: 20);
      expect(fullTour.availableSpots, 0);
      expect(fullTour.hasAvailableSpots, false);

      // Test overbooked tour (edge case)
      final overbookedTour = testCustomTour.copyWith(currentTourists: 25);
      expect(overbookedTour.availableSpots, -5);
      expect(overbookedTour.hasAvailableSpots, false);
    });

    test('should validate date range correctly', () {
      expect(testCustomTour.isValidDateRange, true);

      // Test same date (valid)
      final sameDateTour = testCustomTour.copyWith(
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 1),
      );
      expect(sameDateTour.isValidDateRange, true);

      // Test invalid date range
      final invalidDateTour = testCustomTour.copyWith(
        startDate: DateTime(2024, 6, 7),
        endDate: DateTime(2024, 6, 1),
      );
      expect(invalidDateTour.isValidDateRange, false);
    });

    test('should validate tour correctly', () {
      expect(testCustomTour.isValid, true);

      // Test empty tour name
      final emptyNameTour = testCustomTour.copyWith(tourName: '');
      expect(emptyNameTour.isValid, false);

      // Test empty join code
      final emptyJoinCodeTour = testCustomTour.copyWith(joinCode: '');
      expect(emptyJoinCodeTour.isValid, false);

      // Test invalid date range
      final invalidDateTour = testCustomTour.copyWith(
        startDate: DateTime(2024, 6, 7),
        endDate: DateTime(2024, 6, 1),
      );
      expect(invalidDateTour.isValid, false);

      // Test invalid max tourists
      final invalidMaxTour = testCustomTour.copyWith(maxTourists: 0);
      expect(invalidMaxTour.isValid, false);

      // Test negative current tourists
      final negativeTouristsTour = testCustomTour.copyWith(currentTourists: -1);
      expect(negativeTouristsTour.isValid, false);

      // Test current tourists exceeding max
      final exceedingTouristsTour =
          testCustomTour.copyWith(currentTourists: 25);
      expect(exceedingTouristsTour.isValid, false);

      // Test negative price
      final negativePriceTour = testCustomTour.copyWith(pricePerPerson: -100);
      expect(negativePriceTour.isValid, false);

      // Test empty currency
      final emptyCurrencyTour = testCustomTour.copyWith(currency: '');
      expect(emptyCurrencyTour.isValid, false);
    });

    test('should determine if can accept registrations', () {
      // Create a tour with future start date
      final futureTour = testCustomTour.copyWith(
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 37)),
      );
      expect(futureTour.canAcceptRegistrations, true);

      // Test draft status
      final draftTour = futureTour.copyWith(status: TourStatus.draft);
      expect(draftTour.canAcceptRegistrations, false);

      // Test fully booked
      final fullTour = futureTour.copyWith(currentTourists: 20);
      expect(fullTour.canAcceptRegistrations, false);

      // Test past start date
      final pastTour = testCustomTour.copyWith(
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(pastTour.canAcceptRegistrations, false);

      // Test cancelled status
      final cancelledTour = futureTour.copyWith(status: TourStatus.cancelled);
      expect(cancelledTour.canAcceptRegistrations, false);
    });

    test('should determine if tour is active', () {
      final now = DateTime.now();

      // Test active tour with current dates
      final activeTour = testCustomTour.copyWith(
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 1)),
        status: TourStatus.active,
      );
      expect(activeTour.isActive, true);

      // Test non-active status
      final publishedTour = activeTour.copyWith(status: TourStatus.published);
      expect(publishedTour.isActive, false);

      // Test past tour
      final pastTour = testCustomTour.copyWith(
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 5)),
        status: TourStatus.active,
      );
      expect(pastTour.isActive, false);

      // Test future tour
      final futureTour = testCustomTour.copyWith(
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 10)),
        status: TourStatus.active,
      );
      expect(futureTour.isActive, false);
    });

    test('should test all tour statuses', () {
      final statuses = [
        TourStatus.draft,
        TourStatus.published,
        TourStatus.active,
        TourStatus.completed,
        TourStatus.cancelled,
      ];

      for (final status in statuses) {
        final tour = testCustomTour.copyWith(status: status);
        expect(tour.status, status);
      }
    });

    test('should create copy with updated fields', () {
      final updatedTour = testCustomTour.copyWith(
        tourName: 'Updated Tour Name',
        maxTourists: 25,
        status: TourStatus.active,
        tags: const ['updated', 'tags'],
      );

      expect(updatedTour.tourName, 'Updated Tour Name');
      expect(updatedTour.maxTourists, 25);
      expect(updatedTour.status, TourStatus.active);
      expect(updatedTour.tags, ['updated', 'tags']);
      expect(updatedTour.providerId, 'provider123'); // unchanged
      expect(updatedTour.joinCode, 'EUR2024'); // unchanged
    });

    test('should support equality comparison', () {
      final sameCustomTour = CustomTour(
        id: 'tour123',
        providerId: 'provider123',
        tourTemplateId: 'template123',
        tourName: 'Amazing European Adventure',
        joinCode: 'EUR2024',
        startDate: startDate,
        endDate: endDate,
        maxTourists: 20,
        currentTourists: 5,
        pricePerPerson: 1500.0,
        currency: 'USD',
        status: TourStatus.published,
        tags: const ['adventure', 'europe', 'culture'],
        description: 'An amazing tour through Europe',
        createdDate: createdDate,
      );

      expect(testCustomTour, equals(sameCustomTour));

      final differentTour = testCustomTour.copyWith(id: 'tour456');
      expect(testCustomTour, isNot(equals(differentTour)));
    });

    test('should handle optional description', () {
      final tourWithoutDescription = CustomTour(
        id: testCustomTour.id,
        providerId: testCustomTour.providerId,
        tourTemplateId: testCustomTour.tourTemplateId,
        tourName: testCustomTour.tourName,
        joinCode: testCustomTour.joinCode,
        startDate: testCustomTour.startDate,
        endDate: testCustomTour.endDate,
        maxTourists: testCustomTour.maxTourists,
        currentTourists: testCustomTour.currentTourists,
        pricePerPerson: testCustomTour.pricePerPerson,
        currency: testCustomTour.currency,
        status: testCustomTour.status,
        tags: testCustomTour.tags,
        description: null, // explicitly null
        createdDate: testCustomTour.createdDate,
      );
      expect(tourWithoutDescription.description, null);
      expect(tourWithoutDescription.isValid, true);
    });

    test('should handle empty tags', () {
      final tourWithoutTags = testCustomTour.copyWith(tags: []);
      expect(tourWithoutTags.tags, isEmpty);
      expect(tourWithoutTags.isValid, true);
    });

    test('should handle zero price (free tour)', () {
      final freeTour = testCustomTour.copyWith(pricePerPerson: 0.0);
      expect(freeTour.pricePerPerson, 0.0);
      expect(freeTour.isValid, true);
    });
  });
}
