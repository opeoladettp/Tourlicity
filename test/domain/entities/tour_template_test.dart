import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/tour_template.dart';
import 'package:tourlicity_app/domain/entities/web_link.dart';

void main() {
  group('TourTemplate Entity Tests', () {
    late TourTemplate testTourTemplate;
    late DateTime createdDate;
    late DateTime updatedDate;
    late List<WebLink> webLinks;

    setUp(() {
      createdDate = DateTime(2024, 1, 1);
      updatedDate = DateTime(2024, 1, 15);
      webLinks = [
        const WebLink(
          id: 'link1',
          title: 'Itinerary',
          url: 'https://example.com/itinerary',
        ),
        const WebLink(
          id: 'link2',
          title: 'Booking Info',
          url: 'https://example.com/booking',
        ),
      ];

      testTourTemplate = TourTemplate(
        id: 'template123',
        title: 'European Adventure',
        description: 'A wonderful 7-day European adventure tour',
        duration: 168, // 7 days in hours
        price: 1299.99,
        maxParticipants: 20,
        providerId: 'provider123',
        imageUrl: 'https://example.com/tour-image.jpg',
        webLinks: webLinks,
        isActive: true,
        createdAt: createdDate,
        updatedAt: updatedDate,
      );
    });

    test('should create TourTemplate with all required fields', () {
      expect(testTourTemplate.id, 'template123');
      expect(testTourTemplate.title, 'European Adventure');
      expect(testTourTemplate.description,
          'A wonderful 7-day European adventure tour');
      expect(testTourTemplate.duration, 168);
      expect(testTourTemplate.price, 1299.99);
      expect(testTourTemplate.maxParticipants, 20);
      expect(testTourTemplate.providerId, 'provider123');
      expect(testTourTemplate.imageUrl, 'https://example.com/tour-image.jpg');
      expect(testTourTemplate.webLinks, webLinks);
      expect(testTourTemplate.isActive, true);
      expect(testTourTemplate.createdAt, createdDate);
      expect(testTourTemplate.updatedAt, updatedDate);
    });

    test('should create TourTemplate with minimal required fields', () {
      const minimalTemplate = TourTemplate(
        id: 'template456',
        title: 'Simple Tour',
        description: 'A simple day tour',
        duration: 8, // 8 hours
        price: 99.99,
        maxParticipants: 10,
        providerId: 'provider456',
      );

      expect(minimalTemplate.id, 'template456');
      expect(minimalTemplate.title, 'Simple Tour');
      expect(minimalTemplate.description, 'A simple day tour');
      expect(minimalTemplate.duration, 8);
      expect(minimalTemplate.price, 99.99);
      expect(minimalTemplate.maxParticipants, 10);
      expect(minimalTemplate.providerId, 'provider456');
      expect(minimalTemplate.isActive, true); // default value
      expect(minimalTemplate.webLinks, isEmpty); // default value
      expect(minimalTemplate.imageUrl, isNull);
    });

    test('should provide backward compatibility getters', () {
      expect(testTourTemplate.templateName, 'European Adventure');
      expect(testTourTemplate.startDate, createdDate);
      expect(testTourTemplate.endDate, updatedDate);
      expect(testTourTemplate.createdDate, createdDate);
      expect(testTourTemplate.durationDays, 7); // 168 hours / 24 = 7 days
    });

    test('should validate tour template data', () {
      expect(testTourTemplate.isValid, true);

      const invalidTemplate = TourTemplate(
        id: 'invalid',
        title: '',
        description: '',
        duration: 0,
        price: 0,
        maxParticipants: 0,
        providerId: 'provider',
      );

      expect(invalidTemplate.isValid, false);
    });

    test('should calculate duration in days correctly', () {
      const oneDayTour = TourTemplate(
        id: 'day_tour',
        title: 'Day Tour',
        description: 'One day tour',
        duration: 8, // 8 hours
        price: 50.0,
        maxParticipants: 15,
        providerId: 'provider',
      );

      const multiDayTour = TourTemplate(
        id: 'multi_day',
        title: 'Multi Day Tour',
        description: 'Multi day tour',
        duration: 72, // 3 days
        price: 300.0,
        maxParticipants: 12,
        providerId: 'provider',
      );

      expect(oneDayTour.durationDays, 1);
      expect(multiDayTour.durationDays, 3);
    });

    test('should support copyWith method', () {
      final updatedTemplate = testTourTemplate.copyWith(
        title: 'Updated European Adventure',
        price: 1499.99,
        maxParticipants: 25,
        isActive: false,
      );

      expect(updatedTemplate.id, testTourTemplate.id); // unchanged
      expect(updatedTemplate.title, 'Updated European Adventure'); // changed
      expect(updatedTemplate.price, 1499.99); // changed
      expect(updatedTemplate.maxParticipants, 25); // changed
      expect(updatedTemplate.isActive, false); // changed
      expect(updatedTemplate.description,
          testTourTemplate.description); // unchanged
      expect(updatedTemplate.duration, testTourTemplate.duration); // unchanged
    });

    test('should implement Equatable correctly', () {
      const template1 = TourTemplate(
        id: 'same_id',
        title: 'Same Title',
        description: 'Same Description',
        duration: 24,
        price: 100.0,
        maxParticipants: 10,
        providerId: 'provider',
      );

      const template2 = TourTemplate(
        id: 'same_id',
        title: 'Same Title',
        description: 'Same Description',
        duration: 24,
        price: 100.0,
        maxParticipants: 10,
        providerId: 'provider',
      );

      const template3 = TourTemplate(
        id: 'different_id',
        title: 'Same Title',
        description: 'Same Description',
        duration: 24,
        price: 100.0,
        maxParticipants: 10,
        providerId: 'provider',
      );

      expect(template1, equals(template2));
      expect(template1, isNot(equals(template3)));
      expect(template1.hashCode, equals(template2.hashCode));
    });

    test('should handle web links correctly', () {
      const templateWithLinks = TourTemplate(
        id: 'with_links',
        title: 'Tour with Links',
        description: 'Tour with web links',
        duration: 12,
        price: 150.0,
        maxParticipants: 8,
        providerId: 'provider',
        webLinks: [
          WebLink(
            id: 'link1',
            title: 'Map',
            url: 'https://example.com/map',
          ),
        ],
      );

      expect(templateWithLinks.webLinks, hasLength(1));
      expect(templateWithLinks.webLinks.first.title, 'Map');
      expect(templateWithLinks.webLinks.first.url, 'https://example.com/map');
    });

    test('should handle inactive template', () {
      final inactiveTemplate = testTourTemplate.copyWith(isActive: false);

      expect(inactiveTemplate.isActive, false);
      expect(inactiveTemplate.isCurrentlyActive, false);
    });

    test('should validate date range for backward compatibility', () {
      final templateWithDates = TourTemplate(
        id: 'with_dates',
        title: 'Tour with Dates',
        description: 'Tour with start and end dates',
        duration: 48,
        price: 200.0,
        maxParticipants: 15,
        providerId: 'provider',
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 3),
      );

      expect(templateWithDates.isValidDateRange, true);

      final templateWithInvalidDates = TourTemplate(
        id: 'invalid_dates',
        title: 'Invalid Dates',
        description: 'Tour with invalid dates',
        duration: 24,
        price: 100.0,
        maxParticipants: 10,
        providerId: 'provider',
        startDate: DateTime(2024, 6, 3),
        endDate: DateTime(2024, 6, 1), // end before start
      );

      expect(templateWithInvalidDates.isValidDateRange, false);
    });
  });
}
