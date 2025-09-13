import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_result.dart';
import '../../../domain/repositories/tour_template_repository.dart';
import 'tour_template_event.dart';
import 'tour_template_state.dart';

/// BLoC for managing tour template-related state and operations
class TourTemplateBloc extends Bloc<TourTemplateEvent, TourTemplateState> {
  final TourTemplateRepository _tourTemplateRepository;

  TourTemplateBloc({
    required TourTemplateRepository tourTemplateRepository,
  })  : _tourTemplateRepository = tourTemplateRepository,
        super(const TourTemplateInitial()) {
    on<LoadTourTemplates>(_onLoadTourTemplates);
    on<LoadTourTemplateById>(_onLoadTourTemplateById);
    on<CreateTourTemplate>(_onCreateTourTemplate);
    on<UpdateTourTemplate>(_onUpdateTourTemplate);
    on<ActivateTourTemplate>(_onActivateTourTemplate);
    on<DeactivateTourTemplate>(_onDeactivateTourTemplate);
    on<DeleteTourTemplate>(_onDeleteTourTemplate);
    on<SearchTourTemplates>(_onSearchTourTemplates);
    on<ClearTourTemplateSearch>(_onClearTourTemplateSearch);
    on<RefreshTourTemplates>(_onRefreshTourTemplates);
  }

  Future<void> _onLoadTourTemplates(
    LoadTourTemplates event,
    Emitter<TourTemplateState> emit,
  ) async {
    // Show loading more if we already have templates and loading next page
    if (state is TourTemplatesLoaded && (event.page ?? 1) > 1) {
      final currentState = state as TourTemplatesLoaded;
      emit(TourTemplateLoadingMore(currentState.templates));
    } else {
      emit(const TourTemplateLoading());
    }

    final result = await _tourTemplateRepository.getTourTemplates(
      search: event.search,
      isActive: event.isActive,
      startDateFrom: event.startDateFrom,
      startDateTo: event.startDateTo,
      page: event.page,
      limit: event.limit,
    );

    switch (result) {
      case ApiSuccess():
        final templates = result.data;
        final currentPage = event.page ?? 1;

        // If loading more, append to existing templates
        if (state is TourTemplateLoadingMore) {
          final currentState = state as TourTemplateLoadingMore;
          final allTemplates = [...currentState.currentTemplates, ...templates];
          emit(TourTemplatesLoaded(
            templates: allTemplates,
            hasReachedMax:
                templates.isEmpty || templates.length < (event.limit ?? 20),
            currentPage: currentPage,
            currentSearch: event.search,
            currentIsActive: event.isActive,
            currentStartDateFrom: event.startDateFrom,
            currentStartDateTo: event.startDateTo,
          ));
        } else {
          emit(TourTemplatesLoaded(
            templates: templates,
            hasReachedMax:
                templates.isEmpty || templates.length < (event.limit ?? 20),
            currentPage: currentPage,
            currentSearch: event.search,
            currentIsActive: event.isActive,
            currentStartDateFrom: event.startDateFrom,
            currentStartDateTo: event.startDateTo,
          ));
        }
        break;
      case ApiFailure():
        emit(TourTemplateError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onLoadTourTemplateById(
    LoadTourTemplateById event,
    Emitter<TourTemplateState> emit,
  ) async {
    emit(const TourTemplateLoading());

    final result = await _tourTemplateRepository.getTourTemplateById(event.id);

    switch (result) {
      case ApiSuccess():
        emit(TourTemplateLoaded(result.data));
        break;
      case ApiFailure():
        emit(TourTemplateError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onCreateTourTemplate(
    CreateTourTemplate event,
    Emitter<TourTemplateState> emit,
  ) async {
    emit(const TourTemplateLoading());

    final result =
        await _tourTemplateRepository.createTourTemplate(event.template);

    switch (result) {
      case ApiSuccess():
        emit(TourTemplateOperationSuccess(
          message: 'Tour template created successfully',
          template: result.data,
        ));
        // Refresh the templates list
        add(const RefreshTourTemplates());
        break;
      case ApiFailure():
        emit(TourTemplateError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onUpdateTourTemplate(
    UpdateTourTemplate event,
    Emitter<TourTemplateState> emit,
  ) async {
    emit(const TourTemplateLoading());

    final result = await _tourTemplateRepository.updateTourTemplate(
        event.id, event.template);

    switch (result) {
      case ApiSuccess():
        emit(TourTemplateOperationSuccess(
          message: 'Tour template updated successfully',
          template: result.data,
        ));
        // Refresh the templates list
        add(const RefreshTourTemplates());
        break;
      case ApiFailure():
        emit(TourTemplateError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onActivateTourTemplate(
    ActivateTourTemplate event,
    Emitter<TourTemplateState> emit,
  ) async {
    final result = await _tourTemplateRepository.activateTourTemplate(event.id);

    switch (result) {
      case ApiSuccess():
        emit(TourTemplateOperationSuccess(
          message: 'Tour template activated successfully',
          template: result.data,
        ));
        // Update the template in the current list if available
        if (state is TourTemplatesLoaded) {
          final currentState = state as TourTemplatesLoaded;
          final updatedTemplates = currentState.templates.map((template) {
            return template.id == result.data.id ? result.data : template;
          }).toList();
          emit(currentState.copyWith(templates: updatedTemplates));
        }
        break;
      case ApiFailure():
        emit(TourTemplateError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onDeactivateTourTemplate(
    DeactivateTourTemplate event,
    Emitter<TourTemplateState> emit,
  ) async {
    final result =
        await _tourTemplateRepository.deactivateTourTemplate(event.id);

    switch (result) {
      case ApiSuccess():
        emit(TourTemplateOperationSuccess(
          message: 'Tour template deactivated successfully',
          template: result.data,
        ));
        // Update the template in the current list if available
        if (state is TourTemplatesLoaded) {
          final currentState = state as TourTemplatesLoaded;
          final updatedTemplates = currentState.templates.map((template) {
            return template.id == result.data.id ? result.data : template;
          }).toList();
          emit(currentState.copyWith(templates: updatedTemplates));
        }
        break;
      case ApiFailure():
        emit(TourTemplateError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onDeleteTourTemplate(
    DeleteTourTemplate event,
    Emitter<TourTemplateState> emit,
  ) async {
    final result = await _tourTemplateRepository.deleteTourTemplate(event.id);

    switch (result) {
      case ApiSuccess():
        emit(const TourTemplateOperationSuccess(
          message: 'Tour template deleted successfully',
        ));
        // Remove the template from the current list if available
        if (state is TourTemplatesLoaded) {
          final currentState = state as TourTemplatesLoaded;
          final updatedTemplates = currentState.templates
              .where((template) => template.id != event.id)
              .toList();
          emit(currentState.copyWith(templates: updatedTemplates));
        }
        break;
      case ApiFailure():
        emit(TourTemplateError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onSearchTourTemplates(
    SearchTourTemplates event,
    Emitter<TourTemplateState> emit,
  ) async {
    emit(const TourTemplateLoading());

    final result =
        await _tourTemplateRepository.searchTourTemplates(event.query);

    switch (result) {
      case ApiSuccess():
        emit(TourTemplateSearchResults(
          searchResults: result.data,
          query: event.query,
        ));
        break;
      case ApiFailure():
        emit(TourTemplateError(
          message: result.message,
          errorCode: result.errorCode,
        ));
        break;
    }
  }

  Future<void> _onClearTourTemplateSearch(
    ClearTourTemplateSearch event,
    Emitter<TourTemplateState> emit,
  ) async {
    // Return to the last loaded templates state or load fresh
    add(const RefreshTourTemplates());
  }

  Future<void> _onRefreshTourTemplates(
    RefreshTourTemplates event,
    Emitter<TourTemplateState> emit,
  ) async {
    // Get current filters if available
    String? search;
    bool? isActive;
    DateTime? startDateFrom;
    DateTime? startDateTo;

    if (state is TourTemplatesLoaded) {
      final currentState = state as TourTemplatesLoaded;
      search = currentState.currentSearch;
      isActive = currentState.currentIsActive;
      startDateFrom = currentState.currentStartDateFrom;
      startDateTo = currentState.currentStartDateTo;
    }

    add(LoadTourTemplates(
      search: search,
      isActive: isActive,
      startDateFrom: startDateFrom,
      startDateTo: startDateTo,
      page: 1,
    ));
  }
}
