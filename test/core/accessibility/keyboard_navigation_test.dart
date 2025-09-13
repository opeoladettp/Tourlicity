import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/accessibility/keyboard_navigation.dart';

void main() {
  group('KeyboardNavigationService', () {
    late KeyboardNavigationService service;

    setUp(() {
      service = KeyboardNavigationService();
      service.clear(); // Clear any existing focus nodes
    });

    tearDown(() {
      service.clear();
    });

    test('registers and unregisters focus nodes', () {
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();

      service.registerFocusNode(focusNode1);
      service.registerFocusNode(focusNode2);

      // Should not register the same node twice
      service.registerFocusNode(focusNode1);

      service.unregisterFocusNode(focusNode1);
      service.unregisterFocusNode(focusNode2);

      focusNode1.dispose();
      focusNode2.dispose();
    });

    test('handles focus navigation with empty list', () {
      // Should not throw when no focus nodes are registered
      service.focusNext();
      service.focusPrevious();
    });
  });

  group('KeyboardNavigationWrapper', () {
    testWidgets('handles tab navigation shortcuts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardNavigationWrapper(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Field 1'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Field 2'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Focus first field
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      // Press Tab to move to next field
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Press Shift+Tab to move to previous field
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();
    });

    testWidgets('handles arrow navigation when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardNavigationWrapper(
              enableArrowNavigation: true,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Field 1'),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Field 2'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Focus first field
      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      // Press arrow down to move to next field
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press arrow up to move to previous field
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
    });

    testWidgets('handles escape key when callback provided', (tester) async {
      bool escapePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardNavigationWrapper(
              onEscape: () {
                escapePressed = true;
              },
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(escapePressed, isTrue);
    });
  });

  group('KeyboardNavigableFormField', () {
    testWidgets('auto-registers focus node when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardNavigableFormField(
              autoRegister: true,
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Test Field'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Focus), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('does not auto-register when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardNavigableFormField(
              autoRegister: false,
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Test Field'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Focus), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });

  group('KeyboardShortcuts', () {
    testWidgets('handles save shortcut (Ctrl+S)', (tester) async {
      bool savePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardShortcuts(
              onSave: () {
                savePressed = true;
              },
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      expect(savePressed, isTrue);
    });

    testWidgets('handles cancel shortcut (Escape)', (tester) async {
      bool cancelPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardShortcuts(
              onCancel: () {
                cancelPressed = true;
              },
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(cancelPressed, isTrue);
    });

    testWidgets('handles submit shortcut (Ctrl+Enter)', (tester) async {
      bool submitPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardShortcuts(
              onSubmit: () {
                submitPressed = true;
              },
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      expect(submitPressed, isTrue);
    });

    testWidgets('handles refresh shortcut (F5)', (tester) async {
      bool refreshPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardShortcuts(
              onRefresh: () {
                refreshPressed = true;
              },
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.f5);
      await tester.pumpAndSettle();

      expect(refreshPressed, isTrue);
    });

    testWidgets('handles search shortcut (Ctrl+F)', (tester) async {
      bool searchPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardShortcuts(
              onSearch: () {
                searchPressed = true;
              },
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.pumpAndSettle();

      expect(searchPressed, isTrue);
    });
  });

  group('AccessibleFocusScope', () {
    testWidgets('creates focus scope with autofocus', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleFocusScope(
              autofocus: true,
              debugLabel: 'Test Scope',
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(FocusScope), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('uses provided focus node', (tester) async {
      final focusNode = FocusNode(debugLabel: 'Custom Node');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleFocusScope(
              focusNode: focusNode,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(FocusScope), findsOneWidget);
      
      focusNode.dispose();
    });
  });
}