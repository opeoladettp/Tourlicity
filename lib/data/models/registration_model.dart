import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'registration_model.g.dart';

@JsonSerializable()
class RegistrationModel {
  final String id;
  @JsonKey(name: 'custom_tour_id')
  final String customTourId;
  @JsonKey(name: 'tourist_id')
  final String touristId;
  final String status;
  @JsonKey(name: 'confirmation_code')
  final String confirmationCode;
  @JsonKey(name: 'special_requirements')
  final String? specialRequirements;
  @JsonKey(name: 'emergency_contact_name')
  final String? emergencyContactName;
  @JsonKey(name: 'emergency_contact_phone')
  final String? emergencyContactPhone;
  @JsonKey(name: 'registration_date')
  final String registrationDate;
  @JsonKey(name: 'approval_notes')
  final String? approvalNotes;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @JsonKey(name: 'status_updated_date')
  final String? statusUpdatedDate;

  const RegistrationModel({
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

  factory RegistrationModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationModelToJson(this);

  factory RegistrationModel.fromEntity(Registration registration) {
    return RegistrationModel(
      id: registration.id,
      customTourId: registration.customTourId,
      touristId: registration.touristId,
      status: registration.status.name,
      confirmationCode: registration.confirmationCode,
      specialRequirements: registration.specialRequirements,
      emergencyContactName: registration.emergencyContactName,
      emergencyContactPhone: registration.emergencyContactPhone,
      registrationDate: registration.registrationDate.toIso8601String(),
      approvalNotes: registration.approvalNotes,
      rejectionReason: registration.rejectionReason,
      statusUpdatedDate: registration.statusUpdatedDate?.toIso8601String(),
    );
  }

  Registration toEntity() {
    return Registration(
      id: id,
      customTourId: customTourId,
      touristId: touristId,
      status: _parseRegistrationStatus(status),
      confirmationCode: confirmationCode,
      specialRequirements: specialRequirements,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      registrationDate: DateTime.parse(registrationDate),
      approvalNotes: approvalNotes,
      rejectionReason: rejectionReason,
      statusUpdatedDate:
          statusUpdatedDate != null ? DateTime.parse(statusUpdatedDate!) : null,
    );
  }

  RegistrationStatus _parseRegistrationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RegistrationStatus.pending;
      case 'approved':
        return RegistrationStatus.approved;
      case 'rejected':
        return RegistrationStatus.rejected;
      case 'cancelled':
        return RegistrationStatus.cancelled;
      case 'completed':
        return RegistrationStatus.completed;
      default:
        return RegistrationStatus.pending;
    }
  }
}
