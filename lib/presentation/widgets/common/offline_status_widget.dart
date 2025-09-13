import 'package:flutter/material.dart';
import '../../../core/services/offline_manager.dart';

class OfflineStatusWidget extends StatelessWidget {
  final Widget child;
  final bool showBanner;

  const OfflineStatusWidget({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OfflineStatus>(
      stream: OfflineManager().statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isOnline = status?.isOnline ?? true;
        final pendingSync = status?.pendingSyncCount ?? 0;

        if (!showBanner || isOnline) {
          return child;
        }

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off,
                    color: Colors.orange.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pendingSync > 0
                          ? 'Offline - $pendingSync items pending sync'
                          : 'You are offline',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (pendingSync > 0)
                    Icon(
                      Icons.sync_problem,
                      color: Colors.orange.shade700,
                      size: 16,
                    ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OfflineStatus>(
      stream: OfflineManager().statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isOnline = status?.isOnline ?? true;
        final pendingSync = status?.pendingSyncCount ?? 0;

        if (isOnline && pendingSync == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOnline ? Colors.blue.shade100 : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOnline ? Icons.sync : Icons.cloud_off,
                size: 12,
                color: isOnline ? Colors.blue.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                isOnline ? 'Syncing...' : 'Offline',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isOnline ? Colors.blue.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OfflineStatus>(
      stream: OfflineManager().statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isOnline = status?.isOnline ?? true;
        final pendingSync = status?.pendingSyncCount ?? 0;

        if (!isOnline || pendingSync == 0) {
          return const SizedBox.shrink();
        }

        return IconButton(
          onPressed: () async {
            try {
              await OfflineManager().forceSync();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sync completed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sync failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.sync),
          tooltip: 'Sync pending changes',
        );
      },
    );
  }
}