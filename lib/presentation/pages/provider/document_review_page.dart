import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/document/document_bloc.dart';
import '../../blocs/document/document_event.dart';
import '../../blocs/document/document_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/entities/document.dart';

class DocumentReviewPage extends StatefulWidget {
  final String? tourId;

  const DocumentReviewPage({super.key, this.tourId});

  @override
  State<DocumentReviewPage> createState() => _DocumentReviewPageState();
}

class _DocumentReviewPageState extends State<DocumentReviewPage> with TickerProviderStateMixin {
  late TabController _tabController;
  DocumentType? _selectedType;
  final List<String> _selectedDocuments = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
    final types = [
      null, // All
      DocumentType.passport,
      DocumentType.visa,
      DocumentType.insurance,
      DocumentType.medicalCertificate,
      DocumentType.emergencyContact,
      DocumentType.other,
    ];
    
    setState(() {
      _selectedType = types[_tabController.index];
      _selectedDocuments.clear();
      _isSelectionMode = false;
    });
    _loadDocuments();
  }

  void _loadDocuments() {
    final authState = context.read<AuthBloc>().state;
    if (authState.isAuthenticated && authState.userEntity != null) {
      context.read<DocumentBloc>().add(
        LoadDocumentsForReview(
          providerId: authState.userEntity!.id,
          tourId: widget.tourId,
          type: _selectedType,
          limit: 100,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tourId != null ? 'Tour Document Review' : 'Document Review'),
        elevation: 0,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _selectedDocuments.isNotEmpty ? _bulkApprove : null,
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _selectedDocuments.isNotEmpty ? _bulkReject : null,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedDocuments.clear();
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDocuments,
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Passport'),
            Tab(text: 'Visa'),
            Tab(text: 'Insurance'),
            Tab(text: 'Medical'),
            Tab(text: 'Emergency'),
            Tab(text: 'Other'),
          ],
        ),
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentOperationSuccess || state is DocumentBulkOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state is DocumentOperationSuccess ? state.message : (state as DocumentBulkOperationSuccess).message),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              _selectedDocuments.clear();
              _isSelectionMode = false;
            });
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
          children: List.generate(7, (index) => _buildDocumentsList()),
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const LoadingWidget(message: 'Loading documents for review...');
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

    switch (_selectedType) {
      case DocumentType.passport:
        message = 'No Passport Documents';
        subtitle = 'No passport documents need review.';
        icon = Icons.card_membership;
        break;
      case DocumentType.visa:
        message = 'No Visa Documents';
        subtitle = 'No visa documents need review.';
        icon = Icons.flight_takeoff;
        break;
      case DocumentType.insurance:
        message = 'No Insurance Documents';
        subtitle = 'No insurance documents need review.';
        icon = Icons.security;
        break;
      case DocumentType.medicalCertificate:
        message = 'No Medical Documents';
        subtitle = 'No medical certificates need review.';
        icon = Icons.medical_services;
        break;
      case DocumentType.emergencyContact:
        message = 'No Emergency Contact Documents';
        subtitle = 'No emergency contact documents need review.';
        icon = Icons.emergency;
        break;
      case DocumentType.other:
        message = 'No Other Documents';
        subtitle = 'No other documents need review.';
        icon = Icons.description;
        break;
      default:
        message = 'No Documents to Review';
        subtitle = 'All documents have been reviewed!';
        icon = Icons.task_alt;
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

  Widget _buildDocumentCard(Document document) {
    final isSelected = _selectedDocuments.contains(document.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: _isSelectionMode 
            ? () => _toggleSelection(document.id)
            : () => _showDocumentDetails(document),
        onLongPress: () {
          if (!_isSelectionMode) {
            setState(() {
              _isSelectionMode = true;
              _selectedDocuments.add(document.id);
            });
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with selection and document info
              Row(
                children: [
                  if (_isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(document.id),
                    ),
                    const SizedBox(width: 8),
                  ],
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
                  const Chip(
                    label: Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Colors.orange,
                  ),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        document.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons (only show when not in selection mode)
              if (!_isSelectionMode) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showRejectDialog(document),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(document),
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

  void _toggleSelection(String documentId) {
    setState(() {
      if (_selectedDocuments.contains(documentId)) {
        _selectedDocuments.remove(documentId);
      } else {
        _selectedDocuments.add(documentId);
      }
    });
  }

  void _showDocumentDetails(Document document) {
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
                'Document Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildDocumentCard(document),
                ),
              ),
              
              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showRejectDialog(document);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showApproveDialog(document);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApproveDialog(Document document) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Approve "${document.originalFileName}"?'),
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
              final authState = context.read<AuthBloc>().state;
              if (authState.isAuthenticated && authState.userEntity != null) {
                context.read<DocumentBloc>().add(
                  ApproveDocument(
                    documentId: document.id,
                    notes: notesController.text.trim().isEmpty 
                        ? null 
                        : notesController.text.trim(),
                    reviewedBy: authState.userEntity!.id,
                  ),
                );
              }
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

  void _showRejectDialog(Document document) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject "${document.originalFileName}"?'),
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
                final authState = context.read<AuthBloc>().state;
                if (authState.isAuthenticated && authState.userEntity != null) {
                  context.read<DocumentBloc>().add(
                    RejectDocument(
                      documentId: document.id,
                      reason: reasonController.text.trim(),
                      reviewedBy: authState.userEntity!.id,
                    ),
                  );
                }
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

  void _bulkApprove() {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve ${_selectedDocuments.length} Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Approve ${_selectedDocuments.length} selected documents?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Approval Notes (Optional)',
                hintText: 'Add notes for all selected documents...',
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
              final authState = context.read<AuthBloc>().state;
              if (authState.isAuthenticated && authState.userEntity != null) {
                context.read<DocumentBloc>().add(
                  BulkApproveDocuments(
                    documentIds: _selectedDocuments,
                    notes: notesController.text.trim().isEmpty 
                        ? null 
                        : notesController.text.trim(),
                    reviewedBy: authState.userEntity!.id,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve All'),
          ),
        ],
      ),
    );
  }

  void _bulkReject() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject ${_selectedDocuments.length} Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${_selectedDocuments.length} selected documents?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                hintText: 'Please provide a reason for all documents...',
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
                final authState = context.read<AuthBloc>().state;
                if (authState.isAuthenticated && authState.userEntity != null) {
                  context.read<DocumentBloc>().add(
                    BulkRejectDocuments(
                      documentIds: _selectedDocuments,
                      reason: reasonController.text.trim(),
                      reviewedBy: authState.userEntity!.id,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject All'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}