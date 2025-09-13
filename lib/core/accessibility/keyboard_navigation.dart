import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A service for managing keyboard navigation and focus
class KeyboardNavigationService {
  static final KeyboardNavigationService _instance = KeyboardNavigationService._internal();
  factory KeyboardNavigationService() => _instance;
  KeyboardNavigationService._internal();

  /// Focus nodes for managing keyboard navigation
  final List<FocusNode> _focusNodes = [];
  int _currentFocusIndex = -1;

  /// Register a focus node for keyboard navigation
  void registerFocusNode(FocusNode node) {
    if (!_focusNodes.contains(node)) {
      _focusNodes.add(node);
    }
  }

  /// Unregister a focus node
  void unregisterFocusNode(FocusNode node) {
    _focusNodes.remove(node);
    if (_currentFocusIndex >= _focusNodes.length) {
      _currentFocusIndex = _focusNodes.length - 1;
    }
  }

  /// Move focus to the next focusable element
  void focusNext() {
    if (_focusNodes.isEmpty) return;
    
    _currentFocusIndex = (_currentFocusIndex + 1) % _focusNodes.length;
    _focusNodes[_currentFocusIndex].requestFocus();
  }

  /// Move focus to the previous focusable element
  void focusPrevious() {
    if (_focusNodes.isEmpty) return;
    
    _currentFocusIndex = (_currentFocusIndex - 1) % _focusNodes.length;
    if (_currentFocusIndex < 0) {
      _currentFocusIndex = _focusNodes.length - 1;
    }
    _focusNodes[_currentFocusIndex].requestFocus();
  }

  /// Clear all registered focus nodes
  void clear() {
    _focusNodes.clear();
    _currentFocusIndex = -1;
  }
}

/// A widget that provides keyboard navigation shortcuts
class KeyboardNavigationWrapper extends StatefulWidget {
  final Widget child;
  final bool enableTabNavigation;
  final bool enableArrowNavigation;
  final VoidCallback? onEscape;

  const KeyboardNavigationWrapper({
    super.key,
    required this.child,
    this.enableTabNavigation = true,
    this.enableArrowNavigation = false,
    this.onEscape,
  });

  @override
  State<KeyboardNavigationWrapper> createState() => _KeyboardNavigationWrapperState();
}

class _KeyboardNavigationWrapperState extends State<KeyboardNavigationWrapper> {
  final KeyboardNavigationService _navigationService = KeyboardNavigationService();

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        if (widget.enableTabNavigation) ...{
          LogicalKeySet(LogicalKeyboardKey.tab): const NextFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): const PreviousFocusIntent(),
        },
        if (widget.enableArrowNavigation) ...{
          LogicalKeySet(LogicalKeyboardKey.arrowDown): const NextFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowUp): const PreviousFocusIntent(),
        },
        if (widget.onEscape != null)
          LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: {
          NextFocusIntent: CallbackAction<NextFocusIntent>(
            onInvoke: (intent) {
              _navigationService.focusNext();
              return null;
            },
          ),
          PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
            onInvoke: (intent) {
              _navigationService.focusPrevious();
              return null;
            },
          ),
          if (widget.onEscape != null)
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) {
                widget.onEscape!();
                return null;
              },
            ),
        },
        child: widget.child,
      ),
    );
  }
}

/// A form field that automatically registers for keyboard navigation
class KeyboardNavigableFormField extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;
  final bool autoRegister;

  const KeyboardNavigableFormField({
    super.key,
    required this.child,
    this.focusNode,
    this.autoRegister = true,
  });

  @override
  State<KeyboardNavigableFormField> createState() => _KeyboardNavigableFormFieldState();
}

class _KeyboardNavigableFormFieldState extends State<KeyboardNavigableFormField> {
  late FocusNode _focusNode;
  final KeyboardNavigationService _navigationService = KeyboardNavigationService();

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    
    if (widget.autoRegister) {
      _navigationService.registerFocusNode(_focusNode);
    }
  }

  @override
  void dispose() {
    if (widget.autoRegister) {
      _navigationService.unregisterFocusNode(_focusNode);
    }
    
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: widget.child,
    );
  }
}

/// A keyboard shortcut helper for common actions
class KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;
  final VoidCallback? onRefresh;
  final VoidCallback? onSearch;

  const KeyboardShortcuts({
    super.key,
    required this.child,
    this.onSave,
    this.onCancel,
    this.onSubmit,
    this.onRefresh,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        if (onSave != null)
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const SaveIntent(),
        if (onCancel != null)
          LogicalKeySet(LogicalKeyboardKey.escape): const CancelIntent(),
        if (onSubmit != null)
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter): const SubmitIntent(),
        if (onRefresh != null)
          LogicalKeySet(LogicalKeyboardKey.f5): const RefreshIntent(),
        if (onSearch != null)
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const SearchIntent(),
      },
      child: Actions(
        actions: {
          if (onSave != null)
            SaveIntent: CallbackAction<SaveIntent>(onInvoke: (_) => onSave!()),
          if (onCancel != null)
            CancelIntent: CallbackAction<CancelIntent>(onInvoke: (_) => onCancel!()),
          if (onSubmit != null)
            SubmitIntent: CallbackAction<SubmitIntent>(onInvoke: (_) => onSubmit!()),
          if (onRefresh != null)
            RefreshIntent: CallbackAction<RefreshIntent>(onInvoke: (_) => onRefresh!()),
          if (onSearch != null)
            SearchIntent: CallbackAction<SearchIntent>(onInvoke: (_) => onSearch!()),
        },
        child: child,
      ),
    );
  }
}

// Intent classes for keyboard shortcuts
class SaveIntent extends Intent {
  const SaveIntent();
}

class CancelIntent extends Intent {
  const CancelIntent();
}

class SubmitIntent extends Intent {
  const SubmitIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

/// A focus scope that manages focus within a specific area
class AccessibleFocusScope extends StatefulWidget {
  final Widget child;
  final bool autofocus;
  final FocusNode? focusNode;
  final String? debugLabel;

  const AccessibleFocusScope({
    super.key,
    required this.child,
    this.autofocus = false,
    this.focusNode,
    this.debugLabel,
  });

  @override
  State<AccessibleFocusScope> createState() => _AccessibleFocusScopeState();
}

class _AccessibleFocusScopeState extends State<AccessibleFocusScope> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: widget.debugLabel);
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: widget.child,
    );
  }
}