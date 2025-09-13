import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/security/input_validator.dart';

void main() {
  group('InputValidator', () {
    group('validateEmail', () {
      test('validates correct email addresses', () {
        final validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          'user123@test-domain.com',
        ];

        for (final email in validEmails) {
          final result = InputValidator.validateEmail(email);
          expect(result.isValid, isTrue, reason: 'Email $email should be valid');
          expect(result.value, equals(email));
        }
      });

      test('rejects invalid email addresses', () {
        final invalidEmails = [
          'invalid-email',
          '@domain.com',
          'user@',
          'user..name@domain.com',
          'user@domain',
          '',
        ];

        for (final email in invalidEmails) {
          final result = InputValidator.validateEmail(email);
          expect(result.isValid, isFalse, reason: 'Email $email should be invalid');
          expect(result.errorMessage, isNotNull);
        }
      });

      test('rejects null email', () {
        final result = InputValidator.validateEmail(null);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, equals('Email is required'));
      });

      test('rejects email that is too long', () {
        final longEmail = '${'a' * 250}@example.com';
        final result = InputValidator.validateEmail(longEmail);
        expect(result.isValid, isFalse);
        expect(result.errorMessage, equals('Email address is too long'));
      });
    });

    group('validatePhoneNumber', () {
      test('validates correct phone numbers', () {
        final validPhones = [
          '+1234567890',
          '+44123456789',
          '1234567890',
          '+12345678901234',
        ];

        for (final phone in validPhones) {
          final result = InputValidator.validatePhoneNumber(phone);
          expect(result.isValid, isTrue, reason: 'Phone $phone should be valid');
        }
      });

      test('rejects invalid phone numbers', () {
        final invalidPhones = [
          'abc123',
          '+',
          '123',
          '+123456789012345', // too long
          '',
        ];

        for (final phone in invalidPhones) {
          final result = InputValidator.validatePhoneNumber(phone);
          expect(result.isValid, isFalse, reason: 'Phone $phone should be invalid');
        }
      });

      test('sanitizes phone number correctly', () {
        final result = InputValidator.validatePhoneNumber('+1 (234) 567-8900');
        expect(result.isValid, isTrue);
        expect(result.value, equals('+12345678900'));
      });
    });

    group('validateName', () {
      test('validates correct names', () {
        final validNames = [
          'John',
          'Mary Jane',
          "O'Connor",
          'Jean-Pierre',
          'Smith Jr.',
        ];

        for (final name in validNames) {
          final result = InputValidator.validateName(name);
          expect(result.isValid, isTrue, reason: 'Name $name should be valid');
        }
      });

      test('rejects invalid names', () {
        final invalidNames = [
          'A', // too short
          'John123',
          'Name@domain',
          ('a' * 51), // too long
          '',
        ];

        for (final name in invalidNames) {
          final result = InputValidator.validateName(name);
          expect(result.isValid, isFalse, reason: 'Name $name should be invalid');
        }
      });
    });

    group('validatePassword', () {
      test('validates strong passwords', () {
        final validPasswords = [
          'StrongPass123!',
          'MySecure@Pass1',
          'Complex#Password9',
        ];

        for (final password in validPasswords) {
          final result = InputValidator.validatePassword(password);
          expect(result.isValid, isTrue, reason: 'Password should be valid');
        }
      });

      test('rejects weak passwords', () {
        final weakPasswords = [
          'weak', // too short
          'nouppercase123!',
          'NOLOWERCASE123!',
          'NoNumbers!',
          'NoSpecialChars123',
          '', // empty
        ];

        for (final password in weakPasswords) {
          final result = InputValidator.validatePassword(password);
          expect(result.isValid, isFalse, reason: 'Password should be invalid');
        }
      });
    });

    group('validateJoinCode', () {
      test('validates correct join codes', () {
        final validCodes = [
          'ABC12345',
          'xyz98765',
          '12345678',
        ];

        for (final code in validCodes) {
          final result = InputValidator.validateJoinCode(code);
          expect(result.isValid, isTrue);
          expect(result.value, equals(code.toUpperCase()));
        }
      });

      test('rejects invalid join codes', () {
        final invalidCodes = [
          'ABC123', // too short
          'ABC123456', // too long
          'ABC123@#', // special characters
          '',
        ];

        for (final code in invalidCodes) {
          final result = InputValidator.validateJoinCode(code);
          expect(result.isValid, isFalse);
        }
      });
    });

    group('sanitizeInput', () {
      test('removes dangerous content', () {
        final dangerousInputs = {
          '<script>alert("xss")</script>': 'alert("xss")',
          'SELECT * FROM users': ' * FROM users',
          'javascript:alert(1)': 'alert(1)',
          'normal text': 'normal text',
        };

        dangerousInputs.forEach((input, expected) {
          final result = InputValidator.sanitizeInput(input);
          expect(result, equals(expected));
        });
      });

      test('removes control characters', () {
        const input = 'text\x00with\x08control\x1fchars';
        final result = InputValidator.sanitizeInput(input);
        expect(result, equals('textwithcontrolchars'));
      });

      test('trims whitespace', () {
        const input = '  text with spaces  ';
        final result = InputValidator.sanitizeInput(input);
        expect(result, equals('text with spaces'));
      });
    });

    group('validateFileUpload', () {
      test('validates allowed file types', () {
        final result = InputValidator.validateFileUpload(
          fileName: 'document.pdf',
          fileSize: 1024 * 1024, // 1MB
          allowedExtensions: ['pdf', 'doc', 'docx'],
        );
        expect(result.isValid, isTrue);
      });

      test('rejects disallowed file types', () {
        final result = InputValidator.validateFileUpload(
          fileName: 'script.exe',
          fileSize: 1024,
          allowedExtensions: ['pdf', 'doc', 'docx'],
        );
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('File type not allowed'));
      });

      test('rejects files that are too large', () {
        final result = InputValidator.validateFileUpload(
          fileName: 'document.pdf',
          fileSize: 20 * 1024 * 1024, // 20MB
          allowedExtensions: ['pdf'],
          maxSizeBytes: 10 * 1024 * 1024, // 10MB limit
        );
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('File size must be less than'));
      });

      test('sanitizes dangerous filenames', () {
        final result = InputValidator.validateFileUpload(
          fileName: '../../../etc/passwd.pdf',
          fileSize: 1024,
          allowedExtensions: ['pdf'],
        );
        expect(result.isValid, isTrue);
        expect(result.value, equals('etcpasswd.pdf'));
      });
    });

    group('sanitizeFileName', () {
      test('removes path traversal attempts', () {
        const dangerous = '../../../malicious.txt';
        final result = InputValidator.sanitizeFileName(dangerous);
        expect(result, equals('malicious.txt'));
      });

      test('removes dangerous characters', () {
        const dangerous = 'file<>:"|?*.txt';
        final result = InputValidator.sanitizeFileName(dangerous);
        expect(result, equals('file.txt'));
      });

      test('limits filename length', () {
        final longName = '${'a' * 300}.txt';
        final result = InputValidator.sanitizeFileName(longName);
        expect(result.length, lessThanOrEqualTo(255));
        expect(result.endsWith('.txt'), isTrue);
      });
    });
  });
}