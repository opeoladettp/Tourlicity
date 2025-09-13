import 'package:equatable/equatable.dart';
import 'user_type.dart';

/// User entity representing a user in the system
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    this.phoneNumber,
    this.role = UserRole.tourist,
    this.isProfileComplete = false,
    this.createdAt,
    this.updatedAt,
    this.providerId,
    // Backward compatibility parameters
    String? firstName,
    String? lastName,
    String? phone,
    UserType? userType,
    bool? profileCompleted,
    DateTime? createdDate,
  })  : _firstName = firstName,
        _lastName = lastName,
        _phone = phone,
        _userType = userType,
        _profileCompleted = profileCompleted,
        _createdDate = createdDate;

  final String id;
  final String email;
  final String name;
  final String? profilePicture;
  final String? phoneNumber;
  final UserRole role;
  final bool isProfileComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? providerId;

  // Backward compatibility fields
  final String? _firstName;
  final String? _lastName;
  final String? _phone;
  final UserType? _userType;
  final bool? _profileCompleted;
  final DateTime? _createdDate;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        profilePicture,
        phoneNumber,
        role,
        isProfileComplete,
        createdAt,
        updatedAt,
        providerId,
        _firstName,
        _lastName,
        _phone,
        _userType,
        _profileCompleted,
        _createdDate,
      ];

  /// Get full name for display
  String get fullName => name;

  /// Backward compatibility getters for tests
  String get firstName => _firstName ?? name.split(' ').first;
  String get lastName => _lastName ?? name.split(' ').skip(1).join(' ');
  String? get phone => _phone ?? phoneNumber;
  UserType get userType => _userType ?? role.toUserType();
  bool get profileCompleted => _profileCompleted ?? isProfileComplete;
  DateTime? get createdDate => _createdDate ?? createdAt;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePicture,
    String? phoneNumber,
    UserRole? role,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? providerId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      providerId: providerId ?? this.providerId,
    );
  }
}
