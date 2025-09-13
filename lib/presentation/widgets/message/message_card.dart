import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final String currentUserId;
  final bool isProvider;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDismiss;
  final VoidCallback? onDelete;

  const MessageCard({
    super.key,
    required this.message,
    required this.currentUserId,
    this.isProvider = false,
    this.onMarkAsRead,
    this.onDismiss,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !message.isReadBy(currentUserId);
    final isDismissed = message.isDismissedBy(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnread ? 4 : 2,
      color: isDismissed ? Colors.grey[100] : null,
      child: InkWell(
        onTap: isUnread ? onMarkAsRead : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Priority and Type Indicators
                  _buildPriorityChip(),
                  const SizedBox(width: 8),
                  _buildTypeChip(),
                  const Spacer(),
                  // Unread Indicator
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  // Actions Menu
                  PopupMenuButton<String>(
                    onSelected: _handleMenuAction,
                    itemBuilder: (context) => [
                      if (isUnread)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read),
                              SizedBox(width: 8),
                              Text('Mark as Read'),
                            ],
                          ),
                        ),
                      if (!isDismissed)
                        const PopupMenuItem(
                          value: 'dismiss',
                          child: Row(
                            children: [
                              Icon(Icons.visibility_off),
                              SizedBox(width: 8),
                              Text('Dismiss'),
                            ],
                          ),
                        ),
                      if (isProvider && onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                message.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  color: isDismissed ? Colors.grey : null,
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isDismissed ? Colors.grey : Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  // Sender Info
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Timestamp
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimestamp(message.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // Read Count (for providers)
                  if (isProvider)
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${message.readBy.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Expanded Content (if tapped)
              if (message.content.length > 150)
                TextButton(
                  onPressed: () => _showFullMessage(context),
                  child: const Text('Read more'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    IconData icon;

    switch (message.priority) {
      case MessagePriority.low:
        color = Colors.grey;
        icon = Icons.keyboard_arrow_down;
        break;
      case MessagePriority.normal:
        color = Colors.blue;
        icon = Icons.remove;
        break;
      case MessagePriority.high:
        color = Colors.orange;
        icon = Icons.keyboard_arrow_up;
        break;
      case MessagePriority.urgent:
        color = Colors.red;
        icon = Icons.priority_high;
        break;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            message.priority.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTypeChip() {
    Color color;
    IconData icon;

    switch (message.type) {
      case MessageType.broadcast:
        color = Colors.blue;
        icon = Icons.campaign;
        break;
      case MessageType.tourUpdate:
        color = Colors.green;
        icon = Icons.update;
        break;
      case MessageType.announcement:
        color = Colors.purple;
        icon = Icons.announcement;
        break;
      case MessageType.reminder:
        color = Colors.amber;
        icon = Icons.schedule;
        break;
      case MessageType.alert:
        color = Colors.red;
        icon = Icons.warning;
        break;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            message.type.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_read':
        onMarkAsRead?.call();
        break;
      case 'dismiss':
        onDismiss?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  void _showFullMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message Info
              Row(
                children: [
                  _buildPriorityChip(),
                  const SizedBox(width: 8),
                  _buildTypeChip(),
                ],
              ),
              const SizedBox(height: 16),
              
              // Full Content
              Text(
                message.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              
              // Metadata
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From: ${message.senderName} (${message.senderRole})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sent: ${DateFormat('MMM d, y \'at\' h:mm a').format(message.createdAt)}',
                    ),
                    if (message.updatedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Updated: ${DateFormat('MMM d, y \'at\' h:mm a').format(message.updatedAt!)}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!message.isReadBy(currentUserId))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onMarkAsRead?.call();
              },
              child: const Text('Mark as Read'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}