import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/presentation/blocs/registration/registration_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/registration/registration_event.dart';
import 'package:tourlicity_app/presentation/blocs/registration/registration_state.dart';
import 'package:tourlicity_app/domain/repositories/registration_repository.dart';
import 'package:tourlicity_app/domain/entities/registration.dart';
import 'package:tourlicity_app/core/network/api_result.dart';

import 'registration_bloc_test.mocks.dart';

@GenerateMocks([RegistrationRepository])
void main() {
  late RegistrationBloc registrationBloc;
  late MockRegistrationRepository mockRepository;

  setUp(() {
    mockRepository = MockRegistrationRepository();
    registrationBloc = RegistrationBloc(registrationRepository: mockRepository);
  });

  tearDown(() {
    registrationBloc.close();
  });

  group('RegistrationBloc', () {
    test('initial state is RegistrationInitial', () {
      expect(registrationBloc.state, isA<RegistrationInitial>());
    });

    group('RegisterForTour', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationLoading, RegistrationSuccess] when successful',
        build: () {
          final registration = Registration(
            id: "1",
            customTourId: "tour1",
            touristId: "user1",
            status: RegistrationStatus.pending,
            confirmationCode: "ABC123",
            registrationDate: DateTime.now(),
          );
          when(mockRepository.registerForTour(
            joinCode: any,
            touristId: any,
            specialRequirements: any,
            emergencyContactName: any,
            emergencyContactPhone: any,
          )).thenAnswer((_) async => ApiSuccess(data: registration));
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const RegisterForTour(
          joinCode: 'ABC123',
          touristId: 'user1',
        )),
        expect: () => [
          isA<RegistrationLoading>(),
          isA<RegistrationSuccess>(),
        ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationLoading, RegistrationError] when fails',
        build: () {
          when(mockRepository.registerForTour(
            joinCode: any,
            touristId: any,
            specialRequirements: any,
            emergencyContactName: any,
            emergencyContactPhone: any,
          )).thenAnswer((_) async => const ApiFailure(message: 'Error'));
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const RegisterForTour(
          joinCode: 'ABC123',
          touristId: 'user1',
        )),
        expect: () => [
          isA<RegistrationLoading>(),
          isA<RegistrationError>(),
        ],
      );
    });

    group('LoadRegistrationsByTourist', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationLoading, RegistrationsLoaded] when successful',
        build: () {
          when(mockRepository.getRegistrationsByTourist(
            any,
            status: any,
            limit: any,
            offset: any,
          )).thenAnswer((_) async => const ApiSuccess(data: <Registration>[]));
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const LoadRegistrationsByTourist(
          touristId: 'user1',
        )),
        expect: () => [
          isA<RegistrationLoading>(),
          isA<RegistrationsLoaded>(),
        ],
      );
    });

    group('ApproveRegistration', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationLoading, RegistrationApproved] when successful',
        build: () {
          final registration = Registration(
            id: "1",
            customTourId: "tour1",
            touristId: "user1",
            status: RegistrationStatus.approved,
            confirmationCode: "ABC123",
            registrationDate: DateTime.now(),
          );
          when(mockRepository.approveRegistration(
            any,
            notes: any,
          )).thenAnswer((_) async => ApiSuccess(data: registration));
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const ApproveRegistration(
          registrationId: '1',
        )),
        expect: () => [
          isA<RegistrationLoading>(),
          isA<RegistrationApproved>(),
        ],
      );
    });

    group('CancelRegistration', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationLoading, RegistrationCancelled] when successful',
        build: () {
          final registration = Registration(
            id: "1",
            customTourId: "tour1",
            touristId: "user1",
            status: RegistrationStatus.cancelled,
            confirmationCode: "ABC123",
            registrationDate: DateTime.now(),
          );
          when(mockRepository.cancelRegistration(any))
              .thenAnswer((_) async => ApiSuccess(data: registration));
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const CancelRegistration('1')),
        expect: () => [
          isA<RegistrationLoading>(),
          isA<RegistrationCancelled>(),
        ],
      );
    });
  });
}