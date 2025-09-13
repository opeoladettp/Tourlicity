import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_result.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

/// Bloc for managing user profile state
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<CompleteUserProfile>(_onCompleteUserProfile);
    on<CheckProfileCompletion>(_onCheckProfileCompletion);
    on<ResetUserState>(_onResetUserState);
  }

  /// Handle loading user profile
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _userRepository.getCurrentUser();

    if (result is ApiSuccess<User>) {
      emit(UserLoaded(user: result.data));
    } else {
      final failure = result as ApiFailure<User>;
      emit(UserError(
        message: failure.message,
        errorCode: failure.errorCode,
      ));
    }
  }

  /// Handle updating user profile
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserUpdating());

    final result = await _userRepository.updateProfile(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
    );

    if (result is ApiSuccess<User>) {
      emit(UserUpdated(user: result.data));
    } else {
      final failure = result as ApiFailure<User>;
      emit(UserError(
        message: failure.message,
        errorCode: failure.errorCode,
      ));
    }
  }

  /// Handle completing user profile
  Future<void> _onCompleteUserProfile(
    CompleteUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserProfileCompleting());

    final result = await _userRepository.completeProfile(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
    );

    if (result is ApiSuccess<User>) {
      emit(UserProfileCompleted(user: result.data));
    } else {
      final failure = result as ApiFailure<User>;
      emit(UserError(
        message: failure.message,
        errorCode: failure.errorCode,
      ));
    }
  }

  /// Handle checking profile completion
  Future<void> _onCheckProfileCompletion(
    CheckProfileCompletion event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    final result = await _userRepository.isProfileComplete();

    if (result is ApiSuccess<bool>) {
      emit(ProfileCompletionChecked(isComplete: result.data));
    } else {
      final failure = result as ApiFailure<bool>;
      emit(UserError(
        message: failure.message,
        errorCode: failure.errorCode,
      ));
    }
  }

  /// Handle resetting user state
  void _onResetUserState(
    ResetUserState event,
    Emitter<UserState> emit,
  ) {
    emit(const UserInitial());
  }
}
