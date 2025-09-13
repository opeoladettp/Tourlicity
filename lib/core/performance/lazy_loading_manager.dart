import 'package:flutter/foundation.dart';

/// Manages lazy loading and pagination for large datasets
class LazyLoadingManager<T> {
  final List<T> _items = [];
  final int _pageSize;
  final Future<List<T>> Function(int page, int pageSize) _loadFunction;
  
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  
  LazyLoadingManager({
    required Future<List<T>> Function(int page, int pageSize) loadFunction,
    int pageSize = 20,
  }) : _loadFunction = loadFunction,
       _pageSize = pageSize;

  /// Gets the current list of items
  List<T> get items => List.unmodifiable(_items);
  
  /// Whether currently loading
  bool get isLoading => _isLoading;
  
  /// Whether more items are available
  bool get hasMore => _hasMore;
  
  /// Current page number
  int get currentPage => _currentPage;
  
  /// Total number of items loaded
  int get itemCount => _items.length;

  /// Loads the next page of items
  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    
    try {
      final newItems = await _loadFunction(_currentPage, _pageSize);
      
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        _currentPage++;
        
        // If we got fewer items than requested, we've reached the end
        if (newItems.length < _pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading page $_currentPage: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Resets the manager and loads the first page
  Future<void> refresh() async {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
    
    await loadNextPage();
  }

  /// Clears all loaded items
  void clear() {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
  }

  /// Gets an item at the specified index, loading more if needed
  Future<T?> getItem(int index) async {
    if (index < _items.length) {
      return _items[index];
    }
    
    // If we're near the end and have more items, load them
    if (index >= _items.length - 5 && _hasMore && !_isLoading) {
      await loadNextPage();
      
      if (index < _items.length) {
        return _items[index];
      }
    }
    
    return null;
  }

  /// Preloads items if we're approaching the end
  Future<void> preloadIfNeeded(int currentIndex) async {
    final threshold = _items.length - (_pageSize ~/ 2);
    
    if (currentIndex >= threshold && _hasMore && !_isLoading) {
      await loadNextPage();
    }
  }
}

/// State class for pagination
class PaginationState<T> {
  final List<T> items;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const PaginationState({
    this.items = const [],
    this.currentPage = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }

  /// Creates a loading state
  PaginationState<T> loading() {
    return copyWith(isLoading: true, error: null);
  }

  /// Creates a loaded state with new items
  PaginationState<T> loaded(List<T> newItems, {bool? hasMore}) {
    return copyWith(
      items: [...items, ...newItems],
      currentPage: currentPage + 1,
      isLoading: false,
      hasMore: hasMore ?? (newItems.isNotEmpty),
      error: null,
    );
  }

  /// Creates an error state
  PaginationState<T> withError(String error) {
    return copyWith(isLoading: false, error: error);
  }

  /// Creates a refreshed state (clears items and resets page)
  PaginationState<T> refreshed() {
    return const PaginationState();
  }
}

/// Pagination controller for managing paginated data
class PaginationController<T> extends ChangeNotifier {
  PaginationState<T> _state = const PaginationState();
  final Future<List<T>> Function(int page, int pageSize) _loadFunction;
  final int _pageSize;

  PaginationController({
    required Future<List<T>> Function(int page, int pageSize) loadFunction,
    int pageSize = 20,
  }) : _loadFunction = loadFunction,
       _pageSize = pageSize;

  PaginationState<T> get state => _state;

  /// Loads the next page
  Future<void> loadNextPage() async {
    if (_state.isLoading || !_state.hasMore) return;

    _state = _state.loading();
    notifyListeners();

    try {
      final newItems = await _loadFunction(_state.currentPage, _pageSize);
      _state = _state.loaded(newItems);
    } catch (e) {
      _state = _state.withError(e.toString());
    }

    notifyListeners();
  }

  /// Refreshes the data (starts from page 0)
  Future<void> refresh() async {
    _state = _state.refreshed().loading();
    notifyListeners();

    try {
      final newItems = await _loadFunction(0, _pageSize);
      _state = _state.loaded(newItems);
    } catch (e) {
      _state = _state.withError(e.toString());
    }

    notifyListeners();
  }

  /// Clears all data
  void clear() {
    _state = const PaginationState();
    notifyListeners();
  }
}