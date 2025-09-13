import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/registration/registration_bloc.dart';
import '../../blocs/registration/registration_event.dart';
import '../../blocs/registration/registration_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/entities/registration.dart';

class TourRegistrationsPage extends StatefulWidget {
  final String tourId;

  const TourRegistrationsPage({super.key, required this.tourId});

  @override
  State<TourRegistrationsPage> createState() => _TourRegistrationsPageState();
}

class _TourRegistrationsPageState extends State<TourRegistrationsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  RegistrationStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadRegistrations();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final statuses = [
      null, // All
      RegistrationStatus.pending,
      RegistrationStatus.approved,
      RegistrationStatus.rejected,
      RegistrationStatus.cancelled,
      RegistrationStatus.completed,
    ];
    
    setState(() {
      _selectedStatus = statuses[_tabController.index];
    });
    _loadRegistrations();
  }

  void _loadRegistrations() {
    context.read<RegistrationBloc>().add(
      LoadRegistrationsByTour(
        customTourId: widget.tourId,
        status: _selectedStatus,
        limit: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Registrations'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRegistrations,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
            Tab(text: 'Cancelled'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadRegistrations(); // Refresh the list
          }

          if (state is RegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: List.generate(6, (index) => _buildRegistrationsList()),
        ),
      ),
    );
  }

  Widget _buildRegistrationsList() {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        if (state is RegistrationLoading) {
          return const LoadingWidget(message: 'Loading registrations...');
        }

        if (state is RegistrationError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: _loadRegistrations,
          );
        }

        if (state is RegistrationsLoaded) {
          if (state.registrations.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadRegistrations(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.registrations.length,
              itemBuilder: (context, index) {
                final registration = state.registrations[index];
                return _buildRegistrationCard(registration);
              },
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    switch (_selectedStatus) {
      case RegistrationStatus.pending:
        message = 'No Pending Registrations';
        subtitle = 'No registrations are waiting for your approval.';
        icon = Icons.hourglass_empty;
        break;
      case RegistrationStatus.approved:
        message = 'No Approved Registrations';
        subtitle = 'No registrations have been approved yet.';
        icon = Icons.check_circle_outline;
        break;
      case RegistrationStatus.rejected:
        message = 'No Rejected Registrations';
        subtitle = 'No registrations have been rejected.';
        icon = Icons.cancel_outlined;
        break;
      case RegistrationStatus.cancelled:
        message = 'No Cancelled Registrations';
        subtitle = 'No registrations have been cancelled.';
        icon = Icons.block;
        break;
      case RegistrationStatus.completed:
        message = 'No Completed Registrations';
        subtitle = 'No registrations have been completed yet.';
        icon = Icons.done_all;
        break;
      default:
        message = 'No Registrations Yet';
        subtitle = 'Share your tour join code to get registrations.';
        icon = Icons.people_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
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

  Widget _buildRegistrationCard(Registration registration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Registration ${registration.confirmationCode}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusChip(registration.status),
              ],
            ),
            const SizedBox(height: 12),

            // Registration details
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Registration Date',
              value: _formatDate(registration.registrationDate),
            ),

            if (registration.specialRequirements != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.accessibility,
                label: 'Special Requirements',
                value: registration.specialRequirements!,
              ),
            ],

            if (registration.emergencyContactName != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.emergency,
                label: 'Emergency Contact',
                value: '${registration.emergencyContactName} (${registration.emergencyContactPhone})',
              ),
            ],

            // Status-specific information
            if (registration.approvalNotes != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Approval Notes',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            registration.approvalNotes!,
                            style: TextStyle(color: Colors.green[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (registration.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Reason',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.red[700],
                            ),
                          ),
                          Text(
                            registration.rejectionReason!,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons for pending registrations
            if (registration.isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showRejectDialog(registration),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Reject'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(registration),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
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
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(RegistrationStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case RegistrationStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case RegistrationStatus.approved:
        color = Colors.green;
        text = 'Approved';
        icon = Icons.check_circle;
        break;
      case RegistrationStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
      case RegistrationStatus.cancelled:
        color = Colors.grey;
        text = 'Cancelled';
        icon = Icons.block;
        break;
      case RegistrationStatus.completed:
        color = Colors.blue;
        text = 'Completed';
        icon = Icons.done_all;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color,
    );
  }

  void _showApproveDialog(Registration registration) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Registration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Approve registration ${registration.confirmationCode}?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Approval Notes (Optional)',
                hintText: 'Add any notes for the tourist...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RegistrationBloc>().add(
                ApproveRegistration(
                  registrationId: registration.id,
                  notes: notesController.text.trim().isEmpty 
                      ? null 
                      : notesController.text.trim(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Registration registration) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Registration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject registration ${registration.confirmationCode}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                hintText: 'Please provide a reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                context.read<RegistrationBloc>().add(
                  RejectRegistration(
                    registrationId: registration.id,
                    reason: reasonController.text.trim(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}