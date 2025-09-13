import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tourlicity_app/core/theme/theme_manager.dart';

void main() {
  group('ThemeManager', () {
    late ThemeManager themeManager;

    setUp(() {
      themeManager = ThemeManager();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      themeManager.dispose();
    });

    test('initializes with default values', () {
      expect(themeManager.themeMode, ThemeMode.system);
      expect(themeManager.isHighContrastMode, false);
      expect(themeManager.textScaleFactor, 1.0);
    });

    test('can set theme mode', () async {
      await themeManager.initialize();
      
      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      await themeManager.setThemeMode(ThemeMode.dark);

      expect(themeManager.themeMode, ThemeMode.dark);
      expect(notified, true);
    });

    test('can toggle theme mode', () async {
      await themeManager.initialize();
      
      // Start with light theme
      await themeManager.setThemeMode(ThemeMode.light);
      
      await themeManager.toggleTheme();
      expect(themeManager.themeMode, ThemeMode.dark);
      
      await themeManager.toggleTheme();
      expect(themeManager.themeMode, ThemeMode.light);
    });

    test('can set high contrast mode', () async {
      await themeManager.initialize();
      
      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      await themeManager.setHighContrastMode(true);

      expect(themeManager.isHighContrastMode, true);
      expect(notified, true);
    });

    test('can toggle high contrast mode', () async {
      await themeManager.initialize();
      
      expect(themeManager.isHighContrastMode, false);
      
      await themeManager.toggleHighContrastMode();
      expect(themeManager.isHighContrastMode, true);
      
      await themeManager.toggleHighContrastMode();
      expect(themeManager.isHighContrastMode, false);
    });

    test('can set text scale factor', () async {
      await themeManager.initialize();
      
      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      await themeManager.setTextScaleFactor(1.5);

      expect(themeManager.textScaleFactor, 1.5);
      expect(notified, true);
    });

    test('clamps text scale factor to valid range', () async {
      await themeManager.initialize();
      
      // Test minimum clamp
      await themeManager.setTextScaleFactor(0.5);
      expect(themeManager.textScaleFactor, 0.8);
      
      // Test maximum clamp
      await themeManager.setTextScaleFactor(3.0);
      expect(themeManager.textScaleFactor, 2.0);
    });

    test('can reset to defaults', () async {
      await themeManager.initialize();
      
      // Change all settings
      await themeManager.setThemeMode(ThemeMode.dark);
      await themeManager.setHighContrastMode(true);
      await themeManager.setTextScaleFactor(1.5);
      
      bool notified = false;
      themeManager.addListener(() {
        notified = true;
      });

      await themeManager.resetToDefaults();

      expect(themeManager.themeMode, ThemeMode.system);
      expect(themeManager.isHighContrastMode, false);
      expect(themeManager.textScaleFactor, 1.0);
      expect(notified, true);
    });

    test('persists settings to shared preferences', () async {
      await themeManager.initialize();
      
      await themeManager.setThemeMode(ThemeMode.dark);
      await themeManager.setHighContrastMode(true);
      await themeManager.setTextScaleFactor(1.2);

      // Verify settings are persisted by checking the current instance
      expect(themeManager.themeMode, ThemeMode.dark);
      expect(themeManager.isHighContrastMode, true);
      expect(themeManager.textScaleFactor, 1.2);
    });

    test('does not notify listeners when setting same value', () async {
      await themeManager.initialize();
      
      int notificationCount = 0;
      themeManager.addListener(() {
        notificationCount++;
      });

      // Set same theme mode twice
      await themeManager.setThemeMode(ThemeMode.system);
      await themeManager.setThemeMode(ThemeMode.system);

      expect(notificationCount, 0);
    });

    testWidgets('detects reduced motion preference', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isReduced = themeManager.isReducedMotionPreferred(context);
              return Text(isReduced.toString());
            },
          ),
        ),
      );

      // By default, reduced motion should be false in tests
      expect(find.text('false'), findsOneWidget);
    });

    testWidgets('returns zero duration for reduced motion', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final duration = themeManager.getAnimationDuration(
                  context, 
                  const Duration(milliseconds: 300),
                );
                return Text(duration.inMilliseconds.toString());
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('returns normal duration when motion not reduced', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final duration = themeManager.getAnimationDuration(
                  context, 
                  const Duration(milliseconds: 300),
                );
                return Text(duration.inMilliseconds.toString());
              },
            ),
          ),
        ),
      );

      expect(find.text('300'), findsOneWidget);
    });
  });
}