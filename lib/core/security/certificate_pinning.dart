import 'package:dio/dio.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Certificate pinning configuration for secure API communications
class CertificatePinning {
  /// List of allowed SHA256 fingerprints for the API server
  static const List<String> _allowedSHA256Fingerprints = [
    // Production API server certificate fingerprint
    'YOUR_PRODUCTION_CERT_SHA256_FINGERPRINT',
    // Staging API server certificate fingerprint (if different)
    'YOUR_STAGING_CERT_SHA256_FINGERPRINT',
    // Backup certificate fingerprint
    'YOUR_BACKUP_CERT_SHA256_FINGERPRINT',
  ];

  /// API hostname for certificate validation
  static const String _apiHostname = 'api.tourlicity.com';

  /// Creates and configures certificate pinning interceptor
  static Interceptor createCertificatePinningInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Certificate pinning will be handled at the HttpClient level
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.type == DioExceptionType.badCertificate) {
          // Handle certificate validation errors
          handler.next(DioException(
            requestOptions: error.requestOptions,
            message: 'Certificate validation failed - possible security threat',
            type: DioExceptionType.badCertificate,
          ));
        } else {
          handler.next(error);
        }
      },
    );
  }

  /// Creates HttpClient with certificate pinning
  static HttpClient createHttpClientWithPinning() {
    final client = HttpClient();
    
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Only validate certificates for our API domain
      if (!shouldPinCertificate(host)) {
        return true; // Allow other certificates
      }
      
      // Calculate certificate fingerprint
      final certBytes = cert.der;
      final digest = sha256.convert(certBytes);
      final fingerprint = digest.toString().toUpperCase();
      
      // Check if fingerprint matches any allowed fingerprints
      return validateCertificate(fingerprint);
    };
    
    return client;
  }

  /// Validates if the given hostname should use certificate pinning
  static bool shouldPinCertificate(String hostname) {
    return hostname.contains(_apiHostname) || 
           hostname.contains('tourlicity.com');
  }

  /// Gets the list of allowed fingerprints for a specific environment
  static List<String> getAllowedFingerprints({bool isProduction = true}) {
    if (isProduction) {
      return [_allowedSHA256Fingerprints.first];
    }
    return _allowedSHA256Fingerprints;
  }

  /// Validates certificate manually (for additional security checks)
  static bool validateCertificate(String fingerprint) {
    return _allowedSHA256Fingerprints.contains(fingerprint);
  }
}