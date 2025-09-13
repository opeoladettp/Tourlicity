import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';
import 'web_link_model.dart';

part 'tour_template_model.g.dart';

@JsonSerializable()
class TourTemplateModel {
  final String id;
  @JsonKey(name: 'template_name')
  final String templateName;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  final String? description;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'web_links')
  final List<WebLinkModel> webLinks;
  @JsonKey(name: 'created_date')
  final String createdDate;

  const TourTemplateModel({
    required this.id,
    required this.templateName,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.isActive,
    required this.webLinks,
    required this.createdDate,
  });

  factory TourTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TourTemplateModelFromJson(json);

  Map<String, dynamic> toJson() => _$TourTemplateModelToJson(this);

  factory TourTemplateModel.fromEntity(TourTemplate tourTemplate) {
    return TourTemplateModel(
      id: tourTemplate.id,
      templateName: tourTemplate.templateName,
      startDate: tourTemplate.startDate?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      endDate: tourTemplate.endDate?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      description: tourTemplate.description,
      isActive: tourTemplate.isActive,
      webLinks: tourTemplate.webLinks
          .map((link) => WebLinkModel.fromEntity(link))
          .toList(),
      createdDate: tourTemplate.createdDate?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    );
  }

  TourTemplate toEntity() {
    return TourTemplate(
      id: id,
      title: templateName,
      description: description ?? 'No description',
      duration: 24, // Default 1 day in hours
      price: 0.0, // Default price
      maxParticipants: 10, // Default max participants
      providerId: 'default-provider', // Default provider
      isActive: isActive,
      webLinks: webLinks.map((model) => model.toEntity()).toList(),
      templateName: templateName,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      createdDate: DateTime.parse(createdDate),
    );
  }
}
