import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/custom_tour_repository.dart';
import 'custom_tour_event.dart';
import 'custom_tour_state.dart';

class CustomTourBloc extends Bloc<CustomTourEvent, CustomTourState> {
  final CustomTourRepository _customTourRepository;

  CustomTourBloc({
    required CustomTourRepository customTourRepository,
  })  : _customTourRepository = customTourRepository,
        super(const CustomTourInitial()) {
    on<LoadCustomTours>(_onLoadCustomTours);
    on<LoadCustomTourById>(_onLoadCustomTourById);
    on<LoadCustomTourByJoinCode>(_onLoadCustomTourByJoinCode);
    on<CreateCustomTour>(_onCreateCustomTour);
    on<UpdateCustomTour>(_onUpdateCustomTour);
    on<DeleteCustomTour>(_onDeleteCustomTour);
    on<UpdateTourStatus>(_onUpdateTourStatus);
    on<PublishTour>(_onPublishTour);
    on<CancelTour>(_onCancelTour);
    on<StartTour>(_onStartTour);
    on<CompleteTour>(_onCompleteTour);
    on<UpdateTouristCount>(_onUpdateTouristCount);
    on<GenerateNewJoinCode>(_onGenerateNewJoinCode);
    on<SearchTours>(_onSearchTours);
    on<RefreshCustomTours>(_onRefreshCustomTours);
    on<ClearCustomTourError>(_onClearCustomTourError);
    on<FilterToursByStatus>(_onFilterToursByStatus);
  }

  Future<void> _onLoadCustomTours(
    LoadCustomTours event,
    Emitter<CustomTourState> emit,
  ) async {
    if (state is! CustomToursLoaded) {
      emit(const CustomTourLoading());
    }

    final result = await _customTourRepository.getCustomTours(
      providerId: event.providerId,
      status: event.status,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      onSuccess: (customTours) {
        final currentState = state;
        if (currentState is CustomToursLoaded && event.page != null && event.page! > 1) {
          // Append to existing list for pagination
          final updatedTours = List.of(currentState.customTours)
            ..addAll(customTours);
          emit(CustomToursLoaded(
            customTours: updatedTours,
            hasReachedMax: customTours.isEmpty,
            totalCount: currentState.totalCount + customTours.length,
            currentFilter: event.status,
          ));
        } else {
          // Replace list for initial load or refresh
          emit(CustomToursLoaded(
            customTours: customTours,
            hasReachedMax: customTours.isEmpty || (event.limit != null && customTours.length < event.limit!),
            totalCount: customTours.length,
            currentFilter: event.status,
          ));
        }
      },
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onLoadCustomTourById(
    LoadCustomTourById event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.getCustomTourById(event.id);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourLoaded(customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onLoadCustomTourByJoinCode(
    LoadCustomTourByJoinCode event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.getCustomTourByJoinCode(event.joinCode);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourLoaded(customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onCreateCustomTour(
    CreateCustomTour event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.createCustomTour(event.customTour);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourCreated(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onUpdateCustomTour(
    UpdateCustomTour event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.updateCustomTour(event.customTour);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourUpdated(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onDeleteCustomTour(
    DeleteCustomTour event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.deleteCustomTour(event.id);

    result.fold(
      onSuccess: (_) => emit(const CustomTourDeleted()),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onUpdateTourStatus(
    UpdateTourStatus event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.updateTourStatus(event.id, event.status);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourUpdated(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onPublishTour(
    PublishTour event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.publishTour(event.id);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourPublished(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onCancelTour(
    CancelTour event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.cancelTour(event.id);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourCancelled(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onStartTour(
    StartTour event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.startTour(event.id);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourStarted(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onCompleteTour(
    CompleteTour event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.completeTour(event.id);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourCompleted(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onUpdateTouristCount(
    UpdateTouristCount event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.updateTouristCount(event.id, event.count);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourTouristCountUpdated(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onGenerateNewJoinCode(
    GenerateNewJoinCode event,
    Emitter<CustomTourState> emit,
  ) async {
    emit(const CustomTourLoading());

    final result = await _customTourRepository.generateNewJoinCode(event.id);

    result.fold(
      onSuccess: (customTour) => emit(CustomTourJoinCodeGenerated(customTour: customTour)),
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onSearchTours(
    SearchTours event,
    Emitter<CustomTourState> emit,
  ) async {
    if (state is! CustomToursLoaded) {
      emit(const CustomTourLoading());
    }

    final result = await _customTourRepository.searchTours(
      query: event.query,
      tags: event.tags,
      startDateFrom: event.startDateFrom,
      startDateTo: event.startDateTo,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      status: event.status,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      onSuccess: (customTours) {
        emit(CustomToursLoaded(
          customTours: customTours,
          hasReachedMax: customTours.isEmpty || (event.limit != null && customTours.length < event.limit!),
          totalCount: customTours.length,
          currentFilter: event.status,
        ));
      },
      onFailure: (error) => emit(CustomTourError(message: error)),
    );
  }

  Future<void> _onRefreshCustomTours(
    RefreshCustomTours event,
    Emitter<CustomTourState> emit,
  ) async {
    // Reset to initial state and trigger a refresh
    emit(const CustomTourInitial());
  }

  void _onClearCustomTourError(
    ClearCustomTourError event,
    Emitter<CustomTourState> emit,
  ) {
    if (state is CustomTourError) {
      emit(const CustomTourInitial());
    }
  }

  Future<void> _onFilterToursByStatus(
    FilterToursByStatus event,
    Emitter<CustomTourState> emit,
  ) async {
    final currentState = state;
    if (currentState is CustomToursLoaded) {
      // Get the provider ID from the first tour if available
      final providerId = currentState.customTours.isNotEmpty 
          ? currentState.customTours.first.providerId 
          : null;
      
      add(LoadCustomTours(
        providerId: providerId,
        status: event.status,
        limit: 50,
      ));
    }
  }
}