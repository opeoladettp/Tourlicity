import 'package:equatable/equatable.dart';
import 'user.dart';
import 'user_type.dart';

/// Authenticated user entity containing user data and tokens
class AuthUser extends Equatable {
  const AuthUser({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [user, accessToken, refreshToken, expiresAt];

  /// Backward compatibility getters for tests
  String get id => user.id;
  String get email => user.email;
  String get name => user.name;
  String? get photoUrl => user.profilePicture;
  UserType get userType => user.userType;
  bool get profileCompleted => user.profileCompleted;

  AuthUser copyWith({
    User? user,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthUser(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
