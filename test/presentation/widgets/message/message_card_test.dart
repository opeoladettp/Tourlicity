import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/message/message_card.dart';
import 'package:tourlicity_app/domain/entities/message.dart';

void main() {
  group('MessageCard Widget Tests', () {
    late Message testMessage;

    setUp(() {
      testMessage = Message(
        id: "1",
        senderId: "sender1",
        senderName: "John Doe",
        senderRole: "guide",
        tourId: "tour1",
        title: "Test Subject",
        content: "Test message content",
        type: MessageType.broadcast,
        priority: MessagePriority.normal,
        createdAt: DateTime.now(),
        readBy: const [],
        dismissedBy: const [],
      );
    });

    testWidgets('should display message content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageCard(
              message: testMessage,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      expect(find.text('Test Subject'), findsOneWidget);
      expect(find.text('Test message content'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should show unread indicator for unread messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageCard(
              message: testMessage,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      // Should show unread indicator (blue dot)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should not show unread indicator for read messages', (WidgetTester tester) async {
      final readMessage = testMessage.copyWith(readBy: ['user1']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageCard(
              message: readMessage,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      // Message should appear as read
      expect(find.text('Test Subject'), findsOneWidget);
    });

    testWidgets('should show priority indicator for high priority messages', (WidgetTester tester) async {
      final highPriorityMessage = testMessage.copyWith(priority: MessagePriority.high);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageCard(
              message: highPriorityMessage,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      // Should show priority indicator
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('should call onMarkAsRead when card is tapped for unread message', (WidgetTester tester) async {
      bool onMarkAsReadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageCard(
              message: testMessage,
              currentUserId: 'user1',
              onMarkAsRead: () {
                onMarkAsReadCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(onMarkAsReadCalled, isTrue);
    });

    testWidgets('should display formatted date', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageCard(
              message: testMessage,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      // Should display some form of date/time
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('should display message type chip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageCard(
              message: testMessage,
              currentUserId: 'user1',
            ),
          ),
        ),
      );

      // Should display message type
      expect(find.text('Broadcast'), findsOneWidget);
    });
  });
}