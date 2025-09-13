import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc for managing authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthTokenRefreshRequested>(_onTokenRefreshRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
  }

  final AuthRepository _authRepository;

  /// Handle authentication check request
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        final result = await _authRepository.getCurrentUser();

        if (result.isSuccess) {
          final user = result.data;
          if (user != null) {
            emit(AuthState.authenticated(user));
          } else {
            emit(AuthState.unauthenticated());
          }
        } else {
          emit(AuthState.unauthenticated());
        }
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error('Failed to check authentication status'));
    }
  }

  /// Handle Google sign-in request
  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      // First, sign in with Google
      final googleResult = await _authRepository.signInWithGoogle();

      if (googleResult.isSuccess) {
        final googleSignInResult = googleResult.data!;

        // Then authenticate with backend
        final authResult = await _authRepository.authenticateWithGoogle(
          idToken: googleSignInResult.idToken,
          accessToken: googleSignInResult.accessToken,
        );

        if (authResult.isSuccess) {
          emit(AuthState.authenticated(authResult.data!));
        } else {
          emit(AuthState.error(authResult.error ?? 'Authentication failed'));
        }
      } else {
        emit(AuthState.error(googleResult.error ?? 'Google sign-in failed'));
      }
    } catch (e) {
      emit(AuthState.error('Sign in failed: ${e.toString()}'));
    }
  }

  /// Handle sign-out request
  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loading());

    try {
      await _authRepository.signOut();

      // Always emit unauthenticated, even if sign out fails
      emit(AuthState.unauthenticated());
    } catch (e) {
      // Even if sign out fails, clear local state
      emit(AuthState.unauthenticated());
    }
  }

  /// Handle token refresh request
  Future<void> _onTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await _authRepository.refreshTokens();

      if (result.isSuccess) {
        emit(AuthState.authenticated(result.data!));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.unauthenticated());
    }
  }

  /// Handle external authentication status changes
  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (!event.isAuthenticated) {
      emit(AuthState.unauthenticated());
    } else {
      // Re-check authentication status
      add(const AuthCheckRequested());
    }
  }
}
