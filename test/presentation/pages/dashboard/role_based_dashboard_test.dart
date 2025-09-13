import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mockito/annotations.dart';

import 'package:tourlicity_app/presentation/pages/dashboard/system_admin_dashboard.dart';
import 'package:tourlicity_app/presentation/pages/dashboard/provider_admin_dashboard.dart';
import 'package:tourlicity_app/presentation/pages/dashboard/tourist_dashboard.dart';
import 'package:tourlicity_app/core/navigation/role_based_home.dart';
import 'package:tourlicity_app/domain/entities/user.dart';
import 'package:tourlicity_app/domain/entities/user_type.dart';

import 'package:tourlicity_app/presentation/blocs/auth/auth_bloc.dart';

import '../../../core/navigation/app_router_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  group('Role-based Dashboard Tests', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    Widget createTestWidget(Widget child) {
      return BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: MaterialApp(
          home: child,
        ),
      );
    }

    group('RoleBasedHome', () {
      testWidgets('should display SystemAdminDashboard for system admin user',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(const RoleBasedHome()),
        );

        expect(find.byType(SystemAdminDashboard), findsOneWidget);
        expect(find.text('System Admin Dashboard'), findsOneWidget);
      });

      testWidgets(
          'should display ProviderAdminDashboard for provider admin user',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(const RoleBasedHome()),
        );

        expect(find.byType(ProviderAdminDashboard), findsOneWidget);
        expect(find.text('Provider Dashboard'), findsOneWidget);
      });

      testWidgets('should display TouristDashboard for tourist user',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(const RoleBasedHome()),
        );

        expect(find.byType(TouristDashboard), findsOneWidget);
        expect(find.text('My Tours'), findsOneWidget);
      });
    });

    group('SystemAdminDashboard', () {
      testWidgets('should display welcome message and quick actions',
          (tester) async {
        final user = User(
          id: '1',
          email: 'admin@example.com',
          name: 'System Admin',
          role: UserRole.systemAdmin,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(SystemAdminDashboard(user: user)),
        );

        expect(find.text('Welcome back, System Admin!'), findsOneWidget);
        expect(find.text('System Administrator'), findsOneWidget);
        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('Manage Providers'), findsOneWidget);
        expect(find.text('Tour Templates'), findsOneWidget);
        expect(find.text('User Management'), findsOneWidget);
        expect(find.text('Analytics'), findsOneWidget);
      });

      testWidgets('should have drawer with navigation menu', (tester) async {
        final user = User(
          id: '1',
          email: 'admin@example.com',
          name: 'System Admin',
          role: UserRole.systemAdmin,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(SystemAdminDashboard(user: user)),
        );

        // Open drawer
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        expect(find.text('System Admin'), findsOneWidget);
        expect(find.text('admin@example.com'), findsOneWidget);
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Providers'), findsOneWidget);
        expect(find.text('Tour Templates'), findsOneWidget);
        expect(find.text('Users'), findsOneWidget);
        expect(find.text('Analytics'), findsOneWidget);
      });
    });

    group('ProviderAdminDashboard', () {
      testWidgets('should display welcome message and stats', (tester) async {
        final user = User(
          id: '2',
          email: 'provider@example.com',
          name: 'Provider Admin',
          role: UserRole.provider,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(ProviderAdminDashboard(user: user)),
        );

        expect(find.text('Welcome back, Provider Admin!'), findsOneWidget);
        expect(find.text('Provider Administrator'), findsOneWidget);
        expect(find.text('Active Tours'), findsOneWidget);
        expect(find.text('Registrations'), findsOneWidget);
        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('Create Tour'), findsOneWidget);
        expect(find.text('Manage Tours'), findsOneWidget);
      });

      testWidgets('should have drawer with provider-specific menu',
          (tester) async {
        final user = User(
          id: '2',
          email: 'provider@example.com',
          name: 'Provider Admin',
          role: UserRole.provider,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(ProviderAdminDashboard(user: user)),
        );

        // Open drawer
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        expect(find.text('Provider Admin'), findsOneWidget);
        expect(find.text('provider@example.com'), findsOneWidget);
        expect(find.text('My Tours'), findsOneWidget);
        expect(find.text('Registrations'), findsOneWidget);
        expect(find.text('Messages'), findsOneWidget);
        expect(find.text('Documents'), findsOneWidget);
      });
    });

    group('TouristDashboard', () {
      testWidgets('should display welcome message and bottom navigation',
          (tester) async {
        final user = User(
          id: '3',
          email: 'tourist@example.com',
          name: 'Tourist User',
          role: UserRole.tourist,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(TouristDashboard(user: user)),
        );

        expect(find.text('Welcome back, Tourist User!'), findsOneWidget);
        expect(find.text('Ready for your next adventure?'), findsOneWidget);
        expect(find.text('Upcoming Tours'), findsOneWidget);
        expect(find.text('Completed Tours'), findsOneWidget);
        expect(find.text('Recent Activity'), findsOneWidget);

        // Check bottom navigation
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('My Tours'),
            findsAtLeastNWidgets(1)); // Appears in both app bar and bottom nav
        expect(find.text('Join Tour'), findsOneWidget);
        expect(find.text('Documents'), findsOneWidget);
      });

      testWidgets('should switch tabs when bottom navigation is tapped',
          (tester) async {
        final user = User(
          id: '3',
          email: 'tourist@example.com',
          name: 'Tourist User',
          role: UserRole.tourist,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(TouristDashboard(user: user)),
        );

        // Tap on Join Tour tab
        await tester.tap(find.text('Join Tour'));
        await tester.pumpAndSettle();

        expect(find.text('Enter Join Code'), findsOneWidget);
        expect(find.text('Enter the tour join code'), findsOneWidget);

        // Tap on Documents tab
        await tester.tap(
            find.text('Documents').last); // Use last to get bottom nav item
        await tester.pumpAndSettle();

        expect(find.text('Passport Copy'), findsOneWidget);
        expect(find.text('Travel Insurance'), findsOneWidget);
      });

      testWidgets('should have user menu in app bar', (tester) async {
        final user = User(
          id: '3',
          email: 'tourist@example.com',
          name: 'Tourist User',
          role: UserRole.tourist,
          isProfileComplete: true,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(TouristDashboard(user: user)),
        );

        // Tap on menu button
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        expect(find.text('Profile'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Logout'), findsOneWidget);
      });
    });
  });
}
