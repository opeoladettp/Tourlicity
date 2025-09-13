import 'package:equatable/equatable.dart';
import '../../../domain/entities/registration.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class RegisterForTour extends RegistrationEvent {
  final String joinCode;
  final String touristId;
  final String? specialRequirements;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const RegisterForTour({
    required this.joinCode,
    required this.touristId,
    this.specialRequirements,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  @override
  List<Object?> get props => [
        joinCode,
        touristId,
        specialRequirements,
        emergencyContactName,
        emergencyContactPhone,
      ];
}

class LoadRegistrationById extends RegistrationEvent {
  final String registrationId;

  const LoadRegistrationById(this.registrationId);

  @override
  List<Object> get props => [registrationId];
}

class LoadRegistrationsByTourist extends RegistrationEvent {
  final String touristId;
  final RegistrationStatus? status;
  final int? limit;
  final int? offset;

  const LoadRegistrationsByTourist({
    required this.touristId,
    this.status,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [touristId, status, limit, offset];
}

class LoadRegistrationsByTour extends RegistrationEvent {
  final String customTourId;
  final RegistrationStatus? status;
  final int? limit;
  final int? offset;

  const LoadRegistrationsByTour({
    required this.customTourId,
    this.status,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [customTourId, status, limit, offset];
}

class ApproveRegistration extends RegistrationEvent {
  final String registrationId;
  final String? notes;

  const ApproveRegistration({
    required this.registrationId,
    this.notes,
  });

  @override
  List<Object?> get props => [registrationId, notes];
}

class RejectRegistration extends RegistrationEvent {
  final String registrationId;
  final String reason;

  const RejectRegistration({
    required this.registrationId,
    required this.reason,
  });

  @override
  List<Object> get props => [registrationId, reason];
}

class CancelRegistration extends RegistrationEvent {
  final String registrationId;

  const CancelRegistration(this.registrationId);

  @override
  List<Object> get props => [registrationId];
}

class UpdateRegistration extends RegistrationEvent {
  final String registrationId;
  final String? specialRequirements;
  final String? emergencyContactName;
  final String? emergencyContactPhone;

  const UpdateRegistration({
    required this.registrationId,
    this.specialRequirements,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  @override
  List<Object?> get props => [
        registrationId,
        specialRequirements,
        emergencyContactName,
        emergencyContactPhone,
      ];
}

class LoadRegistrationByConfirmationCode extends RegistrationEvent {
  final String confirmationCode;

  const LoadRegistrationByConfirmationCode(this.confirmationCode);

  @override
  List<Object> get props => [confirmationCode];
}

class CompleteRegistration extends RegistrationEvent {
  final String registrationId;

  const CompleteRegistration(this.registrationId);

  @override
  List<Object> get props => [registrationId];
}

class LoadRegistrationStats extends RegistrationEvent {
  final String customTourId;

  const LoadRegistrationStats(this.customTourId);

  @override
  List<Object> get props => [customTourId];
}

class RefreshRegistrations extends RegistrationEvent {
  const RefreshRegistrations();
}

class ClearRegistrationError extends RegistrationEvent {
  const ClearRegistrationError();
}