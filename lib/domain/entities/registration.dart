import 'package:equatable/equatable.dart';

enum RegistrationStatus {
  pending,
  approved,
  rejected,
  cancelled,
  completed,
}

class Registration extends Equatable {
  final String id;
  final String customTourId;
  final String touristId;
  final RegistrationStatus status;
  final String confirmationCode;
  final String? specialRequirements;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime registrationDate;
  final String? approvalNotes;
  final String? rejectionReason;
  final DateTime? statusUpdatedDate;

  const Registration({
    required this.id,
    required this.customTourId,
    required this.touristId,
    required this.status,
    required this.confirmationCode,
    this.specialRequirements,
    this.emergencyContactName,
    this.emergencyContactPhone,
    required this.registrationDate,
    this.approvalNotes,
    this.rejectionReason,
    this.statusUpdatedDate,
  });

  bool get isValid {
    return customTourId.isNotEmpty &&
        touristId.isNotEmpty &&
        confirmationCode.isNotEmpty &&
        _isValidEmergencyContact();
  }

  bool _isValidEmergencyContact() {
    if (emergencyContactName != null && emergencyContactName!.isNotEmpty) {
      return emergencyContactPhone != null &&
          emergencyContactPhone!.isNotEmpty &&
          _isValidPhoneNumber(emergencyContactPhone!);
    }
    return true; // Emergency contact is optional
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)\.]{10,}$').hasMatch(phone);
  }

  bool get isPending => status == RegistrationStatus.pending;
  bool get isApproved => status == RegistrationStatus.approved;
  bool get isRejected => status == RegistrationStatus.rejected;
  bool get isCancelled => status == RegistrationStatus.cancelled;
  bool get isCompleted => status == RegistrationStatus.completed;

  bool get canBeCancelled {
    return status == RegistrationStatus.pending ||
        status == RegistrationStatus.approved;
  }

  bool get requiresAction {
    return status == RegistrationStatus.pending;
  }

  Registration approve({String? notes}) {
    return copyWith(
      status: RegistrationStatus.approved,
      approvalNotes: notes,
      statusUpdatedDate: DateTime.now(),
    );
  }

  Registration reject({required String reason}) {
    return copyWith(
      status: RegistrationStatus.rejected,
      rejectionReason: reason,
      statusUpdatedDate: DateTime.now(),
    );
  }

  Registration cancel() {
    return copyWith(
      status: RegistrationStatus.cancelled,
      statusUpdatedDate: DateTime.now(),
    );
  }

  Registration complete() {
    return copyWith(
      status: RegistrationStatus.completed,
      statusUpdatedDate: DateTime.now(),
    );
  }

  Registration copyWith({
    String? id,
    String? customTourId,
    String? touristId,
    RegistrationStatus? status,
    String? confirmationCode,
    String? specialRequirements,
    String? emergencyContactName,
    String? emergencyContactPhone,
    DateTime? registrationDate,
    String? approvalNotes,
    String? rejectionReason,
    DateTime? statusUpdatedDate,
  }) {
    return Registration(
      id: id ?? this.id,
      customTourId: customTourId ?? this.customTourId,
      touristId: touristId ?? this.touristId,
      status: status ?? this.status,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      registrationDate: registrationDate ?? this.registrationDate,
      approvalNotes: approvalNotes ?? this.approvalNotes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      statusUpdatedDate: statusUpdatedDate ?? this.statusUpdatedDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customTourId,
        touristId,
        status,
        confirmationCode,
        specialRequirements,
        emergencyContactName,
        emergencyContactPhone,
        registrationDate,
        approvalNotes,
        rejectionReason,
        statusUpdatedDate,
      ];
}
