import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import 'app_routes.dart';

/// Navigation guard for handling route protection and redirects
class NavigationGuard {
  /// Determine if a redirect is needed based on auth state and current route
  static String? redirect(
      BuildContext context, GoRouterState state, AuthBloc authBloc) {
    final authState = authBloc.state;
    final currentPath = state.uri.path;

    // Don't redirect if we're still loading
    if (authState.isLoading || authState.isInitial) {
      return null;
    }

    // If user is not authenticated
    if (authState.isUnauthenticated) {
      // Allow access to login page
      if (currentPath == AppRoutes.login) {
        return null;
      }
      // Redirect to login for all other routes
      return AppRoutes.login;
    }

    // If user is authenticated
    if (authState.isAuthenticated && authState.userEntity != null) {
      final user = authState.userEntity!;

      // If on login page, redirect to home
      if (currentPath == AppRoutes.login) {
        return AppRoutes.home;
      }

      // If profile is not complete, redirect to profile completion
      // unless already on profile completion page
      if (!user.isProfileComplete &&
          currentPath != AppRoutes.profileCompletion) {
        return AppRoutes.profileCompletion;
      }

      // If profile is complete but on profile completion page, redirect to home
      if (user.isProfileComplete &&
          currentPath == AppRoutes.profileCompletion) {
        return AppRoutes.home;
      }
    }

    // No redirect needed
    return null;
  }

  /// Check if a route requires authentication
  static bool requiresAuth(String path) {
    const publicRoutes = [
      AppRoutes.login,
    ];
    return !publicRoutes.contains(path);
  }

  /// Check if user has permission to access a route based on their role
  static bool hasPermission(String path, String userRole) {
    // Define role-based route permissions
    const adminOnlyRoutes = [
      AppRoutes.adminDashboard,
      AppRoutes.userManagement,
      AppRoutes.providerManagement,
      AppRoutes.analytics,
    ];

    const providerRoutes = [
      AppRoutes.tourTemplates,
      AppRoutes.tourTemplateCreate,
      AppRoutes.tourTemplateEdit,
    ];

    // System admin can access everything
    if (userRole.toLowerCase() == 'systemadmin' ||
        userRole.toLowerCase() == 'system_admin') {
      return true;
    }

    // Provider admin can access provider routes and general routes
    if (userRole.toLowerCase() == 'provider' ||
        userRole.toLowerCase() == 'provideradmin') {
      return !adminOnlyRoutes.contains(path);
    }

    // Tourist can access general routes but not admin or provider specific routes
    if (userRole.toLowerCase() == 'tourist') {
      return !adminOnlyRoutes.contains(path) && !providerRoutes.contains(path);
    }

    // Default deny
    return false;
  }
}
