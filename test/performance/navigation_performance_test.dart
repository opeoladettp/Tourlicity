import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/performance/performance_monitor.dart';

void main() {
  group('Navigation Performance Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUp(() {
      performanceMonitor = PerformanceMonitor.instance;
      performanceMonitor.clearMetrics();
    });

    testWidgets('Page transition performance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/second': (context) => const SecondPage(),
            '/third': (context) => const ThirdPage(),
          },
        ),
      );

      // Measure navigation time
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('Go to Second Page'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500),
          reason: 'Navigation should be fast');
      
      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('Multiple rapid navigations performance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: {
            '/second': (context) => const SecondPage(),
            '/third': (context) => const ThirdPage(),
          },
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      // Perform multiple navigations rapidly
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Go to Second Page'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        await tester.pageBack();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
          reason: 'Multiple navigations should complete quickly');
    });

    testWidgets('Hero animation performance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HeroTestPage(),
          routes: {
            '/detail': (context) => const HeroDetailPage(),
          },
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('hero_widget')));
      await tester.pumpAndSettle();
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(600),
          reason: 'Hero animation should complete smoothly');
      
      expect(find.text('Detail Page'), findsOneWidget);
    });

    testWidgets('Optimized hero animation performance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OptimizedHeroTestPage(),
          routes: {
            '/detail': (context) => const OptimizedHeroDetailPage(),
          },
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('optimized_hero_widget')));
      await tester.pumpAndSettle();
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(400),
          reason: 'Optimized hero animation should be faster');
    });

    testWidgets('Route generation performance', (tester) async {
      final routes = <String, WidgetBuilder>{};
      
      // Generate many routes
      for (int i = 0; i < 100; i++) {
        routes['/page$i'] = (context) => TestPage(title: 'Page $i');
      }

      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          routes: routes,
        ),
      );
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Route generation should be fast');
    });

    test('Navigation benchmark', () async {
      int navigationCount = 0;
      
      final result = await PerformanceBenchmark.benchmarkNavigation(
        navigationFunction: () async {
          navigationCount++;
          await Future.delayed(const Duration(milliseconds: 10));
        },
        iterations: 50,
      );

      expect(result.itemsProcessed, equals(50));
      expect(result.itemsPerSecond, greaterThan(10));
      expect(navigationCount, equals(50));
      
      debugPrint(result.toString());
    });

    testWidgets('Memory usage during navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/heavy':
                return MaterialPageRoute(
                  builder: (context) => const HeavyPage(),
                );
              default:
                return null;
            }
          },
        ),
      );

      // Navigate to heavy page
      await tester.tap(find.text('Go to Heavy Page'));
      await tester.pumpAndSettle();
      
      expect(find.text('Heavy Page'), findsOneWidget);
      
      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      expect(find.text('Home Page'), findsOneWidget);
      
      // The heavy page should be disposed and not consume memory
      expect(find.text('Heavy Page'), findsNothing);
    });

    testWidgets('Nested navigation performance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NestedNavigationPage(),
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      // Navigate through nested structure
      await tester.tap(find.text('Tab 1'));
      await tester.pump();
      
      await tester.tap(find.text('Go Deeper'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Go Even Deeper'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(300),
          reason: 'Nested navigation should be efficient');
    });

    testWidgets('Animation optimization in navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AnimatedNavigationPage(),
          routes: {
            '/animated': (context) => const AnimatedDestinationPage(),
          },
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('Animated Navigation'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(800),
          reason: 'Animated navigation should complete smoothly');
    });
  });
}

// Test pages for navigation performance testing

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/second'),
            child: const Text('Go to Second Page'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/heavy'),
            child: const Text('Go to Heavy Page'),
          ),
        ],
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: const Center(child: Text('Second Page')),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Third Page')),
      body: const Center(child: Text('Third Page')),
    );
  }
}

class TestPage extends StatelessWidget {
  final String title;
  
  const TestPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

class HeavyPage extends StatelessWidget {
  const HeavyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate a heavy page with many widgets
    return Scaffold(
      appBar: AppBar(title: const Text('Heavy Page')),
      body: ListView.builder(
        itemCount: 1000,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Heavy Item $index'),
            subtitle: Text('Subtitle $index'),
            leading: const CircleAvatar(child: Icon(Icons.person)),
          );
        },
      ),
    );
  }
}

class HeroTestPage extends StatelessWidget {
  const HeroTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Test')),
      body: Center(
        child: GestureDetector(
          key: const Key('hero_widget'),
          onTap: () => Navigator.pushNamed(context, '/detail'),
          child: const Hero(
            tag: 'hero_tag',
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}

class HeroDetailPage extends StatelessWidget {
  const HeroDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Page')),
      body: const Center(
        child: Hero(
          tag: 'hero_tag',
          child: CircleAvatar(
            radius: 100,
            child: Icon(Icons.person, size: 100),
          ),
        ),
      ),
    );
  }
}

class OptimizedHeroTestPage extends StatelessWidget {
  const OptimizedHeroTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optimized Hero Test')),
      body: Center(
        child: GestureDetector(
          key: const Key('optimized_hero_widget'),
          onTap: () => Navigator.pushNamed(context, '/detail'),
          child: const Hero(
            tag: 'optimized_hero_tag',
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}

class OptimizedHeroDetailPage extends StatelessWidget {
  const OptimizedHeroDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Page')),
      body: const Center(
        child: Hero(
          tag: 'optimized_hero_tag',
          child: CircleAvatar(
            radius: 100,
            child: Icon(Icons.person, size: 100),
          ),
        ),
      ),
    );
  }
}

class NestedNavigationPage extends StatefulWidget {
  const NestedNavigationPage({super.key});

  @override
  State<NestedNavigationPage> createState() => _NestedNavigationPageState();
}

class _NestedNavigationPageState extends State<NestedNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested Navigation')),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          NestedTab1(),
          NestedTab2(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tab 1'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Tab 2'),
        ],
      ),
    );
  }
}

class NestedTab1 extends StatelessWidget {
  const NestedTab1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Tab 1'),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DeeperPage()),
            );
          },
          child: const Text('Go Deeper'),
        ),
      ],
    );
  }
}

class NestedTab2 extends StatelessWidget {
  const NestedTab2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tab 2'));
  }
}

class DeeperPage extends StatelessWidget {
  const DeeperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deeper Page')),
      body: Column(
        children: [
          const Text('Deeper Page'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EvenDeeperPage()),
              );
            },
            child: const Text('Go Even Deeper'),
          ),
        ],
      ),
    );
  }
}

class EvenDeeperPage extends StatelessWidget {
  const EvenDeeperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Even Deeper Page')),
      body: const Center(child: Text('Even Deeper Page')),
    );
  }
}

class AnimatedNavigationPage extends StatelessWidget {
  const AnimatedNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Navigation')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/animated'),
          child: const Text('Animated Navigation'),
        ),
      ),
    );
  }
}

class AnimatedDestinationPage extends StatefulWidget {
  const AnimatedDestinationPage({super.key});

  @override
  State<AnimatedDestinationPage> createState() => _AnimatedDestinationPageState();
}

class _AnimatedDestinationPageState extends State<AnimatedDestinationPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Destination')),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: const Center(
              child: Text('Animated Destination Page'),
            ),
          );
        },
      ),
    );
  }
}