import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/common/app_drawer.dart';

/// Dashboard for Provider Administrators
class ProviderAdminDashboard extends StatefulWidget {
  final User user;

  const ProviderAdminDashboard({
    super.key,
    required this.user,
  });

  @override
  State<ProviderAdminDashboard> createState() => _ProviderAdminDashboardState();
}

class _ProviderAdminDashboardState extends State<ProviderAdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon')),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        user: widget.user,
        menuItems: _getProviderAdminMenuItems(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${widget.user.fullName}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Provider Administrator',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Active Tours',
                    value: '12', // Will be replaced with real data from CustomTourBloc
                    icon: Icons.tour,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Registrations',
                    value: '45', // Will be replaced with real data from RegistrationBloc
                    icon: Icons.people,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    context,
                    icon: Icons.add_circle,
                    title: 'Create Tour',
                    subtitle: 'Create a new custom tour',
                    onTap: () {
                      Navigator.pushNamed(context, '/custom-tours/create');
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.tour,
                    title: 'Manage Tours',
                    subtitle: 'View and edit your tours',
                    onTap: () {
                      Navigator.pushNamed(context, '/custom-tours');
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.people_alt,
                    title: 'Registrations',
                    subtitle: 'Manage tourist registrations',
                    onTap: () {
                      Navigator.pushNamed(context, '/registrations');
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.message,
                    title: 'Messages',
                    subtitle: 'Send updates to tourists',
                    onTap: () {
                      Navigator.pushNamed(context, '/messages');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DrawerMenuItem> _getProviderAdminMenuItems() {
    return [
      DrawerMenuItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      DrawerMenuItem(
        icon: Icons.tour,
        title: 'My Tours',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/custom-tours');
        },
      ),
      DrawerMenuItem(
        icon: Icons.people_alt,
        title: 'Registrations',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/registrations');
        },
      ),
      DrawerMenuItem(
        icon: Icons.message,
        title: 'Messages',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/messages');
        },
      ),
      DrawerMenuItem(
        icon: Icons.folder,
        title: 'Documents',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/documents');
        },
      ),
    ];
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
