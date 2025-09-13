import 'package:flutter/foundation.dart';

/// Environment configuration for different build variants
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const String _envKey = 'ENVIRONMENT';
  
  static Environment get current {
    const envString = String.fromEnvironment(_envKey, defaultValue: 'development');
    switch (envString.toLowerCase()) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        return Environment.development;
    }
  }

  static bool get isDevelopment => current == Environment.development;
  static bool get isStaging => current == Environment.staging;
  static bool get isProduction => current == Environment.production;

  /// API Configuration
  static String get apiBaseUrl {
    switch (current) {
      case Environment.development:
        return 'http://localhost:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.tourlicity.com/api/v1';
      case Environment.production:
        return 'https://api.tourlicity.com/api/v1';
    }
  }

  /// App Configuration
  static String get appName {
    switch (current) {
      case Environment.development:
        return 'Tourlicity Dev';
      case Environment.staging:
        return 'Tourlicity Staging';
      case Environment.production:
        return 'Tourlicity';
    }
  }

  static String get appId {
    switch (current) {
      case Environment.development:
        return 'com.tourlicity.app.dev';
      case Environment.staging:
        return 'com.tourlicity.app.staging';
      case Environment.production:
        return 'com.tourlicity.app';
    }
  }

  /// Firebase Configuration
  static String get firebaseProjectId {
    switch (current) {
      case Environment.development:
        return 'tourlicity-dev';
      case Environment.staging:
        return 'tourlicity-staging';
      case Environment.production:
        return 'tourlicity-prod';
    }
  }

  /// Google Sign-In Configuration
  static String get googleClientId {
    switch (current) {
      case Environment.development:
        return '519507867000-q7afm0sitg8g1r5860u4ftclu60fb376.apps.googleusercontent.com';
      case Environment.staging:
        return 'staging-client-id.googleusercontent.com';
      case Environment.production:
        return 'prod-client-id.googleusercontent.com';
    }
  }

  /// Backend OAuth Configuration
  static String get googleAuthUrl => '$apiBaseUrl/auth/google';
  static String get googleCallbackUrl => '$apiBaseUrl/auth/google/callback';
  static String get refreshTokenUrl => '$apiBaseUrl/auth/refresh';
  static String get profileCompleteUrl => '$apiBaseUrl/auth/profile/complete';
  
  /// Health Check Configuration
  static String get healthCheckUrl {
    switch (current) {
      case Environment.development:
        return 'http://localhost:3000/health';
      case Environment.staging:
        return 'https://staging-api.tourlicity.com/health';
      case Environment.production:
        return 'https://api.tourlicity.com/health';
    }
  }

  /// Feature Flags
  static bool get enableAnalytics => isStaging || isProduction;
  static bool get enableCrashReporting => isStaging || isProduction;
  static bool get enablePerformanceMonitoring => isProduction;
  static bool get enableDebugLogging => isDevelopment || isStaging;

  /// Security Configuration
  static bool get enableCertificatePinning => isProduction;
  static bool get enableBiometricAuth => isStaging || isProduction;
  static Duration get tokenRefreshThreshold => isProduction 
      ? const Duration(minutes: 5) 
      : const Duration(minutes: 1);

  /// Performance Configuration
  static int get maxCacheSize => isProduction ? 100 * 1024 * 1024 : 50 * 1024 * 1024; // 100MB prod, 50MB dev
  static Duration get networkTimeout => isProduction 
      ? const Duration(seconds: 30) 
      : const Duration(seconds: 10);

  /// Get environment info for debugging
  static Map<String, dynamic> get environmentInfo => {
    'environment': current.name,
    'apiBaseUrl': apiBaseUrl,
    'appName': appName,
    'appId': appId,
    'isDebug': kDebugMode,
    'enableAnalytics': enableAnalytics,
    'enableCrashReporting': enableCrashReporting,
    'timestamp': DateTime.now().toIso8601String(),
  };

  /// Validate environment configuration
  static bool validateConfiguration() {
    try {
      // Validate required configurations
      if (apiBaseUrl.isEmpty) return false;
      if (appName.isEmpty) return false;
      if (appId.isEmpty) return false;
      if (firebaseProjectId.isEmpty) return false;
      if (googleClientId.isEmpty) return false;
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Environment configuration validation failed: $e');
      }
      return false;
    }
  }
}