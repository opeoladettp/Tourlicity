import 'package:equatable/equatable.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event to sign in with Google
class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Event to sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Event to refresh tokens
class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested();
}

/// Event when authentication status changes externally
class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  List<Object?> get props => [isAuthenticated];
}
