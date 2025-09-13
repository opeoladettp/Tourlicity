import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/feedback/feedback_form_widget.dart';
import 'package:tourlicity_app/presentation/widgets/feedback/rating_widget.dart';

void main() {
  group('FeedbackFormWidget Tests', () {
    testWidgets('should display all form elements for general feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackFormWidget(
              title: 'General Feedback',
              feedbackType: FeedbackType.general,
              onSubmitted: () {},
            ),
          ),
        ),
      );

      // Check for form elements
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(DropdownButtonFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Submit Feedback'), findsOneWidget);
    });

    testWidgets('should validate required fields for general feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackFormWidget(
              title: 'General Feedback',
              feedbackType: FeedbackType.general,
              onSubmitted: () {},
            ),
          ),
        ),
      );

      // Try to submit without filling fields
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Please enter your message'), findsOneWidget);
    });

    testWidgets('should display rating widget for tour feedback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackFormWidget(
              title: 'Tour Feedback',
              feedbackType: FeedbackType.tour,
              entityId: 'tour123',
              entityName: 'Test Tour',
              onSubmitted: () {},
            ),
          ),
        ),
      );

      // Should display rating widget for tour feedback
      expect(find.byType(RatingWidget), findsOneWidget);
      expect(find.text('Rate Tour'), findsOneWidget);
      expect(find.text('Test Tour'), findsOneWidget);
    });

    testWidgets('should show additional fields for bug reports', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackFormWidget(
              title: 'Bug Report',
              feedbackType: FeedbackType.bug,
              onSubmitted: () {},
            ),
          ),
        ),
      );

      // Should show bug-specific fields
      expect(find.text('Bug Title'), findsOneWidget);
      expect(find.text('Bug Description'), findsOneWidget);
      expect(find.text('Steps to Reproduce'), findsOneWidget);
    });

    testWidgets('should show additional fields for feature requests', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackFormWidget(
              title: 'Feature Request',
              feedbackType: FeedbackType.feature,
              onSubmitted: () {},
            ),
          ),
        ),
      );

      // Should show feature-specific fields
      expect(find.text('Feature Title'), findsOneWidget);
      expect(find.text('Feature Description'), findsOneWidget);
      expect(find.text('Why is this feature needed?'), findsOneWidget);
    });
  });
}