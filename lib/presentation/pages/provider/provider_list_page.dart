import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/provider.dart';
import '../../blocs/provider/provider_bloc.dart';
import '../../blocs/provider/provider_event.dart';
import '../../blocs/provider/provider_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/provider/provider_list_item.dart';
import '../../widgets/provider/provider_search_bar.dart';
import '../../widgets/provider/provider_filter_sheet.dart';
import 'provider_form_page.dart';

/// Page displaying list of providers with search and filtering capabilities
class ProviderListPage extends StatefulWidget {
  const ProviderListPage({super.key});

  @override
  State<ProviderListPage> createState() => _ProviderListPageState();
}

class _ProviderListPageState extends State<ProviderListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String? _currentCountryFilter;
  bool? _currentActiveFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial providers
    context.read<ProviderBloc>().add(const LoadProviders());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ProviderBloc>().state;
      if (state is ProvidersLoaded && !state.hasReachedMax) {
        context.read<ProviderBloc>().add(LoadProviders(
              search: state.currentSearch,
              country: state.currentCountry,
              isActive: state.currentIsActive,
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
      context.read<ProviderBloc>().add(LoadProviders(
            country: _currentCountryFilter,
            isActive: _currentActiveFilter,
          ));
    } else {
      context.read<ProviderBloc>().add(LoadProviders(
            search: query.trim(),
            country: _currentCountryFilter,
            isActive: _currentActiveFilter,
          ));
    }
  }

  void _loadProviders() {
    context.read<ProviderBloc>().add(LoadProviders(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          country: _currentCountryFilter,
          isActive: _currentActiveFilter,
        ));
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProviderFilterSheet(
        initialActiveOnly: _currentActiveFilter ?? false,
        onApplyFilters: (activeOnly) {
          setState(() {
            _currentActiveFilter = activeOnly;
          });
          _loadProviders();
        },
      ),
    );
  }

  void _navigateToCreateProvider() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ProviderFormPage(),
      ),
    );
  }

  void _navigateToProviderDetails(Provider provider) {
    Navigator.pushNamed(
      context, 
      '/providers/details',
      arguments: provider.id,
    );
  }

  void _navigateToEditProvider(Provider provider) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ProviderFormPage(provider: provider),
      ),
    );
  }

  void _showDeleteConfirmation(Provider provider) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Provider'),
        content: Text(
          'Are you sure you want to delete "${provider.providerName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProviderBloc>().add(DeleteProvider(provider.id));
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
    context.read<ProviderBloc>().add(const RefreshProviders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers'),
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter providers',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ProviderSearchBar(
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: BlocConsumer<ProviderBloc, ProviderState>(
              listener: (context, state) {
                if (state is ProviderError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                } else if (state is ProviderOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProviderLoading) {
                  return const LoadingWidget();
                }

                if (state is ProviderError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: _onRefresh,
                  );
                }

                if (state is ProvidersLoaded) {
                  if (state.providers.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: state.providers.length +
                          (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.providers.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final provider = state.providers[index];
                        return ProviderListItem(
                          provider: provider,
                          onTap: () => _navigateToProviderDetails(provider),
                          onEdit: () => _navigateToEditProvider(provider),
                          onDelete: () => _showDeleteConfirmation(provider),
                        );
                      },
                    ),
                  );
                }

                if (state is ProviderLoadingMore) {
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: state.currentProviders.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.currentProviders.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final provider = state.currentProviders[index];
                        return ProviderListItem(
                          provider: provider,
                          onTap: () => _navigateToProviderDetails(provider),
                          onEdit: () => _navigateToEditProvider(provider),
                          onDelete: () => _showDeleteConfirmation(provider),
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
        onPressed: _navigateToCreateProvider,
        tooltip: 'Add Provider',
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
            Icons.business,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No providers found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new provider to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _navigateToCreateProvider,
            icon: const Icon(Icons.add),
            label: const Text('Add Provider'),
          ),
        ],
      ),
    );
  }
}
