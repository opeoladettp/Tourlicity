// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      profilePicture: json['profile_picture'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String,
      isProfileComplete: json['is_profile_complete'] as bool,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'profile_picture': instance.profilePicture,
      'phone_number': instance.phoneNumber,
      'role': instance.role,
      'is_profile_complete': instance.isProfileComplete,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
