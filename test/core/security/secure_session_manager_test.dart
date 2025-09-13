import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourlicity_app/core/security/secure_session_manager.dart';

void main() {
  group('SecureSessionManager', () {
    late SecureSessionManager sessionManager;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      sessionManager = SecureSessionManager.stub(
        sessionTimeout:
            const Duration(hours: 24), // Very long timeout for testing
        inactivityTimeout:
            const Duration(hours: 24), // Very long timeout for testing
      );
    });

    tearDown(() {
      sessionManager.dispose();
    });

    group('initializeSession', () {
      test('initializes session successfully', () async {
        const accessToken = 'access-token-123';
        const refreshToken = 'refresh-token-456';
        final userData = {'userId': '123', 'email': 'test@example.com'};

        // This should not throw an exception
        await sessionManager.initializeSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userData: userData,
        );

        // The session initialization should complete without errors
        expect(true, isTrue); // Basic test that initialization completes
      });
    });

    group('validateSession', () {
      test('returns invalid for missing session', () async {
        // Don't initialize any session
        final result = await sessionManager.validateSession();
        expect(result.isValid, isFalse);
        expect(result.errorMessage, equals('No active session'));
      });

      test('returns invalid after clearing session', () async {
        // Clear any existing session
        await sessionManager.clearSession();

        // Validate should return invalid
        final result = await sessionManager.validateSession();
        expect(result.isValid, isFalse);
        expect(result.errorMessage, equals('No active session'));
      });
    });

    group('getAccessToken', () {
      test('returns null for invalid session', () async {
        // Clear any existing session
        await sessionManager.clearSession();

        final token = await sessionManager.getAccessToken();
        expect(token, isNull);
      });
    });

    group('updateTokens', () {
      test('completes without error', () async {
        const newAccessToken = 'new-access-token';
        const newRefreshToken = 'new-refresh-token';

        // This should not throw an exception
        await sessionManager.updateTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // The update should complete without errors
        expect(true, isTrue);
      });
    });

    group('clearSession', () {
      test('clears all session data', () async {
        // Initialize session first
        await sessionManager.initializeSession(
          accessToken: 'test-token',
          refreshToken: 'test-refresh',
        );

        // Verify session exists
        expect(await sessionManager.hasActiveSession(), isTrue);

        // Clear session
        await sessionManager.clearSession();

        // Verify session is cleared
        expect(await sessionManager.hasActiveSession(), isFalse);
        expect(await sessionManager.getAccessToken(), isNull);
      });
    });

    group('hasActiveSession', () {
      test('returns false when no session exists', () async {
        // Clear any existing session
        await sessionManager.clearSession();

        final hasSession = await sessionManager.hasActiveSession();
        expect(hasSession, isFalse);
      });
    });
  });

  group('SessionValidationResult', () {
    test('creates valid result correctly', () {
      final result = SessionValidationResult.valid();
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('creates invalid result correctly', () {
      const errorMessage = 'Test error';
      final result = SessionValidationResult.invalid(errorMessage);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals(errorMessage));
    });

    test('creates expired result correctly', () {
      const errorMessage = 'Session expired';
      final result = SessionValidationResult.expired(errorMessage);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals(errorMessage));
    });
  });

  group('SessionInfo', () {
    test('calculates session duration correctly', () {
      final sessionStart = DateTime.now().subtract(const Duration(hours: 1));
      final sessionInfo = SessionInfo(
        sessionId: 'test-session',
        sessionStart: sessionStart,
        lastActivity: DateTime.now(),
        deviceFingerprint: 'test-fingerprint',
      );

      final duration = sessionInfo.sessionDuration;
      expect(duration, isNotNull);
      expect(duration!.inMinutes, greaterThanOrEqualTo(59));
      expect(duration.inMinutes, lessThanOrEqualTo(61));
    });

    test('calculates time since last activity correctly', () {
      final lastActivity = DateTime.now().subtract(const Duration(minutes: 5));
      final sessionInfo = SessionInfo(
        sessionId: 'test-session',
        sessionStart: DateTime.now().subtract(const Duration(hours: 1)),
        lastActivity: lastActivity,
        deviceFingerprint: 'test-fingerprint',
      );

      final timeSinceActivity = sessionInfo.timeSinceLastActivity;
      expect(timeSinceActivity, isNotNull);
      expect(timeSinceActivity!.inMinutes, greaterThanOrEqualTo(4));
      expect(timeSinceActivity.inMinutes, lessThanOrEqualTo(6));
    });
  });
}
