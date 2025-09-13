import 'package:flutter/material.dart';

/// Filter sheet for providers
class ProviderFilterSheet extends StatefulWidget {
  const ProviderFilterSheet({
    super.key,
    this.initialActiveOnly = false,
    this.onApplyFilters,
  });

  final bool initialActiveOnly;
  final Function(bool activeOnly)? onApplyFilters;

  @override
  State<ProviderFilterSheet> createState() => _ProviderFilterSheetState();
}

class _ProviderFilterSheetState extends State<ProviderFilterSheet> {
  late bool _activeOnly;

  @override
  void initState() {
    super.initState();
    _activeOnly = widget.initialActiveOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Providers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Active providers only'),
            value: _activeOnly,
            onChanged: (value) {
              setState(() {
                _activeOnly = value ?? false;
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _activeOnly = false;
                    });
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters?.call(_activeOnly);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
