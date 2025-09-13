import 'package:equatable/equatable.dart';
import '../../../domain/entities/provider.dart';

/// Events for ProviderBloc
abstract class ProviderEvent extends Equatable {
  const ProviderEvent();

  @override
  List<Object?> get props => [];
}

/// Load providers with optional filters
class LoadProviders extends ProviderEvent {
  final String? search;
  final String? country;
  final bool? isActive;
  final int? page;
  final int? limit;

  const LoadProviders({
    this.search,
    this.country,
    this.isActive,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [search, country, isActive, page, limit];
}

/// Load a specific provider by ID
class LoadProviderById extends ProviderEvent {
  final String id;

  const LoadProviderById(this.id);

  @override
  List<Object> get props => [id];
}

/// Create a new provider
class CreateProvider extends ProviderEvent {
  final Provider provider;

  const CreateProvider(this.provider);

  @override
  List<Object> get props => [provider];
}

/// Update an existing provider
class UpdateProvider extends ProviderEvent {
  final String id;
  final Provider provider;

  const UpdateProvider(this.id, this.provider);

  @override
  List<Object> get props => [id, provider];
}

/// Activate a provider
class ActivateProvider extends ProviderEvent {
  final String id;

  const ActivateProvider(this.id);

  @override
  List<Object> get props => [id];
}

/// Deactivate a provider
class DeactivateProvider extends ProviderEvent {
  final String id;

  const DeactivateProvider(this.id);

  @override
  List<Object> get props => [id];
}

/// Delete a provider
class DeleteProvider extends ProviderEvent {
  final String id;

  const DeleteProvider(this.id);

  @override
  List<Object> get props => [id];
}

/// Search providers by query
class SearchProviders extends ProviderEvent {
  final String query;

  const SearchProviders(this.query);

  @override
  List<Object> get props => [query];
}

/// Clear provider search results
class ClearProviderSearch extends ProviderEvent {
  const ClearProviderSearch();
}

/// Refresh providers list
class RefreshProviders extends ProviderEvent {
  const RefreshProviders();
}
