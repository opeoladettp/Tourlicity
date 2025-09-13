import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth_user.dart';
import '../../../domain/entities/user.dart';

/// Authentication status enumeration
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication state
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, user, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Factory constructors for common states
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading);
  }

  factory AuthState.authenticated(AuthUser user) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  factory AuthState.error(String message) {
    return AuthState(
      status: AuthStatus.error,
      errorMessage: message,
    );
  }

  /// Convenience getters
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
  bool get isInitial => status == AuthStatus.initial;

  /// Get User entity from AuthUser
  User? get userEntity => user?.user;

  /// Pattern matching helper for easier state handling
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(User user) authenticated,
    required T Function() unauthenticated,
    required T Function(String message) error,
  }) {
    switch (status) {
      case AuthStatus.initial:
        return initial();
      case AuthStatus.loading:
        return loading();
      case AuthStatus.authenticated:
        return authenticated(userEntity!);
      case AuthStatus.unauthenticated:
        return unauthenticated();
      case AuthStatus.error:
        return error(errorMessage ?? 'Unknown error');
    }
  }
}
