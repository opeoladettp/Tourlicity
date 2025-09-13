import 'package:equatable/equatable.dart';

/// Base class for all user events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load current user profile
class LoadUserProfile extends UserEvent {
  const LoadUserProfile();
}

/// Event to update user profile
class UpdateUserProfile extends UserEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;

  const UpdateUserProfile({
    this.firstName,
    this.lastName,
    this.phone,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone];
}

/// Event to complete user profile (first time setup)
class CompleteUserProfile extends UserEvent {
  final String firstName;
  final String lastName;
  final String? phone;

  const CompleteUserProfile({
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone];
}

/// Event to check if profile is complete
class CheckProfileCompletion extends UserEvent {
  const CheckProfileCompletion();
}

/// Event to reset user state
class ResetUserState extends UserEvent {
  const ResetUserState();
}
