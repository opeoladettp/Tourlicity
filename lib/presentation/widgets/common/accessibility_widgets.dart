import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/accessibility/keyboard_navigation.dart';

/// A semantically enhanced button with proper accessibility labels
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final ButtonType type;
  final bool autofocus;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.type = ButtonType.elevated,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    
    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: onPressed,
          autofocus: autofocus,
          child: child,
        );
        break;
      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: onPressed,
          autofocus: autofocus,
          child: child,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: onPressed,
          autofocus: autofocus,
          child: child,
        );
        break;
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}

enum ButtonType { elevated, outlined, text }

/// An accessible text field with enhanced keyboard navigation and screen reader support
class AccessibleTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? semanticLabel;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final bool enableKeyboardNavigation;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    this.keyboardType,
    this.obscureText = false,
    this.autofocus = false,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon,
    this.focusNode,
    this.enableKeyboardNavigation = true,
  });

  @override
  State<AccessibleTextField> createState() => _AccessibleTextFieldState();
}

class _AccessibleTextFieldState extends State<AccessibleTextField> {
  late FocusNode _focusNode;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AccessibleTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasError = widget.errorText != null;
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _hasError) {
      // Announce error when field gains focus
      SemanticsService.announce(
        'Error: ${widget.errorText}',
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      style: const TextStyle(
        fontSize: AppTheme.accessibleFontSize,
        height: AppTheme.accessibleLineHeight,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        suffixIcon: widget.suffixIcon,
        prefixIcon: widget.prefixIcon,
      ),
    );

    return Semantics(
      label: widget.semanticLabel ?? widget.labelText,
      textField: true,
      child: widget.enableKeyboardNavigation
          ? KeyboardNavigableFormField(
              focusNode: _focusNode,
              child: textField,
            )
          : textField,
    );
  }
}

/// An accessible list tile with proper semantics and keyboard navigation
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool selected;
  final bool enabled;
  final bool autofocus;

  const AccessibleListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.selected = false,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: selected,
      enabled: enabled,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        selected: selected,
        enabled: enabled,
        autofocus: autofocus,
        minVerticalPadding: 12,
      ),
    );
  }
}

/// An accessible card with proper semantics and focus handling
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool selected;
  final bool autofocus;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding,
    this.margin,
    this.selected = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Card(
      margin: margin ?? const EdgeInsets.all(8),
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        autofocus: autofocus,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: selected,
      child: card,
    );
  }
}

/// An accessible icon button with proper semantics and minimum touch target
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final double? iconSize;
  final Color? color;
  final bool autofocus;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.iconSize,
    this.color,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = IconButton(
      icon: Icon(icon, size: iconSize),
      onPressed: onPressed,
      color: color,
      autofocus: autofocus,
      constraints: const BoxConstraints(
        minWidth: AppTheme.minTouchTargetSize,
        minHeight: AppTheme.minTouchTargetSize,
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}

/// A widget that announces text changes to screen readers
class AccessibleAnnouncement extends StatelessWidget {
  final String message;
  final Widget child;
  final bool polite;

  const AccessibleAnnouncement({
    super.key,
    required this.message,
    required this.child,
    this.polite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: child,
    );
  }
}

/// A focus trap widget for modal dialogs and overlays
class FocusTrap extends StatefulWidget {
  final Widget child;
  final bool active;

  const FocusTrap({
    super.key,
    required this.child,
    this.active = true,
  });

  @override
  State<FocusTrap> createState() => _FocusTrapState();
}

class _FocusTrapState extends State<FocusTrap> {
  late FocusNode _firstFocusNode;
  late FocusNode _lastFocusNode;

  @override
  void initState() {
    super.initState();
    _firstFocusNode = FocusNode();
    _lastFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstFocusNode.dispose();
    _lastFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }

    return Column(
      children: [
        Focus(
          focusNode: _firstFocusNode,
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              _lastFocusNode.requestFocus();
            }
          },
          child: const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
        Focus(
          focusNode: _lastFocusNode,
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              _firstFocusNode.requestFocus();
            }
          },
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// A skip link widget for keyboard navigation
class SkipLink extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  const SkipLink({
    super.key,
    required this.text,
    required this.onPressed,
    this.focusNode,
  });

  @override
  State<SkipLink> createState() => _SkipLinkState();
}

class _SkipLinkState extends State<SkipLink> {
  late FocusNode _focusNode;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isVisible = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _isVisible ? 16 : -100,
      left: 16,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Focus(
          focusNode: _focusNode,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(widget.text),
          ),
        ),
      ),
    );
  }
}

/// A widget that provides semantic information for complex UI elements
class SemanticWrapper extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool? button;
  final bool? link;
  final bool? header;
  final bool? textField;
  final bool? slider;
  final bool? selected;
  final bool? enabled;
  final bool? checked;
  final bool? mixed;
  final bool? expanded;
  final bool? hidden;
  final bool? image;
  final bool? liveRegion;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDidGainAccessibilityFocus;
  final VoidCallback? onDidLoseAccessibilityFocus;

  const SemanticWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.button,
    this.link,
    this.header,
    this.textField,
    this.slider,
    this.selected,
    this.enabled,
    this.checked,
    this.mixed,
    this.expanded,
    this.hidden,
    this.image,
    this.liveRegion,
    this.onTap,
    this.onLongPress,
    this.onDidGainAccessibilityFocus,
    this.onDidLoseAccessibilityFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      link: link,
      header: header,
      textField: textField,
      slider: slider,
      selected: selected,
      enabled: enabled,
      checked: checked,
      mixed: mixed,
      expanded: expanded,
      hidden: hidden,
      image: image,
      liveRegion: liveRegion,
      onTap: onTap,
      onLongPress: onLongPress,
      onDidGainAccessibilityFocus: onDidGainAccessibilityFocus,
      onDidLoseAccessibilityFocus: onDidLoseAccessibilityFocus,
      child: child,
    );
  }
}

/// A progress indicator with accessibility announcements
class AccessibleProgressIndicator extends StatelessWidget {
  final double? value;
  final String? semanticLabel;
  final String? progressText;
  final bool announceProgress;

  const AccessibleProgressIndicator({
    super.key,
    this.value,
    this.semanticLabel,
    this.progressText,
    this.announceProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage = value != null ? (value! * 100).round() : null;
    final label = semanticLabel ?? 
        (progressPercentage != null 
            ? 'Progress: $progressPercentage percent complete'
            : 'Loading in progress');

    return Semantics(
      label: label,
      value: progressText ?? (progressPercentage?.toString()),
      liveRegion: announceProgress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: value),
          if (progressText != null) ...[
            const SizedBox(height: 8),
            Text(
              progressText!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// An accessible loading overlay with proper semantics
class AccessibleLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Widget? loadingWidget;

  const AccessibleLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Semantics(
                  label: loadingText ?? 'Loading, please wait',
                  liveRegion: true,
                  child: loadingWidget ?? 
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          if (loadingText != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              loadingText!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ],
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// An accessible expansion tile with proper semantics
class AccessibleExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final String? expandedSemanticLabel;
  final String? collapsedSemanticLabel;

  const AccessibleExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.children,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.expandedSemanticLabel,
    this.collapsedSemanticLabel,
  });

  @override
  State<AccessibleExpansionTile> createState() => _AccessibleExpansionTileState();
}

class _AccessibleExpansionTileState extends State<AccessibleExpansionTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final semanticLabel = _isExpanded 
        ? (widget.expandedSemanticLabel ?? 'Expanded section, tap to collapse')
        : (widget.collapsedSemanticLabel ?? 'Collapsed section, tap to expand');

    return Semantics(
      label: semanticLabel,
      button: true,
      expanded: _isExpanded,
      child: ExpansionTile(
        title: widget.title,
        subtitle: widget.subtitle,
        leading: widget.leading,
        initiallyExpanded: widget.initiallyExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
          widget.onExpansionChanged?.call(expanded);
        },
        children: widget.children,
      ),
    );
  }
}