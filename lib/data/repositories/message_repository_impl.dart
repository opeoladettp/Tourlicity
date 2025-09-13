import '../../core/network/api_client.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../models/message_model.dart';

class MessageRepositoryImpl implements MessageRepository {
  final ApiClient _apiClient;

  MessageRepositoryImpl(this._apiClient);

  @override
  Future<Message> sendBroadcastMessage({
    required String tourId,
    required String title,
    required String content,
    required MessageType type,
    required MessagePriority priority,
    Map<String, dynamic>? metadata,
  }) async {
    final request = CreateMessageRequest(
      tourId: tourId,
      title: title,
      content: content,
      type: type,
      priority: priority,
      metadata: metadata,
    );

    final response = await _apiClient.post(
      '/messages/broadcast',
      data: request.toJson(),
    );

    return MessageModel.fromJson(response.data).toEntity();
  }

  @override
  Future<Message> sendTourUpdate({
    required String tourId,
    required String title,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final request = CreateMessageRequest(
      tourId: tourId,
      title: title,
      content: content,
      type: MessageType.tourUpdate,
      priority: MessagePriority.high,
      metadata: metadata,
    );

    final response = await _apiClient.post(
      '/messages/tour-update',
      data: request.toJson(),
    );

    return MessageModel.fromJson(response.data).toEntity();
  }

  @override
  Future<List<Message>> getMessagesForTour(String tourId) async {
    final response = await _apiClient.get('/messages/tour/$tourId');
    
    final List<dynamic> messagesJson = response.data;
    return messagesJson
        .map((json) => MessageModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<Message>> getMessagesForUser(String userId) async {
    final response = await _apiClient.get('/messages/user/$userId');
    
    final List<dynamic> messagesJson = response.data;
    return messagesJson
        .map((json) => MessageModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<Message>> getUnreadMessages(String userId) async {
    final response = await _apiClient.get('/messages/user/$userId/unread');
    
    final List<dynamic> messagesJson = response.data;
    return messagesJson
        .map((json) => MessageModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> markMessageAsRead(String messageId, String userId) async {
    await _apiClient.patch(
      '/messages/$messageId/read',
      data: {'userId': userId},
    );
  }

  @override
  Future<void> markMessageAsDismissed(String messageId, String userId) async {
    await _apiClient.patch(
      '/messages/$messageId/dismiss',
      data: {'userId': userId},
    );
  }

  @override
  Future<void> markMultipleMessagesAsRead(
    List<String> messageIds,
    String userId,
  ) async {
    await _apiClient.patch(
      '/messages/bulk/read',
      data: {
        'messageIds': messageIds,
        'userId': userId,
      },
    );
  }

  @override
  Future<Message> getMessageById(String messageId) async {
    final response = await _apiClient.get('/messages/$messageId');
    return MessageModel.fromJson(response.data).toEntity();
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _apiClient.delete('/messages/$messageId');
  }

  @override
  Future<Message> updateMessage({
    required String messageId,
    String? title,
    String? content,
    MessagePriority? priority,
    Map<String, dynamic>? metadata,
  }) async {
    final request = UpdateMessageRequest(
      title: title,
      content: content,
      priority: priority,
      metadata: metadata,
    );

    final response = await _apiClient.patch(
      '/messages/$messageId',
      data: request.toJson(),
    );

    return MessageModel.fromJson(response.data).toEntity();
  }

  @override
  Future<Map<String, dynamic>> getMessageStatistics(String tourId) async {
    final response = await _apiClient.get('/messages/tour/$tourId/statistics');
    return response.data;
  }

  @override
  Future<List<Message>> searchMessages({
    required String query,
    String? tourId,
    MessageType? type,
    MessagePriority? priority,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final request = MessageSearchRequest(
      query: query,
      tourId: tourId,
      type: type,
      priority: priority,
      fromDate: fromDate,
      toDate: toDate,
    );

    final response = await _apiClient.post(
      '/messages/search',
      data: request.toJson(),
    );

    final List<dynamic> messagesJson = response.data;
    return messagesJson
        .map((json) => MessageModel.fromJson(json).toEntity())
        .toList();
  }
}