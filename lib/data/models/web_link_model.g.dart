// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_link_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebLinkModel _$WebLinkModelFromJson(Map<String, dynamic> json) => WebLinkModel(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$WebLinkModelToJson(WebLinkModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'description': instance.description,
    };
