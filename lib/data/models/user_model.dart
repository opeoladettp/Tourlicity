import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'user_model.g.dart';

/// Data model for User entity
@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    this.phoneNumber,
    required this.role,
    required this.isProfileComplete,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String name;

  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'role')
  final String role;

  @JsonKey(name: 'is_profile_complete')
  final bool isProfileComplete;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      profilePicture: profilePicture,
      phoneNumber: phoneNumber,
      role: _parseUserRole(role),
      isProfileComplete: isProfileComplete,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      profilePicture: user.profilePicture,
      phoneNumber: user.phoneNumber,
      role: _userRoleToString(user.role),
      isProfileComplete: user.isProfileComplete,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  static UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'tourist':
        return UserRole.tourist;
      case 'provider':
        return UserRole.provider;
      case 'system_admin':
      case 'systemadmin':
        return UserRole.systemAdmin;
      default:
        return UserRole.tourist;
    }
  }

  static String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.tourist:
        return 'tourist';
      case UserRole.provider:
        return 'provider';
      case UserRole.systemAdmin:
        return 'system_admin';
    }
  }
}
