import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/common/responsive_layout.dart';
import 'package:tourlicity_app/core/theme/app_theme.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('shows mobile layout on small screens', (tester) async {
      // Set mobile screen size first
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows tablet layout on medium screens', (tester) async {
      // Set tablet screen size (between 600 and 900)
      await tester.binding.setSurfaceSize(const Size(700, 600));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows desktop layout on large screens', (tester) async {
      // Set desktop screen size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('falls back to mobile when tablet/desktop not provided', (tester) async {
      // Set desktop screen size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mobile'), findsOneWidget);
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('applies responsive padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Set mobile screen size (less than 600)
      await tester.binding.setSurfaceSize(const Size(500, 800));
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, const EdgeInsets.all(16));
    });

    testWidgets('centers content on larger screens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Set tablet screen size (600 or larger)
      await tester.binding.setSurfaceSize(const Size(700, 800));
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsOneWidget);
    });
  });

  group('ResponsiveRow', () {
    testWidgets('shows as column on mobile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveRow(
              children: [
                Text('Item 1'),
                Text('Item 2'),
              ],
            ),
          ),
        ),
      );

      // Set mobile screen size (less than 600)
      await tester.binding.setSurfaceSize(const Size(500, 800));
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('shows as row on larger screens', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveRow(
              children: [
                Text('Item 1'),
                Text('Item 2'),
              ],
            ),
          ),
        ),
      );

      // Set tablet screen size (600 or larger)
      await tester.binding.setSurfaceSize(const Size(700, 600));
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('forces vertical layout when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveRow(
              forceVertical: true,
              children: [
                Text('Item 1'),
                Text('Item 2'),
              ],
            ),
          ),
        ),
      );

      // Set large screen size
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsNothing);
    });
  });

  group('AppTheme helper methods', () {
    testWidgets('correctly identifies mobile screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 800));
      
      bool isMobile = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isMobile = AppTheme.isMobile(context);
              return Text(isMobile.toString());
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(isMobile, isTrue);
    });

    testWidgets('correctly identifies tablet screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(700, 600));
      
      bool isTablet = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isTablet = AppTheme.isTablet(context);
              return Text(isTablet.toString());
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(isTablet, isTrue);
    });

    testWidgets('correctly identifies desktop screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      
      bool isDesktop = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isDesktop = AppTheme.isDesktop(context);
              return Text(isDesktop.toString());
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(isDesktop, isTrue);
    });

    testWidgets('returns correct responsive column count', (tester) async {
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(500, 800));
      int mobileColumns = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              mobileColumns = AppTheme.getResponsiveColumns(context);
              return Text(mobileColumns.toString());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(mobileColumns, equals(1));

      // Test tablet
      await tester.binding.setSurfaceSize(const Size(700, 600));
      int tabletColumns = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              tabletColumns = AppTheme.getResponsiveColumns(context);
              return Text(tabletColumns.toString());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tabletColumns, equals(2));

      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      int desktopColumns = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              desktopColumns = AppTheme.getResponsiveColumns(context);
              return Text(desktopColumns.toString());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(desktopColumns, equals(3));
    });
  });

  group('ResponsiveScaffold', () {
    testWidgets('uses standard scaffold on mobile portrait', (tester) async {
      await tester.binding.setSurfaceSize(const Size(350, 700)); // Smaller mobile portrait
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Text('Body'),
            drawer: const Drawer(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('uses navigation rail on tablet landscape', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const Text('Body'),
            drawer: const Drawer(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('ResponsiveForm', () {
    testWidgets('arranges fields in column on mobile', (tester) async {
      await tester.binding.setSurfaceSize(const Size(350, 700));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveForm(
              fields: [
                TextField(decoration: InputDecoration(labelText: 'Field 1')),
                TextField(decoration: InputDecoration(labelText: 'Field 2')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('arranges fields in wrap on tablet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveForm(
              fields: [
                TextField(decoration: InputDecoration(labelText: 'Field 1')),
                TextField(decoration: InputDecoration(labelText: 'Field 2')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsOneWidget);
    });
  });

  group('ResponsiveDialog', () {
    testWidgets('shows full screen dialog on mobile portrait', (tester) async {
      await tester.binding.setSurfaceSize(const Size(350, 700));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ResponsiveDialog.show(
                    context: context,
                    title: 'Test Dialog',
                    child: const Text('Dialog content'),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Should show full screen dialog (new route)
      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Dialog content'), findsOneWidget);
    });

    testWidgets('shows alert dialog on larger screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ResponsiveDialog.show(
                    context: context,
                    title: 'Test Dialog',
                    child: const Text('Dialog content'),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Test Dialog'), findsOneWidget);
    });
  });
}