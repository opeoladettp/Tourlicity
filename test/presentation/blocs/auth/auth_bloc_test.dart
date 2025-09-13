import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/auth/auth_event.dart';
import 'package:tourlicity_app/presentation/blocs/auth/auth_state.dart';
import 'package:tourlicity_app/domain/repositories/auth_repository.dart';
import 'package:tourlicity_app/domain/entities/auth_user.dart';
import 'package:tourlicity_app/domain/entities/user.dart';
import 'package:tourlicity_app/domain/entities/user_type.dart';
import 'package:tourlicity_app/domain/entities/google_sign_in_result.dart';
import 'package:tourlicity_app/core/network/api_result.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  provideDummy<ApiResult<AuthUser?>>(
    const ApiFailure(message: 'dummy'),
  );
  provideDummy<ApiResult<GoogleSignInResult>>(
    const ApiFailure(message: 'dummy'),
  );
  provideDummy<ApiResult<AuthUser>>(
    const ApiFailure(message: 'dummy'),
  );
  provideDummy<ApiResult<void>>(
    const ApiFailure(message: 'dummy'),
  );

  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthRepository mockAuthRepository;

    final testUser = AuthUser(
      user: User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
        role: UserRole.tourist,
        isProfileComplete: true,
        createdAt: DateTime(2024, 1, 1),
      ),
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
    );

    const testGoogleResult = GoogleSignInResult(
      idToken: 'id_token',
      accessToken: 'access_token',
      email: 'test@example.com',
      displayName: 'Test User',
      photoUrl: 'https://example.com/photo.jpg',
    );

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthState.initial', () {
      expect(authBloc.state, AuthState.initial());
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when user is authenticated',
        build: () {
          when(mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => ApiSuccess(data: testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.authenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when user is not authenticated',
        build: () {
          when(mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.unauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when getCurrentUser returns null',
        build: () {
          when(mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => const ApiSuccess(data: null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.unauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] when exception occurs',
        build: () {
          when(mockAuthRepository.isAuthenticated())
              .thenThrow(Exception('Test error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.error('Failed to check authentication status'),
        ],
      );
    });

    group('AuthGoogleSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] when sign in is successful',
        build: () {
          when(mockAuthRepository.signInWithGoogle()).thenAnswer(
              (_) async => const ApiSuccess(data: testGoogleResult));
          when(mockAuthRepository.authenticateWithGoogle(
            idToken: testGoogleResult.idToken,
            accessToken: testGoogleResult.accessToken,
          )).thenAnswer((_) async => ApiSuccess(data: testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.authenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] when Google sign in fails',
        build: () {
          when(mockAuthRepository.signInWithGoogle()).thenAnswer(
              (_) async => const ApiFailure(message: 'Google sign in failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.error('Google sign in failed'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] when backend authentication fails',
        build: () {
          when(mockAuthRepository.signInWithGoogle()).thenAnswer(
              (_) async => const ApiSuccess(data: testGoogleResult));
          when(mockAuthRepository.authenticateWithGoogle(
            idToken: testGoogleResult.idToken,
            accessToken: testGoogleResult.accessToken,
          )).thenAnswer((_) async =>
              const ApiFailure(message: 'Backend authentication failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.error('Backend authentication failed'),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] when sign out is successful',
        build: () {
          when(mockAuthRepository.signOut())
              .thenAnswer((_) async => const ApiSuccess(data: null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.unauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, unauthenticated] even when sign out fails',
        build: () {
          const errorMessage = 'Sign out failed';
          when(mockAuthRepository.signOut())
              .thenAnswer((_) async => const ApiFailure(message: errorMessage));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          AuthState.loading(),
          AuthState.unauthenticated(),
        ],
      );
    });

    group('AuthTokenRefreshRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [authenticated] when token refresh is successful',
        build: () {
          when(mockAuthRepository.refreshTokens())
              .thenAnswer((_) async => ApiSuccess(data: testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthTokenRefreshRequested()),
        expect: () => [
          AuthState.authenticated(testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when token refresh fails',
        build: () {
          const errorMessage = 'Token refresh failed';
          when(mockAuthRepository.refreshTokens())
              .thenAnswer((_) async => const ApiFailure(message: errorMessage));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthTokenRefreshRequested()),
        expect: () => [
          AuthState.unauthenticated(),
        ],
      );
    });

    group('AuthStatusChanged', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when status changed to unauthenticated',
        build: () => authBloc,
        act: (bloc) =>
            bloc.add(const AuthStatusChanged(isAuthenticated: false)),
        expect: () => [
          AuthState.unauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'triggers auth check when status changed to authenticated',
        build: () {
          when(mockAuthRepository.isAuthenticated())
              .thenAnswer((_) async => true);
          when(mockAuthRepository.getCurrentUser())
              .thenAnswer((_) async => ApiSuccess(data: testUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthStatusChanged(isAuthenticated: true)),
        expect: () => [
          AuthState.loading(),
          AuthState.authenticated(testUser),
        ],
      );
    });
  });
}
