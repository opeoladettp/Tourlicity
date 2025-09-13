import 'package:equatable/equatable.dart';
import '../../../domain/entities/message.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessagesForTour extends MessageEvent {
  final String tourId;

  const LoadMessagesForTour(this.tourId);

  @override
  List<Object> get props => [tourId];
}

class LoadMessagesForUser extends MessageEvent {
  final String userId;

  const LoadMessagesForUser(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadUnreadMessages extends MessageEvent {
  final String userId;

  const LoadUnreadMessages(this.userId);

  @override
  List<Object> get props => [userId];
}

class SendBroadcastMessage extends MessageEvent {
  final String tourId;
  final String title;
  final String content;
  final MessageType type;
  final MessagePriority priority;
  final Map<String, dynamic>? metadata;

  const SendBroadcastMessage({
    required this.tourId,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    this.metadata,
  });

  @override
  List<Object?> get props => [tourId, title, content, type, priority, metadata];
}

class SendTourUpdate extends MessageEvent {
  final String tourId;
  final String title;
  final String content;
  final Map<String, dynamic>? metadata;

  const SendTourUpdate({
    required this.tourId,
    required this.title,
    required this.content,
    this.metadata,
  });

  @override
  List<Object?> get props => [tourId, title, content, metadata];
}

class MarkMessageAsRead extends MessageEvent {
  final String messageId;
  final String userId;

  const MarkMessageAsRead({
    required this.messageId,
    required this.userId,
  });

  @override
  List<Object> get props => [messageId, userId];
}

class MarkMessageAsDismissed extends MessageEvent {
  final String messageId;
  final String userId;

  const MarkMessageAsDismissed({
    required this.messageId,
    required this.userId,
  });

  @override
  List<Object> get props => [messageId, userId];
}

class MarkMultipleMessagesAsRead extends MessageEvent {
  final List<String> messageIds;
  final String userId;

  const MarkMultipleMessagesAsRead({
    required this.messageIds,
    required this.userId,
  });

  @override
  List<Object> get props => [messageIds, userId];
}

class UpdateMessage extends MessageEvent {
  final String messageId;
  final String? title;
  final String? content;
  final MessagePriority? priority;
  final Map<String, dynamic>? metadata;

  const UpdateMessage({
    required this.messageId,
    this.title,
    this.content,
    this.priority,
    this.metadata,
  });

  @override
  List<Object?> get props => [messageId, title, content, priority, metadata];
}

class DeleteMessage extends MessageEvent {
  final String messageId;

  const DeleteMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class SearchMessages extends MessageEvent {
  final String query;
  final String? tourId;
  final MessageType? type;
  final MessagePriority? priority;
  final DateTime? fromDate;
  final DateTime? toDate;

  const SearchMessages({
    required this.query,
    this.tourId,
    this.type,
    this.priority,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [query, tourId, type, priority, fromDate, toDate];
}

class LoadMessageStatistics extends MessageEvent {
  final String tourId;

  const LoadMessageStatistics(this.tourId);

  @override
  List<Object> get props => [tourId];
}

class RefreshMessages extends MessageEvent {
  const RefreshMessages();
}

class ClearMessageError extends MessageEvent {
  const ClearMessageError();
}