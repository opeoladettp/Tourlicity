import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/tour_template.dart';
import '../../../domain/entities/web_link.dart';
import '../../blocs/tour_template/tour_template_bloc.dart';
import '../../blocs/tour_template/tour_template_event.dart';
import '../../blocs/tour_template/tour_template_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/forms/tour_template_form.dart';

/// Page for creating and editing tour templates
class TourTemplateFormPage extends StatefulWidget {
  final TourTemplate? template;

  const TourTemplateFormPage({
    super.key,
    this.template,
  });

  @override
  State<TourTemplateFormPage> createState() => _TourTemplateFormPageState();
}

class _TourTemplateFormPageState extends State<TourTemplateFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _templateNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  List<WebLink> _webLinks = [];

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (_isEditing) {
      final template = widget.template!;
      _templateNameController.text = template.templateName;
      _descriptionController.text = template.description;
      _startDate = template.startDate;
      _endDate = template.endDate;
      _isActive = template.isActive;
      _webLinks = List.from(template.webLinks);
    }
  }

  @override
  void dispose() {
    _templateNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
        ),
      );
      return;
    }

    final template = TourTemplate(
      id: _isEditing ? widget.template!.id : '',
      title: _templateNameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? 'No description provided'
          : _descriptionController.text.trim(),
      duration: 24, // Default 1 day in hours
      price: 0.0, // Default price
      maxParticipants: 10, // Default max participants
      providerId: context.read<AuthBloc>().state.user?.id ?? 'default-provider',
      isActive: _isActive,
      webLinks: _webLinks,
      templateName: _templateNameController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      createdDate: _isEditing ? widget.template!.createdDate : DateTime.now(),
    );

    if (_isEditing) {
      context.read<TourTemplateBloc>().add(
            UpdateTourTemplate(widget.template!.id, template),
          );
    } else {
      context.read<TourTemplateBloc>().add(
            CreateTourTemplate(template),
          );
    }
  }

  void _onStartDateChanged(DateTime? date) {
    setState(() {
      _startDate = date;
      // If end date is before new start date, clear it
      if (_endDate != null && date != null && _endDate!.isBefore(date)) {
        _endDate = null;
      }
    });
  }

  void _onEndDateChanged(DateTime? date) {
    setState(() {
      _endDate = date;
    });
  }

  void _onActiveChanged(bool value) {
    setState(() {
      _isActive = value;
    });
  }

  void _onWebLinksChanged(List<WebLink> webLinks) {
    setState(() {
      _webLinks = webLinks;
    });
  }

  int get _durationDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Tour Template' : 'Create Tour Template'),
        actions: [
          TextButton(
            onPressed: _onSubmit,
            child: Text(_isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
      body: BlocConsumer<TourTemplateBloc, TourTemplateState>(
        listener: (context, state) {
          if (state is TourTemplateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is TourTemplateOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is TourTemplateLoading) {
            return const LoadingWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Template Name
                  TextFormField(
                    controller: _templateNameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name *',
                      hintText: 'Enter template name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Template name is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Template name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter template description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Date Selection Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Start Date *',
                          date: _startDate,
                          onDateSelected: _onStartDateChanged,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'End Date *',
                          date: _endDate,
                          onDateSelected: _onEndDateChanged,
                          firstDate: _startDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Duration Display
                  if (_durationDays > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: $_durationDays ${_durationDays == 1 ? 'day' : 'days'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Active Status
                  SwitchListTile(
                    title: const Text('Active Template'),
                    subtitle:
                        const Text('Template can be used to create tours'),
                    value: _isActive,
                    onChanged: _onActiveChanged,
                  ),
                  const SizedBox(height: 24),

                  // Web Links Section
                  TourTemplateForm(
                    webLinks: _webLinks,
                    onWebLinksChanged: _onWebLinksChanged,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  FilledButton(
                    onPressed: state is TourTemplateLoading ? null : _onSubmit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _isEditing ? 'Update Template' : 'Create Template',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime?> onDateSelected,
    DateTime? firstDate,
  }) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
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
