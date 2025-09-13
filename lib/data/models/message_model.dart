import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/message.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.tourId,
    required super.title,
    required super.content,
    required super.type,
    required super.priority,
    required super.createdAt,
    super.updatedAt,
    required super.readBy,
    required super.dismissedBy,
    super.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      senderId: message.senderId,
      senderName: message.senderName,
      senderRole: message.senderRole,
      tourId: message.tourId,
      title: message.title,
      content: message.content,
      type: message.type,
      priority: message.priority,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
      readBy: message.readBy,
      dismissedBy: message.dismissedBy,
      metadata: message.metadata,
    );
  }

  Message toEntity() {
    return Message(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      tourId: tourId,
      title: title,
      content: content,
      type: type,
      priority: priority,
      createdAt: createdAt,
      updatedAt: updatedAt,
      readBy: readBy,
      dismissedBy: dismissedBy,
      metadata: metadata,
    );
  }

  @override
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? tourId,
    String? title,
    String? content,
    MessageType? type,
    MessagePriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? readBy,
    List<String>? dismissedBy,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      tourId: tourId ?? this.tourId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readBy: readBy ?? this.readBy,
      dismissedBy: dismissedBy ?? this.dismissedBy,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class CreateMessageRequest {
  final String tourId;
  final String title;
  final String content;
  final MessageType type;
  final MessagePriority priority;
  final Map<String, dynamic>? metadata;

  const CreateMessageRequest({
    required this.tourId,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    this.metadata,
  });

  factory CreateMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMessageRequestToJson(this);
}

@JsonSerializable()
class UpdateMessageRequest {
  final String? title;
  final String? content;
  final MessagePriority? priority;
  final Map<String, dynamic>? metadata;

  const UpdateMessageRequest({
    this.title,
    this.content,
    this.priority,
    this.metadata,
  });

  factory UpdateMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMessageRequestToJson(this);
}

@JsonSerializable()
class MessageSearchRequest {
  final String query;
  final String? tourId;
  final MessageType? type;
  final MessagePriority? priority;
  final DateTime? fromDate;
  final DateTime? toDate;

  const MessageSearchRequest({
    required this.query,
    this.tourId,
    this.type,
    this.priority,
    this.fromDate,
    this.toDate,
  });

  factory MessageSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageSearchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MessageSearchRequestToJson(this);
}