import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/registration_repository.dart';
import 'registration_event.dart';
import 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegistrationRepository _registrationRepository;

  RegistrationBloc({
    required RegistrationRepository registrationRepository,
  })  : _registrationRepository = registrationRepository,
        super(const RegistrationInitial()) {
    on<RegisterForTour>(_onRegisterForTour);
    on<LoadRegistrationById>(_onLoadRegistrationById);
    on<LoadRegistrationsByTourist>(_onLoadRegistrationsByTourist);
    on<LoadRegistrationsByTour>(_onLoadRegistrationsByTour);
    on<ApproveRegistration>(_onApproveRegistration);
    on<RejectRegistration>(_onRejectRegistration);
    on<CancelRegistration>(_onCancelRegistration);
    on<UpdateRegistration>(_onUpdateRegistration);
    on<LoadRegistrationByConfirmationCode>(_onLoadRegistrationByConfirmationCode);
    on<CompleteRegistration>(_onCompleteRegistration);
    on<LoadRegistrationStats>(_onLoadRegistrationStats);
    on<RefreshRegistrations>(_onRefreshRegistrations);
    on<ClearRegistrationError>(_onClearRegistrationError);
  }

  Future<void> _onRegisterForTour(
    RegisterForTour event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.registerForTour(
      joinCode: event.joinCode,
      touristId: event.touristId,
      specialRequirements: event.specialRequirements,
      emergencyContactName: event.emergencyContactName,
      emergencyContactPhone: event.emergencyContactPhone,
    );

    result.fold(
      onSuccess: (registration) => emit(RegistrationSuccess(registration)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onLoadRegistrationById(
    LoadRegistrationById event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.getRegistrationById(
      event.registrationId,
    );

    result.fold(
      onSuccess: (registration) => emit(RegistrationSuccess(registration)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onLoadRegistrationsByTourist(
    LoadRegistrationsByTourist event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state is! RegistrationsLoaded) {
      emit(const RegistrationLoading());
    }

    final result = await _registrationRepository.getRegistrationsByTourist(
      event.touristId,
      status: event.status,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      onSuccess: (registrations) {
        final currentState = state;
        if (currentState is RegistrationsLoaded && event.offset != null && event.offset! > 0) {
          // Append to existing list for pagination
          final updatedRegistrations = List.of(currentState.registrations)
            ..addAll(registrations);
          emit(RegistrationsLoaded(
            registrations: updatedRegistrations,
            hasReachedMax: registrations.isEmpty,
            totalCount: currentState.totalCount + registrations.length,
          ));
        } else {
          // Replace list for initial load or refresh
          emit(RegistrationsLoaded(
            registrations: registrations,
            hasReachedMax: registrations.isEmpty || (event.limit != null && registrations.length < event.limit!),
            totalCount: registrations.length,
          ));
        }
      },
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onLoadRegistrationsByTour(
    LoadRegistrationsByTour event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state is! RegistrationsLoaded) {
      emit(const RegistrationLoading());
    }

    final result = await _registrationRepository.getRegistrationsByTour(
      event.customTourId,
      status: event.status,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      onSuccess: (registrations) {
        final currentState = state;
        if (currentState is RegistrationsLoaded && event.offset != null && event.offset! > 0) {
          // Append to existing list for pagination
          final updatedRegistrations = List.of(currentState.registrations)
            ..addAll(registrations);
          emit(RegistrationsLoaded(
            registrations: updatedRegistrations,
            hasReachedMax: registrations.isEmpty,
            totalCount: currentState.totalCount + registrations.length,
          ));
        } else {
          // Replace list for initial load or refresh
          emit(RegistrationsLoaded(
            registrations: registrations,
            hasReachedMax: registrations.isEmpty || (event.limit != null && registrations.length < event.limit!),
            totalCount: registrations.length,
          ));
        }
      },
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onApproveRegistration(
    ApproveRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.approveRegistration(
      event.registrationId,
      notes: event.notes,
    );

    result.fold(
      onSuccess: (registration) => emit(RegistrationApproved(registration: registration)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onRejectRegistration(
    RejectRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.rejectRegistration(
      event.registrationId,
      reason: event.reason,
    );

    result.fold(
      onSuccess: (registration) => emit(RegistrationRejected(registration: registration)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onCancelRegistration(
    CancelRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.cancelRegistration(
      event.registrationId,
    );

    result.fold(
      onSuccess: (registration) => emit(RegistrationCancelled(registration: registration)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onUpdateRegistration(
    UpdateRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.updateRegistration(
      event.registrationId,
      specialRequirements: event.specialRequirements,
      emergencyContactName: event.emergencyContactName,
      emergencyContactPhone: event.emergencyContactPhone,
    );

    result.fold(
      onSuccess: (registration) => emit(RegistrationUpdated(registration: registration)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onLoadRegistrationByConfirmationCode(
    LoadRegistrationByConfirmationCode event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.getRegistrationByConfirmationCode(
      event.confirmationCode,
    );

    result.fold(
      onSuccess: (registration) => emit(RegistrationSuccess(registration)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onCompleteRegistration(
    CompleteRegistration event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.completeRegistration(
      event.registrationId,
    );

    result.fold(
      onSuccess: (registration) => emit(RegistrationCompleted(registration: registration)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onLoadRegistrationStats(
    LoadRegistrationStats event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registrationRepository.getRegistrationStats(
      event.customTourId,
    );

    result.fold(
      onSuccess: (stats) => emit(RegistrationStatsLoaded(stats)),
      onFailure: (error) => emit(RegistrationError(message: error)),
    );
  }

  Future<void> _onRefreshRegistrations(
    RefreshRegistrations event,
    Emitter<RegistrationState> emit,
  ) async {
    // Reset to initial state and trigger a refresh
    emit(const RegistrationInitial());
  }

  void _onClearRegistrationError(
    ClearRegistrationError event,
    Emitter<RegistrationState> emit,
  ) {
    if (state is RegistrationError) {
      emit(const RegistrationInitial());
    }
  }
}