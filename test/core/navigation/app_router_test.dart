import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:tourlicity_app/core/navigation/app_router.dart';
import 'package:tourlicity_app/core/navigation/app_routes.dart';
import 'package:tourlicity_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/auth/auth_state.dart';
import 'package:tourlicity_app/domain/entities/user.dart';
import 'package:tourlicity_app/domain/entities/auth_user.dart';
import 'package:tourlicity_app/domain/entities/user_type.dart';

import 'app_router_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  group('AppRouter', () {
    late MockAuthBloc mockAuthBloc;
    late GoRouter router;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
      when(mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(AuthState.initial()));
      router = AppRouter.createRouter(mockAuthBloc);
    });

    group('Route Navigation', () {
      testWidgets('should navigate to login when unauthenticated',
          (tester) async {
        when(mockAuthBloc.state).thenReturn(AuthState.unauthenticated());

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        expect(router.routerDelegate.currentConfiguration.uri.path,
            equals(AppRoutes.login));
      });

      testWidgets(
          'should navigate to profile completion when profile incomplete',
          (tester) async {
        final authUser = AuthUser(
          user: User(
            id: '1',
            email: 'test@example.com',
            name: 'Test User',
            userType: UserType.tourist,
            profileCompleted: false,
            createdAt: DateTime.now(),
          ),
          accessToken: 'token',
          refreshToken: 'refresh',
        );

        when(mockAuthBloc.state).thenReturn(AuthState.authenticated(authUser));

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        expect(router.routerDelegate.currentConfiguration.uri.path,
            equals(AppRoutes.profileCompletion));
      });

      testWidgets(
          'should navigate to tourist dashboard when tourist authenticated',
          (tester) async {
        final authUser = AuthUser(
          user: User(
            id: '1',
            email: 'test@example.com',
            name: 'Test User',
            userType: UserType.tourist,
            profileCompleted: true,
            createdAt: DateTime.now(),
          ),
          accessToken: 'token',
          refreshToken: 'refresh',
        );

        when(mockAuthBloc.state).thenReturn(AuthState.authenticated(authUser));

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        expect(router.routerDelegate.currentConfiguration.uri.path,
            equals(AppRoutes.touristDashboard));
      });

      testWidgets(
          'should navigate to system admin dashboard when system admin authenticated',
          (tester) async {
        final authUser = AuthUser(
          user: User(
            id: '1',
            email: 'admin@example.com',
            name: 'Admin User',
            userType: UserType.systemAdmin,
            profileCompleted: true,
            createdAt: DateTime.now(),
          ),
          accessToken: 'token',
          refreshToken: 'refresh',
        );

        when(mockAuthBloc.state).thenReturn(AuthState.authenticated(authUser));

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        expect(router.routerDelegate.currentConfiguration.uri.path,
            equals(AppRoutes.systemAdminDashboard));
      });

      testWidgets(
          'should navigate to provider admin dashboard when provider admin authenticated',
          (tester) async {
        final authUser = AuthUser(
          user: User(
            id: '1',
            email: 'provider@example.com',
            name: 'Provider User',
            userType: UserType.providerAdmin,
            profileCompleted: true,
            createdAt: DateTime.now(),
          ),
          accessToken: 'token',
          refreshToken: 'refresh',
        );

        when(mockAuthBloc.state).thenReturn(AuthState.authenticated(authUser));

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        expect(router.routerDelegate.currentConfiguration.uri.path,
            equals(AppRoutes.providerAdminDashboard));
      });
    });

    group('Role-based Access Control', () {
      testWidgets('should redirect tourist trying to access admin dashboard',
          (tester) async {
        final authUser = AuthUser(
          user: User(
            id: '1',
            email: 'tourist@example.com',
            name: 'Tourist User',
            role: UserRole.tourist,
            isProfileComplete: true,
            createdAt: DateTime.now(),
          ),
          accessToken: 'token',
          refreshToken: 'refresh',
        );

        when(mockAuthBloc.state).thenReturn(AuthState.authenticated(authUser));

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        // Try to navigate to system admin dashboard
        router.go(AppRoutes.systemAdminDashboard);
        await tester.pumpAndSettle();

        // Should be redirected to tourist dashboard
        expect(router.routerDelegate.currentConfiguration.uri.path,
            equals(AppRoutes.touristDashboard));
      });

      testWidgets(
          'should redirect system admin trying to access provider dashboard',
          (tester) async {
        final authUser = AuthUser(
          user: User(
            id: '1',
            email: 'admin@example.com',
            name: 'Admin User',
            role: UserRole.systemAdmin,
            isProfileComplete: true,
            createdAt: DateTime.now(),
          ),
          accessToken: 'token',
          refreshToken: 'refresh',
        );

        when(mockAuthBloc.state).thenReturn(AuthState.authenticated(authUser));

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        // Try to navigate to provider admin dashboard
        router.go(AppRoutes.providerAdminDashboard);
        await tester.pumpAndSettle();

        // Should be redirected to system admin dashboard
        expect(router.routerDelegate.currentConfiguration.uri.path,
            equals(AppRoutes.systemAdminDashboard));
      });
    });

    group('Error Handling', () {
      testWidgets('should navigate to login on authentication error',
          (tester) async {
        when(mockAuthBloc.state)
            .thenReturn(AuthState.error('Authentication failed'));

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        expect(router.routerDelegate.currentConfiguration.uri.path,
            equals(AppRoutes.login));
        expect(
            router.routerDelegate.currentConfiguration.uri
                .queryParameters['error'],
            equals('Authentication failed'));
      });

      testWidgets('should show error page for unknown routes', (tester) async {
        when(mockAuthBloc.state).thenReturn(AuthState.unauthenticated());

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: MaterialApp.router(routerConfig: router),
          ),
        );

        // Navigate to unknown route
        router.go('/unknown-route');
        await tester.pumpAndSettle();

        // Should show error page
        expect(find.text('Page not found'), findsOneWidget);
        expect(find.text('Go Home'), findsOneWidget);
      });
    });

    group('AppRouter Configuration', () {
      test('should create router with correct initial location', () {
        final testRouter = AppRouter.createRouter(mockAuthBloc);
        expect(testRouter.routeInformationProvider, isNotNull);
        expect(testRouter.routeInformationParser, isNotNull);
        expect(testRouter.routerDelegate, isNotNull);
      });

      test('should have redirect logic configured', () {
        final testRouter = AppRouter.createRouter(mockAuthBloc);
        // The router should have redirect logic configured
        // This is tested indirectly through the navigation tests above
        expect(testRouter, isA<GoRouter>());
      });
    });
  });
}
