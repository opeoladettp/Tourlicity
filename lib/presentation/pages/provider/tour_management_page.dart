import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/custom_tour/custom_tour_bloc.dart';
import '../../blocs/custom_tour/custom_tour_event.dart';
import '../../blocs/custom_tour/custom_tour_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/entities/custom_tour.dart';
import 'tour_form_page.dart';
import 'tour_details_page.dart';

class TourManagementPage extends StatefulWidget {
  const TourManagementPage({super.key});

  @override
  State<TourManagementPage> createState() => _TourManagementPageState();
}

class _TourManagementPageState extends State<TourManagementPage> with TickerProviderStateMixin {
  late TabController _tabController;
  TourStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTours();
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
      TourStatus.draft,
      TourStatus.published,
      TourStatus.active,
      TourStatus.completed,
      TourStatus.cancelled,
    ];
    
    setState(() {
      _selectedStatus = statuses[_tabController.index];
    });
    _loadTours();
  }

  void _loadTours() {
    final authState = context.read<AuthBloc>().state;
    if (authState.isAuthenticated && authState.userEntity != null) {
      context.read<CustomTourBloc>().add(
        LoadCustomTours(
          providerId: authState.userEntity!.id,
          status: _selectedStatus,
          limit: 50,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTours,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Draft'),
            Tab(text: 'Published'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: BlocListener<CustomTourBloc, CustomTourState>(
        listener: (context, state) {
          if (state is CustomTourOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadTours(); // Refresh the list
          }

          if (state is CustomTourDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadTours(); // Refresh the list
          }

          if (state is CustomTourError) {
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
          children: List.generate(6, (index) => _buildToursList()),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TourFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Tour'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildToursList() {
    return BlocBuilder<CustomTourBloc, CustomTourState>(
      builder: (context, state) {
        if (state is CustomTourLoading) {
          return const LoadingWidget(message: 'Loading tours...');
        }

        if (state is CustomTourError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: _loadTours,
          );
        }

        if (state is CustomToursLoaded) {
          if (state.customTours.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadTours(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.customTours.length,
              itemBuilder: (context, index) {
                final tour = state.customTours[index];
                return _buildTourCard(tour);
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
      case TourStatus.draft:
        message = 'No Draft Tours';
        subtitle = 'Create a new tour to get started.';
        icon = Icons.edit_note;
        break;
      case TourStatus.published:
        message = 'No Published Tours';
        subtitle = 'Publish your draft tours to make them available.';
        icon = Icons.public;
        break;
      case TourStatus.active:
        message = 'No Active Tours';
        subtitle = 'No tours are currently running.';
        icon = Icons.play_circle;
        break;
      case TourStatus.completed:
        message = 'No Completed Tours';
        subtitle = 'Completed tours will appear here.';
        icon = Icons.done_all;
        break;
      case TourStatus.cancelled:
        message = 'No Cancelled Tours';
        subtitle = 'Cancelled tours will appear here.';
        icon = Icons.cancel;
        break;
      default:
        message = 'No Tours Yet';
        subtitle = 'Create your first tour to get started!';
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
            if (_selectedStatus == null || _selectedStatus == TourStatus.draft) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TourFormPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Tour'),
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

  Widget _buildTourCard(CustomTour tour) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TourDetailsPage(tourId: tour.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tour.tourName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusChip(tour.status),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) => _handleMenuAction(value, tour),
                        itemBuilder: (context) => _buildMenuItems(tour),
                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tour details
              _buildDetailRow(
                icon: Icons.confirmation_number,
                label: 'Join Code',
                value: tour.joinCode,
                copyable: true,
              ),
              const SizedBox(height: 8),
              
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Duration',
                value: '${_formatDate(tour.startDate)} - ${_formatDate(tour.endDate)} (${tour.durationDays} days)',
              ),
              const SizedBox(height: 8),
              
              _buildDetailRow(
                icon: Icons.people,
                label: 'Capacity',
                value: '${tour.currentTourists}/${tour.maxTourists} tourists',
              ),
              const SizedBox(height: 8),
              
              _buildDetailRow(
                icon: Icons.attach_money,
                label: 'Price',
                value: '${tour.currency} ${tour.pricePerPerson.toStringAsFixed(2)} per person',
              ),

              if (tour.description != null && tour.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  tour.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Tags
              if (tour.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tour.tags.take(3).map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[100],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],

              // Progress indicator for capacity
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Capacity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${((tour.currentTourists / tour.maxTourists) * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: tour.currentTourists / tour.maxTourists,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tour.hasAvailableSpots ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),

              // Quick action buttons
              const SizedBox(height: 16),
              _buildActionButtons(tour),
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
    bool copyable = false,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (copyable) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _copyToClipboard(value),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(TourStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case TourStatus.draft:
        color = Colors.grey;
        text = 'Draft';
        icon = Icons.edit_note;
        break;
      case TourStatus.published:
        color = Colors.blue;
        text = 'Published';
        icon = Icons.public;
        break;
      case TourStatus.active:
        color = Colors.green;
        text = 'Active';
        icon = Icons.play_circle;
        break;
      case TourStatus.completed:
        color = Colors.purple;
        text = 'Completed';
        icon = Icons.done_all;
        break;
      case TourStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        icon = Icons.cancel;
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

  Widget _buildActionButtons(CustomTour tour) {
    List<Widget> buttons = [];

    switch (tour.status) {
      case TourStatus.draft:
        buttons.addAll([
          ElevatedButton.icon(
            onPressed: () => _publishTour(tour.id),
            icon: const Icon(Icons.public, size: 16),
            label: const Text('Publish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _editTour(tour),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit'),
          ),
        ]);
        break;
      case TourStatus.published:
        buttons.addAll([
          ElevatedButton.icon(
            onPressed: () => _startTour(tour.id),
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Start'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _cancelTour(tour.id),
            icon: const Icon(Icons.cancel, size: 16),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ]);
        break;
      case TourStatus.active:
        buttons.addAll([
          ElevatedButton.icon(
            onPressed: () => _completeTour(tour.id),
            icon: const Icon(Icons.done, size: 16),
            label: const Text('Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ]);
        break;
      default:
        // For completed and cancelled tours, show view details button
        buttons.add(
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TourDetailsPage(tourId: tour.id),
                ),
              );
            },
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('View Details'),
          ),
        );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: buttons,
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(CustomTour tour) {
    List<PopupMenuEntry<String>> items = [
      const PopupMenuItem(
        value: 'view',
        child: ListTile(
          leading: Icon(Icons.visibility),
          title: Text('View Details'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ];

    if (tour.status == TourStatus.draft || tour.status == TourStatus.published) {
      items.add(
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
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
          title: Text('Duplicate'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ]);

    if (tour.status == TourStatus.draft) {
      items.add(
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
    }

    return items;
  }

  void _handleMenuAction(String action, CustomTour tour) {
    switch (action) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TourDetailsPage(tourId: tour.id),
          ),
        );
        break;
      case 'edit':
        _editTour(tour);
        break;
      case 'generate_code':
        _generateNewJoinCode(tour.id);
        break;
      case 'duplicate':
        _duplicateTour(tour);
        break;
      case 'delete':
        _showDeleteDialog(tour);
        break;
    }
  }

  void _publishTour(String tourId) {
    context.read<CustomTourBloc>().add(PublishTour(tourId));
  }

  void _startTour(String tourId) {
    context.read<CustomTourBloc>().add(StartTour(tourId));
  }

  void _completeTour(String tourId) {
    context.read<CustomTourBloc>().add(CompleteTour(tourId));
  }

  void _cancelTour(String tourId) {
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
              context.read<CustomTourBloc>().add(CancelTour(tourId));
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

  void _editTour(CustomTour tour) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TourFormPage(tour: tour),
      ),
    );
  }

  void _generateNewJoinCode(String tourId) {
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
              context.read<CustomTourBloc>().add(GenerateNewJoinCode(tourId));
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _duplicateTour(CustomTour tour) {
    final duplicatedTour = tour.copyWith(
      id: '', // Will be generated by backend
      tourName: '${tour.tourName} (Copy)',
      joinCode: '', // Will be generated by backend
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

  void _showDeleteDialog(CustomTour tour) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tour'),
        content: Text(
          'Are you sure you want to delete "${tour.tourName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CustomTourBloc>().add(DeleteCustomTour(tour.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search functionality coming soon!'),
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



  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}