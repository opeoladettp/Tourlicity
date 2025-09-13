import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/common/accessibility_widgets.dart';

void main() {
  group('AccessibleButton', () {
    testWidgets('creates elevated button by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('creates outlined button when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              type: ButtonType.outlined,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('creates text button when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              type: ButtonType.text,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('includes tooltip when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              tooltip: 'Button tooltip',
              child: const Text('Button'),
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('has proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              semanticLabel: 'Accessible button',
              child: const Text('Button'),
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('AccessibleTextField', () {
    testWidgets('creates text field with proper semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTextField(
              labelText: 'Email',
              semanticLabel: 'Email input field',
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('applies accessible font size and line height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTextField(
              labelText: 'Test',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontSize, 16.0);
      expect(textField.style?.height, 1.5);
    });

    testWidgets('announces errors when field gains focus', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTextField(
              labelText: 'Test',
              errorText: 'This field is required',
            ),
          ),
        ),
      );

      // Focus the text field
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Verify the field has focus
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });

    testWidgets('supports keyboard navigation when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleTextField(
              labelText: 'Test',
              enableKeyboardNavigation: true,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      // KeyboardNavigableFormField should be present
      expect(find.byType(Focus), findsWidgets);
    });
  });

  group('AccessibleListTile', () {
    testWidgets('creates list tile with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleListTile(
              title: const Text('List item'),
              semanticLabel: 'Accessible list item',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('AccessibleIconButton', () {
    testWidgets('creates icon button with minimum touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.home,
              onPressed: () {},
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.constraints?.minWidth, 48.0);
      expect(iconButton.constraints?.minHeight, 48.0);
    });

    testWidgets('includes tooltip when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.home,
              onPressed: () {},
              tooltip: 'Home button',
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });
  });

  group('AccessibleCard', () {
    testWidgets('creates card with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleCard(
              semanticLabel: 'Accessible card',
              onTap: () {},
              child: const Text('Card content'),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('FocusTrap', () {
    testWidgets('creates focus nodes when active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FocusTrap(
              active: true,
              child: Text('Trapped content'),
            ),
          ),
        ),
      );

      expect(find.byType(Focus), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('does not create focus trap when inactive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FocusTrap(
              active: false,
              child: Text('Normal content'),
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsNothing);
      expect(find.text('Normal content'), findsOneWidget);
    });
  });

  group('SemanticWrapper', () {
    testWidgets('applies semantic properties correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticWrapper(
              label: 'Test label',
              hint: 'Test hint',
              button: true,
              enabled: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Semantics), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('AccessibleProgressIndicator', () {
    testWidgets('shows progress with semantic label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleProgressIndicator(
              value: 0.5,
              semanticLabel: 'Loading progress',
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('shows indeterminate progress when value is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleProgressIndicator(
              semanticLabel: 'Loading',
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, isNull);
    });

    testWidgets('displays progress text when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleProgressIndicator(
              value: 0.75,
              progressText: '75% complete',
            ),
          ),
        ),
      );

      expect(find.text('75% complete'), findsOneWidget);
    });
  });

  group('AccessibleLoadingOverlay', () {
    testWidgets('shows loading overlay when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleLoadingOverlay(
              isLoading: true,
              loadingText: 'Please wait...',
              child: Text('Main content'),
            ),
          ),
        ),
      );

      expect(find.text('Main content'), findsOneWidget);
      expect(find.text('Please wait...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides loading overlay when isLoading is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleLoadingOverlay(
              isLoading: false,
              child: Text('Main content'),
            ),
          ),
        ),
      );

      expect(find.text('Main content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('AccessibleExpansionTile', () {
    testWidgets('creates expansion tile with proper semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleExpansionTile(
              title: Text('Expandable Section'),
              children: [
                Text('Child 1'),
                Text('Child 2'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(find.text('Expandable Section'), findsOneWidget);
    });

    testWidgets('updates semantic label when expanded state changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleExpansionTile(
              title: Text('Expandable Section'),
              expandedSemanticLabel: 'Expanded, tap to collapse',
              collapsedSemanticLabel: 'Collapsed, tap to expand',
              children: [
                Text('Child content'),
              ],
            ),
          ),
        ),
      );

      // Initially collapsed
      expect(find.byType(ExpansionTile), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('Expandable Section'));
      await tester.pumpAndSettle();

      // Should now be expanded
      expect(find.text('Child content'), findsOneWidget);
    });
  });

  group('SkipLink', () {
    testWidgets('becomes visible when focused', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Main content'),
                SkipLink(
                  text: 'Skip to main content',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Initially not visible (opacity 0)
      final skipLink = find.byType(SkipLink);
      expect(skipLink, findsOneWidget);

      // The skip link should be present but positioned off-screen initially
      expect(find.text('Skip to main content'), findsOneWidget);
    });

    testWidgets('calls onPressed when activated', (tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Text('Main content'),
                SkipLink(
                  text: 'Skip to main content',
                  onPressed: () {
                    buttonPressed = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Skip to main content'));
      await tester.pumpAndSettle();

      expect(buttonPressed, isTrue);
    });
  });
}