import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/presentation/blocs/custom_tour/custom_tour_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/custom_tour/custom_tour_event.dart';
import 'package:tourlicity_app/presentation/blocs/custom_tour/custom_tour_state.dart';
import 'package:tourlicity_app/domain/repositories/custom_tour_repository.dart';
import 'package:tourlicity_app/domain/entities/custom_tour.dart';
import 'package:tourlicity_app/core/network/api_result.dart';

import 'custom_tour_bloc_test.mocks.dart';

@GenerateMocks([CustomTourRepository])
void main() {
  group('CustomTourBloc Tests', () {
    late CustomTourBloc customTourBloc;
    late MockCustomTourRepository mockRepository;

    setUp(() {
      mockRepository = MockCustomTourRepository();
      customTourBloc = CustomTourBloc(customTourRepository: mockRepository);
    });

    tearDown(() {
      customTourBloc.close();
    });

    test('initial state is CustomTourInitial', () {
      expect(customTourBloc.state, equals(const CustomTourInitial()));
    });

    group('LoadCustomTours', () {
      final testTours = [
        CustomTour(
          id: '1',
          providerId: 'provider1',
          tourTemplateId: 'template1',
          tourName: 'Test Tour 1',
          joinCode: 'JOIN001',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          maxTourists: 20,
          currentTourists: 5,
          pricePerPerson: 299.99,
          currency: 'USD',
          status: TourStatus.published,
          tags: const ['adventure', 'nature'],
          createdDate: DateTime.now(),
        ),
      ];

      blocTest<CustomTourBloc, CustomTourState>(
        'emits [CustomTourLoading, CustomTourLoaded] when LoadCustomTours succeeds',
        build: () {
          when(mockRepository.getCustomTours()).thenAnswer(
            (_) async => ApiSuccess(data: testTours),
          );
          return customTourBloc;
        },
        act: (bloc) => bloc.add(const LoadCustomTours(providerId: "provider1")),
        expect: () => [
          const CustomTourLoading(),
          CustomToursLoaded(customTours: testTours),
        ],
      );

      blocTest<CustomTourBloc, CustomTourState>(
        'emits [CustomTourLoading, CustomTourError] when LoadCustomTours fails',
        build: () {
          when(mockRepository.getCustomTours()).thenAnswer(
            (_) async => const ApiFailure(message: 'Failed to load tours'),
          );
          return customTourBloc;
        },
        act: (bloc) => bloc.add(const LoadCustomTours(providerId: "provider1")),
        expect: () => [
          const CustomTourLoading(),
          const CustomTourError(message: 'Failed to load tours'),
        ],
      );
    });

    group('CreateCustomTour', () {
      final newTour = CustomTour(
        id: '2',
        providerId: 'provider1',
        tourTemplateId: 'template1',
        tourName: 'New Tour',
        joinCode: 'JOIN002',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        maxTourists: 15,
        currentTourists: 0,
        pricePerPerson: 399.99,
        currency: 'USD',
        status: TourStatus.draft,
        tags: const ['cultural'],
        createdDate: DateTime.now(),
      );

      blocTest<CustomTourBloc, CustomTourState>(
        'emits [CustomTourLoading, CustomTourLoaded] when CreateCustomTour succeeds',
        build: () {
          when(mockRepository.createCustomTour(any)).thenAnswer(
            (_) async => ApiSuccess(data: newTour),
          );
          when(mockRepository.getCustomTours()).thenAnswer(
            (_) async => ApiSuccess(data: [newTour]),
          );
          return customTourBloc;
        },
        act: (bloc) => bloc.add(CreateCustomTour(newTour)),
        expect: () => [
          const CustomTourLoading(),
          CustomTourCreated(customTour: newTour),
        ],
      );

      blocTest<CustomTourBloc, CustomTourState>(
        'emits [CustomTourLoading, CustomTourError] when CreateCustomTour fails',
        build: () {
          when(mockRepository.createCustomTour(any)).thenAnswer(
            (_) async => const ApiFailure(message: 'Failed to create tour'),
          );
          return customTourBloc;
        },
        act: (bloc) => bloc.add(CreateCustomTour(newTour)),
        expect: () => [
          const CustomTourLoading(),
          const CustomTourError(message: 'Failed to create tour'),
        ],
      );
    });

    group('UpdateCustomTour', () {
      final updatedTour = CustomTour(
        id: '1',
        providerId: 'provider1',
        tourTemplateId: 'template1',
        tourName: 'Updated Tour',
        joinCode: 'JOIN001',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        maxTourists: 25,
        currentTourists: 5,
        pricePerPerson: 349.99,
        currency: 'USD',
        status: TourStatus.published,
        tags: const ['adventure', 'updated'],
        createdDate: DateTime.now(),
      );

      blocTest<CustomTourBloc, CustomTourState>(
        'emits [CustomTourLoading, CustomTourLoaded] when UpdateCustomTour succeeds',
        build: () {
          when(mockRepository.updateCustomTour(updatedTour)).thenAnswer(
            (_) async => ApiSuccess(data: updatedTour),
          );
          when(mockRepository.getCustomTours()).thenAnswer(
            (_) async => ApiSuccess(data: [updatedTour]),
          );
          return customTourBloc;
        },
        act: (bloc) => bloc.add(UpdateCustomTour(updatedTour)),
        expect: () => [
          const CustomTourLoading(),
          CustomToursLoaded(customTours: [updatedTour]),
        ],
      );
    });

    group('DeleteCustomTour', () {
      blocTest<CustomTourBloc, CustomTourState>(
        'emits [CustomTourLoading, CustomTourLoaded] when DeleteCustomTour succeeds',
        build: () {
          when(mockRepository.deleteCustomTour('1')).thenAnswer(
            (_) async => const ApiSuccess(data: null),
          );
          when(mockRepository.getCustomTours()).thenAnswer(
            (_) async => const ApiSuccess(data: []),
          );
          return customTourBloc;
        },
        act: (bloc) => bloc.add(const DeleteCustomTour('1')),
        expect: () => [
          const CustomTourLoading(),
          const CustomToursLoaded(customTours: []),
        ],
      );
    });
  });
}