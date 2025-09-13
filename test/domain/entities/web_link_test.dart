import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/entities.dart';

void main() {
  group('WebLink Entity Tests', () {
    late WebLink testWebLink;

    setUp(() {
      testWebLink = const WebLink(
        id: 'link123',
        title: 'Official Website',
        url: 'https://example.com',
        description: 'Visit our official website for more information',
      );
    });

    test('should create WebLink with all fields', () {
      expect(testWebLink.id, 'link123');
      expect(testWebLink.title, 'Official Website');
      expect(testWebLink.url, 'https://example.com');
      expect(testWebLink.description,
          'Visit our official website for more information');
    });

    test('should validate web link correctly', () {
      expect(testWebLink.isValid, true);

      // Test empty title
      final emptyTitleLink = testWebLink.copyWith(title: '');
      expect(emptyTitleLink.isValid, false);

      // Test empty URL
      final emptyUrlLink = testWebLink.copyWith(url: '');
      expect(emptyUrlLink.isValid, false);

      // Test invalid URL
      final invalidUrlLink = testWebLink.copyWith(url: 'not-a-url');
      expect(invalidUrlLink.isValid, false);
    });

    test('should validate URLs correctly', () {
      final validUrls = [
        'https://example.com',
        'http://example.com',
        'https://subdomain.example.com/path?query=value',
        'http://localhost:3000',
        'https://example.com/path/to/resource',
      ];

      for (final url in validUrls) {
        final webLink = testWebLink.copyWith(url: url);
        expect(webLink.isValid, true, reason: 'URL $url should be valid');
      }

      final invalidUrls = [
        'not-a-url',
        'ftp://example.com', // Only http/https allowed
        'example.com', // Missing scheme
        'https://', // Incomplete URL
        '',
      ];

      for (final url in invalidUrls) {
        final webLink = testWebLink.copyWith(url: url);
        expect(webLink.isValid, false, reason: 'URL $url should be invalid');
      }
    });

    test('should create copy with updated fields', () {
      final updatedWebLink = testWebLink.copyWith(
        title: 'Updated Title',
        url: 'https://newdomain.com',
      );

      expect(updatedWebLink.title, 'Updated Title');
      expect(updatedWebLink.url, 'https://newdomain.com');
      expect(updatedWebLink.id, 'link123'); // unchanged
      expect(updatedWebLink.description,
          'Visit our official website for more information'); // unchanged
    });

    test('should support equality comparison', () {
      const sameWebLink = WebLink(
        id: 'link123',
        title: 'Official Website',
        url: 'https://example.com',
        description: 'Visit our official website for more information',
      );

      expect(testWebLink, equals(sameWebLink));

      final differentWebLink = testWebLink.copyWith(id: 'link456');
      expect(testWebLink, isNot(equals(differentWebLink)));
    });

    test('should handle optional description', () {
      const minimalWebLink = WebLink(
        id: 'link123',
        title: 'Simple Link',
        url: 'https://example.com',
      );

      expect(minimalWebLink.description, null);
      expect(minimalWebLink.isValid, true);
    });

    test('should handle edge cases in URL validation', () {
      // Test case sensitivity
      final httpsUpperCase = testWebLink.copyWith(url: 'HTTPS://example.com');
      expect(httpsUpperCase.isValid,
          true); // URI.parse handles case-insensitive schemes

      // Test with query parameters and fragments
      final complexUrl = testWebLink.copyWith(
        url: 'https://example.com/path?param=value&other=123#section',
      );
      expect(complexUrl.isValid, true);

      // Test with port
      final urlWithPort = testWebLink.copyWith(url: 'https://example.com:8080');
      expect(urlWithPort.isValid, true);
    });
  });
}
