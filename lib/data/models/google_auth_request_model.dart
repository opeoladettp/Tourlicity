import 'package:json_annotation/json_annotation.dart';

part 'google_auth_request_model.g.dart';

/// Model for Google authentication request
@JsonSerializable()
class GoogleAuthRequestModel {
  const GoogleAuthRequestModel({
    required this.idToken,
    required this.accessToken,
  });

  @JsonKey(name: 'id_token')
  final String idToken;

  @JsonKey(name: 'access_token')
  final String accessToken;

  factory GoogleAuthRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleAuthRequestModelToJson(this);
}
