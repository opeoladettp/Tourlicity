import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tourlicity_app/main.dart' as app;


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Workflow E2E Tests', () {
    testWidgets('Tourist complete workflow - from login to tour registration', (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login flow
      expect(find.text('Tourlicity'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);

      // Simulate login (in real test, this would use actual Google Sign-In)
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Profile completion (if needed)
      if (find.text('Complete Profile').evaluate().isNotEmpty) {
        await tester.enterText(find.byKey(const Key('firstName')), 'John');
        await tester.enterText(find.byKey(const Key('lastName')), 'Doe');
        await tester.tap(find.text('Complete Profile'));
        await tester.pumpAndSettle();
      }

      // Step 3: Navigate to tourist dashboard
      expect(find.text('My Tours'), findsOneWidget);
      expect(find.text('Join Tour'), findsOneWidget);

      // Step 4: Join a tour using join code
      await tester.tap(find.text('Join Tour'));
      await tester.pumpAndSettle();

      expect(find.text('Enter Join Code'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('joinCode')), 'TOUR123');
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Step 5: Fill registration form
      if (find.text('Register for Tour').evaluate().isNotEmpty) {
        await tester.enterText(
          find.byKey(const Key('specialRequirements')), 
          'No special requirements'
        );
        await tester.enterText(
          find.byKey(const Key('emergencyContact')), 
          'Jane Doe - +1234567890'
        );
        await tester.tap(find.text('Register'));
        await tester.pumpAndSettle();
      }

      // Step 6: Verify registration success
      expect(find.textContaining('Registration successful'), findsOneWidget);

      // Step 7: Navigate back to dashboard and verify tour appears
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('My Tours'), findsOneWidget);
      // Should show the registered tour
    });

    testWidgets('Provider complete workflow - from login to tour management', (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login as provider
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Navigate to provider dashboard
      expect(find.text('Tour Management'), findsOneWidget);
      expect(find.text('Create Tour'), findsOneWidget);

      // Step 3: Create a new tour
      await tester.tap(find.text('Create Tour'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('tourName')), 'City Walking Tour');
      await tester.enterText(find.byKey(const Key('description')), 'Amazing city tour');
      
      // Select dates (simplified for test)
      await tester.tap(find.byKey(const Key('startDate')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // Confirm date picker
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('endDate')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // Confirm date picker
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('maxTourists')), '20');
      await tester.enterText(find.byKey(const Key('price')), '50.00');

      await tester.tap(find.text('Create Tour'));
      await tester.pumpAndSettle();

      // Step 4: Verify tour creation
      expect(find.textContaining('Tour created successfully'), findsOneWidget);

      // Step 5: Navigate to tour management and verify tour appears
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('City Walking Tour'), findsOneWidget);

      // Step 6: Manage tour registrations
      await tester.tap(find.text('City Walking Tour'));
      await tester.pumpAndSettle();

      expect(find.text('Registrations'), findsOneWidget);
      await tester.tap(find.text('Registrations'));
      await tester.pumpAndSettle();

      // Should show registration management interface
      expect(find.text('Pending Registrations'), findsOneWidget);
    });

    testWidgets('System admin complete workflow - provider and template management', (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login as system admin
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 2: Navigate to system admin dashboard
      expect(find.text('Provider Management'), findsOneWidget);
      expect(find.text('Tour Templates'), findsOneWidget);

      // Step 3: Create a new provider
      await tester.tap(find.text('Provider Management'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('providerName')), 'Test Provider');
      await tester.enterText(find.byKey(const Key('email')), 'test@provider.com');
      await tester.enterText(find.byKey(const Key('phone')), '+1234567890');
      await tester.enterText(find.byKey(const Key('address')), '123 Test Street');

      await tester.tap(find.text('Create Provider'));
      await tester.pumpAndSettle();

      // Step 4: Verify provider creation
      expect(find.textContaining('Provider created successfully'), findsOneWidget);

      // Step 5: Navigate to tour templates
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tour Templates'));
      await tester.pumpAndSettle();

      // Step 6: Create a tour template
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('templateName')), 'City Tour Template');
      await tester.enterText(find.byKey(const Key('description')), 'Standard city tour');

      await tester.tap(find.text('Create Template'));
      await tester.pumpAndSettle();

      // Step 7: Verify template creation
      expect(find.textContaining('Template created successfully'), findsOneWidget);
    });

    testWidgets('Document management workflow', (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Login and navigate to documents
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to documents section
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Upload a document
      await tester.tap(find.text('Upload Document'));
      await tester.pumpAndSettle();

      // Simulate file selection (in real test, this would use actual file picker)
      expect(find.text('Select File'), findsOneWidget);
      await tester.tap(find.text('Select File'));
      await tester.pumpAndSettle();

      // Verify document appears in list
      expect(find.text('My Documents'), findsOneWidget);
    });

    testWidgets('Message and communication workflow', (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Login as provider
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to messages
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();

      // Create a broadcast message
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('messageTitle')), 'Important Update');
      await tester.enterText(find.byKey(const Key('messageContent')), 'Tour schedule has been updated');

      await tester.tap(find.text('Send Message'));
      await tester.pumpAndSettle();

      // Verify message was sent
      expect(find.textContaining('Message sent successfully'), findsOneWidget);
    });
  });
}