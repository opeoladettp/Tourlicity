/// User types in the system (for backward compatibility)
enum UserType {
  tourist,
  providerAdmin,
  systemAdmin,
}

/// Extension to convert UserType to UserRole
extension UserTypeExtension on UserType {
  UserRole toUserRole() {
    switch (this) {
      case UserType.tourist:
        return UserRole.tourist;
      case UserType.providerAdmin:
        return UserRole.provider;
      case UserType.systemAdmin:
        return UserRole.systemAdmin;
    }
  }
}

/// User roles in the system
enum UserRole {
  tourist,
  provider,
  systemAdmin,
}

/// Extension to convert UserRole to UserType
extension UserRoleExtension on UserRole {
  UserType toUserType() {
    switch (this) {
      case UserRole.tourist:
        return UserType.tourist;
      case UserRole.provider:
        return UserType.providerAdmin;
      case UserRole.systemAdmin:
        return UserType.systemAdmin;
    }
  }
}
