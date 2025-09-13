// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_tour_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomTourModel _$CustomTourModelFromJson(Map<String, dynamic> json) =>
    CustomTourModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      tourTemplateId: json['tour_template_id'] as String,
      tourName: json['tour_name'] as String,
      joinCode: json['join_code'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      maxTourists: (json['max_tourists'] as num).toInt(),
      currentTourists: (json['current_tourists'] as num).toInt(),
      pricePerPerson: (json['price_per_person'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String?,
      createdDate: json['created_date'] as String,
    );

Map<String, dynamic> _$CustomTourModelToJson(CustomTourModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider_id': instance.providerId,
      'tour_template_id': instance.tourTemplateId,
      'tour_name': instance.tourName,
      'join_code': instance.joinCode,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'max_tourists': instance.maxTourists,
      'current_tourists': instance.currentTourists,
      'price_per_person': instance.pricePerPerson,
      'currency': instance.currency,
      'status': instance.status,
      'tags': instance.tags,
      'description': instance.description,
      'created_date': instance.createdDate,
    };
