import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/profile/profile_completion_page.dart';
import '../../presentation/pages/profile/profile_edit_page.dart';
import '../../presentation/pages/tour_template/tour_template_list_page.dart';
import '../../presentation/pages/provider/provider_list_page.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_type.dart';
import 'auth_wrapper.dart';
import 'role_based_home.dart';
import 'app_routes.dart';
import 'navigation_guard.dart';

/// Application router configuration
class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      redirect: (context, state) {
        return NavigationGuard.redirect(context, state, authBloc);
      },
      routes: [
        // Auth routes
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),

        // Profile completion
        GoRoute(
          path: AppRoutes.profileCompletion,
          builder: (context, state) => const ProfileCompletionPage(),
        ),

        // Main app routes (protected)
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const AuthWrapper(
            child: RoleBasedHome(),
          ),
        ),

        // Tour template routes
        GoRoute(
          path: AppRoutes.tourTemplates,
          builder: (context, state) => const AuthWrapper(
            child: TourTemplateListPage(),
          ),
        ),

        // Provider routes
        GoRoute(
          path: AppRoutes.providers,
          builder: (context, state) => const AuthWrapper(
            child: ProviderListPage(),
          ),
        ),

        // Profile routes
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const AuthWrapper(
            child: ProfileEditPage(),
          ),
        ),

        GoRoute(
          path: AppRoutes.profileEdit,
          builder: (context, state) => const AuthWrapper(
            child: ProfileEditPage(),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(state.error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get dashboard route based on user type (for backward compatibility with tests)
  static String getDashboardRoute(UserType userType) {
    switch (userType) {
      case UserType.systemAdmin:
        return AppRoutes.home; // Will redirect to system admin dashboard
      case UserType.providerAdmin:
        return AppRoutes.home; // Will redirect to provider admin dashboard
      case UserType.tourist:
        return AppRoutes.home; // Will redirect to tourist dashboard
    }
  }

  /// Check if user should be redirected to profile completion (for backward compatibility with tests)
  static bool shouldRedirectToProfileCompletion(User user) {
    return !user.isProfileComplete;
  }
}
