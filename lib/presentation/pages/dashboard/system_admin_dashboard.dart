import 'package:flutter/material.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/common/app_drawer.dart';
import '../tour_template/tour_template_list_page.dart';

/// Dashboard for System Administrators
class SystemAdminDashboard extends StatefulWidget {
  final User user;

  const SystemAdminDashboard({
    super.key,
    required this.user,
  });

  @override
  State<SystemAdminDashboard> createState() => _SystemAdminDashboardState();
}

class _SystemAdminDashboardState extends State<SystemAdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Admin Dashboard'),
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
        menuItems: _getSystemAdminMenuItems(),
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
                      'System Administrator',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
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
                    icon: Icons.business,
                    title: 'Manage Providers',
                    subtitle: 'Add, edit, and manage tour providers',
                    onTap: () {
                      Navigator.pushNamed(context, '/providers');
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.description,
                    title: 'Tour Templates',
                    subtitle: 'Create and manage tour templates',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const TourTemplateListPage(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.people,
                    title: 'User Management',
                    subtitle: 'Manage user accounts and roles',
                    onTap: () {
                      Navigator.pushNamed(context, '/users');
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Analytics',
                    subtitle: 'View system analytics and reports',
                    onTap: () {
                      Navigator.pushNamed(context, '/analytics');
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

  List<DrawerMenuItem> _getSystemAdminMenuItems() {
    return [
      DrawerMenuItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      DrawerMenuItem(
        icon: Icons.business,
        title: 'Providers',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/providers');
        },
      ),
      DrawerMenuItem(
        icon: Icons.description,
        title: 'Tour Templates',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const TourTemplateListPage(),
            ),
          );
        },
      ),
      DrawerMenuItem(
        icon: Icons.people,
        title: 'Users',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/users');
        },
      ),
      DrawerMenuItem(
        icon: Icons.analytics,
        title: 'Analytics',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/analytics');
        },
      ),
    ];
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
