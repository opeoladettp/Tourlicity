import 'package:equatable/equatable.dart';

enum TourStatus {
  draft,
  published,
  active,
  completed,
  cancelled,
}

class CustomTour extends Equatable {
  final String id;
  final String providerId;
  final String tourTemplateId;
  final String tourName;
  final String joinCode;
  final DateTime startDate;
  final DateTime endDate;
  final int maxTourists;
  final int currentTourists;
  final double pricePerPerson;
  final String currency;
  final TourStatus status;
  final List<String> tags;
  final String? description;
  final DateTime createdDate;

  const CustomTour({
    required this.id,
    required this.providerId,
    required this.tourTemplateId,
    required this.tourName,
    required this.joinCode,
    required this.startDate,
    required this.endDate,
    required this.maxTourists,
    required this.currentTourists,
    required this.pricePerPerson,
    required this.currency,
    required this.status,
    required this.tags,
    this.description,
    required this.createdDate,
  });

  int get durationDays {
    return endDate.difference(startDate).inDays + 1;
  }

  int get availableSpots {
    return maxTourists - currentTourists;
  }

  bool get hasAvailableSpots {
    return availableSpots > 0;
  }

  bool get isValidDateRange {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }

  bool get isValid {
    return tourName.isNotEmpty &&
        joinCode.isNotEmpty &&
        isValidDateRange &&
        maxTourists > 0 &&
        currentTourists >= 0 &&
        currentTourists <= maxTourists &&
        pricePerPerson >= 0 &&
        currency.isNotEmpty;
  }

  bool get canAcceptRegistrations {
    return status == TourStatus.published &&
        hasAvailableSpots &&
        DateTime.now().isBefore(startDate);
  }

  bool get isActive {
    final now = DateTime.now();
    return status == TourStatus.active &&
        (startDate.isBefore(now) || startDate.isAtSameMomentAs(now)) &&
        (endDate.isAfter(now) || endDate.isAtSameMomentAs(now));
  }

  CustomTour copyWith({
    String? id,
    String? providerId,
    String? tourTemplateId,
    String? tourName,
    String? joinCode,
    DateTime? startDate,
    DateTime? endDate,
    int? maxTourists,
    int? currentTourists,
    double? pricePerPerson,
    String? currency,
    TourStatus? status,
    List<String>? tags,
    String? description,
    DateTime? createdDate,
  }) {
    return CustomTour(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      tourTemplateId: tourTemplateId ?? this.tourTemplateId,
      tourName: tourName ?? this.tourName,
      joinCode: joinCode ?? this.joinCode,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxTourists: maxTourists ?? this.maxTourists,
      currentTourists: currentTourists ?? this.currentTourists,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        providerId,
        tourTemplateId,
        tourName,
        joinCode,
        startDate,
        endDate,
        maxTourists,
        currentTourists,
        pricePerPerson,
        currency,
        status,
        tags,
        description,
        createdDate,
      ];
}
