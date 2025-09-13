// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderRole: json['senderRole'] as String,
      tourId: json['tourId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      priority: $enumDecode(_$MessagePriorityEnumMap, json['priority']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      readBy:
          (json['readBy'] as List<dynamic>).map((e) => e as String).toList(),
      dismissedBy: (json['dismissedBy'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderRole': instance.senderRole,
      'tourId': instance.tourId,
      'title': instance.title,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'priority': _$MessagePriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'readBy': instance.readBy,
      'dismissedBy': instance.dismissedBy,
      'metadata': instance.metadata,
    };

const _$MessageTypeEnumMap = {
  MessageType.broadcast: 'broadcast',
  MessageType.tourUpdate: 'tourUpdate',
  MessageType.announcement: 'announcement',
  MessageType.reminder: 'reminder',
  MessageType.alert: 'alert',
};

const _$MessagePriorityEnumMap = {
  MessagePriority.low: 'low',
  MessagePriority.normal: 'normal',
  MessagePriority.high: 'high',
  MessagePriority.urgent: 'urgent',
};

CreateMessageRequest _$CreateMessageRequestFromJson(
        Map<String, dynamic> json) =>
    CreateMessageRequest(
      tourId: json['tourId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      priority: $enumDecode(_$MessagePriorityEnumMap, json['priority']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreateMessageRequestToJson(
        CreateMessageRequest instance) =>
    <String, dynamic>{
      'tourId': instance.tourId,
      'title': instance.title,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'priority': _$MessagePriorityEnumMap[instance.priority]!,
      'metadata': instance.metadata,
    };

UpdateMessageRequest _$UpdateMessageRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateMessageRequest(
      title: json['title'] as String?,
      content: json['content'] as String?,
      priority: $enumDecodeNullable(_$MessagePriorityEnumMap, json['priority']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UpdateMessageRequestToJson(
        UpdateMessageRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'priority': _$MessagePriorityEnumMap[instance.priority],
      'metadata': instance.metadata,
    };

MessageSearchRequest _$MessageSearchRequestFromJson(
        Map<String, dynamic> json) =>
    MessageSearchRequest(
      query: json['query'] as String,
      tourId: json['tourId'] as String?,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']),
      priority: $enumDecodeNullable(_$MessagePriorityEnumMap, json['priority']),
      fromDate: json['fromDate'] == null
          ? null
          : DateTime.parse(json['fromDate'] as String),
      toDate: json['toDate'] == null
          ? null
          : DateTime.parse(json['toDate'] as String),
    );

Map<String, dynamic> _$MessageSearchRequestToJson(
        MessageSearchRequest instance) =>
    <String, dynamic>{
      'query': instance.query,
      'tourId': instance.tourId,
      'type': _$MessageTypeEnumMap[instance.type],
      'priority': _$MessagePriorityEnumMap[instance.priority],
      'fromDate': instance.fromDate?.toIso8601String(),
      'toDate': instance.toDate?.toIso8601String(),
    };
