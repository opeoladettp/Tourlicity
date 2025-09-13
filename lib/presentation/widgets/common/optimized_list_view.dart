import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/performance/performance_monitor.dart';

/// Optimized list view with virtualization and lazy loading
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final double? itemExtent;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMore = true,
    this.loadingWidget,
    this.emptyWidget,
    this.scrollController,
    this.padding,
    this.itemExtent,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>>
    with PerformanceMonitorMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('No items found'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: widget.loadingWidget ?? const CircularProgressIndicator(),
          );
        }

        return _buildOptimizedItem(context, index);
      },
    );
  }

  Widget _buildOptimizedItem(BuildContext context, int index) {
    final item = widget.items[index];
    
    return PerformanceMonitor.instance.measureSync(
      'list_item_build_$index',
      () => RepaintBoundary(
        child: widget.itemBuilder(context, item, index),
      ),
    );
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    
    // Load more when 80% scrolled
    if (scrollOffset >= maxScroll * 0.8 && 
        widget.hasMore && 
        !widget.isLoading) {
      widget.onLoadMore?.call();
    }
  }
}

/// Optimized grid view with staggered layout
class OptimizedStaggeredGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const OptimizedStaggeredGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMore = true,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.loadingWidget,
    this.emptyWidget,
    this.scrollController,
    this.padding,
  });

  @override
  State<OptimizedStaggeredGridView<T>> createState() => 
      _OptimizedStaggeredGridViewState<T>();
}

class _OptimizedStaggeredGridViewState<T> extends State<OptimizedStaggeredGridView<T>>
    with PerformanceMonitorMixin {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('No items found'));
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: widget.padding ?? const EdgeInsets.all(8.0),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            itemBuilder: (context, index) {
              return _buildOptimizedItem(context, index);
            },
            childCount: widget.items.length,
          ),
        ),
        if (widget.hasMore)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: widget.loadingWidget ?? const CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildOptimizedItem(BuildContext context, int index) {
    final item = widget.items[index];
    
    return PerformanceMonitor.instance.measureSync(
      'grid_item_build_$index',
      () => RepaintBoundary(
        child: widget.itemBuilder(context, item, index),
      ),
    );
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    
    if (scrollOffset >= maxScroll * 0.8 && 
        widget.hasMore && 
        !widget.isLoading) {
      widget.onLoadMore?.call();
    }
  }
}

/// Optimized sliver list for use in CustomScrollView
class OptimizedSliverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final double? itemExtent;

  const OptimizedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
  });

  @override
  Widget build(BuildContext context) {
    if (itemExtent != null) {
      return SliverFixedExtentList(
        itemExtent: itemExtent!,
        delegate: SliverChildBuilderDelegate(
          (context, index) => RepaintBoundary(
            child: itemBuilder(context, items[index], index),
          ),
          childCount: items.length,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => RepaintBoundary(
          child: itemBuilder(context, items[index], index),
        ),
        childCount: items.length,
      ),
    );
  }
}

/// Virtualized list view for very large datasets
class VirtualizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final double itemHeight;
  final ScrollController? scrollController;
  final EdgeInsets? padding;

  const VirtualizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.itemHeight,
    this.scrollController,
    this.padding,
  });

  @override
  State<VirtualizedListView<T>> createState() => _VirtualizedListViewState<T>();
}

class _VirtualizedListViewState<T> extends State<VirtualizedListView<T>> {
  late ScrollController _scrollController;
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_updateVisibleRange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibleRange());
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemExtent: widget.itemHeight,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        // Only build items that are visible or close to being visible
        if (index < _firstVisibleIndex - 5 || index > _lastVisibleIndex + 5) {
          return SizedBox(height: widget.itemHeight);
        }
        
        return RepaintBoundary(
          child: widget.itemBuilder(context, widget.items[index], index),
        );
      },
    );
  }

  void _updateVisibleRange() {
    if (!_scrollController.hasClients) return;
    
    final scrollOffset = _scrollController.offset;
    final viewportHeight = MediaQuery.of(context).size.height;
    
    setState(() {
      _firstVisibleIndex = (scrollOffset / widget.itemHeight).floor();
      _lastVisibleIndex = ((scrollOffset + viewportHeight) / widget.itemHeight).ceil();
      
      _firstVisibleIndex = _firstVisibleIndex.clamp(0, widget.items.length - 1);
      _lastVisibleIndex = _lastVisibleIndex.clamp(0, widget.items.length - 1);
    });
  }
}

/// Mixin for optimizing list performance
mixin ListOptimizationMixin<T extends StatefulWidget> on State<T> {
  final Set<int> _builtItems = {};
  
  /// Tracks which items have been built for performance monitoring
  void trackItemBuild(int index) {
    _builtItems.add(index);
  }
  
  /// Gets the number of built items
  int get builtItemsCount => _builtItems.length;
  
  /// Clears built items tracking
  void clearBuiltItems() {
    _builtItems.clear();
  }
}