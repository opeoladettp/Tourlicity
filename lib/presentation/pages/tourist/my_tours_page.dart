import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/registration/registration_bloc.dart';
import '../../blocs/registration/registration_event.dart';
import '../../blocs/registration/registration_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/optimized_list_view.dart';
import '../../../domain/entities/registration.dart';
import '../../../core/performance/performance_monitor.dart';

class MyToursPage extends StatefulWidget {
  const MyToursPage({super.key});

  @override
  State<MyToursPage> createState() => _MyToursPageState();
}

class _MyToursPageState extends State<MyToursPage> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  RegistrationStatus? _selectedStatus;
  final ScrollController _scrollController = ScrollController();
  
  // Pagination state
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 0;
  List<dynamic> items = [];
  
  Map<String, dynamic> get paginationState => {
    'isLoading': isLoading,
    'hasMore': hasMore,
    'currentPage': currentPage,
    'items': items,
  };
  
  void resetPagination() {
    setState(() {
      currentPage = 0;
      hasMore = true;
      isLoading = false;
    });
  }
  
  void startLoading() {
    setState(() {
      isLoading = true;
    });
  }

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
    _scrollController.dispose();
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
    PerformanceMonitor.instance.measureSync('load_registrations', () {
      final authState = context.read<AuthBloc>().state;
      if (authState.isAuthenticated && authState.userEntity != null) {
        resetPagination();
        context.read<RegistrationBloc>().add(
          LoadRegistrationsByTourist(
            touristId: authState.userEntity!.id,
            status: _selectedStatus,
            limit: 20, // Reduced for better performance
            offset: 0,
          ),
        );
      }
    });
  }

  void _loadMoreRegistrations() {
    if (paginationState['isLoading'] || !paginationState['hasMore']) return;
    
    PerformanceMonitor.instance.measureSync('load_more_registrations', () {
      final authState = context.read<AuthBloc>().state;
      if (authState.isAuthenticated && authState.userEntity != null) {
        startLoading();
        context.read<RegistrationBloc>().add(
          LoadRegistrationsByTourist(
            touristId: authState.userEntity!.id,
            status: _selectedStatus,
            limit: 20,
            offset: paginationState['items'].length,
          ),
        );
      }
    });
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
      body: TabBarView(
        controller: _tabController,
        children: List.generate(6, (index) => _buildRegistrationsList()),
      ),
    );
  }

  Widget _buildRegistrationsList() {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        if (state is RegistrationLoading) {
          return const LoadingWidget(message: 'Loading your tours...');
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
            child: OptimizedListView<Registration>(
              items: state.registrations,
              scrollController: _scrollController,
              onLoadMore: _loadMoreRegistrations,
              isLoading: paginationState['isLoading'],
              hasMore: paginationState['hasMore'],
              itemBuilder: (context, registration, index) {
                return PerformanceMonitor.instance.measureSync(
                  'build_registration_card_$index',
                  () => _buildOptimizedRegistrationCard(registration, index),
                );
              },
              padding: const EdgeInsets.all(16.0),
              loadingWidget: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
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
        message = 'No Pending Tours';
        subtitle = 'You don\'t have any tours waiting for approval.';
        icon = Icons.hourglass_empty;
        break;
      case RegistrationStatus.approved:
        message = 'No Approved Tours';
        subtitle = 'You don\'t have any approved tours yet.';
        icon = Icons.check_circle_outline;
        break;
      case RegistrationStatus.rejected:
        message = 'No Rejected Tours';
        subtitle = 'None of your tour applications were rejected.';
        icon = Icons.cancel_outlined;
        break;
      case RegistrationStatus.cancelled:
        message = 'No Cancelled Tours';
        subtitle = 'You haven\'t cancelled any tours.';
        icon = Icons.block;
        break;
      case RegistrationStatus.completed:
        message = 'No Completed Tours';
        subtitle = 'You haven\'t completed any tours yet.';
        icon = Icons.done_all;
        break;
      default:
        message = 'No Tours Yet';
        subtitle = 'Join your first tour to get started!';
        icon = Icons.tour;
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
            if (_selectedStatus == null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.add),
                label: const Text('Join a Tour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedRegistrationCard(Registration registration, int index) {
    return RepaintBoundary(
      key: ValueKey('registration_${registration.id}'),
      child: _buildRegistrationCard(registration),
    );
  }

  Widget _buildRegistrationCard(Registration registration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRegistrationDetails(registration),
        borderRadius: BorderRadius.circular(8),
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
                      'Tour Registration',
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
                icon: Icons.confirmation_number,
                label: 'Confirmation Code',
                value: registration.confirmationCode,
              ),
              const SizedBox(height: 8),
              
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

              // Action buttons
              if (registration.canBeCancelled) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showCancelDialog(registration),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (registration.isPending || registration.isApproved) ...[
                      ElevatedButton.icon(
                        onPressed: () => _showEditDialog(registration),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
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

  void _showRegistrationDetails(Registration registration) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Registration Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildRegistrationCard(registration),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(Registration registration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Registration'),
        content: const Text(
          'Are you sure you want to cancel this tour registration? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Registration'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RegistrationBloc>().add(
                CancelRegistration(registration.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Registration'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Registration registration) {
    final specialRequirementsController = TextEditingController(
      text: registration.specialRequirements ?? '',
    );
    final emergencyNameController = TextEditingController(
      text: registration.emergencyContactName ?? '',
    );
    final emergencyPhoneController = TextEditingController(
      text: registration.emergencyContactPhone ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Registration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: specialRequirementsController,
                decoration: const InputDecoration(
                  labelText: 'Special Requirements',
                  hintText: 'Any special needs or requirements...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emergencyNameController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emergencyPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact Phone',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update registration
              context.read<RegistrationBloc>().add(
                UpdateRegistration(
                  registrationId: registration.id,
                  specialRequirements: specialRequirementsController.text.trim().isEmpty
                      ? null
                      : specialRequirementsController.text.trim(),
                  emergencyContactName: emergencyNameController.text.trim().isEmpty
                      ? null
                      : emergencyNameController.text.trim(),
                  emergencyContactPhone: emergencyPhoneController.text.trim().isEmpty
                      ? null
                      : emergencyPhoneController.text.trim(),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }



  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}