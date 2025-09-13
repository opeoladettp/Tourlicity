// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUserModel _$AuthUserModelFromJson(Map<String, dynamic> json) =>
    AuthUserModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$AuthUserModelToJson(AuthUserModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_at': instance.expiresAt?.toIso8601String(),
    };
