import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/auth/google_sign_in_button.dart';

void main() {
  group('GoogleSignInButton Widget Tests', () {
    testWidgets('should display Google Sign In button with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify button is displayed
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      
      // Verify Google icon is present (fallback icon when image fails)
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('should call onPressed when button is tapped', (WidgetTester tester) async {
      bool onPressedCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {
                onPressedCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify callback was called
      expect(onPressedCalled, isTrue);
    });

    testWidgets('should be disabled when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      
      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Should show loading indicator instead of text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continue with Google'), findsNothing);
    });
  });
}