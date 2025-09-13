import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/presentation/pages/auth/login_page.dart';
import 'package:tourlicity_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/auth/auth_state.dart';
import 'package:tourlicity_app/presentation/blocs/auth/auth_event.dart';

// Mock classes
class MockAuthBloc extends Mock implements AuthBloc {}

@GenerateMocks([AuthBloc])
void main() {
  group('LoginPage Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      when(mockAuthBloc.state).thenReturn(AuthState.initial());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthState.initial()));
    });

    testWidgets('should display login UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Should display app title/logo
      expect(find.text('Tourlicity'), findsOneWidget);
      
      // Should display Google Sign-In button
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('should show loading state during authentication', (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthState.loading());
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthState.loading()));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message on authentication failure', (WidgetTester tester) async {
      when(mockAuthBloc.state).thenReturn(AuthState.error('Authentication failed'));
      when(mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthState.error('Authentication failed')));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Should show error message
      expect(find.text('Authentication failed'), findsOneWidget);
    });

    testWidgets('should trigger authentication when sign-in button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Tap the sign-in button
      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      // Should trigger authentication event
      verify(mockAuthBloc.add(const AuthGoogleSignInRequested())).called(1);
    });

    testWidgets('should have proper accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Check accessibility for sign-in button
      final signInButton = find.text('Sign in with Google');
      expect(
        tester.getSemantics(signInButton),
        matchesSemantics(
          label: 'Sign in with Google',
          isButton: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('should display welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>(
            create: (_) => mockAuthBloc,
            child: const LoginPage(),
          ),
        ),
      );

      // Should display welcome text
      expect(find.textContaining('Welcome'), findsOneWidget);
    });
  });
}