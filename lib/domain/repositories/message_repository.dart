import '../entities/message.dart';

abstract class MessageRepository {
  /// Send a broadcast message to all participants of a tour
  Future<Message> sendBroadcastMessage({
    required String tourId,
    required String title,
    required String content,
    required MessageType type,
    required MessagePriority priority,
    Map<String, dynamic>? metadata,
  });

  /// Send a tour update message
  Future<Message> sendTourUpdate({
    required String tourId,
    required String title,
    required String content,
    Map<String, dynamic>? metadata,
  });

  /// Get all messages for a specific tour
  Future<List<Message>> getMessagesForTour(String tourId);

  /// Get messages for a specific user (across all their tours)
  Future<List<Message>> getMessagesForUser(String userId);

  /// Get unread messages for a user
  Future<List<Message>> getUnreadMessages(String userId);

  /// Mark a message as read by a user
  Future<void> markMessageAsRead(String messageId, String userId);

  /// Mark a message as dismissed by a user
  Future<void> markMessageAsDismissed(String messageId, String userId);

  /// Mark multiple messages as read
  Future<void> markMultipleMessagesAsRead(List<String> messageIds, String userId);

  /// Get message by ID
  Future<Message> getMessageById(String messageId);

  /// Delete a message (only by sender or admin)
  Future<void> deleteMessage(String messageId);

  /// Update a message (only by sender within time limit)
  Future<Message> updateMessage({
    required String messageId,
    String? title,
    String? content,
    MessagePriority? priority,
    Map<String, dynamic>? metadata,
  });

  /// Get message statistics for a tour
  Future<Map<String, dynamic>> getMessageStatistics(String tourId);

  /// Search messages by content or title
  Future<List<Message>> searchMessages({
    required String query,
    String? tourId,
    MessageType? type,
    MessagePriority? priority,
    DateTime? fromDate,
    DateTime? toDate,
  });
}