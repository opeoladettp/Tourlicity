// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_auth_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAuthRequestModel _$GoogleAuthRequestModelFromJson(
        Map<String, dynamic> json) =>
    GoogleAuthRequestModel(
      idToken: json['id_token'] as String,
      accessToken: json['access_token'] as String,
    );

Map<String, dynamic> _$GoogleAuthRequestModelToJson(
        GoogleAuthRequestModel instance) =>
    <String, dynamic>{
      'id_token': instance.idToken,
      'access_token': instance.accessToken,
    };
