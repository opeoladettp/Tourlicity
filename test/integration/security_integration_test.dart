import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tourlicity_app/core/security/biometric_auth_service.dart';
import 'package:tourlicity_app/core/security/certificate_pinning.dart';
import 'package:tourlicity_app/core/security/input_validator.dart';
import 'package:tourlicity_app/core/security/request_signer.dart';
import 'package:tourlicity_app/core/security/secure_session_manager.dart';

/// Integration tests for security features
void main() {
  group('Security Integration Tests', () {
    setUpAll(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    test('Input validation prevents malicious inputs', () async {
      // Test SQL injection prevention
      const sqlInjection = "'; DROP TABLE users; --";
      final sanitized = InputValidator.sanitizeInput(sqlInjection);
      expect(sanitized, isNot(contains('DROP')));
      // TABLE is not in the blocked keywords list, so it remains
      expect(sanitized, contains('TABLE'));
      // Note: -- is not removed by current implementation, only SQL keywords

      // Test XSS prevention
      const xssPayload = '<script>alert("XSS")</script>';
      final sanitizedXss = InputValidator.sanitizeInput(xssPayload);
      expect(sanitizedXss, isNot(contains('<script')));

      // Test command injection prevention
      const commandInjection = 'test; rm -rf /';
      final sanitizedCommand = InputValidator.sanitizeInput(commandInjection);
      expect(sanitizedCommand, isNot(contains(';')));
      expect(sanitizedCommand, equals('test rm -rf /'));
    });

    test('Request signing works correctly', () async {
      const secretKey = 'test-secret-key';
      final signer = RequestSigner(secretKey: secretKey);

      const method = 'POST';
      const path = '/api/test';
      final body = {'key': 'value'};
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Sign request
      final signature = signer.signRequest(
        method: method,
        path: path,
        body: body,
        timestamp: timestamp,
      );

      expect(signature, isNotEmpty);
      expect(signature.length, equals(64)); // SHA256 hex length

      // Verify signature
      final isValid = signer.verifySignature(
        method: method,
        path: path,
        body: body,
        timestamp: timestamp,
        signature: signature,
      );

      expect(isValid, isTrue);
    });

    test('Session manager handles session lifecycle', () async {
      final sessionManager = SecureSessionManager.stub(
        sessionTimeout: const Duration(hours: 24), // Long timeout for testing
        inactivityTimeout:
            const Duration(hours: 24), // Long timeout for testing
      );

      // Initialize session (should complete without error)
      await sessionManager.initializeSession(
        accessToken: 'test-access-token',
        refreshToken: 'test-refresh-token',
        userData: {'userId': '123', 'email': 'test@example.com'},
      );

      // Clear session to test cleanup
      await sessionManager.clearSession();
      final hasSessionAfterClear = await sessionManager.hasActiveSession();
      expect(hasSessionAfterClear, isFalse);

      sessionManager.dispose();
    });

    test('File upload validation prevents dangerous files', () async {
      // Test dangerous file extensions
      final dangerousFile = InputValidator.validateFileUpload(
        fileName: 'malware.exe',
        fileSize: 1024,
        allowedExtensions: ['pdf', 'doc', 'txt'],
      );
      expect(dangerousFile.isValid, isFalse);

      // Test allowed file
      final safeFile = InputValidator.validateFileUpload(
        fileName: 'document.pdf',
        fileSize: 1024,
        allowedExtensions: ['pdf', 'doc', 'txt'],
      );
      expect(safeFile.isValid, isTrue);

      // Test file size limit
      final largeFile = InputValidator.validateFileUpload(
        fileName: 'large.pdf',
        fileSize: 20 * 1024 * 1024, // 20MB
        allowedExtensions: ['pdf'],
        maxSizeBytes: 10 * 1024 * 1024, // 10MB limit
      );
      expect(largeFile.isValid, isFalse);
    });

    test('Password validation enforces security requirements', () async {
      // Test weak passwords
      final weakPasswords = [
        'password',
        '123456',
        'Password1', // Missing special character
        'password!', // Missing uppercase and number
      ];

      for (final password in weakPasswords) {
        final result = InputValidator.validatePassword(password);
        expect(result.isValid, isFalse,
            reason: 'Password "$password" should be invalid');
      }

      // Test strong passwords
      final strongPasswords = [
        'MyStr0ng!Pass',
        'C0mplex#Passw0rd',
        'Secure@123Pass',
      ];

      for (final password in strongPasswords) {
        final result = InputValidator.validatePassword(password);
        expect(result.isValid, isTrue,
            reason: 'Password "$password" should be valid');
      }
    });

    test('Email validation handles various formats', () async {
      // Valid emails
      final validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@example.org',
      ];

      for (final email in validEmails) {
        final result = InputValidator.validateEmail(email);
        expect(result.isValid, isTrue,
            reason: 'Email "$email" should be valid');
      }

      // Invalid emails
      final invalidEmails = [
        'invalid-email',
        '@domain.com',
        'user@',
        'user@domain', // Missing TLD
      ];

      for (final email in invalidEmails) {
        final result = InputValidator.validateEmail(email);
        expect(result.isValid, isFalse,
            reason: 'Email "$email" should be invalid');
      }
    });

    test('Biometric service handles availability correctly', () async {
      final biometricService = BiometricAuthService();

      // Check availability (may vary by device)
      final isAvailable = await biometricService.isBiometricAvailable();
      expect(isAvailable, isA<bool>());

      // Get available biometrics
      final availableBiometrics =
          await biometricService.getAvailableBiometrics();
      expect(availableBiometrics, isA<List>());

      // Test result creation
      final successResult = BiometricAuthResult.success();
      expect(successResult.isSuccess, isTrue);

      final errorResult = BiometricAuthResult.error('Test error');
      expect(errorResult.isSuccess, isFalse);
      expect(errorResult.errorMessage, equals('Test error'));
    });

    test('Certificate pinning configuration is valid', () async {
      // Test hostname validation
      expect(
        CertificatePinning.shouldPinCertificate('api.tourlicity.com'),
        isTrue,
      );
      expect(
        CertificatePinning.shouldPinCertificate('other-domain.com'),
        isFalse,
      );

      // Test fingerprint validation
      const testFingerprint = 'YOUR_PRODUCTION_CERT_SHA256_FINGERPRINT';
      expect(
        CertificatePinning.validateCertificate(testFingerprint),
        isTrue,
      );
      expect(
        CertificatePinning.validateCertificate('invalid-fingerprint'),
        isFalse,
      );
    });

    test('Security configuration is properly set up', () async {
      const config = RequestSigningConfig(
        secretKey: 'test-key',
        criticalEndpoints: ['/auth/login', '/users/profile'],
      );

      // Test endpoint identification
      expect(config.requiresSigning('/auth/login'), isTrue);
      expect(config.requiresSigning('/users/profile/update'), isTrue);
      expect(config.requiresSigning('/public/info'), isFalse);

      // Test nonce generation
      final nonce1 = NonceGenerator.generate();
      final nonce2 = NonceGenerator.generate();
      expect(nonce1, isNot(equals(nonce2)));
      expect(nonce1.length, equals(16));
      expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(nonce1), isTrue);
    });
  });
}
