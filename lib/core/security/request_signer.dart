import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Service for signing critical API requests
class RequestSigner {
  RequestSigner({
    required String secretKey,
  }) : _secretKey = secretKey;

  final String _secretKey;

  /// Signs a request with HMAC-SHA256
  String signRequest({
    required String method,
    required String path,
    required Map<String, dynamic> body,
    required int timestamp,
    String? nonce,
  }) {
    // Create canonical request string
    final canonicalRequest = _createCanonicalRequest(
      method: method,
      path: path,
      body: body,
      timestamp: timestamp,
      nonce: nonce,
    );

    // Sign with HMAC-SHA256
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(canonicalRequest);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return digest.toString();
  }

  /// Verifies a request signature
  bool verifySignature({
    required String method,
    required String path,
    required Map<String, dynamic> body,
    required int timestamp,
    required String signature,
    String? nonce,
    int timestampToleranceSeconds = 300, // 5 minutes
  }) {
    // Check timestamp validity
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if ((now - timestamp).abs() > timestampToleranceSeconds) {
      return false;
    }

    // Generate expected signature
    final expectedSignature = signRequest(
      method: method,
      path: path,
      body: body,
      timestamp: timestamp,
      nonce: nonce,
    );

    // Compare signatures using constant-time comparison
    return _constantTimeEquals(signature, expectedSignature);
  }

  /// Creates canonical request string for signing
  String _createCanonicalRequest({
    required String method,
    required String path,
    required Map<String, dynamic> body,
    required int timestamp,
    String? nonce,
  }) {
    // Sort body parameters
    final sortedBody = _sortMapRecursively(body);
    final bodyString = json.encode(sortedBody);

    // Create canonical string
    final parts = [
      method.toUpperCase(),
      path,
      bodyString,
      timestamp.toString(),
      if (nonce != null) nonce,
    ];

    return parts.join('\n');
  }

  /// Recursively sorts map keys for consistent serialization
  Map<String, dynamic> _sortMapRecursively(Map<String, dynamic> map) {
    final sortedMap = <String, dynamic>{};
    final sortedKeys = map.keys.toList()..sort();

    for (final key in sortedKeys) {
      final value = map[key];
      if (value is Map<String, dynamic>) {
        sortedMap[key] = _sortMapRecursively(value);
      } else if (value is List) {
        sortedMap[key] = _sortListRecursively(value);
      } else {
        sortedMap[key] = value;
      }
    }

    return sortedMap;
  }

  /// Recursively sorts list elements if they are maps
  List<dynamic> _sortListRecursively(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return _sortMapRecursively(item);
      } else if (item is List) {
        return _sortListRecursively(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// Constant-time string comparison to prevent timing attacks
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }

    return result == 0;
  }
}

/// Configuration for request signing
class RequestSigningConfig {
  const RequestSigningConfig({
    required this.secretKey,
    this.timestampToleranceSeconds = 300,
    this.includeNonce = true,
    this.criticalEndpoints = const [
      '/auth/login',
      '/auth/refresh',
      '/users/profile',
      '/tours/create',
      '/tours/update',
      '/registrations/approve',
      '/registrations/reject',
      '/documents/upload',
      '/messages/broadcast',
    ],
  });

  final String secretKey;
  final int timestampToleranceSeconds;
  final bool includeNonce;
  final List<String> criticalEndpoints;

  /// Checks if an endpoint requires request signing
  bool requiresSigning(String path) {
    return criticalEndpoints.any((endpoint) => path.startsWith(endpoint));
  }
}

/// Nonce generator for request signing
class NonceGenerator {
  static final Random _random = Random.secure();
  
  static String generate({int length = 16}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    
    String nonce = '';
    for (int i = 0; i < length; i++) {
      nonce += chars[_random.nextInt(chars.length)];
    }
    
    return nonce;
  }
}