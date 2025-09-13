import 'package:equatable/equatable.dart';
import '../../../domain/entities/registration.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();
}

class RegistrationLoading extends RegistrationState {
  const RegistrationLoading();
}

class RegistrationSuccess extends RegistrationState {
  final Registration registration;

  const RegistrationSuccess(this.registration);

  @override
  List<Object> get props => [registration];
}

class RegistrationsLoaded extends RegistrationState {
  final List<Registration> registrations;
  final bool hasReachedMax;
  final int totalCount;

  const RegistrationsLoaded({
    required this.registrations,
    this.hasReachedMax = false,
    this.totalCount = 0,
  });

  @override
  List<Object> get props => [registrations, hasReachedMax, totalCount];

  RegistrationsLoaded copyWith({
    List<Registration>? registrations,
    bool? hasReachedMax,
    int? totalCount,
  }) {
    return RegistrationsLoaded(
      registrations: registrations ?? this.registrations,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class RegistrationStatsLoaded extends RegistrationState {
  final Map<String, int> stats;

  const RegistrationStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class RegistrationError extends RegistrationState {
  final String message;
  final String? errorCode;

  const RegistrationError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class RegistrationOperationSuccess extends RegistrationState {
  final Registration registration;
  final String message;

  const RegistrationOperationSuccess({
    required this.registration,
    required this.message,
  });

  @override
  List<Object> get props => [registration, message];
}

// Specific states for different operations
class RegistrationApproved extends RegistrationOperationSuccess {
  const RegistrationApproved({
    required super.registration,
  }) : super(
          message: 'Registration approved successfully',
        );
}

class RegistrationRejected extends RegistrationOperationSuccess {
  const RegistrationRejected({
    required super.registration,
  }) : super(
          message: 'Registration rejected',
        );
}

class RegistrationCancelled extends RegistrationOperationSuccess {
  const RegistrationCancelled({
    required super.registration,
  }) : super(
          message: 'Registration cancelled',
        );
}

class RegistrationUpdated extends RegistrationOperationSuccess {
  const RegistrationUpdated({
    required super.registration,
  }) : super(
          message: 'Registration updated successfully',
        );
}

class RegistrationCompleted extends RegistrationOperationSuccess {
  const RegistrationCompleted({
    required super.registration,
  }) : super(
          message: 'Registration completed',
        );
}