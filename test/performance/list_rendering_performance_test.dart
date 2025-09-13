import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/widgets/common/optimized_list_view.dart';
import 'package:tourlicity_app/core/performance/performance_monitor.dart';

void main() {
  group('List Rendering Performance Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUp(() {
      performanceMonitor = PerformanceMonitor.instance;
      performanceMonitor.clearMetrics();
    });

    testWidgets('OptimizedListView renders large dataset efficiently', (tester) async {
      const itemCount = 1000;
      final items = List.generate(itemCount, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item),
                  subtitle: Text('Index: $index'),
                );
              },
            ),
          ),
        ),
      );

      // Measure initial render time
      final stopwatch = Stopwatch()..start();
      await tester.pump();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Initial render should be fast');

      // Test scrolling performance
      final scrollStopwatch = Stopwatch()..start();
      final listFinder = find.byType(ListView);
      if (listFinder.evaluate().isNotEmpty) {
        await tester.drag(listFinder, const Offset(0, -500));
        await tester.pump();
      }
      scrollStopwatch.stop();

      expect(scrollStopwatch.elapsedMilliseconds, lessThan(50),
          reason: 'Scrolling should be smooth');
    });

    testWidgets('VirtualizedListView handles very large datasets', (tester) async {
      const itemCount = 10000;
      final items = List.generate(itemCount, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualizedListView<String>(
              items: items,
              itemHeight: 60.0,
              itemBuilder: (context, item, index) {
                return Container(
                  height: 60,
                  padding: const EdgeInsets.all(8),
                  child: Text(item),
                );
              },
            ),
          ),
        ),
      );

      // Should render without performance issues
      await tester.pump();
      
      // Test that only visible items are built
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 100'), findsNothing);
    });

    testWidgets('OptimizedStaggeredGridView performance', (tester) async {
      const itemCount = 500;
      final items = List.generate(itemCount, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedStaggeredGridView<String>(
              items: items,
              crossAxisCount: 2,
              itemBuilder: (context, item, index) {
                return Card(
                  child: Container(
                    height: 100 + (index % 3) * 20, // Variable heights
                    padding: const EdgeInsets.all(8),
                    child: Text(item),
                  ),
                );
              },
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      await tester.pump();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(150),
          reason: 'Staggered grid should render efficiently');
    });

    test('Performance benchmark for list rendering', () async {
      final result = await PerformanceBenchmark.benchmarkListRendering(
        itemCount: 1000,
        itemBuilder: (index) => SizedBox(
          height: 60,
          child: Text('Item $index'),
        ),
        testDuration: const Duration(seconds: 2),
      );

      expect(result.itemsPerSecond, greaterThan(1000),
          reason: 'Should render at least 1000 items per second');
      
      debugPrint(result.toString());
    });

    testWidgets('Memory usage during list scrolling', (tester) async {
      const itemCount = 2000;
      final items = List.generate(itemCount, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return RepaintBoundary(
                  child: ListTile(
                    title: Text(item),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Simulate scrolling through the list
      final listFinder = find.byType(ListView);
      if (listFinder.evaluate().isNotEmpty) {
        for (int i = 0; i < 5; i++) {
          await tester.drag(listFinder, const Offset(0, -200));
          await tester.pump();
        }
      }

      // Memory should remain stable (this is a basic check)
      expect(tester.allWidgets.length, lessThan(100),
          reason: 'Should not keep all widgets in memory');
    });

    testWidgets('Lazy loading performance', (tester) async {
      final items = <String>[];
      bool isLoading = false;
      bool hasMore = true;
      
      void loadMore() {
        if (!isLoading && hasMore) {
          isLoading = true;
          // Simulate loading delay
          Future.delayed(const Duration(milliseconds: 100), () {
            final newItems = List.generate(20, (index) => 'Item ${items.length + index}');
            items.addAll(newItems);
            isLoading = false;
            hasMore = items.length < 200;
          });
        }
      }

      // Initial load
      loadMore();
      await Future.delayed(const Duration(milliseconds: 150));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return OptimizedListView<String>(
                  items: items,
                  isLoading: isLoading,
                  hasMore: hasMore,
                  onLoadMore: () {
                    setState(() {
                      loadMore();
                    });
                  },
                  itemBuilder: (context, item, index) {
                    return ListTile(title: Text(item));
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      
      // Should have initial items
      expect(find.text('Item 0'), findsOneWidget);
      
      // Scroll to trigger load more
      final listFinder = find.byType(ListView);
      if (listFinder.evaluate().isNotEmpty) {
        await tester.drag(listFinder, const Offset(0, -1000));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
      }
      
      // Should have loaded more items
      expect(items.length, greaterThan(20));
    });

    testWidgets('RepaintBoundary optimization test', (tester) async {
      const itemCount = 100;
      final items = List.generate(itemCount, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return RepaintBoundary(
                  child: Container(
                    height: 60,
                    color: index.isEven ? Colors.grey[100] : Colors.white,
                    child: ListTile(title: Text(item)),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      
      // Verify RepaintBoundary widgets are present
      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });

  group('Performance Monitoring Tests', () {
    test('PerformanceMonitor tracks metrics correctly', () {
      final monitor = PerformanceMonitor.instance;
      monitor.clearMetrics();
      
      // Record some test metrics
      monitor.recordMetric('test_metric', 100.0);
      monitor.recordMetric('test_metric', 150.0);
      monitor.recordMetric('test_metric', 120.0);
      
      final metrics = monitor.getMetrics();
      expect(metrics.containsKey('test_metric'), isTrue);
      
      final testMetric = metrics['test_metric']!;
      expect(testMetric.count, equals(3));
      expect(testMetric.average, equals(123.33333333333333));
      expect(testMetric.min, equals(100.0));
      expect(testMetric.max, equals(150.0));
    });

    test('Performance report generation', () {
      final monitor = PerformanceMonitor.instance;
      monitor.clearMetrics();
      
      // Add some test data
      monitor.recordMetric('render_time', 16.0);
      monitor.recordMetric('render_time', 18.0);
      monitor.recordMetric('api_call', 200.0);
      
      final report = monitor.getReport();
      expect(report.metrics.length, equals(2));
      expect(report.metrics.containsKey('render_time'), isTrue);
      expect(report.metrics.containsKey('api_call'), isTrue);
    });

    test('Async performance measurement', () async {
      final monitor = PerformanceMonitor.instance;
      monitor.clearMetrics();
      
      final result = await monitor.measureAsync('test_async', () async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 'test_result';
      });
      
      expect(result, equals('test_result'));
      
      final metrics = monitor.getMetrics();
      expect(metrics.containsKey('test_async'), isTrue);
      expect(metrics['test_async']!.average, greaterThan(90));
    });

    test('Sync performance measurement', () {
      final monitor = PerformanceMonitor.instance;
      monitor.clearMetrics();
      
      final result = monitor.measureSync('test_sync', () {
        // Simulate some work
        var sum = 0;
        for (int i = 0; i < 1000; i++) {
          sum += i;
        }
        return sum;
      });
      
      expect(result, equals(499500));
      
      final metrics = monitor.getMetrics();
      expect(metrics.containsKey('test_sync'), isTrue);
    });
  });
}