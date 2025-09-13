import 'package:flutter/material.dart';

/// Search bar widget for tour templates
class TourTemplateSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final String? hintText;

  const TourTemplateSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hintText,
  });

  @override
  State<TourTemplateSearchBar> createState() => _TourTemplateSearchBarState();
}

class _TourTemplateSearchBarState extends State<TourTemplateSearchBar> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search tour templates...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.onSearch('');
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
      ),
      onChanged: widget.onSearch,
      onSubmitted: widget.onSearch,
    );
  }
}
