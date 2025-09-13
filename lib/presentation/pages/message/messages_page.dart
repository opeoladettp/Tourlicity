import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/message.dart';
import '../../blocs/message/message_bloc.dart';
import '../../blocs/message/message_event.dart';
import '../../blocs/message/message_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/message/message_card.dart';
import 'create_message_page.dart';

class MessagesPage extends StatefulWidget {
  final String tourId;
  final String tourTitle;
  final String currentUserId;
  final bool isProvider;

  const MessagesPage({
    super.key,
    required this.tourId,
    required this.tourTitle,
    required this.currentUserId,
    this.isProvider = false,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MessageType? _filterType;
  MessagePriority? _filterPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.isProvider ? 3 : 2, vsync: this);
    _loadMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    context.read<MessageBloc>().add(LoadMessagesForTour(widget.tourId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Messages'),
            Text(
              widget.tourTitle,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: 'All Messages'),
            const Tab(text: 'Unread'),
            if (widget.isProvider) const Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: BlocBuilder<MessageBloc, MessageState>(
        builder: (context, state) {
          if (state is MessageLoading) {
            return const LoadingWidget(message: 'Loading messages...');
          }

          if (state is MessageError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: _loadMessages,
            );
          }

          if (state is MessagesLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildAllMessagesTab(state.messages),
                _buildUnreadMessagesTab(state.getUnreadMessagesForUser(widget.currentUserId)),
                if (widget.isProvider) _buildStatisticsTab(state),
              ],
            );
          }

          return const Center(
            child: Text('No messages available'),
          );
        },
      ),
      floatingActionButton: widget.isProvider
          ? FloatingActionButton(
              onPressed: _createMessage,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAllMessagesTab(List<Message> messages) {
    final filteredMessages = _applyFilters(messages);

    if (filteredMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadMessages(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMessages.length,
        itemBuilder: (context, index) {
          final message = filteredMessages[index];
          return MessageCard(
            message: message,
            currentUserId: widget.currentUserId,
            isProvider: widget.isProvider,
            onMarkAsRead: () => _markAsRead(message.id),
            onDismiss: () => _dismissMessage(message.id),
            onDelete: widget.isProvider ? () => _deleteMessage(message.id) : null,
          );
        },
      ),
    );
  }

  Widget _buildUnreadMessagesTab(List<Message> unreadMessages) {
    final filteredMessages = _applyFilters(unreadMessages);

    if (filteredMessages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_read, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'All caught up!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'No unread messages',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (filteredMessages.length > 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _markAllAsRead(filteredMessages),
              icon: const Icon(Icons.done_all),
              label: Text('Mark All ${filteredMessages.length} as Read'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _loadMessages(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredMessages.length,
              itemBuilder: (context, index) {
                final message = filteredMessages[index];
                return MessageCard(
                  message: message,
                  currentUserId: widget.currentUserId,
                  isProvider: widget.isProvider,
                  onMarkAsRead: () => _markAsRead(message.id),
                  onDismiss: () => _dismissMessage(message.id),
                  onDelete: widget.isProvider ? () => _deleteMessage(message.id) : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab(MessagesLoaded state) {
    final messages = state.messages;
    final totalMessages = messages.length;
    final broadcastCount = messages.where((m) => m.type == MessageType.broadcast).length;
    final updateCount = messages.where((m) => m.type == MessageType.tourUpdate).length;
    final urgentCount = messages.where((m) => m.priority == MessagePriority.urgent).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard('Total Messages', totalMessages.toString(), Icons.message),
          _buildStatCard('Broadcasts', broadcastCount.toString(), Icons.campaign),
          _buildStatCard('Tour Updates', updateCount.toString(), Icons.update),
          _buildStatCard('Urgent Messages', urgentCount.toString(), Icons.priority_high),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Message Types Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...MessageType.values.map((type) {
                    final count = messages.where((m) => m.type == type).length;
                    final percentage = totalMessages > 0 ? (count / totalMessages * 100) : 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(type.displayName),
                          ),
                          Expanded(
                            flex: 3,
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$count (${percentage.toStringAsFixed(1)}%)'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Message> _applyFilters(List<Message> messages) {
    var filtered = messages;

    if (_filterType != null) {
      filtered = filtered.where((m) => m.type == _filterType).toList();
    }

    if (_filterPriority != null) {
      filtered = filtered.where((m) => m.priority == _filterPriority).toList();
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MessageType?>(
              initialValue: _filterType,
              decoration: const InputDecoration(labelText: 'Message Type'),
              items: [
                const DropdownMenuItem<MessageType?>(
                  value: null,
                  child: Text('All Types'),
                ),
                ...MessageType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    )),
              ],
              onChanged: (value) => setState(() => _filterType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MessagePriority?>(
              initialValue: _filterPriority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: [
                const DropdownMenuItem<MessagePriority?>(
                  value: null,
                  child: Text('All Priorities'),
                ),
                ...MessagePriority.values.map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.displayName),
                    )),
              ],
              onChanged: (value) => setState(() => _filterPriority = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterType = null;
                _filterPriority = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _createMessage() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateMessagePage(
          tourId: widget.tourId,
          tourTitle: widget.tourTitle,
        ),
      ),
    );

    if (result == true) {
      _loadMessages();
    }
  }

  void _markAsRead(String messageId) {
    context.read<MessageBloc>().add(
          MarkMessageAsRead(messageId: messageId, userId: widget.currentUserId),
        );
  }

  void _dismissMessage(String messageId) {
    context.read<MessageBloc>().add(
          MarkMessageAsDismissed(messageId: messageId, userId: widget.currentUserId),
        );
  }

  void _deleteMessage(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MessageBloc>().add(DeleteMessage(messageId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead(List<Message> messages) {
    final messageIds = messages.map((m) => m.id).toList();
    context.read<MessageBloc>().add(
          MarkMultipleMessagesAsRead(
            messageIds: messageIds,
            userId: widget.currentUserId,
          ),
        );
  }
}