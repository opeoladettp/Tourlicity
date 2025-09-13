import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/custom_tour/custom_tour_bloc.dart';
import '../../blocs/custom_tour/custom_tour_event.dart';
import '../../blocs/custom_tour/custom_tour_state.dart';
import '../../blocs/registration/registration_bloc.dart';
import '../../blocs/registration/registration_event.dart';
import '../../blocs/registration/registration_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/entities/custom_tour.dart';
import '../../../domain/entities/registration.dart';
import 'tour_form_page.dart';
import 'tour_registrations_page.dart';

class TourDetailsPage extends StatefulWidget {
  final String tourId;

  const TourDetailsPage({super.key, required this.tourId});

  @override
  State<TourDetailsPage> createState() => _TourDetailsPageState();
}

class _TourDetailsPageState extends State<TourDetailsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTourDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTourDetails() {
    context.read<CustomTourBloc>().add(LoadCustomTourById(widget.tourId));
    context.read<RegistrationBloc>().add(LoadRegistrationsByTour(
      customTourId: widget.tourId,
      limit: 10,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CustomTourBloc, CustomTourState>(
        builder: (context, state) {
          if (state is CustomTourLoading) {
            return const Scaffold(
              body: LoadingWidget(message: 'Loading tour details...'),
            );
          }

          if (state is CustomTourError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Tour Details')),
              body: CustomErrorWidget(
                message: state.message,
                onRetry: _loadTourDetails,
              ),
            );
          }

          if (state is CustomTourLoaded) {
            return _buildTourDetails(state.customTour);
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Tour Details')),
            body: const CustomErrorWidget(
              message: 'Tour not found',
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourDetails(CustomTour tour) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tour.tourName),
        elevation: 0,
        actions: [
          if (tour.status == TourStatus.draft || tour.status == TourStatus.published)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TourFormPage(tour: tour),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, tour),
            itemBuilder: (context) => _buildMenuItems(tour),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Registrations'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(tour),
          _buildRegistrationsTab(tour),
          _buildAnalyticsTab(tour),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(tour),
    );
  }

  Widget _buildOverviewTab(CustomTour tour) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Card(
            color: _getStatusColor(tour.status).withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(tour.status),
                    color: _getStatusColor(tour.status),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(tour.status),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(tour.status),
                          ),
                        ),
                        Text(
                          _getStatusDescription(tour.status),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getStatusColor(tour.status).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Capacity',
                  value: '${tour.currentTourists}/${tour.maxTourists}',
                  subtitle: '${tour.availableSpots} spots left',
                  icon: Icons.people,
                  color: tour.hasAvailableSpots ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Duration',
                  value: '${tour.durationDays}',
                  subtitle: 'days',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tour Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tour Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.confirmation_number,
                    label: 'Join Code',
                    value: tour.joinCode,
                    copyable: true,
                  ),
                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Start Date',
                    value: _formatDate(tour.startDate),
                  ),
                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'End Date',
                    value: _formatDate(tour.endDate),
                  ),
                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.attach_money,
                    label: 'Price per Person',
                    value: '${tour.currency} ${tour.pricePerPerson.toStringAsFixed(2)}',
                  ),
                  const Divider(),

                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Created',
                    value: _formatDateTime(tour.createdDate),
                  ),

                  if (tour.description != null && tour.description!.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tour.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],

                  if (tour.tags.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: tour.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue[100],
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Capacity Progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capacity Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Registered Tourists',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        '${tour.currentTourists} / ${tour.maxTourists}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  LinearProgressIndicator(
                    value: tour.currentTourists / tour.maxTourists,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tour.hasAvailableSpots ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    tour.hasAvailableSpots
                        ? '${tour.availableSpots} spots remaining'
                        : 'Tour is fully booked',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tour.hasAvailableSpots ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
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

  Widget _buildRegistrationsTab(CustomTour tour) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        if (state is RegistrationLoading) {
          return const LoadingWidget(message: 'Loading registrations...');
        }

        if (state is RegistrationError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<RegistrationBloc>().add(LoadRegistrationsByTour(
                customTourId: widget.tourId,
                limit: 10,
              ));
            },
          );
        }

        if (state is RegistrationsLoaded) {
          return _buildRegistrationsList(state.registrations, tour);
        }

        return const Center(
          child: Text('No registrations found'),
        );
      },
    );
  }

  Widget _buildRegistrationsList(List<Registration> registrations, CustomTour tour) {
    if (registrations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'No Registrations Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Share the join code "${tour.joinCode}" with tourists to get registrations.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRegistrationStat(
                'Pending',
                registrations.where((r) => r.isPending).length,
                Colors.orange,
              ),
              _buildRegistrationStat(
                'Approved',
                registrations.where((r) => r.isApproved).length,
                Colors.green,
              ),
              _buildRegistrationStat(
                'Rejected',
                registrations.where((r) => r.isRejected).length,
                Colors.red,
              ),
            ],
          ),
        ),
        const Divider(),
        
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index];
              return _buildRegistrationCard(registration);
            },
          ),
        ),
        
        // View All Button
        if (registrations.length >= 10)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TourRegistrationsPage(tourId: widget.tourId),
                  ),
                );
              },
              child: const Text('View All Registrations'),
            ),
          ),
      ],
    );
  }

  Widget _buildAnalyticsTab(CustomTour tour) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tour Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Revenue Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildRevenueCard(
                          'Current Revenue',
                          '${tour.currency} ${(tour.currentTourists * tour.pricePerPerson).toStringAsFixed(2)}',
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildRevenueCard(
                          'Potential Revenue',
                          '${tour.currency} ${(tour.maxTourists * tour.pricePerPerson).toStringAsFixed(2)}',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Performance Metrics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Metrics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMetricRow(
                    'Occupancy Rate',
                    '${((tour.currentTourists / tour.maxTourists) * 100).toInt()}%',
                    Icons.people,
                  ),
                  const Divider(),
                  
                  _buildMetricRow(
                    'Days Until Start',
                    '${tour.startDate.difference(DateTime.now()).inDays}',
                    Icons.calendar_today,
                  ),
                  const Divider(),
                  
                  _buildMetricRow(
                    'Price per Day',
                    '${tour.currency} ${(tour.pricePerPerson / tour.durationDays).toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () => _copyToClipboard(value),
              child: Icon(
                Icons.copy,
                size: 20,
                color: Colors.blue[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegistrationStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationCard(Registration registration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRegistrationStatusColor(registration.status),
          child: Icon(
            _getRegistrationStatusIcon(registration.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text('Registration ${registration.confirmationCode}'),
        subtitle: Text(
          'Registered: ${_formatDate(registration.registrationDate)}',
        ),
        trailing: Chip(
          label: Text(
            _getRegistrationStatusText(registration.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          backgroundColor: _getRegistrationStatusColor(registration.status),
        ),
        onTap: () {
          // Navigate to registration details
          _showRegistrationDetails(registration);
        },
      ),
    );
  }

  Widget _buildRevenueCard(String title, String value, Color color) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(CustomTour tour) {
    switch (tour.status) {
      case TourStatus.draft:
        return FloatingActionButton.extended(
          onPressed: () {
            context.read<CustomTourBloc>().add(PublishTour(tour.id));
          },
          icon: const Icon(Icons.public),
          label: const Text('Publish'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        );
      case TourStatus.published:
        return FloatingActionButton.extended(
          onPressed: () {
            context.read<CustomTourBloc>().add(StartTour(tour.id));
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Tour'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        );
      case TourStatus.active:
        return FloatingActionButton.extended(
          onPressed: () {
            context.read<CustomTourBloc>().add(CompleteTour(tour.id));
          },
          icon: const Icon(Icons.done),
          label: const Text('Complete'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        );
      default:
        return null;
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(CustomTour tour) {
    List<PopupMenuEntry<String>> items = [];

    if (tour.status == TourStatus.draft || tour.status == TourStatus.published) {
      items.add(
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Tour'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
    }

    items.addAll([
      const PopupMenuItem(
        value: 'generate_code',
        child: ListTile(
          leading: Icon(Icons.refresh),
          title: Text('Generate New Code'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: 'duplicate',
        child: ListTile(
          leading: Icon(Icons.copy),
          title: Text('Duplicate Tour'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ]);

    if (tour.status == TourStatus.published) {
      items.add(
        const PopupMenuItem(
          value: 'cancel',
          child: ListTile(
            leading: Icon(Icons.cancel, color: Colors.red),
            title: Text('Cancel Tour', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
    }

    return items;
  }

  void _handleMenuAction(String action, CustomTour tour) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TourFormPage(tour: tour),
          ),
        );
        break;
      case 'generate_code':
        _showGenerateCodeDialog(tour);
        break;
      case 'duplicate':
        _duplicateTour(tour);
        break;
      case 'cancel':
        _showCancelTourDialog(tour);
        break;
    }
  }

  void _showGenerateCodeDialog(CustomTour tour) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate New Join Code'),
        content: const Text(
          'This will generate a new join code for the tour. The old code will no longer work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CustomTourBloc>().add(GenerateNewJoinCode(tour.id));
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _duplicateTour(CustomTour tour) {
    final duplicatedTour = tour.copyWith(
      id: '',
      tourName: '${tour.tourName} (Copy)',
      joinCode: '',
      status: TourStatus.draft,
      currentTourists: 0,
      createdDate: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TourFormPage(tour: duplicatedTour),
      ),
    );
  }

  void _showCancelTourDialog(CustomTour tour) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Tour'),
        content: const Text(
          'Are you sure you want to cancel this tour? This action cannot be undone and all registered tourists will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Tour'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CustomTourBloc>().add(CancelTour(tour.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Tour'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Join code copied: $text'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to copy to clipboard'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Color _getStatusColor(TourStatus status) {
    switch (status) {
      case TourStatus.draft:
        return Colors.grey;
      case TourStatus.published:
        return Colors.blue;
      case TourStatus.active:
        return Colors.green;
      case TourStatus.completed:
        return Colors.purple;
      case TourStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TourStatus status) {
    switch (status) {
      case TourStatus.draft:
        return Icons.edit;
      case TourStatus.published:
        return Icons.public;
      case TourStatus.active:
        return Icons.play_circle;
      case TourStatus.completed:
        return Icons.done_all;
      case TourStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(TourStatus status) {
    switch (status) {
      case TourStatus.draft:
        return 'Draft';
      case TourStatus.published:
        return 'Published';
      case TourStatus.active:
        return 'Active';
      case TourStatus.completed:
        return 'Completed';
      case TourStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusDescription(TourStatus status) {
    switch (status) {
      case TourStatus.draft:
        return 'Tour is being prepared and not yet available for registration';
      case TourStatus.published:
        return 'Tour is available for tourist registration';
      case TourStatus.active:
        return 'Tour is currently running';
      case TourStatus.completed:
        return 'Tour has been completed successfully';
      case TourStatus.cancelled:
        return 'Tour has been cancelled';
    }
  }

  Color _getRegistrationStatusColor(RegistrationStatus status) {
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

  IconData _getRegistrationStatusIcon(RegistrationStatus status) {
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

  String _getRegistrationStatusText(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return 'Pending';
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showRegistrationDetails(Registration registration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Details - ${registration.confirmationCode}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSimpleDetailRow('Status', _getRegistrationStatusText(registration.status)),
              _buildSimpleDetailRow('Registration Date', _formatDate(registration.registrationDate)),
              if (registration.specialRequirements != null)
                _buildSimpleDetailRow('Special Requirements', registration.specialRequirements!),
              if (registration.emergencyContactName != null)
                _buildSimpleDetailRow('Emergency Contact', registration.emergencyContactName!),
              if (registration.emergencyContactPhone != null)
                _buildSimpleDetailRow('Emergency Phone', registration.emergencyContactPhone!),
              if (registration.approvalNotes != null)
                _buildSimpleDetailRow('Approval Notes', registration.approvalNotes!),
              if (registration.rejectionReason != null)
                _buildSimpleDetailRow('Rejection Reason', registration.rejectionReason!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }



  Widget _buildSimpleDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}