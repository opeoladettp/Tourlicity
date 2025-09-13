// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegistrationModel _$RegistrationModelFromJson(Map<String, dynamic> json) =>
    RegistrationModel(
      id: json['id'] as String,
      customTourId: json['custom_tour_id'] as String,
      touristId: json['tourist_id'] as String,
      status: json['status'] as String,
      confirmationCode: json['confirmation_code'] as String,
      specialRequirements: json['special_requirements'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      registrationDate: json['registration_date'] as String,
      approvalNotes: json['approval_notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      statusUpdatedDate: json['status_updated_date'] as String?,
    );

Map<String, dynamic> _$RegistrationModelToJson(RegistrationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'custom_tour_id': instance.customTourId,
      'tourist_id': instance.touristId,
      'status': instance.status,
      'confirmation_code': instance.confirmationCode,
      'special_requirements': instance.specialRequirements,
      'emergency_contact_name': instance.emergencyContactName,
      'emergency_contact_phone': instance.emergencyContactPhone,
      'registration_date': instance.registrationDate,
      'approval_notes': instance.approvalNotes,
      'rejection_reason': instance.rejectionReason,
      'status_updated_date': instance.statusUpdatedDate,
    };
