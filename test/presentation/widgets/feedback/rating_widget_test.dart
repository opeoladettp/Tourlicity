import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/feedback/rating_widget.dart';

void main() {
  group('RatingWidget Tests', () {
    testWidgets('should display rating widget with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingWidget(
              title: 'Rate this tour',
              initialRating: 3.0,
              maxRating: 5.0,
              onRatingChanged: (rating) {},
            ),
          ),
        ),
      );

      // Should display title and rating bar
      expect(find.text('Rate this tour'), findsOneWidget);
      expect(find.byType(RatingWidget), findsOneWidget);
    });

    testWidgets('should call onRatingChanged when rating changes', (WidgetTester tester) async {
      double selectedRating = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingWidget(
              title: 'Rate this tour',
              initialRating: 0.0,
              maxRating: 5.0,
              onRatingChanged: (rating) {
                selectedRating = rating;
              },
            ),
          ),
        ),
      );

      // Tap on the rating bar to change rating
      await tester.tap(find.byIcon(Icons.star).first);
      await tester.pump();

      expect(selectedRating, greaterThan(0.0));
    });

    testWidgets('should display read-only rating when isReadOnly is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingWidget(
              title: 'Current Rating',
              initialRating: 4.0,
              maxRating: 5.0,
              isReadOnly: true,
              onRatingChanged: (rating) {},
            ),
          ),
        ),
      );

      // Should display rating widget in read-only mode
      expect(find.text('Current Rating'), findsOneWidget);
      expect(find.byType(RatingWidget), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingWidget(
              title: 'Rate this tour',
              subtitle: 'Amazing City Tour',
              initialRating: 3.0,
              maxRating: 5.0,
              onRatingChanged: (rating) {},
            ),
          ),
        ),
      );

      // Should display both title and subtitle
      expect(find.text('Rate this tour'), findsOneWidget);
      expect(find.text('Amazing City Tour'), findsOneWidget);
    });
  });
}