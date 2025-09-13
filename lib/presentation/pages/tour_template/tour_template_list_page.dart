import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/tour_template.dart';
import '../../blocs/tour_template/tour_template_bloc.dart';
import '../../blocs/tour_template/tour_template_event.dart';
import '../../blocs/tour_template/tour_template_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/tour_template/tour_template_list_item.dart';
import '../../widgets/tour_template/tour_template_search_bar.dart';
import '../../widgets/tour_template/tour_template_filter_sheet.dart';
import 'tour_template_form_page.dart';

/// Page displaying list of tour templates with search and filtering capabilities
class TourTemplateListPage extends StatefulWidget {
  const TourTemplateListPage({super.key});

  @override
  State<TourTemplateListPage> createState() => _TourTemplateListPageState();
}

class _TourTemplateListPageState extends State<TourTemplateListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool? _currentActiveFilter;
  DateTime? _currentStartDateFrom;
  DateTime? _currentStartDateTo;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial tour templates
    context.read<TourTemplateBloc>().add(const LoadTourTemplates());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<TourTemplateBloc>().state;
      if (state is TourTemplatesLoaded && !state.hasReachedMax) {
        context.read<TourTemplateBloc>().add(LoadTourTemplates(
              search: state.currentSearch,
              isActive: state.currentIsActive,
              startDateFrom: state.currentStartDateFrom,
              startDateTo: state.currentStartDateTo,
              page: state.currentPage + 1,
            ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<TourTemplateBloc>().add(LoadTourTemplates(
            isActive: _currentActiveFilter,
            startDateFrom: _currentStartDateFrom,
            startDateTo: _currentStartDateTo,
          ));
    } else {
      context.read<TourTemplateBloc>().add(LoadTourTemplates(
            search: query.trim(),
            isActive: _currentActiveFilter,
            startDateFrom: _currentStartDateFrom,
            startDateTo: _currentStartDateTo,
          ));
    }
  }

  void _onFilterChanged({
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
  }) {
    setState(() {
      _currentActiveFilter = isActive;
      _currentStartDateFrom = startDateFrom;
      _currentStartDateTo = startDateTo;
    });

    context.read<TourTemplateBloc>().add(LoadTourTemplates(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          isActive: isActive,
          startDateFrom: startDateFrom,
          startDateTo: startDateTo,
        ));
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TourTemplateFilterSheet(
        currentIsActive: _currentActiveFilter,
        currentStartDateFrom: _currentStartDateFrom,
        currentStartDateTo: _currentStartDateTo,
        onFilterChanged: _onFilterChanged,
      ),
    );
  }

  void _navigateToCreateTemplate() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const TourTemplateFormPage(),
      ),
    );
  }

  void _navigateToEditTemplate(TourTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TourTemplateFormPage(template: template),
      ),
    );
  }

  void _onTemplateAction(TourTemplate template, String action) {
    switch (action) {
      case 'edit':
        _navigateToEditTemplate(template);
        break;
      case 'activate':
        context.read<TourTemplateBloc>().add(ActivateTourTemplate(template.id));
        break;
      case 'deactivate':
        context
            .read<TourTemplateBloc>()
            .add(DeactivateTourTemplate(template.id));
        break;
      case 'delete':
        _showDeleteConfirmation(template);
        break;
    }
  }

  void _showDeleteConfirmation(TourTemplate template) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tour Template'),
        content: Text(
          'Are you sure you want to delete "${template.templateName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<TourTemplateBloc>()
                  .add(DeleteTourTemplate(template.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onRefresh() {
    context.read<TourTemplateBloc>().add(const RefreshTourTemplates());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Templates'),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter templates',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TourTemplateSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
            ),
          ),
          Expanded(
            child: BlocConsumer<TourTemplateBloc, TourTemplateState>(
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
                }
              },
              builder: (context, state) {
                if (state is TourTemplateLoading) {
                  return const LoadingWidget();
                }

                if (state is TourTemplateError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: _onRefresh,
                  );
                }

                if (state is TourTemplatesLoaded) {
                  if (state.templates.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: state.templates.length +
                          (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.templates.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final template = state.templates[index];
                        return TourTemplateListItem(
                          template: template,
                          onAction: (action) =>
                              _onTemplateAction(template, action),
                        );
                      },
                    ),
                  );
                }

                if (state is TourTemplateLoadingMore) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: state.currentTemplates.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.currentTemplates.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final template = state.currentTemplates[index];
                        return TourTemplateListItem(
                          template: template,
                          onAction: (action) =>
                              _onTemplateAction(template, action),
                        );
                      },
                    ),
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTemplate,
        tooltip: 'Add Tour Template',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No tour templates found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new tour template to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _navigateToCreateTemplate,
            icon: const Icon(Icons.add),
            label: const Text('Add Template'),
          ),
        ],
      ),
    );
  }
}
