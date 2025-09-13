import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

/// Service for handling biometric authentication
class BiometricAuthService {
  BiometricAuthService() : _localAuth = LocalAuthentication();

  final LocalAuthentication _localAuth;

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<BiometricAuthResult> authenticate({
    String localizedReason = 'Please authenticate to access your account',
    bool biometricOnly = false,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult.notAvailable();
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        return BiometricAuthResult.success();
      } else {
        return BiometricAuthResult.cancelled();
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return BiometricAuthResult.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Stop ongoing authentication
  Future<bool> stopAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      return false;
    }
  }

  BiometricAuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        return BiometricAuthResult.notAvailable();
      case auth_error.notEnrolled:
        return BiometricAuthResult.notEnrolled();
      case auth_error.lockedOut:
        return BiometricAuthResult.lockedOut();
      case auth_error.permanentlyLockedOut:
        return BiometricAuthResult.permanentlyLockedOut();
      case auth_error.biometricOnlyNotSupported:
        return BiometricAuthResult.biometricOnlyNotSupported();
      default:
        return BiometricAuthResult.error(e.message ?? 'Authentication failed');
    }
  }
}

/// Result of biometric authentication attempt
class BiometricAuthResult {
  const BiometricAuthResult._({
    required this.isSuccess,
    required this.status,
    this.errorMessage,
  });

  final bool isSuccess;
  final BiometricAuthStatus status;
  final String? errorMessage;

  factory BiometricAuthResult.success() {
    return const BiometricAuthResult._(
      isSuccess: true,
      status: BiometricAuthStatus.success,
    );
  }

  factory BiometricAuthResult.cancelled() {
    return const BiometricAuthResult._(
      isSuccess: false,
      status: BiometricAuthStatus.cancelled,
    );
  }

  factory BiometricAuthResult.notAvailable() {
    return const BiometricAuthResult._(
      isSuccess: false,
      status: BiometricAuthStatus.notAvailable,
      errorMessage: 'Biometric authentication is not available on this device',
    );
  }

  factory BiometricAuthResult.notEnrolled() {
    return const BiometricAuthResult._(
      isSuccess: false,
      status: BiometricAuthStatus.notEnrolled,
      errorMessage: 'No biometrics enrolled on this device',
    );
  }

  factory BiometricAuthResult.lockedOut() {
    return const BiometricAuthResult._(
      isSuccess: false,
      status: BiometricAuthStatus.lockedOut,
      errorMessage: 'Biometric authentication is temporarily locked',
    );
  }

  factory BiometricAuthResult.permanentlyLockedOut() {
    return const BiometricAuthResult._(
      isSuccess: false,
      status: BiometricAuthStatus.permanentlyLockedOut,
      errorMessage: 'Biometric authentication is permanently locked',
    );
  }

  factory BiometricAuthResult.biometricOnlyNotSupported() {
    return const BiometricAuthResult._(
      isSuccess: false,
      status: BiometricAuthStatus.biometricOnlyNotSupported,
      errorMessage: 'Biometric-only authentication is not supported',
    );
  }

  factory BiometricAuthResult.error(String message) {
    return BiometricAuthResult._(
      isSuccess: false,
      status: BiometricAuthStatus.error,
      errorMessage: message,
    );
  }
}

/// Status of biometric authentication
enum BiometricAuthStatus {
  success,
  cancelled,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  biometricOnlyNotSupported,
  error,
}