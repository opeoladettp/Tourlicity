import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import 'accessibility_widgets.dart';

/// Drawer menu item model
class DrawerMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

/// App drawer for admin roles with navigation menu
class AppDrawer extends StatelessWidget {
  final User user;
  final List<DrawerMenuItem> menuItems;

  const AppDrawer({
    super.key,
    required this.user,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Navigation drawer',
      child: Drawer(
        child: Column(
          children: [
            // Drawer header with semantic information
            Semantics(
              label: 'User profile header for ${user.fullName}',
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Semantics(
                      label: 'Profile picture for ${user.fullName}',
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : user.email[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          semanticsLabel: 'Profile initial',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      label: 'User name',
                      child: Text(
                        user.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppTheme.accessibleFontSize + 2,
                          fontWeight: FontWeight.bold,
                          height: AppTheme.accessibleLineHeight,
                        ),
                      ),
                    ),
                    Semantics(
                      label: 'User email',
                      child: Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: AppTheme.accessibleLineHeight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu items with accessibility enhancements
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...menuItems.map((item) => AccessibleListTile(
                        leading: Icon(item.icon),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: AppTheme.accessibleFontSize,
                            height: AppTheme.accessibleLineHeight,
                          ),
                        ),
                        onTap: item.onTap,
                        semanticLabel: 'Navigate to ${item.title}',
                      )),
                  const Divider(),
                  AccessibleListTile(
                    leading: const Icon(Icons.person),
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: AppTheme.accessibleFontSize,
                        height: AppTheme.accessibleLineHeight,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/profile');
                    },
                    semanticLabel: 'Navigate to Profile page',
                  ),
                  AccessibleListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: AppTheme.accessibleFontSize,
                        height: AppTheme.accessibleLineHeight,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings feature coming soon')),
                      );
                    },
                    semanticLabel: 'Navigate to Settings page',
                  ),
                ],
              ),
            ),

            // Logout button with enhanced accessibility
            const Divider(),
            AccessibleListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: AppTheme.accessibleFontSize,
                  height: AppTheme.accessibleLineHeight,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showLogoutDialog(context);
              },
              semanticLabel: 'Logout from the application',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Semantics(
        label: 'Logout confirmation dialog',
        child: AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: AppTheme.accessibleFontSize + 2,
              height: AppTheme.accessibleLineHeight,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: AppTheme.accessibleFontSize,
              height: AppTheme.accessibleLineHeight,
            ),
          ),
          actions: [
            AccessibleButton(
              onPressed: () => Navigator.of(context).pop(),
              semanticLabel: 'Cancel logout',
              type: ButtonType.text,
              child: const Text('Cancel'),
            ),
            AccessibleButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
              semanticLabel: 'Confirm logout',
              type: ButtonType.text,
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
