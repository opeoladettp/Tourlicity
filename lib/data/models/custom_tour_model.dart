import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'custom_tour_model.g.dart';

@JsonSerializable()
class CustomTourModel {
  final String id;
  @JsonKey(name: 'provider_id')
  final String providerId;
  @JsonKey(name: 'tour_template_id')
  final String tourTemplateId;
  @JsonKey(name: 'tour_name')
  final String tourName;
  @JsonKey(name: 'join_code')
  final String joinCode;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  @JsonKey(name: 'max_tourists')
  final int maxTourists;
  @JsonKey(name: 'current_tourists')
  final int currentTourists;
  @JsonKey(name: 'price_per_person')
  final double pricePerPerson;
  final String currency;
  final String status;
  final List<String> tags;
  final String? description;
  @JsonKey(name: 'created_date')
  final String createdDate;

  const CustomTourModel({
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

  factory CustomTourModel.fromJson(Map<String, dynamic> json) =>
      _$CustomTourModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomTourModelToJson(this);

  factory CustomTourModel.fromEntity(CustomTour customTour) {
    return CustomTourModel(
      id: customTour.id,
      providerId: customTour.providerId,
      tourTemplateId: customTour.tourTemplateId,
      tourName: customTour.tourName,
      joinCode: customTour.joinCode,
      startDate: customTour.startDate.toIso8601String(),
      endDate: customTour.endDate.toIso8601String(),
      maxTourists: customTour.maxTourists,
      currentTourists: customTour.currentTourists,
      pricePerPerson: customTour.pricePerPerson,
      currency: customTour.currency,
      status: customTour.status.name,
      tags: customTour.tags,
      description: customTour.description,
      createdDate: customTour.createdDate.toIso8601String(),
    );
  }

  CustomTour toEntity() {
    return CustomTour(
      id: id,
      providerId: providerId,
      tourTemplateId: tourTemplateId,
      tourName: tourName,
      joinCode: joinCode,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      maxTourists: maxTourists,
      currentTourists: currentTourists,
      pricePerPerson: pricePerPerson,
      currency: currency,
      status: _parseTourStatus(status),
      tags: tags,
      description: description,
      createdDate: DateTime.parse(createdDate),
    );
  }

  TourStatus _parseTourStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return TourStatus.draft;
      case 'published':
        return TourStatus.published;
      case 'active':
        return TourStatus.active;
      case 'completed':
        return TourStatus.completed;
      case 'cancelled':
        return TourStatus.cancelled;
      default:
        return TourStatus.draft;
    }
  }
}
