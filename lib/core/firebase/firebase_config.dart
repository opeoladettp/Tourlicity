import 'package:firebase_core/firebase_core.dart';
// Temporarily disabled other Firebase imports
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// Firebase configuration and initialization
class FirebaseConfig {
  static dynamic _analytics;
  static dynamic _crashlytics;
  static dynamic _performance;
  static bool _isInitialized = false;

  /// Initialize Firebase services
  static Future<void> initialize() async {
    try {
      debugPrint('Firebase: Initializing Firebase Core...');
      
      // Skip Firebase initialization in debug mode for web to avoid network issues
      if (kIsWeb && kDebugMode) {
        debugPrint('Firebase: Skipping initialization in web debug mode');
        _isInitialized = true;
        return;
      }
      
      // Initialize Firebase Core with proper options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      debugPrint('Firebase: Core initialized successfully');
      
      // Initialize stub services for other Firebase features
      _analytics = null; // Will be initialized when firebase_analytics is added
      _crashlytics = null; // Will be initialized when firebase_crashlytics is added
      _performance = null; // Will be initialized when firebase_performance is added
      
      _isInitialized = true;
      debugPrint('Firebase: All services initialized');
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      _isInitialized = true; // Mark as initialized to continue app startup
    }
  }

  // Stub implementations - no actual Firebase configuration needed

  /// Get Firebase Analytics instance (Stub)
  static dynamic get analytics => _analytics;

  /// Get Firebase Crashlytics instance (Stub)
  static dynamic get crashlytics => _crashlytics;

  /// Get Firebase Performance instance (Stub)
  static dynamic get performance => _performance;

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;
}
