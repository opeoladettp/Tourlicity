import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring service
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();
  
  PerformanceMonitor._();

  final Map<String, PerformanceMetric> _metrics = {};
  final List<FrameTimingInfo> _frameTimings = [];
  Timer? _memoryTimer;
  
  /// Starts performance monitoring
  void startMonitoring() {
    if (kDebugMode) {
      _startFrameMonitoring();
      _startMemoryMonitoring();
    }
  }

  /// Stops performance monitoring
  void stopMonitoring() {
    _memoryTimer?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
  }

  /// Measures execution time of a function
  Future<T> measureAsync<T>(
    String name,
    Future<T> Function() function,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      _recordMetric(name, stopwatch.elapsedMilliseconds.toDouble());
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordMetric('$name-error', stopwatch.elapsedMilliseconds.toDouble());
      rethrow;
    }
  }

  /// Measures execution time of a synchronous function
  T measureSync<T>(
    String name,
    T Function() function,
  ) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = function();
      stopwatch.stop();
      _recordMetric(name, stopwatch.elapsedMilliseconds.toDouble());
      return result;
    } catch (e) {
      stopwatch.stop();
      _recordMetric('$name-error', stopwatch.elapsedMilliseconds.toDouble());
      rethrow;
    }
  }

  /// Records a custom metric
  void recordMetric(String name, double value) {
    _recordMetric(name, value);
  }

  /// Gets performance metrics
  Map<String, PerformanceMetric> getMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Gets frame timing information
  List<FrameTimingInfo> getFrameTimings() {
    return List.unmodifiable(_frameTimings);
  }

  /// Clears all metrics
  void clearMetrics() {
    _metrics.clear();
    _frameTimings.clear();
  }

  /// Gets performance report
  PerformanceReport getReport() {
    final avgFrameTime = _frameTimings.isNotEmpty
        ? _frameTimings.map((f) => f.totalTime).reduce((a, b) => a + b) / _frameTimings.length
        : 0.0;
    
    final droppedFrames = _frameTimings.where((f) => f.totalTime > 16.67).length;
    
    return PerformanceReport(
      metrics: Map.from(_metrics),
      averageFrameTime: avgFrameTime,
      droppedFrames: droppedFrames,
      totalFrames: _frameTimings.length,
    );
  }

  void _recordMetric(String name, double value) {
    final existing = _metrics[name];
    if (existing != null) {
      _metrics[name] = existing.addValue(value);
    } else {
      _metrics[name] = PerformanceMetric(name: name, values: [value]);
    }
    
    if (kDebugMode) {
      developer.log('Performance: $name = ${value}ms', name: 'PerformanceMonitor');
    }
  }

  void _startFrameMonitoring() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
  }

  void _onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      final info = FrameTimingInfo(
        buildTime: timing.buildDuration.inMicroseconds / 1000.0,
        rasterTime: timing.rasterDuration.inMicroseconds / 1000.0,
        totalTime: timing.totalSpan.inMicroseconds / 1000.0,
      );
      
      _frameTimings.add(info);
      
      // Keep only last 100 frame timings
      if (_frameTimings.length > 100) {
        _frameTimings.removeAt(0);
      }
    }
  }

  void _startMemoryMonitoring() {
    _memoryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Record memory usage if available
      // This would require platform-specific implementation
    });
  }
}

/// Performance metric data
class PerformanceMetric {
  final String name;
  final List<double> values;
  final DateTime lastUpdated;

  PerformanceMetric({
    required this.name,
    required this.values,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  double get average => values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0;
  double get min => values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0;
  double get max => values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0;
  int get count => values.length;

  PerformanceMetric addValue(double value) {
    final newValues = [...values, value];
    // Keep only last 50 values
    if (newValues.length > 50) {
      newValues.removeAt(0);
    }
    
    return PerformanceMetric(
      name: name,
      values: newValues,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Frame timing information
class FrameTimingInfo {
  final double buildTime;
  final double rasterTime;
  final double totalTime;

  FrameTimingInfo({
    required this.buildTime,
    required this.rasterTime,
    required this.totalTime,
  });

  bool get isJanky => totalTime > 16.67; // 60fps threshold
}

/// Performance report
class PerformanceReport {
  final Map<String, PerformanceMetric> metrics;
  final double averageFrameTime;
  final int droppedFrames;
  final int totalFrames;

  PerformanceReport({
    required this.metrics,
    required this.averageFrameTime,
    required this.droppedFrames,
    required this.totalFrames,
  });

  double get frameDropRate => totalFrames > 0 ? droppedFrames / totalFrames : 0;
  double get fps => averageFrameTime > 0 ? 1000 / averageFrameTime : 0;
}

/// Mixin for adding performance monitoring to widgets
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PerformanceMonitor.instance.measureSync(
      '${widget.runtimeType}_build',
      () => buildWidget(context),
    );
  }

  /// Override this method instead of build
  Widget buildWidget(BuildContext context);
}

/// Performance benchmark utility
class PerformanceBenchmark {
  /// Benchmarks list rendering performance
  static Future<BenchmarkResult> benchmarkListRendering({
    required int itemCount,
    required Widget Function(int) itemBuilder,
    Duration testDuration = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    int renderedItems = 0;
    
    while (stopwatch.elapsed < testDuration) {
      for (int i = 0; i < itemCount; i++) {
        itemBuilder(i);
        renderedItems++;
      }
    }
    
    stopwatch.stop();
    
    return BenchmarkResult(
      testName: 'List Rendering',
      duration: stopwatch.elapsed,
      itemsProcessed: renderedItems,
      itemsPerSecond: renderedItems / stopwatch.elapsed.inSeconds,
    );
  }

  /// Benchmarks navigation performance
  static Future<BenchmarkResult> benchmarkNavigation({
    required Future<void> Function() navigationFunction,
    int iterations = 10,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    for (int i = 0; i < iterations; i++) {
      await navigationFunction();
    }
    
    stopwatch.stop();
    
    return BenchmarkResult(
      testName: 'Navigation',
      duration: stopwatch.elapsed,
      itemsProcessed: iterations,
      itemsPerSecond: iterations / stopwatch.elapsed.inSeconds,
    );
  }
}

/// Benchmark result
class BenchmarkResult {
  final String testName;
  final Duration duration;
  final int itemsProcessed;
  final double itemsPerSecond;

  BenchmarkResult({
    required this.testName,
    required this.duration,
    required this.itemsProcessed,
    required this.itemsPerSecond,
  });

  @override
  String toString() {
    return 'Benchmark: $testName\n'
           'Duration: ${duration.inMilliseconds}ms\n'
           'Items: $itemsProcessed\n'
           'Rate: ${itemsPerSecond.toStringAsFixed(2)} items/sec';
  }
}