import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/pages/dashboard/tourist_dashboard.dart';
import '../../presentation/pages/dashboard/provider_admin_dashboard.dart';
import '../../presentation/pages/dashboard/system_admin_dashboard.dart';

/// Home page that shows different content based on user role
class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (!state.isAuthenticated || state.userEntity == null) {
          return const Scaffold(
            body: Center(
              child: Text('Not authenticated'),
            ),
          );
        }

        final user = state.userEntity!;

        // Check if profile is complete, if not redirect to completion
        if (!user.isProfileComplete) {
          return const Scaffold(
            body: Center(
              child: Text('Profile completion required'),
            ),
          );
        }

        return _buildDashboardForRole(user.role, user);
      },
    );
  }

  Widget _buildDashboardForRole(UserRole role, User user) {
    switch (role) {
      case UserRole.tourist:
        return TouristDashboard(user: user);
      case UserRole.provider:
        return ProviderAdminDashboard(user: user);
      case UserRole.systemAdmin:
        return SystemAdminDashboard(user: user);
    }
  }
}
