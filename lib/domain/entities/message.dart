class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String tourId;
  final String title;
  final String content;
  final MessageType type;
  final MessagePriority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> readBy;
  final List<String> dismissedBy;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.tourId,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    required this.readBy,
    required this.dismissedBy,
    this.metadata,
  });

  Message copyWith({
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
    return Message(
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

  bool isReadBy(String userId) => readBy.contains(userId);
  bool isDismissedBy(String userId) => dismissedBy.contains(userId);
  bool isUnreadBy(String userId) => !readBy.contains(userId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message(id: $id, title: $title, type: $type, priority: $priority)';
  }
}

enum MessageType {
  broadcast,
  tourUpdate,
  announcement,
  reminder,
  alert,
}

enum MessagePriority {
  low,
  normal,
  high,
  urgent,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.broadcast:
        return 'Broadcast';
      case MessageType.tourUpdate:
        return 'Tour Update';
      case MessageType.announcement:
        return 'Announcement';
      case MessageType.reminder:
        return 'Reminder';
      case MessageType.alert:
        return 'Alert';
    }
  }

  String get description {
    switch (this) {
      case MessageType.broadcast:
        return 'General message to all tour participants';
      case MessageType.tourUpdate:
        return 'Important update about tour details';
      case MessageType.announcement:
        return 'Official announcement from tour provider';
      case MessageType.reminder:
        return 'Reminder about tour requirements or deadlines';
      case MessageType.alert:
        return 'Urgent alert requiring immediate attention';
    }
  }
}

extension MessagePriorityExtension on MessagePriority {
  String get displayName {
    switch (this) {
      case MessagePriority.low:
        return 'Low';
      case MessagePriority.normal:
        return 'Normal';
      case MessagePriority.high:
        return 'High';
      case MessagePriority.urgent:
        return 'Urgent';
    }
  }

  String get description {
    switch (this) {
      case MessagePriority.low:
        return 'Low priority - can be read when convenient';
      case MessagePriority.normal:
        return 'Normal priority - standard message';
      case MessagePriority.high:
        return 'High priority - should be read soon';
      case MessagePriority.urgent:
        return 'Urgent - requires immediate attention';
    }
  }
}