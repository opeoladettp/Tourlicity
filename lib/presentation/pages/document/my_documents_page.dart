import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/document/document_bloc.dart';
import '../../blocs/document/document_event.dart';
import '../../blocs/document/document_state.dart';
import '../../blocs/auth/auth_bloc.dart';

import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/document/document_upload_widget.dart';
import '../../../domain/entities/document.dart';
import 'document_details_page.dart';

class MyDocumentsPage extends StatefulWidget {
  final String? tourId;

  const MyDocumentsPage({super.key, this.tourId});

  @override
  State<MyDocumentsPage> createState() => _MyDocumentsPageState();
}

class _MyDocumentsPageState extends State<MyDocumentsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  DocumentStatus? _selectedStatus;
  DocumentType? _selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadDocuments();
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
      DocumentStatus.pending,
      DocumentStatus.approved,
      DocumentStatus.rejected,
      DocumentStatus.expired,
    ];
    
    setState(() {
      _selectedStatus = statuses[_tabController.index];
    });
    _loadDocuments();
  }

  void _loadDocuments() {
    final authState = context.read<AuthBloc>().state;
    if (authState.isAuthenticated && authState.userEntity != null) {
      context.read<DocumentBloc>().add(
        LoadDocumentsByUser(
          userId: authState.userEntity!.id,
          status: _selectedStatus,
          type: _selectedType,
          tourId: widget.tourId,
          limit: 50,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tourId != null ? 'Tour Documents' : 'My Documents'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
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
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadDocuments(); // Refresh the list
          }

          if (state is DocumentDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _loadDocuments(); // Refresh the list
          }

          if (state is DocumentError) {
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
          children: List.generate(5, (index) => _buildDocumentsList()),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDocumentsList() {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const LoadingWidget(message: 'Loading documents...');
        }

        if (state is DocumentError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: _loadDocuments,
          );
        }

        if (state is DocumentsLoaded) {
          if (state.documents.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _loadDocuments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.documents.length,
              itemBuilder: (context, index) {
                final document = state.documents[index];
                return _buildDocumentCard(document);
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
      case DocumentStatus.pending:
        message = 'No Pending Documents';
        subtitle = 'Documents awaiting review will appear here.';
        icon = Icons.hourglass_empty;
        break;
      case DocumentStatus.approved:
        message = 'No Approved Documents';
        subtitle = 'Your approved documents will appear here.';
        icon = Icons.check_circle_outline;
        break;
      case DocumentStatus.rejected:
        message = 'No Rejected Documents';
        subtitle = 'Documents that need resubmission will appear here.';
        icon = Icons.cancel_outlined;
        break;
      case DocumentStatus.expired:
        message = 'No Expired Documents';
        subtitle = 'Expired documents will appear here.';
        icon = Icons.schedule;
        break;
      default:
        message = 'No Documents Yet';
        subtitle = 'Upload your first document to get started!';
        icon = Icons.description;
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
                onPressed: _showUploadDialog,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload Document'),
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

  Widget _buildDocumentCard(Document document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DocumentDetailsPage(documentId: document.id),
            ),
          );
        },
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
                    child: Row(
                      children: [
                        Icon(
                          _getDocumentIcon(document.type),
                          color: Colors.blue[600],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document.typeDisplayName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                document.originalFileName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(document.status),
                ],
              ),
              const SizedBox(height: 12),

              // Document details
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'Uploaded',
                value: _formatDate(document.uploadedAt),
              ),
              const SizedBox(height: 8),
              
              _buildDetailRow(
                icon: Icons.storage,
                label: 'File Size',
                value: document.fileSizeFormatted,
              ),

              if (document.expiryDate != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.schedule,
                  label: 'Expires',
                  value: _formatDate(document.expiryDate!),
                  isExpiring: document.isExpiringSoon,
                  isExpired: document.isExpiredByDate,
                ),
              ],

              if (document.description != null && document.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  document.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Status-specific information
              if (document.reviewNotes != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: document.isApproved ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: document.isApproved ? Colors.green[200]! : Colors.red[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        document.isApproved ? Icons.check_circle : Icons.error,
                        color: document.isApproved ? Colors.green[700] : Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.isApproved ? 'Approval Notes' : 'Review Notes',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: document.isApproved ? Colors.green[700] : Colors.red[700],
                              ),
                            ),
                            Text(
                              document.reviewNotes!,
                              style: TextStyle(
                                color: document.isApproved ? Colors.green[600] : Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (document.isApproved && document.canDownload) ...[
                    ElevatedButton.icon(
                      onPressed: () => _downloadDocument(document),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (document.isPending || document.isRejected) ...[
                    OutlinedButton.icon(
                      onPressed: () => _showDeleteDialog(document),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
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
    bool isExpiring = false,
    bool isExpired = false,
  }) {
    Color? valueColor;
    if (isExpired) {
      valueColor = Colors.red;
    } else if (isExpiring) {
      valueColor = Colors.orange;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
        if (isExpiring && !isExpired) ...[
          const SizedBox(width: 8),
          const Icon(Icons.warning, size: 16, color: Colors.orange),
        ],
        if (isExpired) ...[
          const SizedBox(width: 8),
          const Icon(Icons.error, size: 16, color: Colors.red),
        ],
      ],
    );
  }

  Widget _buildStatusChip(DocumentStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case DocumentStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case DocumentStatus.approved:
        color = Colors.green;
        text = 'Approved';
        icon = Icons.check_circle;
        break;
      case DocumentStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        icon = Icons.cancel;
        break;
      case DocumentStatus.expired:
        color = Colors.grey;
        text = 'Expired';
        icon = Icons.schedule;
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

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.passport:
        return Icons.card_membership;
      case DocumentType.visa:
        return Icons.flight_takeoff;
      case DocumentType.insurance:
        return Icons.security;
      case DocumentType.medicalCertificate:
        return Icons.medical_services;
      case DocumentType.emergencyContact:
        return Icons.emergency;
      case DocumentType.other:
        return Icons.description;
    }
  }

  void _showUploadDialog() {
    final authState = context.read<AuthBloc>().state;
    if (authState.isAuthenticated && authState.userEntity != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: DocumentUploadWidget(
              userId: authState.userEntity!.id,
              tourId: widget.tourId,
              onUploadSuccess: () {
                Navigator.of(context).pop();
                _loadDocuments();
              },
            ),
          ),
        ),
      );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<DocumentType?>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Document Type',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<DocumentType?>(
                  value: null,
                  child: Text('All Types'),
                ),
                ...DocumentType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                )),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
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
              _loadDocuments();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _downloadDocument(Document document) {
    context.read<DocumentBloc>().add(GetDownloadUrl(document.id));
  }

  void _showDeleteDialog(Document document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
          'Are you sure you want to delete "${document.originalFileName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DocumentBloc>().add(DeleteDocument(document.id));
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}