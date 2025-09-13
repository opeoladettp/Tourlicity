import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_result.dart';
import '../../../domain/entities/provider.dart';
import '../../../domain/repositories/provider_repository.dart';
import 'provider_event.dart';
import 'provider_state.dart';

/// BLoC for managing provider-related state and operations
class ProviderBloc extends Bloc<ProviderEvent, ProviderState> {
  final ProviderRepository _providerRepository;

  ProviderBloc({
    required ProviderRepository providerRepository,
  })  : _providerRepository = providerRepository,
        super(const ProviderInitial()) {
    on<LoadProviders>(_onLoadProviders);
    on<LoadProviderById>(_onLoadProviderById);
    on<CreateProvider>(_onCreateProvider);
    on<UpdateProvider>(_onUpdateProvider);
    on<ActivateProvider>(_onActivateProvider);
    on<DeactivateProvider>(_onDeactivateProvider);
    on<DeleteProvider>(_onDeleteProvider);
    on<SearchProviders>(_onSearchProviders);
    on<ClearProviderSearch>(_onClearProviderSearch);
    on<RefreshProviders>(_onRefreshProviders);
  }

  Future<void> _onLoadProviders(
    LoadProviders event,
    Emitter<ProviderState> emit,
  ) async {
    // Show loading more if we already have providers and loading next page
    if (state is ProvidersLoaded && (event.page ?? 1) > 1) {
      final currentState = state as ProvidersLoaded;
      emit(ProviderLoadingMore(currentState.providers));
    } else {
      emit(const ProviderLoading());
    }

    final result = await _providerRepository.getProviders(
      search: event.search,
      country: event.country,
      isActive: event.isActive,
      page: event.page,
      limit: event.limit,
    );

    switch (result) {
      case ApiSuccess<List<Provider>>():
        final providers = result.data;
        final currentPage = event.page ?? 1;

        // If loading more, append to existing providers
        if (state is ProviderLoadingMore) {
          final currentState = state as ProviderLoadingMore;
          final allProviders = [...currentState.currentProviders, ...providers];
          emit(ProvidersLoaded(
            providers: allProviders,
            hasReachedMax:
                providers.isEmpty || providers.length < (event.limit ?? 20),
            currentPage: currentPage,
            currentSearch: event.search,
            currentCountry: event.country,
            currentIsActive: event.isActive,
          ));
        } else {
          emit(ProvidersLoaded(
            providers: providers,
            hasReachedMax:
                providers.isEmpty || providers.length < (event.limit ?? 20),
            currentPage: currentPage,
            currentSearch: event.search,
            currentCountry: event.country,
            currentIsActive: event.isActive,
          ));
        }
        break;
      case ApiFailure<List<Provider>>():
        emit(ProviderError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onLoadProviderById(
    LoadProviderById event,
    Emitter<ProviderState> emit,
  ) async {
    emit(const ProviderLoading());

    final result = await _providerRepository.getProviderById(event.id);

    switch (result) {
      case ApiSuccess():
        emit(ProviderLoaded(result.data));
        break;
      case ApiFailure():
        emit(ProviderError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onCreateProvider(
    CreateProvider event,
    Emitter<ProviderState> emit,
  ) async {
    emit(const ProviderLoading());

    final result = await _providerRepository.createProvider(event.provider);

    switch (result) {
      case ApiSuccess():
        emit(ProviderOperationSuccess(
          message: 'Provider created successfully',
          provider: result.data,
        ));
        // Refresh the providers list
        add(const RefreshProviders());
        break;
      case ApiFailure():
        emit(ProviderError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onUpdateProvider(
    UpdateProvider event,
    Emitter<ProviderState> emit,
  ) async {
    emit(const ProviderLoading());

    final result =
        await _providerRepository.updateProvider(event.id, event.provider);

    switch (result) {
      case ApiSuccess():
        emit(ProviderOperationSuccess(
          message: 'Provider updated successfully',
          provider: result.data,
        ));
        // Refresh the providers list
        add(const RefreshProviders());
        break;
      case ApiFailure():
        emit(ProviderError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onActivateProvider(
    ActivateProvider event,
    Emitter<ProviderState> emit,
  ) async {
    final result = await _providerRepository.activateProvider(event.id);

    switch (result) {
      case ApiSuccess():
        emit(ProviderOperationSuccess(
          message: 'Provider activated successfully',
          provider: result.data,
        ));
        // Update the provider in the current list if available
        if (state is ProvidersLoaded) {
          final currentState = state as ProvidersLoaded;
          final updatedProviders = currentState.providers.map((provider) {
            return provider.id == result.data.id ? result.data : provider;
          }).toList();
          emit(currentState.copyWith(providers: updatedProviders));
        }
        break;
      case ApiFailure():
        emit(ProviderError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onDeactivateProvider(
    DeactivateProvider event,
    Emitter<ProviderState> emit,
  ) async {
    final result = await _providerRepository.deactivateProvider(event.id);

    switch (result) {
      case ApiSuccess():
        emit(ProviderOperationSuccess(
          message: 'Provider deactivated successfully',
          provider: result.data,
        ));
        // Update the provider in the current list if available
        if (state is ProvidersLoaded) {
          final currentState = state as ProvidersLoaded;
          final updatedProviders = currentState.providers.map((provider) {
            return provider.id == result.data.id ? result.data : provider;
          }).toList();
          emit(currentState.copyWith(providers: updatedProviders));
        }
        break;
      case ApiFailure():
        emit(ProviderError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onDeleteProvider(
    DeleteProvider event,
    Emitter<ProviderState> emit,
  ) async {
    final result = await _providerRepository.deleteProvider(event.id);

    switch (result) {
      case ApiSuccess():
        emit(const ProviderOperationSuccess(
          message: 'Provider deleted successfully',
        ));
        // Remove the provider from the current list if available
        if (state is ProvidersLoaded) {
          final currentState = state as ProvidersLoaded;
          final updatedProviders = currentState.providers
              .where((provider) => provider.id != event.id)
              .toList();
          emit(currentState.copyWith(providers: updatedProviders));
        }
        break;
      case ApiFailure():
        emit(ProviderError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onSearchProviders(
    SearchProviders event,
    Emitter<ProviderState> emit,
  ) async {
    emit(const ProviderLoading());

    final result = await _providerRepository.searchProviders(event.query);

    switch (result) {
      case ApiSuccess():
        emit(ProviderSearchResults(
          searchResults: result.data,
          query: event.query,
        ));
        break;
      case ApiFailure():
        emit(ProviderError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onClearProviderSearch(
    ClearProviderSearch event,
    Emitter<ProviderState> emit,
  ) async {
    // Return to the last loaded providers state or load fresh
    add(const RefreshProviders());
  }

  Future<void> _onRefreshProviders(
    RefreshProviders event,
    Emitter<ProviderState> emit,
  ) async {
    // Get current filters if available
    String? search;
    String? country;
    bool? isActive;

    if (state is ProvidersLoaded) {
      final currentState = state as ProvidersLoaded;
      search = currentState.currentSearch;
      country = currentState.currentCountry;
      isActive = currentState.currentIsActive;
    }

    add(LoadProviders(
      search: search,
      country: country,
      isActive: isActive,
      page: 1,
    ));
  }
}
