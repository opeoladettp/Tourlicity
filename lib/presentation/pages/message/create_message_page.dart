import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/message.dart';
import '../../blocs/message/message_bloc.dart';
import '../../blocs/message/message_event.dart';
import '../../blocs/message/message_state.dart';
import '../../widgets/common/loading_widget.dart';

class CreateMessagePage extends StatefulWidget {
  final String tourId;
  final String tourTitle;

  const CreateMessagePage({
    super.key,
    required this.tourId,
    required this.tourTitle,
  });

  @override
  State<CreateMessagePage> createState() => _CreateMessagePageState();
}

class _CreateMessagePageState extends State<CreateMessagePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  MessageType _selectedType = MessageType.broadcast;
  MessagePriority _selectedPriority = MessagePriority.normal;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<MessageBloc, MessageState>(
        listener: (context, state) {
          if (state is MessageSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Message sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is MessageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<MessageBloc, MessageState>(
          builder: (context, state) {
            if (state is MessageSending) {
              return const LoadingWidget(message: 'Sending message...');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tour Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tour,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sending to tour:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    widget.tourTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Message Type Selection
                    const Text(
                      'Message Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MessageType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: MessageType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(type.displayName),
                              Text(
                                type.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                            // Auto-set priority for certain types
                            if (value == MessageType.alert) {
                              _selectedPriority = MessagePriority.urgent;
                            } else if (value == MessageType.tourUpdate) {
                              _selectedPriority = MessagePriority.high;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Priority Selection
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MessagePriority>(
                      initialValue: _selectedPriority,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: MessagePriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Row(
                            children: [
                              _getPriorityIcon(priority),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(priority.displayName),
                                  Text(
                                    priority.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Title Field
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter message title...',
                        border: const OutlineInputBorder(),
                        errorText: state is MessageValidationError
                            ? state.getError('title')
                            : null,
                      ),
                      maxLength: 200,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        if (value.length > 200) {
                          return 'Title must be less than 200 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Content Field
                    const Text(
                      'Message Content',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message...',
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                        errorText: state is MessageValidationError
                            ? state.getError('content')
                            : null,
                      ),
                      maxLines: 6,
                      maxLength: 2000,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Message content is required';
                        }
                        if (value.length > 2000) {
                          return 'Content must be less than 2000 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Send Message',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getPriorityIcon(MessagePriority priority) {
    switch (priority) {
      case MessagePriority.low:
        return const Icon(Icons.keyboard_arrow_down, color: Colors.grey);
      case MessagePriority.normal:
        return const Icon(Icons.remove, color: Colors.blue);
      case MessagePriority.high:
        return const Icon(Icons.keyboard_arrow_up, color: Colors.orange);
      case MessagePriority.urgent:
        return const Icon(Icons.priority_high, color: Colors.red);
    }
  }

  void _sendMessage() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MessageBloc>().add(
            SendBroadcastMessage(
              tourId: widget.tourId,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              type: _selectedType,
              priority: _selectedPriority,
            ),
          );
    }
  }
}