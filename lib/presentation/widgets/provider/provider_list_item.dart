import 'package:flutter/material.dart';
import '../../../domain/entities/entities.dart';

/// List item widget for displaying a provider
class ProviderListItem extends StatelessWidget {
  const ProviderListItem({
    super.key,
    required this.provider,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Provider provider;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: provider.isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          child: Text(
            provider.name.isNotEmpty ? provider.name[0].toUpperCase() : 'P',
            style: TextStyle(
              color: provider.isActive
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        title: Text(
          provider.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.email),
            Text(provider.phoneNumber),
            if (provider.address != null) Text(provider.address!),
            Row(
              children: [
                Icon(
                  provider.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: provider.isActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: provider.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (provider.rating > 0) ...[
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    provider.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${provider.totalReviews})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
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
        onTap: onTap,
      ),
    );
  }
}
