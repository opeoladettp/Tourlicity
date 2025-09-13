import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/provider/provider_list_item.dart';
import 'package:tourlicity_app/domain/entities/provider.dart';

void main() {
  group('ProviderListItem Widget Tests', () {
    late Provider testProvider;

    setUp(() {
      testProvider = const Provider(
        id: '1',
        name: 'Test Provider',
        email: 'test@provider.com',
        phoneNumber: '+1234567890',
        address: '123 Test Street',
        isActive: true,
        rating: 4.5,
        totalReviews: 10,
      );
    });

    testWidgets('should display provider information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderListItem(
              provider: testProvider,
            ),
          ),
        ),
      );

      expect(find.text('Test Provider'), findsOneWidget);
      expect(find.text('test@provider.com'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
      expect(find.text('123 Test Street'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(10)'), findsOneWidget);
    });

    testWidgets('should show inactive status for inactive providers', (WidgetTester tester) async {
      final inactiveProvider = testProvider.copyWith(isActive: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderListItem(
              provider: inactiveProvider,
            ),
          ),
        ),
      );

      expect(find.text('Inactive'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('should display provider initial in avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderListItem(
              provider: testProvider,
            ),
          ),
        ),
      );

      expect(find.text('T'), findsOneWidget); // First letter of "Test Provider"
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool onTapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderListItem(
              provider: testProvider,
              onTap: () {
                onTapCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(onTapCalled, isTrue);
    });

    testWidgets('should show popup menu with edit and delete options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderListItem(
              provider: testProvider,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap the popup menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should call onEdit when edit menu item is selected', (WidgetTester tester) async {
      bool onEditCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderListItem(
              provider: testProvider,
              onEdit: () {
                onEditCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap the popup menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap the edit option
      await tester.tap(find.text('Edit'));
      await tester.pump();

      expect(onEditCalled, isTrue);
    });

    testWidgets('should not show rating when rating is 0', (WidgetTester tester) async {
      final providerWithoutRating = testProvider.copyWith(rating: 0.0, totalReviews: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProviderListItem(
              provider: providerWithoutRating,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.text('0.0'), findsNothing);
    });
  });
}