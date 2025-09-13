import 'package:flutter/material.dart';

/// Search bar widget for providers
class ProviderSearchBar extends StatelessWidget {
  const ProviderSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Search providers...',
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
