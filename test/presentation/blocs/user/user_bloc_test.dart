import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/domain/entities/entities.dart';
import 'package:tourlicity_app/domain/repositories/user_repository.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_event.dart';
import 'package:tourlicity_app/presentation/blocs/user/user_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('UserBloc', () {
    late UserBloc userBloc;
    late MockUserRepository mockUserRepository;

    final testUser = User(
      id: '1',
      email: 'test@example.com',
      name: 'John Doe',
      phone: '+1234567890',
      userType: UserType.tourist,
      profileCompleted: true,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      // Backward compatibility
      firstName: 'John',
      lastName: 'Doe',
      createdDate: DateTime.parse('2024-01-01T00:00:00Z'),
    );

    setUp(() {
      mockUserRepository = MockUserRepository();
      userBloc = UserBloc(userRepository: mockUserRepository);
    });

    tearDown(() {
      userBloc.close();
    });

    test('initial state is UserInitial', () {
      expect(userBloc.state, equals(const UserInitial()));
    });

    group('LoadUserProfile', () {
      blocTest<UserBloc, UserState>(
        'emits [UserLoading, UserLoaded] when loading user profile succeeds',
        build: () {
          when(() => mockUserRepository.getCurrentUser())
              .thenAnswer((_) async => ApiSuccess(data: testUser));
          return userBloc;
        },
        act: (bloc) => bloc.add(const LoadUserProfile()),
        expect: () => [
          const UserLoading(),
          UserLoaded(user: testUser),
        ],
        verify: (_) {
          verify(() => mockUserRepository.getCurrentUser()).called(1);
        },
      );

      blocTest<UserBloc, UserState>(
        'emits [UserLoading, UserError] when loading user profile fails',
        build: () {
          when(() => mockUserRepository.getCurrentUser()).thenAnswer(
            (_) async => const ApiFailure(
              message: 'Failed to load user',
              errorCode: 'USER_NOT_FOUND',
            ),
          );
          return userBloc;
        },
        act: (bloc) => bloc.add(const LoadUserProfile()),
        expect: () => [
          const UserLoading(),
          const UserError(
            message: 'Failed to load user',
            errorCode: 'USER_NOT_FOUND',
          ),
        ],
        verify: (_) {
          verify(() => mockUserRepository.getCurrentUser()).called(1);
        },
      );
    });

    group('UpdateUserProfile', () {
      blocTest<UserBloc, UserState>(
        'emits [UserUpdating, UserUpdated] when updating profile succeeds',
        build: () {
          when(() => mockUserRepository.updateProfile(
                firstName: any(named: 'firstName'),
                lastName: any(named: 'lastName'),
                phone: any(named: 'phone'),
              )).thenAnswer((_) async => ApiSuccess(data: testUser));
          return userBloc;
        },
        act: (bloc) => bloc.add(const UpdateUserProfile(
          firstName: 'John',
          lastName: 'Doe',
          phone: '+1234567890',
        )),
        expect: () => [
          const UserUpdating(),
          UserUpdated(user: testUser),
        ],
        verify: (_) {
          verify(() => mockUserRepository.updateProfile(
                firstName: 'John',
                lastName: 'Doe',
                phone: '+1234567890',
              )).called(1);
        },
      );

      blocTest<UserBloc, UserState>(
        'emits [UserUpdating, UserError] when updating profile fails',
        build: () {
          when(() => mockUserRepository.updateProfile(
                firstName: any(named: 'firstName'),
                lastName: any(named: 'lastName'),
                phone: any(named: 'phone'),
              )).thenAnswer(
            (_) async => const ApiFailure(
              message: 'Failed to update profile',
              errorCode: 'UPDATE_FAILED',
            ),
          );
          return userBloc;
        },
        act: (bloc) => bloc.add(const UpdateUserProfile(
          firstName: 'John',
          lastName: 'Doe',
        )),
        expect: () => [
          const UserUpdating(),
          const UserError(
            message: 'Failed to update profile',
            errorCode: 'UPDATE_FAILED',
          ),
        ],
      );

      blocTest<UserBloc, UserState>(
        'handles partial updates correctly',
        build: () {
          when(() => mockUserRepository.updateProfile(
                firstName: any(named: 'firstName'),
                lastName: null,
                phone: null,
              )).thenAnswer((_) async => ApiSuccess(data: testUser));
          return userBloc;
        },
        act: (bloc) => bloc.add(const UpdateUserProfile(
          firstName: 'John',
        )),
        expect: () => [
          const UserUpdating(),
          UserUpdated(user: testUser),
        ],
        verify: (_) {
          verify(() => mockUserRepository.updateProfile(
                firstName: 'John',
                lastName: null,
                phone: null,
              )).called(1);
        },
      );
    });

    group('CompleteUserProfile', () {
      blocTest<UserBloc, UserState>(
        'emits [UserProfileCompleting, UserProfileCompleted] when completing profile succeeds',
        build: () {
          when(() => mockUserRepository.completeProfile(
                firstName: any(named: 'firstName'),
                lastName: any(named: 'lastName'),
                phone: any(named: 'phone'),
              )).thenAnswer((_) async => ApiSuccess(data: testUser));
          return userBloc;
        },
        act: (bloc) => bloc.add(const CompleteUserProfile(
          firstName: 'John',
          lastName: 'Doe',
          phone: '+1234567890',
        )),
        expect: () => [
          const UserProfileCompleting(),
          UserProfileCompleted(user: testUser),
        ],
        verify: (_) {
          verify(() => mockUserRepository.completeProfile(
                firstName: 'John',
                lastName: 'Doe',
                phone: '+1234567890',
              )).called(1);
        },
      );

      blocTest<UserBloc, UserState>(
        'emits [UserProfileCompleting, UserError] when completing profile fails',
        build: () {
          when(() => mockUserRepository.completeProfile(
                firstName: any(named: 'firstName'),
                lastName: any(named: 'lastName'),
                phone: any(named: 'phone'),
              )).thenAnswer(
            (_) async => const ApiFailure(
              message: 'Failed to complete profile',
              errorCode: 'COMPLETION_FAILED',
            ),
          );
          return userBloc;
        },
        act: (bloc) => bloc.add(const CompleteUserProfile(
          firstName: 'John',
          lastName: 'Doe',
        )),
        expect: () => [
          const UserProfileCompleting(),
          const UserError(
            message: 'Failed to complete profile',
            errorCode: 'COMPLETION_FAILED',
          ),
        ],
      );

      blocTest<UserBloc, UserState>(
        'handles profile completion without phone number',
        build: () {
          when(() => mockUserRepository.completeProfile(
                firstName: any(named: 'firstName'),
                lastName: any(named: 'lastName'),
                phone: null,
              )).thenAnswer((_) async => ApiSuccess(data: testUser));
          return userBloc;
        },
        act: (bloc) => bloc.add(const CompleteUserProfile(
          firstName: 'John',
          lastName: 'Doe',
        )),
        expect: () => [
          const UserProfileCompleting(),
          UserProfileCompleted(user: testUser),
        ],
        verify: (_) {
          verify(() => mockUserRepository.completeProfile(
                firstName: 'John',
                lastName: 'Doe',
                phone: null,
              )).called(1);
        },
      );
    });

    group('CheckProfileCompletion', () {
      blocTest<UserBloc, UserState>(
        'emits [UserLoading, ProfileCompletionChecked] when checking profile completion succeeds',
        build: () {
          when(() => mockUserRepository.isProfileComplete())
              .thenAnswer((_) async => const ApiSuccess(data: true));
          return userBloc;
        },
        act: (bloc) => bloc.add(const CheckProfileCompletion()),
        expect: () => [
          const UserLoading(),
          const ProfileCompletionChecked(isComplete: true),
        ],
        verify: (_) {
          verify(() => mockUserRepository.isProfileComplete()).called(1);
        },
      );

      blocTest<UserBloc, UserState>(
        'emits [UserLoading, ProfileCompletionChecked] with false when profile is incomplete',
        build: () {
          when(() => mockUserRepository.isProfileComplete())
              .thenAnswer((_) async => const ApiSuccess(data: false));
          return userBloc;
        },
        act: (bloc) => bloc.add(const CheckProfileCompletion()),
        expect: () => [
          const UserLoading(),
          const ProfileCompletionChecked(isComplete: false),
        ],
      );

      blocTest<UserBloc, UserState>(
        'emits [UserLoading, UserError] when checking profile completion fails',
        build: () {
          when(() => mockUserRepository.isProfileComplete()).thenAnswer(
            (_) async => const ApiFailure(
              message: 'Failed to check profile completion',
              errorCode: 'CHECK_FAILED',
            ),
          );
          return userBloc;
        },
        act: (bloc) => bloc.add(const CheckProfileCompletion()),
        expect: () => [
          const UserLoading(),
          const UserError(
            message: 'Failed to check profile completion',
            errorCode: 'CHECK_FAILED',
          ),
        ],
      );
    });

    group('ResetUserState', () {
      blocTest<UserBloc, UserState>(
        'emits [UserInitial] when resetting state',
        build: () => userBloc,
        seed: () => UserLoaded(user: testUser),
        act: (bloc) => bloc.add(const ResetUserState()),
        expect: () => [const UserInitial()],
      );
    });
  });
}
