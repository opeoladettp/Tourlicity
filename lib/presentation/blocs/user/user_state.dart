import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

/// Base class for all user states
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class UserInitial extends UserState {
  const UserInitial();
}

/// Loading state
class UserLoading extends UserState {
  const UserLoading();
}

/// User profile loaded successfully
class UserLoaded extends UserState {
  final User user;

  const UserLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Profile completion check completed
class ProfileCompletionChecked extends UserState {
  final bool isComplete;

  const ProfileCompletionChecked({required this.isComplete});

  @override
  List<Object?> get props => [isComplete];
}

/// Profile update in progress
class UserUpdating extends UserState {
  const UserUpdating();
}

/// Profile updated successfully
class UserUpdated extends UserState {
  final User user;
  final String message;

  const UserUpdated({
    required this.user,
    this.message = 'Profile updated successfully',
  });

  @override
  List<Object?> get props => [user, message];
}

/// Profile completion in progress
class UserProfileCompleting extends UserState {
  const UserProfileCompleting();
}

/// Profile completed successfully
class UserProfileCompleted extends UserState {
  final User user;
  final String message;

  const UserProfileCompleted({
    required this.user,
    this.message = 'Profile completed successfully',
  });

  @override
  List<Object?> get props => [user, message];
}

/// Error state
class UserError extends UserState {
  final String message;
  final String? errorCode;

  const UserError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}
