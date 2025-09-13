import 'package:equatable/equatable.dart';
import 'web_link.dart';

/// Tour template entity
class TourTemplate extends Equatable {
  const TourTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
    required this.maxParticipants,
    required this.providerId,
    this.imageUrl,
    this.webLinks = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    // Backward compatibility parameters
    String? templateName,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdDate,
  })  : _templateName = templateName,
        _startDate = startDate,
        _endDate = endDate,
        _createdDate = createdDate;

  final String id;
  final String title;
  final String description;
  final int duration; // in hours
  final double price;
  final int maxParticipants;
  final String providerId;
  final String? imageUrl;
  final List<WebLink> webLinks;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Backward compatibility fields
  final String? _templateName;
  final DateTime? _startDate;
  final DateTime? _endDate;
  final DateTime? _createdDate;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        duration,
        price,
        maxParticipants,
        providerId,
        imageUrl,
        webLinks,
        isActive,
        createdAt,
        updatedAt,
        _templateName,
        _startDate,
        _endDate,
        _createdDate,
      ];

  /// Backward compatibility getters for tests
  String get templateName => _templateName ?? title;
  DateTime? get startDate => _startDate ?? createdAt;
  DateTime? get endDate => _endDate ?? updatedAt;
  DateTime? get createdDate => _createdDate ?? createdAt;
  int get durationDays => (duration / 24).ceil();
  bool get isValidDateRange =>
      startDate != null && endDate != null && startDate!.isBefore(endDate!);
  bool get isValid =>
      title.isNotEmpty &&
      description.isNotEmpty &&
      price > 0 &&
      maxParticipants > 0;
  bool get isCurrentlyActive =>
      isActive && (endDate == null || endDate!.isAfter(DateTime.now()));

  TourTemplate copyWith({
    String? id,
    String? title,
    String? description,
    int? duration,
    double? price,
    int? maxParticipants,
    String? providerId,
    String? imageUrl,
    List<WebLink>? webLinks,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TourTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      providerId: providerId ?? this.providerId,
      imageUrl: imageUrl ?? this.imageUrl,
      webLinks: webLinks ?? this.webLinks,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
