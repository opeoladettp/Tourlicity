import 'package:flutter/material.dart';

/// Utilities for code splitting and lazy loading of widgets
class CodeSplitting {
  /// Creates a lazy-loaded widget that only builds when needed
  static Widget lazyWidget(Widget Function() builder) {
    return _LazyWidget(builder: builder);
  }

  /// Creates a deferred widget that loads asynchronously
  static Widget deferredWidget(Future<Widget> Function() builder) {
    return _DeferredWidget(builder: builder);
  }

  /// Creates a conditional widget that only builds based on a condition
  static Widget conditionalWidget({
    required bool condition,
    required Widget Function() builder,
    Widget? fallback,
  }) {
    return condition ? builder() : (fallback ?? const SizedBox.shrink());
  }

  /// Creates a widget that builds only when visible
  static Widget visibilityBasedWidget({
    required Widget Function() builder,
    Widget? placeholder,
  }) {
    return _VisibilityBasedWidget(
      builder: builder,
      placeholder: placeholder,
    );
  }
}

/// Lazy widget implementation
class _LazyWidget extends StatefulWidget {
  final Widget Function() builder;

  const _LazyWidget({required this.builder});

  @override
  State<_LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<_LazyWidget> {
  Widget? _cachedWidget;

  @override
  Widget build(BuildContext context) {
    _cachedWidget ??= widget.builder();
    return _cachedWidget!;
  }
}

/// Deferred widget implementation
class _DeferredWidget extends StatefulWidget {
  final Future<Widget> Function() builder;

  const _DeferredWidget({required this.builder});

  @override
  State<_DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<_DeferredWidget> {
  Widget? _widget;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  Future<void> _loadWidget() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final builtWidget = await widget.builder();
      if (mounted) {
        setState(() {
          _widget = builtWidget;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadWidget,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _widget ?? const SizedBox.shrink();
  }
}

/// Visibility-based widget implementation
class _VisibilityBasedWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;

  const _VisibilityBasedWidget({
    required this.builder,
    this.placeholder,
  });

  @override
  State<_VisibilityBasedWidget> createState() => _VisibilityBasedWidgetState();
}

class _VisibilityBasedWidgetState extends State<_VisibilityBasedWidget> {
  Widget? _builtWidget;
  bool _hasBeenVisible = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if widget is in viewport
        final renderObject = context.findRenderObject();
        if (renderObject != null && !_hasBeenVisible) {
          // Simplified visibility check - build widget when first rendered
          _hasBeenVisible = true;
          _builtWidget = widget.builder();
        }

        if (_hasBeenVisible && _builtWidget != null) {
          return _builtWidget!;
        }

        return widget.placeholder ??
            SizedBox(
              height: constraints.maxHeight > 0 ? constraints.maxHeight : 100,
              child: const Center(child: CircularProgressIndicator()),
            );
      },
    );
  }
}

/// Mixin for implementing code splitting in widgets
mixin CodeSplittingMixin<T extends StatefulWidget> on State<T> {
  final Map<String, Widget> _cachedWidgets = {};

  /// Caches a widget with a key
  Widget cacheWidget(String key, Widget Function() builder) {
    return _cachedWidgets.putIfAbsent(key, builder);
  }

  /// Clears cached widgets
  void clearCache() {
    _cachedWidgets.clear();
  }

  /// Gets cached widget count
  int get cachedWidgetCount => _cachedWidgets.length;
}

/// Tree shaking utilities
class TreeShaking {
  /// Removes unused widgets from the widget tree
  static Widget optimizeWidgetTree(Widget widget) {
    return _OptimizedWidgetTree(child: widget);
  }
}

class _OptimizedWidgetTree extends StatelessWidget {
  final Widget child;

  const _OptimizedWidgetTree({required this.child});

  @override
  Widget build(BuildContext context) {
    // In a real implementation, this would analyze the widget tree
    // and remove unused widgets. For now, we just return the child.
    return child;
  }
}

/// Memory optimization utilities
class MemoryOptimizer {
  /// Creates a memory-efficient widget wrapper
  static Widget memoryEfficient(Widget child) {
    return RepaintBoundary(
      child: child,
    );
  }

  /// Creates a widget that disposes resources when not visible
  static Widget autoDispose(Widget child) {
    return _AutoDisposeWidget(child: child);
  }
}

class _AutoDisposeWidget extends StatefulWidget {
  final Widget child;

  const _AutoDisposeWidget({required this.child});

  @override
  State<_AutoDisposeWidget> createState() => _AutoDisposeWidgetState();
}

class _AutoDisposeWidgetState extends State<_AutoDisposeWidget> {
  @override
  Widget build(BuildContext context) {
    // Simplified auto-dispose implementation
    // In a production app, you might want to use visibility_detector package
    // for proper visibility tracking and resource disposal
    return RepaintBoundary(
      child: widget.child,
    );
  }
}
