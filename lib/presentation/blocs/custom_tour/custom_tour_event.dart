import 'package:equatable/equatable.dart';
import '../../../domain/entities/custom_tour.dart';

abstract class CustomTourEvent extends Equatable {
  const CustomTourEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomTours extends CustomTourEvent {
  final String? providerId;
  final TourStatus? status;
  final int? page;
  final int? limit;

  const LoadCustomTours({
    this.providerId,
    this.status,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [providerId, status, page, limit];
}

class LoadCustomTourById extends CustomTourEvent {
  final String id;

  const LoadCustomTourById(this.id);

  @override
  List<Object> get props => [id];
}

class LoadCustomTourByJoinCode extends CustomTourEvent {
  final String joinCode;

  const LoadCustomTourByJoinCode(this.joinCode);

  @override
  List<Object> get props => [joinCode];
}

class CreateCustomTour extends CustomTourEvent {
  final CustomTour customTour;

  const CreateCustomTour(this.customTour);

  @override
  List<Object> get props => [customTour];
}

class UpdateCustomTour extends CustomTourEvent {
  final CustomTour customTour;

  const UpdateCustomTour(this.customTour);

  @override
  List<Object> get props => [customTour];
}

class DeleteCustomTour extends CustomTourEvent {
  final String id;

  const DeleteCustomTour(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateTourStatus extends CustomTourEvent {
  final String id;
  final TourStatus status;

  const UpdateTourStatus({
    required this.id,
    required this.status,
  });

  @override
  List<Object> get props => [id, status];
}

class PublishTour extends CustomTourEvent {
  final String id;

  const PublishTour(this.id);

  @override
  List<Object> get props => [id];
}

class CancelTour extends CustomTourEvent {
  final String id;

  const CancelTour(this.id);

  @override
  List<Object> get props => [id];
}

class StartTour extends CustomTourEvent {
  final String id;

  const StartTour(this.id);

  @override
  List<Object> get props => [id];
}

class CompleteTour extends CustomTourEvent {
  final String id;

  const CompleteTour(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateTouristCount extends CustomTourEvent {
  final String id;
  final int count;

  const UpdateTouristCount({
    required this.id,
    required this.count,
  });

  @override
  List<Object> get props => [id, count];
}

class GenerateNewJoinCode extends CustomTourEvent {
  final String id;

  const GenerateNewJoinCode(this.id);

  @override
  List<Object> get props => [id];
}

class SearchTours extends CustomTourEvent {
  final String? query;
  final List<String>? tags;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final double? minPrice;
  final double? maxPrice;
  final TourStatus? status;
  final int? page;
  final int? limit;

  const SearchTours({
    this.query,
    this.tags,
    this.startDateFrom,
    this.startDateTo,
    this.minPrice,
    this.maxPrice,
    this.status,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [
        query,
        tags,
        startDateFrom,
        startDateTo,
        minPrice,
        maxPrice,
        status,
        page,
        limit,
      ];
}

class RefreshCustomTours extends CustomTourEvent {
  const RefreshCustomTours();
}

class ClearCustomTourError extends CustomTourEvent {
  const ClearCustomTourError();
}

class FilterToursByStatus extends CustomTourEvent {
  final TourStatus? status;

  const FilterToursByStatus(this.status);

  @override
  List<Object?> get props => [status];
}