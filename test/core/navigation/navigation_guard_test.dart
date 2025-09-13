import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/navigation/navigation_guard.dart';
import 'package:tourlicity_app/core/navigation/app_routes.dart';

void main() {
  group('NavigationGuard', () {
    group('requiresAuth', () {
      test('should return false for public routes', () {
        expect(NavigationGuard.requiresAuth(AppRoutes.login), isFalse);
      });

      test('should return true for protected routes', () {
        expect(NavigationGuard.requiresAuth(AppRoutes.home), isTrue);
        expect(NavigationGuard.requiresAuth('/dashboard'), isTrue);
        expect(NavigationGuard.requiresAuth('/profile'), isTrue);
      });
    });

    group('hasPermission', () {
      group('System Admin', () {
        test('should allow system admin access to all routes', () {
          expect(
              NavigationGuard.hasPermission('/admin', 'systemadmin'), isTrue);
          expect(NavigationGuard.hasPermission('/provider', 'systemadmin'),
              isTrue);
          expect(NavigationGuard.hasPermission('/dashboard', 'systemadmin'),
              isTrue);
          expect(
              NavigationGuard.hasPermission('/tours', 'system_admin'), isTrue);
        });
      });

      group('Provider Admin', () {
        test('should allow provider admin access to provider routes', () {
          expect(
              NavigationGuard.hasPermission('/dashboard', 'provider'), isTrue);
          expect(
              NavigationGuard.hasPermission('/tours', 'provideradmin'), isTrue);
          expect(
              NavigationGuard.hasPermission(
                  AppRoutes.tourTemplates, 'provider'),
              isTrue);
        });

        test('should deny provider admin access to admin-only routes', () {
          expect(
              NavigationGuard.hasPermission(
                  AppRoutes.adminDashboard, 'provider'),
              isFalse);
          expect(
              NavigationGuard.hasPermission(
                  AppRoutes.userManagement, 'provideradmin'),
              isFalse);
        });
      });

      group('Tourist', () {
        test('should allow tourist access to general routes', () {
          expect(
              NavigationGuard.hasPermission('/dashboard', 'tourist'), isTrue);
          expect(NavigationGuard.hasPermission('/profile', 'tourist'), isTrue);
        });

        test('should deny tourist access to admin routes', () {
          expect(
              NavigationGuard.hasPermission(
                  AppRoutes.adminDashboard, 'tourist'),
              isFalse);
          expect(
              NavigationGuard.hasPermission(
                  AppRoutes.userManagement, 'tourist'),
              isFalse);
        });

        test('should deny tourist access to provider routes', () {
          expect(
              NavigationGuard.hasPermission(AppRoutes.tourTemplates, 'tourist'),
              isFalse);
          expect(
              NavigationGuard.hasPermission(
                  AppRoutes.tourTemplateCreate, 'tourist'),
              isFalse);
        });
      });

      group('Unknown Role', () {
        test('should deny access for unknown roles', () {
          expect(
              NavigationGuard.hasPermission('/dashboard', 'unknown'), isFalse);
          expect(NavigationGuard.hasPermission('/admin', 'guest'), isFalse);
        });
      });
    });
  });
}
