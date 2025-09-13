import 'package:flutter/material.dart';

/// Bottom sheet for filtering tour templates
class TourTemplateFilterSheet extends StatefulWidget {
  final bool? currentIsActive;
  final DateTime? currentStartDateFrom;
  final DateTime? currentStartDateTo;
  final Function({
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
  }) onFilterChanged;

  const TourTemplateFilterSheet({
    super.key,
    this.currentIsActive,
    this.currentStartDateFrom,
    this.currentStartDateTo,
    required this.onFilterChanged,
  });

  @override
  State<TourTemplateFilterSheet> createState() =>
      _TourTemplateFilterSheetState();
}

class _TourTemplateFilterSheetState extends State<TourTemplateFilterSheet> {
  bool? _isActive;
  DateTime? _startDateFrom;
  DateTime? _startDateTo;

  @override
  void initState() {
    super.initState();
    _isActive = widget.currentIsActive;
    _startDateFrom = widget.currentStartDateFrom;
    _startDateTo = widget.currentStartDateTo;
  }

  void _applyFilters() {
    widget.onFilterChanged(
      isActive: _isActive,
      startDateFrom: _startDateFrom,
      startDateTo: _startDateTo,
    );
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _isActive = null;
      _startDateFrom = null;
      _startDateTo = null;
    });
  }

  Future<void> _selectStartDateFrom() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate:
          _startDateTo ?? DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _startDateFrom = date;
        // Clear end date if it's before the new start date
        if (_startDateTo != null && _startDateTo!.isBefore(date)) {
          _startDateTo = null;
        }
      });
    }
  }

  Future<void> _selectStartDateTo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDateTo ?? _startDateFrom ?? DateTime.now(),
      firstDate: _startDateFrom ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      setState(() {
        _startDateTo = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Templates',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status Filter
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool?>(
            segments: const [
              ButtonSegment<bool?>(
                value: null,
                label: Text('All'),
              ),
              ButtonSegment<bool?>(
                value: true,
                label: Text('Active'),
              ),
              ButtonSegment<bool?>(
                value: false,
                label: Text('Inactive'),
              ),
            ],
            selected: {_isActive},
            onSelectionChanged: (Set<bool?> selection) {
              setState(() {
                _isActive = selection.first;
              });
            },
          ),
          const SizedBox(height: 24),

          // Date Range Filter
          Text(
            'Start Date Range',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'From',
                  date: _startDateFrom,
                  onTap: _selectStartDateFrom,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  label: 'To',
                  date: _startDateTo,
                  onTap: _selectStartDateTo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
          style: date != null
              ? null
              : TextStyle(
                  color: Theme.of(context).hintColor,
                ),
        ),
      ),
    );
  }
}
