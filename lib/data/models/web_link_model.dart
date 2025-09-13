import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'web_link_model.g.dart';

@JsonSerializable()
class WebLinkModel {
  final String id;
  final String title;
  final String url;
  final String? description;

  const WebLinkModel({
    required this.id,
    required this.title,
    required this.url,
    this.description,
  });

  factory WebLinkModel.fromJson(Map<String, dynamic> json) =>
      _$WebLinkModelFromJson(json);

  Map<String, dynamic> toJson() => _$WebLinkModelToJson(this);

  factory WebLinkModel.fromEntity(WebLink webLink) {
    return WebLinkModel(
      id: webLink.id,
      title: webLink.title,
      url: webLink.url,
      description: webLink.description,
    );
  }

  WebLink toEntity() {
    return WebLink(
      id: id,
      title: title,
      url: url,
      description: description,
    );
  }
}
