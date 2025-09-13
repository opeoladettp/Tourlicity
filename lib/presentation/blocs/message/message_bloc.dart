import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/message_repository.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _messageRepository;

  MessageBloc(this._messageRepository) : super(const MessageInitial()) {
    on<LoadMessagesForTour>(_onLoadMessagesForTour);
    on<LoadMessagesForUser>(_onLoadMessagesForUser);
    on<LoadUnreadMessages>(_onLoadUnreadMessages);
    on<SendBroadcastMessage>(_onSendBroadcastMessage);
    on<SendTourUpdate>(_onSendTourUpdate);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);
    on<MarkMessageAsDismissed>(_onMarkMessageAsDismissed);
    on<MarkMultipleMessagesAsRead>(_onMarkMultipleMessagesAsRead);
    on<UpdateMessage>(_onUpdateMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<SearchMessages>(_onSearchMessages);
    on<LoadMessageStatistics>(_onLoadMessageStatistics);
    on<RefreshMessages>(_onRefreshMessages);
    on<ClearMessageError>(_onClearMessageError);
  }

  Future<void> _onLoadMessagesForTour(
    LoadMessagesForTour event,
    Emitter<MessageState> emit,
  ) async {
    emit(const MessageLoading());
    try {
      final messages =
          await _messageRepository.getMessagesForTour(event.tourId);
      emit(MessagesLoaded(messages: messages));
    } catch (e) {
      emit(MessageError(message: 'Failed to load messages: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMessagesForUser(
    LoadMessagesForUser event,
    Emitter<MessageState> emit,
  ) async {
    emit(const MessageLoading());
    try {
      final messages =
          await _messageRepository.getMessagesForUser(event.userId);
      emit(MessagesLoaded(messages: messages));
    } catch (e) {
      emit(MessageError(message: 'Failed to load messages: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUnreadMessages(
    LoadUnreadMessages event,
    Emitter<MessageState> emit,
  ) async {
    emit(const MessageLoading());
    try {
      final messages = await _messageRepository.getUnreadMessages(event.userId);
      emit(MessagesLoaded(messages: messages));
    } catch (e) {
      emit(MessageError(
          message: 'Failed to load unread messages: ${e.toString()}'));
    }
  }

  Future<void> _onSendBroadcastMessage(
    SendBroadcastMessage event,
    Emitter<MessageState> emit,
  ) async {
    // Validate input
    final validationErrors = _validateMessageInput(
      title: event.title,
      content: event.content,
    );

    if (validationErrors.isNotEmpty) {
      emit(MessageValidationError(validationErrors));
      return;
    }

    emit(const MessageSending());
    try {
      final message = await _messageRepository.sendBroadcastMessage(
        tourId: event.tourId,
        title: event.title,
        content: event.content,
        type: event.type,
        priority: event.priority,
        metadata: event.metadata,
      );
      emit(MessageSent(message));
    } catch (e) {
      emit(MessageError(message: 'Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onSendTourUpdate(
    SendTourUpdate event,
    Emitter<MessageState> emit,
  ) async {
    // Validate input
    final validationErrors = _validateMessageInput(
      title: event.title,
      content: event.content,
    );

    if (validationErrors.isNotEmpty) {
      emit(MessageValidationError(validationErrors));
      return;
    }

    emit(const MessageSending());
    try {
      final message = await _messageRepository.sendTourUpdate(
        tourId: event.tourId,
        title: event.title,
        content: event.content,
        metadata: event.metadata,
      );
      emit(MessageSent(message));
    } catch (e) {
      emit(
          MessageError(message: 'Failed to send tour update: ${e.toString()}'));
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _messageRepository.markMessageAsRead(event.messageId, event.userId);
      emit(MessageMarkedAsRead(
        messageId: event.messageId,
        userId: event.userId,
      ));
    } catch (e) {
      emit(MessageError(
          message: 'Failed to mark message as read: ${e.toString()}'));
    }
  }

  Future<void> _onMarkMessageAsDismissed(
    MarkMessageAsDismissed event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _messageRepository.markMessageAsDismissed(
          event.messageId, event.userId);
      emit(MessageMarkedAsDismissed(
        messageId: event.messageId,
        userId: event.userId,
      ));
    } catch (e) {
      emit(MessageError(message: 'Failed to dismiss message: ${e.toString()}'));
    }
  }

  Future<void> _onMarkMultipleMessagesAsRead(
    MarkMultipleMessagesAsRead event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _messageRepository.markMultipleMessagesAsRead(
        event.messageIds,
        event.userId,
      );
      emit(MultipleMessagesMarkedAsRead(
        messageIds: event.messageIds,
        userId: event.userId,
      ));
    } catch (e) {
      emit(MessageError(
          message: 'Failed to mark messages as read: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateMessage(
    UpdateMessage event,
    Emitter<MessageState> emit,
  ) async {
    // Validate input if title or content is being updated
    if (event.title != null || event.content != null) {
      final validationErrors = _validateMessageInput(
        title: event.title,
        content: event.content,
      );

      if (validationErrors.isNotEmpty) {
        emit(MessageValidationError(validationErrors));
        return;
      }
    }

    try {
      final message = await _messageRepository.updateMessage(
        messageId: event.messageId,
        title: event.title,
        content: event.content,
        priority: event.priority,
        metadata: event.metadata,
      );
      emit(MessageUpdated(message));
    } catch (e) {
      emit(MessageError(message: 'Failed to update message: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _messageRepository.deleteMessage(event.messageId);
      emit(MessageDeleted(event.messageId));
    } catch (e) {
      emit(MessageError(message: 'Failed to delete message: ${e.toString()}'));
    }
  }

  Future<void> _onSearchMessages(
    SearchMessages event,
    Emitter<MessageState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const MessageValidationError(
          {'query': 'Search query cannot be empty'}));
      return;
    }

    emit(const MessageLoading());
    try {
      final results = await _messageRepository.searchMessages(
        query: event.query,
        tourId: event.tourId,
        type: event.type,
        priority: event.priority,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
      emit(MessageSearchResults(results: results, query: event.query));
    } catch (e) {
      emit(MessageError(message: 'Failed to search messages: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMessageStatistics(
    LoadMessageStatistics event,
    Emitter<MessageState> emit,
  ) async {
    try {
      final statistics =
          await _messageRepository.getMessageStatistics(event.tourId);
      emit(MessageStatisticsLoaded(
        statistics: statistics,
        tourId: event.tourId,
      ));
    } catch (e) {
      emit(MessageError(message: 'Failed to load statistics: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<MessageState> emit,
  ) async {
    // Refresh based on current state
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      // Re-emit loading and reload messages
      emit(const MessageLoading());
      // This would need context about which messages to reload
      // For now, we'll just re-emit the current state
      emit(currentState);
    }
  }

  void _onClearMessageError(
    ClearMessageError event,
    Emitter<MessageState> emit,
  ) {
    if (state is MessageError || state is MessageValidationError) {
      emit(const MessageInitial());
    }
  }

  Map<String, String> _validateMessageInput({
    String? title,
    String? content,
  }) {
    final errors = <String, String>{};

    if (title != null) {
      if (title.trim().isEmpty) {
        errors['title'] = 'Title is required';
      } else if (title.length > 200) {
        errors['title'] = 'Title must be less than 200 characters';
      }
    }

    if (content != null) {
      if (content.trim().isEmpty) {
        errors['content'] = 'Content is required';
      } else if (content.length > 2000) {
        errors['content'] = 'Content must be less than 2000 characters';
      }
    }

    return errors;
  }
}
