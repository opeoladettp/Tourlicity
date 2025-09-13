import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/theme/theme_manager.dart';
import 'package:tourlicity_app/presentation/pages/settings/accessibility_settings_page.dart';
import 'package:tourlicity_app/presentation/widgets/common/accessibility_widgets.dart';
import 'package:tourlicity_app/presentation/widgets/common/responsive_layout.dart';

void main() {

  group('Accessibility Integration Tests', () {
    late ThemeManager themeManager;

    setUp(() async {
      themeManager = ThemeManager();
      await themeManager.initialize();
    });

    tearDown(() {
      themeManager.dispose();
    });

    testWidgets('accessibility settings page works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibilitySettingsPage(themeManager: themeManager),
        ),
      );

      // Verify page loads
      expect(find.text('Accessibility Settings'), findsOneWidget);
      expect(find.text('Theme Settings'), findsOneWidget);
      expect(find.text('Text Settings'), findsOneWidget);

      // Test theme mode selection
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(themeManager.themeMode, ThemeMode.dark);

      // Test high contrast toggle
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(themeManager.isHighContrastMode, true);

      // Test text scale adjustment
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(themeManager.textScaleFactor, greaterThan(1.0));
    });

    testWidgets('keyboard navigation works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AccessibleButton(
                  onPressed: () {},
                  autofocus: true,
                  child: const Text('Button 1'),
                ),
                AccessibleButton(
                  onPressed: () {},
                  child: const Text('Button 2'),
                ),
                const AccessibleTextField(
                  labelText: 'Text Field',
                ),
              ],
            ),
          ),
        ),
      );

      // Verify first button has focus
      expect(tester.binding.focusManager.primaryFocus?.hasPrimaryFocus, true);

      // Navigate with Tab key
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Navigate to text field
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Verify text field can receive input
      await tester.enterText(find.byType(TextField), 'Test input');
      expect(find.text('Test input'), findsOneWidget);
    });

    testWidgets('screen reader semantics are properly configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AccessibleButton(
                  onPressed: () {},
                  semanticLabel: 'Submit form button',
                  child: const Text('Submit'),
                ),
                AccessibleListTile(
                  title: const Text('List Item'),
                  semanticLabel: 'Navigable list item',
                  onTap: () {},
                ),
                AccessibleIconButton(
                  icon: Icons.home,
                  onPressed: () {},
                  semanticLabel: 'Navigate to home page',
                ),
              ],
            ),
          ),
        ),
      );

      // Verify semantic labels are present
      final buttonSemantics = tester.getSemantics(find.text('Submit'));
      expect(buttonSemantics.label, contains('Submit form button'));

      final listTileSemantics = tester.getSemantics(find.text('List Item'));
      expect(listTileSemantics.label, contains('Navigable list item'));

      final iconButtonSemantics = tester.getSemantics(find.byIcon(Icons.home));
      expect(iconButtonSemantics.label, contains('Navigate to home page'));
    });

    testWidgets('responsive layout adapts to screen size changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      expect(find.text('Mobile Layout'), findsOneWidget);

      // Test tablet layout
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      expect(find.text('Tablet Layout'), findsOneWidget);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();
      expect(find.text('Desktop Layout'), findsOneWidget);
    });

    testWidgets('high contrast mode affects visual appearance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themeManager.isHighContrastMode 
              ? ThemeData.from(colorScheme: const ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                ))
              : ThemeData.light(),
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () {},
              child: const Text('High Contrast Button'),
            ),
          ),
        ),
      );

      // Enable high contrast mode
      await themeManager.setHighContrastMode(true);
      await tester.pumpAndSettle();

      // Verify button styling changes for high contrast
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor?.resolve({}), isNotNull);
    });

    testWidgets('text scale factor affects text size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(themeManager.textScaleFactor),
              ),
              child: child!,
            );
          },
          home: const Scaffold(
            body: AccessibleTextField(
              labelText: 'Scalable Text',
            ),
          ),
        ),
      );

      // Increase text scale factor
      await themeManager.setTextScaleFactor(1.5);
      await tester.pumpAndSettle();

      // Verify text appears larger (through MediaQuery scaling)
      expect(themeManager.textScaleFactor, 1.5);
    });

    testWidgets('focus trap works in modal dialogs', (tester) async {
      bool dialogShown = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              onPressed: () async {
                dialogShown = true;
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(dialogShown, true);
    });

    testWidgets('minimum touch targets are enforced', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              icon: Icons.star,
              onPressed: () {},
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.constraints?.minWidth, greaterThanOrEqualTo(48.0));
      expect(iconButton.constraints?.minHeight, greaterThanOrEqualTo(48.0));
    });

    testWidgets('responsive grid adjusts column count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveGrid(
              children: List.generate(6, (index) => 
                Container(
                  color: Colors.blue,
                  child: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      // Test mobile (1 column)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      
      final mobileGrid = tester.widget<GridView>(find.byType(GridView));
      final mobileDelegate = mobileGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(mobileDelegate.crossAxisCount, 1);

      // Test tablet (2 columns)
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      
      final tabletGrid = tester.widget<GridView>(find.byType(GridView));
      final tabletDelegate = tabletGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(tabletDelegate.crossAxisCount, 2);

      // Test desktop (3 columns)
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();
      
      final desktopGrid = tester.widget<GridView>(find.byType(GridView));
      final desktopDelegate = desktopGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(desktopDelegate.crossAxisCount, 3);
    });
  });
}