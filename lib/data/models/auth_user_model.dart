import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_user.dart';
import 'user_model.dart';

part 'auth_user_model.g.dart';

/// Data model for AuthUser entity
@JsonSerializable()
class AuthUserModel {
  const AuthUserModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  final UserModel user;

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) =>
      _$AuthUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserModelToJson(this);

  /// Convert to domain entity
  AuthUser toEntity() {
    return AuthUser(
      user: user.toEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  /// Create from domain entity
  factory AuthUserModel.fromEntity(AuthUser authUser) {
    return AuthUserModel(
      user: UserModel.fromEntity(authUser.user),
      accessToken: authUser.accessToken,
      refreshToken: authUser.refreshToken,
      expiresAt: authUser.expiresAt,
    );
  }
}
