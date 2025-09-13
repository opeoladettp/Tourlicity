import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/document/document_bloc.dart';
import '../../blocs/document/document_event.dart';
import '../../blocs/document/document_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../../domain/entities/document.dart';

class DocumentDetailsPage extends StatefulWidget {
  final String documentId;

  const DocumentDetailsPage({super.key, required this.documentId});

  @override
  State<DocumentDetailsPage> createState() => _DocumentDetailsPageState();
}

class _DocumentDetailsPageState extends State<DocumentDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadDocumentDetails();
  }

  void _loadDocumentDetails() {
    context.read<DocumentBloc>().add(LoadDocumentById(widget.documentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentDownloadUrlLoaded) {
            // Open download URL using url_launcher
            _handleDownload(state.downloadUrl);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Download started'),
                backgroundColor: Colors.green,
              ),
            );
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
        child: BlocBuilder<DocumentBloc, DocumentState>(
          builder: (context, state) {
            if (state is DocumentLoading) {
              return const Scaffold(
                body: LoadingWidget(message: 'Loading document details...'),
              );
            }

            if (state is DocumentError) {
              return Scaffold(
                appBar: AppBar(title: const Text('Document Details')),
                body: CustomErrorWidget(
                  message: state.message,
                  onRetry: _loadDocumentDetails,
                ),
              );
            }

            if (state is DocumentLoaded) {
              return _buildDocumentDetails(state.document);
            }

            return Scaffold(
              appBar: AppBar(title: const Text('Document Details')),
              body: const CustomErrorWidget(
                message: 'Document not found',
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentDetails(Document document) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.typeDisplayName),
        elevation: 0,
        actions: [
          if (document.isApproved && document.canDownload)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadDocument(document),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, document),
            itemBuilder: (context) => _buildMenuItems(document),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: _getStatusColor(document.status).withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(document.status),
                      color: _getStatusColor(document.status),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(document.status),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(document.status),
                                ),
                          ),
                          Text(
                            _getStatusDescription(document.status),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: _getStatusColor(document.status)
                                      .withValues(alpha: 0.8),
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

            // Document Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: Icons.category,
                      label: 'Type',
                      value: document.typeDisplayName,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.insert_drive_file,
                      label: 'File Name',
                      value: document.originalFileName,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.storage,
                      label: 'File Size',
                      value: document.fileSizeFormatted,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.code,
                      label: 'File Type',
                      value: document.mimeType,
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Uploaded',
                      value: _formatDateTime(document.uploadedAt),
                    ),
                    if (document.expiryDate != null) ...[
                      const Divider(),
                      _buildDetailRow(
                        icon: Icons.schedule,
                        label: 'Expires',
                        value: _formatDate(document.expiryDate!),
                        isExpiring: document.isExpiringSoon,
                        isExpired: document.isExpiredByDate,
                      ),
                    ],
                    if (document.description != null &&
                        document.description!.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Description',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        document.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Review Information
            if (document.reviewedAt != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        icon: Icons.person,
                        label: 'Reviewed By',
                        value: document.reviewedBy ?? 'Unknown',
                      ),
                      const Divider(),
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Reviewed At',
                        value: _formatDateTime(document.reviewedAt!),
                      ),
                      if (document.reviewNotes != null) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          document.isApproved
                              ? 'Approval Notes'
                              : 'Review Notes',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: document.isApproved
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: document.isApproved
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: document.isApproved
                                  ? Colors.green[200]!
                                  : Colors.red[200]!,
                            ),
                          ),
                          child: Text(
                            document.reviewNotes!,
                            style: TextStyle(
                              color: document.isApproved
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Expiry Warning
            if (document.isExpiringSoon || document.isExpiredByDate) ...[
              Card(
                color: document.isExpiredByDate
                    ? Colors.red[50]
                    : Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        document.isExpiredByDate ? Icons.error : Icons.warning,
                        color: document.isExpiredByDate
                            ? Colors.red[700]
                            : Colors.orange[700],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.isExpiredByDate
                                  ? 'Document Expired'
                                  : 'Expiring Soon',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: document.isExpiredByDate
                                        ? Colors.red[700]
                                        : Colors.orange[700],
                                  ),
                            ),
                            Text(
                              document.isExpiredByDate
                                  ? 'This document has expired and needs to be renewed.'
                                  : 'This document will expire soon. Consider renewing it.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: document.isExpiredByDate
                                        ? Colors.red[600]
                                        : Colors.orange[600],
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
            ],

            // File Preview (if image)
            if (document.isImageFile && document.canDownload) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Image preview not available'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            if (document.isApproved && document.canDownload) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadDocument(document),
                  icon: const Icon(Icons.download),
                  label: const Text('Download Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
    bool isExpiring = false,
    bool isExpired = false,
  }) {
    Color? valueColor;
    if (isExpired) {
      valueColor = Colors.red;
    } else if (isExpiring) {
      valueColor = Colors.orange;
    }

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(Document document) {
    List<PopupMenuEntry<String>> items = [];

    if (document.isApproved && document.canDownload) {
      items.add(
        const PopupMenuItem(
          value: 'download',
          child: ListTile(
            leading: Icon(Icons.download),
            title: Text('Download'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      );
    }

    if (document.isPending || document.isRejected) {
      items.addAll([
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Details'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ]);
    }

    return items;
  }

  void _handleMenuAction(String action, Document document) {
    switch (action) {
      case 'download':
        _downloadDocument(document);
        break;
      case 'edit':
        _showEditDialog(document);
        break;
      case 'delete':
        _showDeleteDialog(document);
        break;
    }
  }

  void _downloadDocument(Document document) {
    context.read<DocumentBloc>().add(GetDownloadUrl(document.id));
  }

  void _showEditDialog(Document document) {
    final descriptionController =
        TextEditingController(text: document.description);
    DateTime? expiryDate = document.expiryDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Document Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: expiryDate ??
                        DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() => expiryDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    expiryDate != null
                        ? _formatDate(expiryDate!)
                        : 'No expiry date',
                  ),
                ),
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
                context.read<DocumentBloc>().add(
                      UpdateDocument(
                        documentId: document.id,
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        expiryDate: expiryDate,
                      ),
                    );
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
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
              Navigator.of(context).pop(); // Go back to documents list
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

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.rejected:
        return Colors.red;
      case DocumentStatus.expired:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return Icons.hourglass_empty;
      case DocumentStatus.approved:
        return Icons.check_circle;
      case DocumentStatus.rejected:
        return Icons.cancel;
      case DocumentStatus.expired:
        return Icons.schedule;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'Pending Review';
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.expired:
        return 'Expired';
    }
  }

  String _getStatusDescription(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'Document is awaiting review by the provider';
      case DocumentStatus.approved:
        return 'Document has been approved and is ready for use';
      case DocumentStatus.rejected:
        return 'Document was rejected and needs to be resubmitted';
      case DocumentStatus.expired:
        return 'Document has expired and needs to be renewed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleDownload(String downloadUrl) async {
    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: show URL in dialog if can't launch
        _showDownloadUrlDialog(downloadUrl);
      }
    } catch (e) {
      // Error handling: show URL in dialog
      _showDownloadUrlDialog(downloadUrl);
    }
  }

  void _showDownloadUrlDialog(String downloadUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Unable to open download automatically. Please copy the URL below:'),
            const SizedBox(height: 8),
            SelectableText(
              downloadUrl,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  await Clipboard.setData(ClipboardData(text: downloadUrl));
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Download URL copied to clipboard'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to copy URL'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy URL'),
            ),
          ],
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
}
