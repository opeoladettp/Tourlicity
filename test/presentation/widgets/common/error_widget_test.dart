import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/common/error_widget.dart';

void main() {
  group('CustomErrorWidget Tests', () {
    testWidgets('should display error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              message: 'Network error',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      expect(retryPressed, isTrue);
    });

    testWidgets('should not display retry button when onRetry is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              message: 'Error without retry',
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('should display custom title when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              title: 'Custom Error',
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Custom Error'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should use default title when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              message: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('should display custom icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(
              message: 'Network error',
              icon: Icons.wifi_off,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });
  });
}