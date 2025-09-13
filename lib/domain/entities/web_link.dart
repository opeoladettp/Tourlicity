import 'package:equatable/equatable.dart';

/// Web link entity for tour templates
class WebLink extends Equatable {
  const WebLink({
    required this.id,
    required this.title,
    required this.url,
    this.description,
    this.order = 0,
  });

  final String id;
  final String title;
  final String url;
  final String? description;
  final int order;

  @override
  List<Object?> get props => [id, title, url, description, order];

  /// Validation getter for tests
  bool get isValid =>
      title.isNotEmpty && url.isNotEmpty && Uri.tryParse(url) != null;

  WebLink copyWith({
    String? id,
    String? title,
    String? url,
    String? description,
    int? order,
  }) {
    return WebLink(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }
}
