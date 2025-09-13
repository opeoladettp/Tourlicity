import 'package:flutter/material.dart';
import '../../../domain/entities/tour_template.dart';

/// Widget displaying a tour template item in a list
class TourTemplateListItem extends StatelessWidget {
  final TourTemplate template;
  final ValueChanged<String> onAction;

  const TourTemplateListItem({
    super.key,
    required this.template,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.templateName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(),
                PopupMenuButton<String>(
                  onSelected: onAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: template.isActive ? 'deactivate' : 'activate',
                      child: ListTile(
                        leading: Icon(
                          template.isActive
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        title:
                            Text(template.isActive ? 'Deactivate' : 'Activate'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title:
                            Text('Delete', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(template.startDate)} - ${_formatDate(template.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${template.durationDays} ${template.durationDays == 1 ? 'day' : 'days'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            if (template.webLinks.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${template.webLinks.length} ${template.webLinks.length == 1 ? 'link' : 'links'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        template.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: template.isActive ? Colors.green[800] : Colors.red[800],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: template.isActive ? Colors.green[100] : Colors.red[100],
      side: BorderSide(
        color: template.isActive ? Colors.green[300]! : Colors.red[300]!,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
