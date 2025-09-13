import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tourlicity_app/domain/entities/user.dart';
import 'package:tourlicity_app/domain/entities/user_type.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_event.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_state.dart';
import 'package:tourlicity_app/presentation/pages/profile/profile_completion_page.dart';

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class FakeUserEvent extends Fake implements UserEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserEvent());
  });

  group('ProfileCompletionPage', () {
    late MockUserBloc mockUserBloc;

    final testUser = User(
      id: '1',
      email: 'test@example.com',
      name: 'John Doe',
      role: UserRole.tourist,
      isProfileComplete: true,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

    setUp(() {
      mockUserBloc = MockUserBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<UserBloc>.value(
          value: mockUserBloc,
          child: const ProfileCompletionPage(),
        ),
      );
    }

    testWidgets('displays welcome message and form', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Welcome to Tourlicity!'), findsOneWidget);
      expect(find.text('Please complete your profile to get started.'),
          findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(3)); // First name, last name, phone
      expect(find.text('Complete Profile'), findsOneWidget);
    });

    testWidgets('shows loading overlay when profile is being completed',
        (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserProfileCompleting());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Completing profile...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows success snackbar when profile completion succeeds',
        (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());
      whenListen(
        mockUserBloc,
        Stream.fromIterable([
          const UserProfileCompleting(),
          UserProfileCompleted(user: testUser),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger the listener

      // Assert
      expect(find.text('Profile completed successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error snackbar when profile completion fails',
        (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());
      whenListen(
        mockUserBloc,
        Stream.fromIterable([
          const UserProfileCompleting(),
          const UserError(message: 'Failed to complete profile'),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger the listener

      // Assert
      expect(find.text('Failed to complete profile'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('form validation works correctly', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Try to submit empty form
      await tester.tap(find.text('Complete Profile'));
      await tester.pump();

      // Assert
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
    });

    testWidgets('submits form with valid data', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in the form
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), '+1234567890');

      await tester.tap(find.text('Complete Profile'));
      await tester.pump();

      // Assert
      verify(() => mockUserBloc.add(const CompleteUserProfile(
            firstName: 'John',
            lastName: 'Doe',
            phone: '+1234567890',
          ))).called(1);
    });

    testWidgets('submits form without phone number', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in only required fields
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');

      await tester.tap(find.text('Complete Profile'));
      await tester.pump();

      // Assert
      verify(() => mockUserBloc.add(const CompleteUserProfile(
            firstName: 'John',
            lastName: 'Doe',
            phone: null,
          ))).called(1);
    });

    testWidgets('validates phone number format', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in form with invalid phone
      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'invalid');

      await tester.tap(find.text('Complete Profile'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
      verifyNever(() => mockUserBloc.add(any()));
    });

    testWidgets('validates minimum name length', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in form with short names
      await tester.enterText(find.byType(TextFormField).at(0), 'J');
      await tester.enterText(find.byType(TextFormField).at(1), 'D');

      await tester.tap(find.text('Complete Profile'));
      await tester.pump();

      // Assert
      expect(find.text('First name must be at least 2 characters'),
          findsOneWidget);
      expect(
          find.text('Last name must be at least 2 characters'), findsOneWidget);
      verifyNever(() => mockUserBloc.add(any()));
    });
  });
}
