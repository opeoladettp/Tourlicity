import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/common/loading_widget.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('should display circular progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display loading message when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              message: 'Loading data...',
            ),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not display message when not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should center content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              message: 'Loading...',
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should have proper spacing between indicator and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(
              message: 'Loading...',
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}