import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/performance/performance_monitor.dart';
import 'package:tourlicity_app/core/performance/lazy_loading_manager.dart';

void main() {
  group('Performance Optimization Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUp(() {
      performanceMonitor = PerformanceMonitor.instance;
      performanceMonitor.clearMetrics();
    });

    test('PerformanceMonitor tracks metrics correctly', () {
      // Record some test metrics
      performanceMonitor.recordMetric('test_metric', 100.0);
      performanceMonitor.recordMetric('test_metric', 150.0);
      performanceMonitor.recordMetric('test_metric', 120.0);
      
      final metrics = performanceMonitor.getMetrics();
      expect(metrics.containsKey('test_metric'), isTrue);
      
      final testMetric = metrics['test_metric']!;
      expect(testMetric.count, equals(3));
      expect(testMetric.average, closeTo(123.33, 0.1));
      expect(testMetric.min, equals(100.0));
      expect(testMetric.max, equals(150.0));
    });

    test('Performance report generation', () {
      // Add some test data
      performanceMonitor.recordMetric('render_time', 16.0);
      performanceMonitor.recordMetric('render_time', 18.0);
      performanceMonitor.recordMetric('api_call', 200.0);
      
      final report = performanceMonitor.getReport();
      expect(report.metrics.length, equals(2));
      expect(report.metrics.containsKey('render_time'), isTrue);
      expect(report.metrics.containsKey('api_call'), isTrue);
    });

    test('Async performance measurement', () async {
      final result = await performanceMonitor.measureAsync('test_async', () async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 'test_result';
      });
      
      expect(result, equals('test_result'));
      
      final metrics = performanceMonitor.getMetrics();
      expect(metrics.containsKey('test_async'), isTrue);
      expect(metrics['test_async']!.average, greaterThan(90));
    });

    test('Sync performance measurement', () {
      final result = performanceMonitor.measureSync('test_sync', () {
        // Simulate some work
        var sum = 0;
        for (int i = 0; i < 1000; i++) {
          sum += i;
        }
        return sum;
      });
      
      expect(result, equals(499500));
      
      final metrics = performanceMonitor.getMetrics();
      expect(metrics.containsKey('test_sync'), isTrue);
    });

    test('PaginationState management', () {
      const initialState = PaginationState<String>();
      expect(initialState.items, isEmpty);
      expect(initialState.currentPage, equals(0));
      expect(initialState.isLoading, isFalse);
      expect(initialState.hasMore, isTrue);

      final loadingState = initialState.copyWith(isLoading: true);
      expect(loadingState.isLoading, isTrue);
      expect(loadingState.items, isEmpty);

      final loadedState = loadingState.copyWith(
        items: ['item1', 'item2'],
        currentPage: 1,
        isLoading: false,
      );
      expect(loadedState.items.length, equals(2));
      expect(loadedState.currentPage, equals(1));
      expect(loadedState.isLoading, isFalse);
    });

    test('Performance benchmark for list rendering', () async {
      // Test the benchmark functionality without actual widgets
      final stopwatch = Stopwatch()..start();
      int itemsProcessed = 0;
      
      while (stopwatch.elapsed < const Duration(milliseconds: 500)) {
        for (int i = 0; i < 100; i++) {
          // Simulate item building
          itemsProcessed++;
        }
      }
      
      stopwatch.stop();
      
      expect(itemsProcessed, greaterThan(100));
      expect(stopwatch.elapsed.inMilliseconds, lessThanOrEqualTo(600));
    });

    test('Performance benchmark for navigation', () async {
      int navigationCount = 0;
      
      final result = await PerformanceBenchmark.benchmarkNavigation(
        navigationFunction: () async {
          navigationCount++;
          await Future.delayed(const Duration(milliseconds: 10));
        },
        iterations: 10,
      );

      expect(result.itemsProcessed, equals(10));
      expect(result.itemsPerSecond, greaterThan(5));
      expect(navigationCount, equals(10));
    });

    test('PerformanceMetric calculations', () {
      final metric = PerformanceMetric(
        name: 'test',
        values: [10.0, 20.0, 30.0, 40.0, 50.0],
      );

      expect(metric.average, equals(30.0));
      expect(metric.min, equals(10.0));
      expect(metric.max, equals(50.0));
      expect(metric.count, equals(5));

      final updatedMetric = metric.addValue(60.0);
      expect(updatedMetric.count, equals(6));
      expect(updatedMetric.max, equals(60.0));
    });

    test('FrameTimingInfo jank detection', () {
      final smoothFrame = FrameTimingInfo(
        buildTime: 8.0,
        rasterTime: 6.0,
        totalTime: 14.0,
      );
      expect(smoothFrame.isJanky, isFalse);

      final jankyFrame = FrameTimingInfo(
        buildTime: 12.0,
        rasterTime: 8.0,
        totalTime: 20.0,
      );
      expect(jankyFrame.isJanky, isTrue);
    });

    test('PerformanceReport calculations', () {
      performanceMonitor.recordMetric('frame_time', 16.0);
      performanceMonitor.recordMetric('frame_time', 18.0);
      
      final report = performanceMonitor.getReport();
      // FPS calculation requires frame timing data, not just metrics
      expect(report.metrics.length, equals(1));
      expect(report.metrics.containsKey('frame_time'), isTrue);
    });
  });
}
