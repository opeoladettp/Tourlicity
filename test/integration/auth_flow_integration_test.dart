import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tourlicity_app/main.dart' as app;
import 'package:tourlicity_app/presentation/pages/auth/login_page.dart';
import 'package:tourlicity_app/presentation/pages/profile/profile_completion_page.dart';
import 'package:tourlicity_app/presentation/pages/dashboard/tourist_dashboard.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('complete authentication flow from login to dashboard', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start at login page
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);

      // Tap Google Sign In button
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      // Note: In a real integration test, this would trigger actual Google Sign In
      // For testing purposes, we'll simulate the flow by checking navigation

      // After successful login with incomplete profile, should navigate to profile completion
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Check if we're on profile completion page (for new users)
      if (find.byType(ProfileCompletionPage).evaluate().isNotEmpty) {
        // Fill in profile completion form
        await tester.enterText(find.byKey(const Key('firstName')), 'Test');
        await tester.enterText(find.byKey(const Key('lastName')), 'User');
        
        // Submit profile completion
        await tester.tap(find.text('Complete Profile'));
        await tester.pumpAndSettle();
      }

      // Should navigate to appropriate dashboard based on user role
      // For this test, assuming tourist role
      expect(find.byType(TouristDashboard), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('login flow with existing complete profile', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start at login page
      expect(find.byType(LoginPage), findsOneWidget);

      // Tap Google Sign In button
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      // For existing users with complete profiles, should go directly to dashboard
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Should be on dashboard (type depends on user role)
      expect(
        find.byType(TouristDashboard).evaluate().isNotEmpty ||
        find.text('Dashboard').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('logout flow', (WidgetTester tester) async {
      // Start the app and assume user is already logged in
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings or profile page where logout option is available
      // This depends on the app's navigation structure
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Find and tap logout option
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Should return to login page
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('authentication error handling', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start at login page
      expect(find.byType(LoginPage), findsOneWidget);

      // Simulate authentication error by tapping sign in multiple times rapidly
      await tester.tap(find.text('Sign in with Google'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      // Should show error message or remain on login page
      expect(
        find.text('Authentication failed').evaluate().isNotEmpty ||
        find.byType(LoginPage).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('profile completion validation', (WidgetTester tester) async {
      // Start the app and navigate to profile completion
      app.main();
      await tester.pumpAndSettle();

      // Assume we're on profile completion page
      if (find.byType(ProfileCompletionPage).evaluate().isEmpty) {
        // Navigate to profile completion if not already there
        await tester.tap(find.text('Sign in with Google'));
        await tester.pumpAndSettle();
      }

      // Try to submit without filling required fields
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your first name'), findsOneWidget);
      expect(find.text('Please enter your last name'), findsOneWidget);

      // Fill in only first name
      await tester.enterText(find.byKey(const Key('firstName')), 'Test');
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      // Should still show last name validation error
      expect(find.text('Please enter your last name'), findsOneWidget);

      // Fill in last name and submit
      await tester.enterText(find.byKey(const Key('lastName')), 'User');
      await tester.tap(find.text('Complete Profile'));
      await tester.pumpAndSettle();

      // Should navigate to dashboard
      expect(find.byType(TouristDashboard), findsOneWidget);
    });
  });
}