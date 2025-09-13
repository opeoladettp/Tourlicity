import 'package:equatable/equatable.dart';
import '../../../domain/entities/provider.dart';

/// States for ProviderBloc
abstract class ProviderState extends Equatable {
  const ProviderState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProviderInitial extends ProviderState {
  const ProviderInitial();
}

/// Loading state
class ProviderLoading extends ProviderState {
  const ProviderLoading();
}

/// Providers loaded successfully
class ProvidersLoaded extends ProviderState {
  final List<Provider> providers;
  final bool hasReachedMax;
  final int currentPage;
  final String? currentSearch;
  final String? currentCountry;
  final bool? currentIsActive;

  const ProvidersLoaded({
    required this.providers,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.currentSearch,
    this.currentCountry,
    this.currentIsActive,
  });

  ProvidersLoaded copyWith({
    List<Provider>? providers,
    bool? hasReachedMax,
    int? currentPage,
    String? currentSearch,
    String? currentCountry,
    bool? currentIsActive,
  }) {
    return ProvidersLoaded(
      providers: providers ?? this.providers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentSearch: currentSearch ?? this.currentSearch,
      currentCountry: currentCountry ?? this.currentCountry,
      currentIsActive: currentIsActive ?? this.currentIsActive,
    );
  }

  @override
  List<Object?> get props => [
        providers,
        hasReachedMax,
        currentPage,
        currentSearch,
        currentCountry,
        currentIsActive,
      ];
}

/// Single provider loaded successfully
class ProviderLoaded extends ProviderState {
  final Provider provider;

  const ProviderLoaded(this.provider);

  @override
  List<Object> get props => [provider];
}

/// Provider operation successful (create, update, activate, deactivate, delete)
class ProviderOperationSuccess extends ProviderState {
  final String message;
  final Provider? provider;

  const ProviderOperationSuccess({
    required this.message,
    this.provider,
  });

  @override
  List<Object?> get props => [message, provider];
}

/// Provider search results
class ProviderSearchResults extends ProviderState {
  final List<Provider> searchResults;
  final String query;

  const ProviderSearchResults({
    required this.searchResults,
    required this.query,
  });

  @override
  List<Object> get props => [searchResults, query];
}

/// Error state
class ProviderError extends ProviderState {
  final String message;
  final String? errorCode;

  const ProviderError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Loading more providers (for pagination)
class ProviderLoadingMore extends ProviderState {
  final List<Provider> currentProviders;

  const ProviderLoadingMore(this.currentProviders);

  @override
  List<Object> get props => [currentProviders];
}
