import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tourlicity_app/core/network/api_client.dart';
import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/data/repositories/message_repository_impl.dart';
import 'package:tourlicity_app/domain/entities/message.dart';

class MockApiClient extends Mock implements ApiClient {
  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#get, [path], {
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future.value(ApiSuccess<T>(data: {} as T)),
      );

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#post, [path], {
          #data: data,
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future.value(ApiSuccess<T>(data: {} as T)),
      );

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#patch, [path], {
          #data: data,
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future.value(ApiSuccess<T>(data: {} as T)),
      );

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#delete, [path], {
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future.value(ApiSuccess<T>(data: {} as T)),
      );
}

void main() {
  late MessageRepositoryImpl repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = MessageRepositoryImpl(mockApiClient);
  });

  group('MessageRepositoryImpl', () {
    final testMessageData = {
      'id': 'message-1',
      'senderId': 'sender-1',
      'senderName': 'John Doe',
      'senderRole': 'Provider',
      'tourId': 'tour-1',
      'title': 'Test Message',
      'content': 'This is a test message',
      'type': 'broadcast',
      'priority': 'normal',
      'createdAt': DateTime.now().toIso8601String(),
      'readBy': <String>[],
      'dismissedBy': <String>[],
    };

    group('sendBroadcastMessage', () {
      test('should send broadcast message successfully', () async {
        // Arrange
        when(mockApiClient.post('/messages/broadcast', data: any))
            .thenAnswer((_) async => ApiSuccess(data: testMessageData));

        // Act
        final result = await repository.sendBroadcastMessage(
          tourId: "tour1", 
          title: "Test", 
          content: "Test message", 
          type: MessageType.broadcast, 
          priority: MessagePriority.normal
        );

        // Assert
        expect(result, isA<Message>());
        expect(result.title, 'Test Message');
        expect(result.type, MessageType.broadcast);
        verify(mockApiClient.post('/messages/broadcast', data: any));
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(mockApiClient.post('/messages/broadcast', data: any))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.sendBroadcastMessage(
            tourId: "tour1", 
            title: "Test", 
            content: "Test message", 
            type: MessageType.broadcast, 
            priority: MessagePriority.normal
          ),
          throwsException,
        );
      });
    });

    group('getMessagesForTour', () {
      test('should get messages for tour successfully', () async {
        // Arrange
        final messages = [testMessageData];
        when(mockApiClient.get('/messages/tour/tour-1'))
            .thenAnswer((_) async => ApiSuccess(data: messages));

        // Act
        final result = await repository.getMessagesForTour('tour-1');

        // Assert
        expect(result, isA<List<Message>>());
        expect(result.length, 1);
        expect(result.first.tourId, 'tour-1');
        verify(mockApiClient.get('/messages/tour/tour-1'));
      });

      test('should return empty list when no messages found', () async {
        // Arrange
        when(mockApiClient.get('/messages/tour/tour-1'))
            .thenAnswer((_) async => const ApiSuccess(data: []));

        // Act
        final result = await repository.getMessagesForTour('tour-1');

        // Assert
        expect(result, isEmpty);
      });
    });

    group('markMessageAsRead', () {
      test('should mark message as read successfully', () async {
        // Arrange
        when(mockApiClient.patch('/messages/message-1/read', data: any))
            .thenAnswer((_) async => const ApiSuccess(data: {}));

        // Act
        await repository.markMessageAsRead('message-1', 'user-1');

        // Assert
        verify(mockApiClient.patch('/messages/message-1/read', data: any));
      });
    });

    group('deleteMessage', () {
      test('should delete message successfully', () async {
        // Arrange
        when(mockApiClient.delete('/messages/message-1'))
            .thenAnswer((_) async => const ApiSuccess(data: {}));

        // Act
        await repository.deleteMessage("message-1");

        // Assert
        verify(mockApiClient.delete('/messages/message-1'));
      });
    });
  });
}