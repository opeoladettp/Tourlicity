// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TourTemplateModel _$TourTemplateModelFromJson(Map<String, dynamic> json) =>
    TourTemplateModel(
      id: json['id'] as String,
      templateName: json['template_name'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      webLinks: (json['web_links'] as List<dynamic>)
          .map((e) => WebLinkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdDate: json['created_date'] as String,
    );

Map<String, dynamic> _$TourTemplateModelToJson(TourTemplateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'template_name': instance.templateName,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'description': instance.description,
      'is_active': instance.isActive,
      'web_links': instance.webLinks,
      'created_date': instance.createdDate,
    };
