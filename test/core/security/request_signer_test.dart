import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/security/request_signer.dart';

void main() {
  group('RequestSigner', () {
    late RequestSigner signer;
    const secretKey = 'test-secret-key-123';

    setUp(() {
      signer = RequestSigner(secretKey: secretKey);
    });

    group('signRequest', () {
      test('generates consistent signatures for same input', () {
        const method = 'POST';
        const path = '/api/test';
        final body = {'key': 'value'};
        const timestamp = 1234567890;
        const nonce = 'test-nonce';

        final signature1 = signer.signRequest(
          method: method,
          path: path,
          body: body,
          timestamp: timestamp,
          nonce: nonce,
        );

        final signature2 = signer.signRequest(
          method: method,
          path: path,
          body: body,
          timestamp: timestamp,
          nonce: nonce,
        );

        expect(signature1, equals(signature2));
        expect(signature1, isNotEmpty);
      });

      test('generates different signatures for different inputs', () {
        const method = 'POST';
        const path = '/api/test';
        final body1 = {'key': 'value1'};
        final body2 = {'key': 'value2'};
        const timestamp = 1234567890;

        final signature1 = signer.signRequest(
          method: method,
          path: path,
          body: body1,
          timestamp: timestamp,
        );

        final signature2 = signer.signRequest(
          method: method,
          path: path,
          body: body2,
          timestamp: timestamp,
        );

        expect(signature1, isNot(equals(signature2)));
      });

      test('handles nested objects in body', () {
        const method = 'POST';
        const path = '/api/test';
        final body = {
          'user': {
            'name': 'John',
            'details': {
              'age': 30,
              'city': 'New York',
            },
          },
          'preferences': ['pref1', 'pref2'],
        };
        const timestamp = 1234567890;

        final signature = signer.signRequest(
          method: method,
          path: path,
          body: body,
          timestamp: timestamp,
        );

        expect(signature, isNotEmpty);
        expect(signature.length, equals(64)); // SHA256 hex length
      });
    });

    group('verifySignature', () {
      test('verifies valid signatures', () {
        const method = 'POST';
        const path = '/api/test';
        final body = {'key': 'value'};
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        const nonce = 'test-nonce';

        final signature = signer.signRequest(
          method: method,
          path: path,
          body: body,
          timestamp: timestamp,
          nonce: nonce,
        );

        final isValid = signer.verifySignature(
          method: method,
          path: path,
          body: body,
          timestamp: timestamp,
          signature: signature,
          nonce: nonce,
        );

        expect(isValid, isTrue);
      });

      test('rejects invalid signatures', () {
        const method = 'POST';
        const path = '/api/test';
        final body = {'key': 'value'};
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        const invalidSignature = 'invalid-signature';

        final isValid = signer.verifySignature(
          method: method,
          path: path,
          body: body,
          timestamp: timestamp,
          signature: invalidSignature,
        );

        expect(isValid, isFalse);
      });

      test('rejects expired timestamps', () {
        const method = 'POST';
        const path = '/api/test';
        final body = {'key': 'value'};
        final expiredTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 600; // 10 minutes ago

        final signature = signer.signRequest(
          method: method,
          path: path,
          body: body,
          timestamp: expiredTimestamp,
        );

        final isValid = signer.verifySignature(
          method: method,
          path: path,
          body: body,
          timestamp: expiredTimestamp,
          signature: signature,
          timestampToleranceSeconds: 300, // 5 minutes tolerance
        );

        expect(isValid, isFalse);
      });

      test('accepts timestamps within tolerance', () {
        const method = 'POST';
        const path = '/api/test';
        final body = {'key': 'value'};
        final recentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60; // 1 minute ago

        final signature = signer.signRequest(
          method: method,
          path: path,
          body: body,
          timestamp: recentTimestamp,
        );

        final isValid = signer.verifySignature(
          method: method,
          path: path,
          body: body,
          timestamp: recentTimestamp,
          signature: signature,
          timestampToleranceSeconds: 300, // 5 minutes tolerance
        );

        expect(isValid, isTrue);
      });
    });
  });

  group('RequestSigningConfig', () {
    test('identifies critical endpoints correctly', () {
      const config = RequestSigningConfig(
        secretKey: 'test-key',
        criticalEndpoints: ['/auth/login', '/users/profile'],
      );

      expect(config.requiresSigning('/auth/login'), isTrue);
      expect(config.requiresSigning('/users/profile/update'), isTrue);
      expect(config.requiresSigning('/public/info'), isFalse);
    });
  });

  group('NonceGenerator', () {
    test('generates nonces of correct length', () {
      final nonce = NonceGenerator.generate(length: 16);
      expect(nonce.length, equals(16));
    });

    test('generates different nonces', () {
      final nonce1 = NonceGenerator.generate();
      final nonce2 = NonceGenerator.generate();
      expect(nonce1, isNot(equals(nonce2)));
    });

    test('generates alphanumeric nonces', () {
      final nonce = NonceGenerator.generate();
      expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(nonce), isTrue);
    });
  });
}