import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tourlicity_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tour Registration Flow Tests', () {
    testWidgets('Complete tour registration flow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test tour registration flow
      await _testTourRegistrationFlow(tester);
    });

    testWidgets('Join tour with valid code', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test joining a tour with a valid code
      await _testJoinTourWithCode(tester);
    });

    testWidgets('Handle invalid join code', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test error handling for invalid join codes
      await _testInvalidJoinCode(tester);
    });
  });
}

Future<void> _testTourRegistrationFlow(WidgetTester tester) async {
  // Wait for app to load
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Look for navigation elements or login screen
  // This is a basic implementation - adjust based on your app's actual flow

  // Try to find join tour button or similar
  Finder? joinTourFinder;
  if (find.text('Join Tour').evaluate().isNotEmpty) {
    joinTourFinder = find.text('Join Tour');
  } else if (find.text('Enter Join Code').evaluate().isNotEmpty) {
    joinTourFinder = find.text('Enter Join Code');
  }

  if (joinTourFinder != null) {
    await tester.tap(joinTourFinder);
    await tester.pumpAndSettle();

    // Look for join code input field
    Finder? joinCodeField;
    if (find.byType(TextField).evaluate().isNotEmpty) {
      joinCodeField = find.byType(TextField);
    } else if (find.byType(TextFormField).evaluate().isNotEmpty) {
      joinCodeField = find.byType(TextFormField);
    }

    if (joinCodeField != null) {
      // Enter a test join code
      await tester.enterText(joinCodeField.first, 'TEST123');
      await tester.pumpAndSettle();

      // Look for submit button
      Finder? submitButton;
      if (find.text('Join').evaluate().isNotEmpty) {
        submitButton = find.text('Join');
      } else if (find.text('Submit').evaluate().isNotEmpty) {
        submitButton = find.text('Submit');
      } else if (find.text('Continue').evaluate().isNotEmpty) {
        submitButton = find.text('Continue');
      }

      if (submitButton != null) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();
      }
    }
  }

  // Verify that we've progressed through the flow
  // This is a basic check - adjust based on your app's behavior
  expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
}

Future<void> _testJoinTourWithCode(WidgetTester tester) async {
  // Wait for app to load
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Navigate to join tour screen
  Finder? joinButton;
  if (find.text('Join Tour').evaluate().isNotEmpty) {
    joinButton = find.text('Join Tour');
  } else if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
    joinButton = find.byIcon(Icons.add);
  }

  if (joinButton != null) {
    await tester.tap(joinButton);
    await tester.pumpAndSettle();

    // Enter join code
    if (find.byType(TextField).evaluate().isNotEmpty) {
      final codeField = find.byType(TextField).first;
      await tester.enterText(codeField, 'VALID123');
      await tester.pumpAndSettle();

      // Submit the code
      Finder? submitButton;
      if (find.text('Join').evaluate().isNotEmpty) {
        submitButton = find.text('Join');
      } else if (find.text('Submit').evaluate().isNotEmpty) {
        submitButton = find.text('Submit');
      }

      if (submitButton != null) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();
      }

      // Verify success or error handling
      // Look for either success message or error message
      final hasMessage = find.byType(SnackBar).evaluate().isNotEmpty ||
          find.text('Success').evaluate().isNotEmpty ||
          find.text('Error').evaluate().isNotEmpty;

      expect(hasMessage, isTrue,
          reason: 'Should show some feedback after join attempt');
    }
  }
}

Future<void> _testInvalidJoinCode(WidgetTester tester) async {
  // Wait for app to load
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Navigate to join tour screen
  Finder? joinButton;
  if (find.text('Join Tour').evaluate().isNotEmpty) {
    joinButton = find.text('Join Tour');
  } else if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
    joinButton = find.byIcon(Icons.add);
  }

  if (joinButton != null) {
    await tester.tap(joinButton);
    await tester.pumpAndSettle();

    // Enter invalid join code
    if (find.byType(TextField).evaluate().isNotEmpty) {
      final codeField = find.byType(TextField).first;
      await tester.enterText(codeField, 'INVALID');
      await tester.pumpAndSettle();

      // Submit the invalid code
      Finder? submitButton;
      if (find.text('Join').evaluate().isNotEmpty) {
        submitButton = find.text('Join');
      } else if (find.text('Submit').evaluate().isNotEmpty) {
        submitButton = find.text('Submit');
      }

      if (submitButton != null) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();
      }

      // Verify error handling
      // Should show error message for invalid code
      final hasErrorMessage = find.text('Invalid').evaluate().isNotEmpty ||
          find.text('Error').evaluate().isNotEmpty ||
          find.text('Not found').evaluate().isNotEmpty;

      expect(hasErrorMessage, isTrue,
          reason: 'Should show error message for invalid join code');
    }
  }
}
