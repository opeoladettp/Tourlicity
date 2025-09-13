import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tourlicity_app/presentation/widgets/forms/profile_completion_form.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_state.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_event.dart';

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

void main() {
  group('ProfileCompletionForm Widget Tests', () {
    late MockUserBloc mockUserBloc;

    setUp(() {
      mockUserBloc = MockUserBloc();
    });

    testWidgets('should display all required form fields',
        (WidgetTester tester) async {
      whenListen(
        mockUserBloc,
        Stream.value(const UserInitial()),
        initialState: const UserInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<UserBloc>(
              create: (_) => mockUserBloc,
              child: const ProfileCompletionForm(),
            ),
          ),
        ),
      );

      // Check for form fields
      expect(find.byType(TextFormField),
          findsNWidgets(3)); // First name, last name, and phone
      expect(find.text('First Name *'), findsOneWidget);
      expect(find.text('Last Name *'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      whenListen(
        mockUserBloc,
        Stream.value(const UserInitial()),
        initialState: const UserInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<UserBloc>(
              create: (_) => mockUserBloc,
              child: const ProfileCompletionForm(),
            ),
          ),
        ),
      );

      // Try to submit without filling fields
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should show validation errors
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
    });

    testWidgets('should submit form with valid data',
        (WidgetTester tester) async {
      whenListen(
        mockUserBloc,
        Stream.value(const UserInitial()),
        initialState: const UserInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<UserBloc>(
              create: (_) => mockUserBloc,
              child: const ProfileCompletionForm(),
            ),
          ),
        ),
      );

      // Fill in the form using text field indices
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John'); // First name field
      await tester.enterText(textFields.at(1), 'Doe'); // Last name field

      // Submit the form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify that the CompleteUserProfile event was added to the bloc
      verify(() => mockUserBloc.add(const CompleteUserProfile(
            firstName: 'John',
            lastName: 'Doe',
            phone: null,
          ))).called(1);
    });

    testWidgets('should show loading state during submission',
        (WidgetTester tester) async {
      whenListen(
        mockUserBloc,
        Stream.value(const UserProfileCompleting()),
        initialState: const UserProfileCompleting(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<UserBloc>(
              create: (_) => mockUserBloc,
              child: const ProfileCompletionForm(),
            ),
          ),
        ),
      );

      // The form should still be displayed during loading
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should handle error state properly',
        (WidgetTester tester) async {
      whenListen(
        mockUserBloc,
        Stream.value(const UserError(message: 'Profile completion failed')),
        initialState: const UserError(message: 'Profile completion failed'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<UserBloc>(
              create: (_) => mockUserBloc,
              child: const ProfileCompletionForm(),
            ),
          ),
        ),
      );

      // The form should still be displayed even in error state
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should have proper form structure',
        (WidgetTester tester) async {
      // Set up mock behavior for this test
      when(mockUserBloc.state).thenReturn(const UserInitial());
      when(mockUserBloc.stream)
          .thenAnswer((_) => Stream.value(const UserInitial()));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<UserBloc>(
              create: (_) => mockUserBloc,
              child: const ProfileCompletionForm(),
            ),
          ),
        ),
      );

      // Check form structure
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(3)); // First name, last name, phone
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('* Required fields'), findsOneWidget);
    });

    testWidgets('should submit form with phone number when provided',
        (WidgetTester tester) async {
      // Set up mock behavior for this test
      when(mockUserBloc.state).thenReturn(const UserInitial());
      when(mockUserBloc.stream)
          .thenAnswer((_) => Stream.value(const UserInitial()));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<UserBloc>(
              create: (_) => mockUserBloc,
              child: const ProfileCompletionForm(),
            ),
          ),
        ),
      );

      // Fill in the form including phone number
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Jane'); // First name field
      await tester.enterText(textFields.at(1), 'Smith'); // Last name field
      await tester.enterText(textFields.at(2), '+1234567890'); // Phone field

      // Submit the form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify that the CompleteUserProfile event was added with phone number
      verify(mockUserBloc.add(const CompleteUserProfile(
        firstName: 'Jane',
        lastName: 'Smith',
        phone: '+1234567890',
      ))).called(1);
    });
  });
}
