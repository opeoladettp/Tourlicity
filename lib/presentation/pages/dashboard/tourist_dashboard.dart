import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/common/tourist_bottom_navigation.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

/// Dashboard for Tourists
class TouristDashboard extends StatefulWidget {
  final User user;

  const TouristDashboard({
    super.key,
    required this.user,
  });

  @override
  State<TouristDashboard> createState() => _TouristDashboardState();
}

class _TouristDashboardState extends State<TouristDashboard> {
  int _currentIndex = 0;
  String _joinCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tours'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'settings':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings feature coming soon')),
                  );
                  break;
                case 'logout':
                  // Handle logout through AuthBloc
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildMyToursTab(),
          _buildJoinTourTab(),
          _buildDocumentsTab(),
        ],
      ),
      bottomNavigationBar: TouristBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeTab() {
    return Padding(
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
                    'Ready for your next adventure?',
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
                  title: 'Upcoming Tours',
                  value: '2', // Will be replaced with real data from RegistrationBloc
                  icon: Icons.upcoming,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Completed Tours',
                  value: '5', // Will be replaced with real data from RegistrationBloc
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              children: [
                _buildActivityItem(
                  context,
                  icon: Icons.tour,
                  title: 'Tour Registration Approved',
                  subtitle:
                      'Your registration for "Paris City Tour" has been approved',
                  time: '2 hours ago',
                ),
                _buildActivityItem(
                  context,
                  icon: Icons.message,
                  title: 'New Message',
                  subtitle: 'Tour guide sent an update about meeting point',
                  time: '1 day ago',
                ),
                _buildActivityItem(
                  context,
                  icon: Icons.file_present,
                  title: 'Document Uploaded',
                  subtitle: 'Your passport copy has been uploaded successfully',
                  time: '3 days ago',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyToursTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Tours',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildTourCard(
                  context,
                  title: 'Paris City Tour',
                  dates: 'Dec 15-20, 2024',
                  status: 'Confirmed',
                  statusColor: Colors.green,
                ),
                _buildTourCard(
                  context,
                  title: 'Rome Historical Walk',
                  dates: 'Jan 10-15, 2025',
                  status: 'Pending',
                  statusColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinTourTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join a Tour',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Join Code',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Join Code',
                      hintText: 'Enter the tour join code',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _joinCode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_joinCode.isNotEmpty) {
                          Navigator.pushNamed(
                            context, 
                            '/tours/join',
                            arguments: _joinCode,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a join code')),
                          );
                        }
                      },
                      child: const Text('Search Tour'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildDocumentItem(
                  context,
                  title: 'Passport Copy',
                  status: 'Approved',
                  statusColor: Colors.green,
                ),
                _buildDocumentItem(
                  context,
                  title: 'Travel Insurance',
                  status: 'Pending Review',
                  statusColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ),
    );
  }

  Widget _buildTourCard(
    BuildContext context, {
    required String title,
    required String dates,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.tour),
        ),
        title: Text(title),
        subtitle: Text(dates),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/tours/details', arguments: 'tour-id');
        },
      ),
    );
  }

  Widget _buildDocumentItem(
    BuildContext context, {
    required String title,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/documents/details', arguments: 'doc-id');
        },
      ),
    );
  }
}
