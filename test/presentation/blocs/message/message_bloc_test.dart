import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/presentation/blocs/message/message_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/message/message_event.dart';
import 'package:tourlicity_app/presentation/blocs/message/message_state.dart';
import 'package:tourlicity_app/domain/repositories/message_repository.dart';
import 'package:tourlicity_app/domain/entities/message.dart';

import 'message_bloc_test.mocks.dart';

@GenerateMocks([MessageRepository])
void main() {
  late MessageBloc messageBloc;
  late MockMessageRepository mockRepository;

  setUp(() {
    mockRepository = MockMessageRepository();
    messageBloc = MessageBloc(mockRepository);
  });

  tearDown(() {
    messageBloc.close();
  });

  group('MessageBloc', () {
    test('initial state is MessageInitial', () {
      expect(messageBloc.state, isA<MessageInitial>());
    });

    group('LoadMessagesForUser', () {
      blocTest<MessageBloc, MessageState>(
        'emits [MessageLoading, MessagesLoaded] when successful',
        build: () {
          when(mockRepository.getMessagesForUser(any))
              .thenAnswer((_) async => <Message>[]);
          return messageBloc;
        },
        act: (bloc) => bloc.add(const LoadMessagesForUser('user1')),
        expect: () => [
          isA<MessageLoading>(),
          isA<MessagesLoaded>(),
        ],
      );

      blocTest<MessageBloc, MessageState>(
        'emits [MessageLoading, MessageError] when fails',
        build: () {
          when(mockRepository.getMessagesForUser(any))
              .thenThrow(Exception('Error'));
          return messageBloc;
        },
        act: (bloc) => bloc.add(const LoadMessagesForUser('user1')),
        expect: () => [
          isA<MessageLoading>(),
          isA<MessageError>(),
        ],
      );
    });

    group('SendBroadcastMessage', () {
      blocTest<MessageBloc, MessageState>(
        'emits [MessageSending, MessageSent] when successful',
        build: () {
          final message = Message(
            id: "1",
            senderId: "sender1",
            senderName: "Test Sender",
            senderRole: "guide",
            tourId: "tour1",
            title: "Test",
            content: "Test message",
            type: MessageType.broadcast,
            priority: MessagePriority.normal,
            createdAt: DateTime.now(),
            readBy: const [],
            dismissedBy: const [],
          );
          when(mockRepository.sendBroadcastMessage(
            tourId: anyNamed('tourId'),
            title: anyNamed('title'),
            content: anyNamed('content'),
            type: anyNamed('type'),
            priority: anyNamed('priority'),
            metadata: anyNamed('metadata'),
          )).thenAnswer((_) async => message);
          return messageBloc;
        },
        act: (bloc) => bloc.add(const SendBroadcastMessage(
          tourId: "tour1",
          title: "Test",
          content: "Test message",
          type: MessageType.broadcast,
          priority: MessagePriority.normal,
        )),
        expect: () => [
          isA<MessageSending>(),
          isA<MessageSent>(),
        ],
      );
    });

    group('MarkMessageAsRead', () {
      blocTest<MessageBloc, MessageState>(
        'emits [MessageMarkedAsRead] when successful',
        build: () {
          when(mockRepository.markMessageAsRead(any, any))
              .thenAnswer((_) async {});
          return messageBloc;
        },
        act: (bloc) => bloc.add(const MarkMessageAsRead(
          messageId: '1',
          userId: 'user1',
        )),
        expect: () => [
          isA<MessageMarkedAsRead>(),
        ],
      );
    });

    group('DeleteMessage', () {
      blocTest<MessageBloc, MessageState>(
        'emits [MessageDeleted] when successful',
        build: () {
          when(mockRepository.deleteMessage(any))
              .thenAnswer((_) async {});
          return messageBloc;
        },
        act: (bloc) => bloc.add(const DeleteMessage('1')),
        expect: () => [
          isA<MessageDeleted>(),
        ],
      );
    });
  });
}