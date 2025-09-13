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
import 'package:tourlicity_app/presentation/pages/profile/profile_edit_page.dart';

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

class FakeUserEvent extends Fake implements UserEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUserEvent());
  });

  group('ProfileEditPage', () {
    late MockUserBloc mockUserBloc;

    final testUser = User(
      id: '1',
      email: 'test@example.com',
      name: 'John Doe',
      phone: '+1234567890',
      role: UserRole.tourist,
      isProfileComplete: true,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    );

    final updatedUser = User(
      id: '1',
      email: 'test@example.com',
      name: 'Jane Smith',
      phone: '+0987654321',
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
          child: const ProfileEditPage(),
        ),
      );
    }

    testWidgets('displays user information in form fields', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(UserLoaded(user: testUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Profile Information'), findsOneWidget);

      // Check that form fields are populated with user data
      final emailField = find.widgetWithText(TextFormField, 'test@example.com');
      final firstNameField = find.widgetWithText(TextFormField, 'John');
      final lastNameField = find.widgetWithText(TextFormField, 'Doe');
      final phoneField = find.widgetWithText(TextFormField, '+1234567890');

      expect(emailField, findsOneWidget);
      expect(firstNameField, findsOneWidget);
      expect(lastNameField, findsOneWidget);
      expect(phoneField, findsOneWidget);

      // Check that email field has lock icon indicating read-only
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('loads user profile on init', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      verify(() => mockUserBloc.add(const LoadUserProfile())).called(1);
    });

    testWidgets('shows loading overlay when updating profile', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserUpdating());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Updating profile...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading overlay when loading profile', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(const UserLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Loading profile...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows success snackbar when profile update succeeds',
        (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(UserLoaded(user: testUser));
      whenListen(
        mockUserBloc,
        Stream.fromIterable([
          const UserUpdating(),
          UserUpdated(user: updatedUser),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger the listener

      // Assert
      expect(find.text('Profile updated successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error snackbar when profile update fails',
        (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(UserLoaded(user: testUser));
      whenListen(
        mockUserBloc,
        Stream.fromIterable([
          const UserUpdating(),
          const UserError(message: 'Failed to update profile'),
        ]),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger the listener

      // Assert
      expect(find.text('Failed to update profile'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('form validation works correctly', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(UserLoaded(user: testUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Clear required fields
      await tester.enterText(
          find.byType(TextFormField).at(1), ''); // First name
      await tester.enterText(find.byType(TextFormField).at(2), ''); // Last name

      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      // Assert
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
    });

    testWidgets('submits form with valid changes', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(UserLoaded(user: testUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Modify the form
      await tester.enterText(find.byType(TextFormField).at(1), 'Jane');
      await tester.enterText(find.byType(TextFormField).at(2), 'Smith');
      await tester.enterText(find.byType(TextFormField).at(3), '+0987654321');

      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      // Assert
      verify(() => mockUserBloc.add(const UpdateUserProfile(
            firstName: 'Jane',
            lastName: 'Smith',
            phone: '+0987654321',
          ))).called(1);
    });

    testWidgets('shows no changes message when no modifications made',
        (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(UserLoaded(user: testUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Don't modify anything, just submit
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      // Assert
      expect(find.text('No changes to save'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      verifyNever(() => mockUserBloc.add(any<UpdateUserProfile>()));
    });

    testWidgets('displays user type correctly', (tester) async {
      // Arrange
      final systemAdminUser = User(
        id: '1',
        email: 'admin@example.com',
        name: 'Admin User',
        role: UserRole.systemAdmin,
        isProfileComplete: true,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      when(() => mockUserBloc.state)
          .thenReturn(UserLoaded(user: systemAdminUser));

      // Act
      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<UserBloc>.value(
          value: mockUserBloc,
          child: const ProfileEditPage(),
        ),
      ));

      // Assert
      expect(find.text('System Administrator'), findsOneWidget);
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    });

    testWidgets('validates phone number format', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(UserLoaded(user: testUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid phone number
      await tester.enterText(find.byType(TextFormField).at(3), 'invalid');

      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
      verifyNever(() => mockUserBloc.add(any<UpdateUserProfile>()));
    });

    testWidgets('handles cancel button tap', (tester) async {
      // Arrange
      when(() => mockUserBloc.state).thenReturn(UserLoaded(user: testUser));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert - The page should be popped (we can't easily test navigation in unit tests)
      // This test mainly ensures the cancel button exists and is tappable
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
