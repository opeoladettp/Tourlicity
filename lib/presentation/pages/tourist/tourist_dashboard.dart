import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/registration/registration_bloc.dart';
import '../../blocs/registration/registration_event.dart';
import '../../blocs/registration/registration_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../registration/join_tour_page.dart';
import 'my_tours_page.dart';
import '../../../domain/entities/registration.dart';

class TouristDashboard extends StatefulWidget {
  const TouristDashboard({super.key});

  @override
  State<TouristDashboard> createState() => _TouristDashboardState();
}

class _TouristDashboardState extends State<TouristDashboard> {
  @override
  void initState() {
    super.initState();
    _loadUserRegistrations();
  }

  void _loadUserRegistrations() {
    final authState = context.read<AuthBloc>().state;
    if (authState.isAuthenticated && authState.userEntity != null) {
      context.read<RegistrationBloc>().add(
        LoadRegistrationsByTourist(
          touristId: authState.userEntity!.id,
          limit: 5, // Load recent registrations for dashboard
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tours'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserRegistrations,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadUserRegistrations(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Recent Registrations
              _buildRecentRegistrations(),
              const SizedBox(height: 24),

              // Statistics
              _buildStatistics(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const JoinTourPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Join Tour'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.isAuthenticated && authState.userEntity != null) {
          final user = authState.userEntity!;
          return Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Text(
                      user.name.isNotEmpty 
                          ? user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          user.name.isNotEmpty 
                              ? user.name
                              : 'Tourist',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Join Tour',
                subtitle: 'Enter join code',
                icon: Icons.add_circle,
                color: Colors.green,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const JoinTourPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'My Tours',
                subtitle: 'View all tours',
                icon: Icons.list,
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MyToursPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRegistrations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Registrations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MyToursPage(),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, state) {
            if (state is RegistrationLoading) {
              return const LoadingWidget(message: 'Loading registrations...');
            }

            if (state is RegistrationError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: _loadUserRegistrations,
              );
            }

            if (state is RegistrationsLoaded) {
              if (state.registrations.isEmpty) {
                return _buildEmptyRegistrations();
              }

              return Column(
                children: state.registrations
                    .take(3) // Show only first 3 on dashboard
                    .map((registration) => _buildRegistrationCard(registration))
                    .toList(),
              );
            }

            return _buildEmptyRegistrations();
          },
        ),
      ],
    );
  }

  Widget _buildEmptyRegistrations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.tour,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No Tours Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join your first tour to get started!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationCard(Registration registration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(registration.status),
          child: Icon(
            _getStatusIcon(registration.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: const Text(
          'Tour Registration',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${registration.confirmationCode}'),
            Text(
              _getStatusText(registration.status),
              style: TextStyle(
                color: _getStatusColor(registration.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to registration details
        },
      ),
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        if (state is RegistrationsLoaded) {
          final registrations = state.registrations;
          final pendingCount = registrations.where((r) => r.isPending).length;
          final approvedCount = registrations.where((r) => r.isApproved).length;
          final completedCount = registrations.where((r) => r.isCompleted).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pending',
                      count: pendingCount,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Approved',
                      count: approvedCount,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Completed',
                      count: completedCount,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return Colors.orange;
      case RegistrationStatus.approved:
        return Colors.green;
      case RegistrationStatus.rejected:
        return Colors.red;
      case RegistrationStatus.cancelled:
        return Colors.grey;
      case RegistrationStatus.completed:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return Icons.hourglass_empty;
      case RegistrationStatus.approved:
        return Icons.check_circle;
      case RegistrationStatus.rejected:
        return Icons.cancel;
      case RegistrationStatus.cancelled:
        return Icons.block;
      case RegistrationStatus.completed:
        return Icons.done_all;
    }
  }

  String _getStatusText(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return 'Pending Review';
      case RegistrationStatus.approved:
        return 'Approved';
      case RegistrationStatus.rejected:
        return 'Rejected';
      case RegistrationStatus.cancelled:
        return 'Cancelled';
      case RegistrationStatus.completed:
        return 'Completed';
    }
  }
}