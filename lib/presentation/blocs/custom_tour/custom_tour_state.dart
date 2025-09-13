import 'package:equatable/equatable.dart';
import '../../../domain/entities/custom_tour.dart';

abstract class CustomTourState extends Equatable {
  const CustomTourState();

  @override
  List<Object?> get props => [];
}

class CustomTourInitial extends CustomTourState {
  const CustomTourInitial();
}

class CustomTourLoading extends CustomTourState {
  const CustomTourLoading();
}

class CustomTourLoaded extends CustomTourState {
  final CustomTour customTour;

  const CustomTourLoaded(this.customTour);

  @override
  List<Object> get props => [customTour];
}

class CustomToursLoaded extends CustomTourState {
  final List<CustomTour> customTours;
  final bool hasReachedMax;
  final int totalCount;
  final TourStatus? currentFilter;

  const CustomToursLoaded({
    required this.customTours,
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [customTours, hasReachedMax, totalCount, currentFilter];

  CustomToursLoaded copyWith({
    List<CustomTour>? customTours,
    bool? hasReachedMax,
    int? totalCount,
    TourStatus? currentFilter,
  }) {
    return CustomToursLoaded(
      customTours: customTours ?? this.customTours,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class CustomTourError extends CustomTourState {
  final String message;
  final String? errorCode;

  const CustomTourError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class CustomTourOperationSuccess extends CustomTourState {
  final CustomTour customTour;
  final String message;

  const CustomTourOperationSuccess({
    required this.customTour,
    required this.message,
  });

  @override
  List<Object> get props => [customTour, message];
}

// Specific success states for different operations
class CustomTourCreated extends CustomTourOperationSuccess {
  const CustomTourCreated({
    required super.customTour,
  }) : super(
          message: 'Tour created successfully',
        );
}

class CustomTourUpdated extends CustomTourOperationSuccess {
  const CustomTourUpdated({
    required super.customTour,
  }) : super(
          message: 'Tour updated successfully',
        );
}

class CustomTourDeleted extends CustomTourState {
  final String message;

  const CustomTourDeleted({
    this.message = 'Tour deleted successfully',
  });

  @override
  List<Object> get props => [message];
}

class CustomTourPublished extends CustomTourOperationSuccess {
  const CustomTourPublished({
    required super.customTour,
  }) : super(
          message: 'Tour published successfully',
        );
}

class CustomTourCancelled extends CustomTourOperationSuccess {
  const CustomTourCancelled({
    required super.customTour,
  }) : super(
          message: 'Tour cancelled',
        );
}

class CustomTourStarted extends CustomTourOperationSuccess {
  const CustomTourStarted({
    required super.customTour,
  }) : super(
          message: 'Tour started',
        );
}

class CustomTourCompleted extends CustomTourOperationSuccess {
  const CustomTourCompleted({
    required super.customTour,
  }) : super(
          message: 'Tour completed',
        );
}

class CustomTourJoinCodeGenerated extends CustomTourOperationSuccess {
  const CustomTourJoinCodeGenerated({
    required super.customTour,
  }) : super(
          message: 'New join code generated',
        );
}

class CustomTourTouristCountUpdated extends CustomTourOperationSuccess {
  const CustomTourTouristCountUpdated({
    required super.customTour,
  }) : super(
          message: 'Tourist count updated',
        );
}