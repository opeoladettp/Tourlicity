import 'package:equatable/equatable.dart';
import '../../../domain/entities/message.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {
  const MessageInitial();
}

class MessageLoading extends MessageState {
  const MessageLoading();
}

class MessageSending extends MessageState {
  const MessageSending();
}

class MessagesLoaded extends MessageState {
  final List<Message> messages;
  final Map<String, dynamic>? statistics;

  const MessagesLoaded({
    required this.messages,
    this.statistics,
  });

  @override
  List<Object?> get props => [messages, statistics];

  MessagesLoaded copyWith({
    List<Message>? messages,
    Map<String, dynamic>? statistics,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      statistics: statistics ?? this.statistics,
    );
  }

  // Helper methods for filtering messages
  List<Message> get unreadMessages =>
      messages.where((m) => m.readBy.isEmpty).toList();

  List<Message> get broadcastMessages =>
      messages.where((m) => m.type == MessageType.broadcast).toList();

  List<Message> get tourUpdateMessages =>
      messages.where((m) => m.type == MessageType.tourUpdate).toList();

  List<Message> get urgentMessages =>
      messages.where((m) => m.priority == MessagePriority.urgent).toList();

  List<Message> get highPriorityMessages => messages
      .where((m) =>
          m.priority == MessagePriority.high ||
          m.priority == MessagePriority.urgent)
      .toList();

  List<Message> getMessagesForTour(String tourId) =>
      messages.where((m) => m.tourId == tourId).toList();

  List<Message> getUnreadMessagesForUser(String userId) =>
      messages.where((m) => !m.isReadBy(userId)).toList();

  int getUnreadCountForUser(String userId) =>
      messages.where((m) => !m.isReadBy(userId)).length;
}

class MessageSent extends MessageState {
  final Message message;

  const MessageSent(this.message);

  @override
  List<Object> get props => [message];
}

class MessageUpdated extends MessageState {
  final Message message;

  const MessageUpdated(this.message);

  @override
  List<Object> get props => [message];
}

class MessageDeleted extends MessageState {
  final String messageId;

  const MessageDeleted(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class MessageMarkedAsRead extends MessageState {
  final String messageId;
  final String userId;

  const MessageMarkedAsRead({
    required this.messageId,
    required this.userId,
  });

  @override
  List<Object> get props => [messageId, userId];
}

class MessageMarkedAsDismissed extends MessageState {
  final String messageId;
  final String userId;

  const MessageMarkedAsDismissed({
    required this.messageId,
    required this.userId,
  });

  @override
  List<Object> get props => [messageId, userId];
}

class MultipleMessagesMarkedAsRead extends MessageState {
  final List<String> messageIds;
  final String userId;

  const MultipleMessagesMarkedAsRead({
    required this.messageIds,
    required this.userId,
  });

  @override
  List<Object> get props => [messageIds, userId];
}

class MessageSearchResults extends MessageState {
  final List<Message> results;
  final String query;

  const MessageSearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object> get props => [results, query];
}

class MessageStatisticsLoaded extends MessageState {
  final Map<String, dynamic> statistics;
  final String tourId;

  const MessageStatisticsLoaded({
    required this.statistics,
    required this.tourId,
  });

  @override
  List<Object> get props => [statistics, tourId];
}

class MessageError extends MessageState {
  final String message;
  final String? code;

  const MessageError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'MessageError(message: $message, code: $code)';
}

class MessageValidationError extends MessageState {
  final Map<String, String> errors;

  const MessageValidationError(this.errors);

  @override
  List<Object> get props => [errors];

  String? getError(String field) => errors[field];
  bool hasError(String field) => errors.containsKey(field);
  bool get hasErrors => errors.isNotEmpty;
}