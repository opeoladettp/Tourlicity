import 'package:equatable/equatable.dart';

/// Provider entity representing a tour provider
class Provider extends Equatable {
  const Provider({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.description,
    this.address,
    this.website,
    this.logoUrl,
    this.isActive = true,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.createdAt,
    this.updatedAt,
    // Backward compatibility parameters
    String? providerName,
    String? country,
    String? emailAddress,
    String? providerCode,
    DateTime? createdDate,
    String? corporateTaxId,
    String? companyDescription,
  })  : _providerName = providerName,
        _country = country,
        _emailAddress = emailAddress,
        _providerCode = providerCode,
        _createdDate = createdDate,
        _corporateTaxId = corporateTaxId,
        _companyDescription = companyDescription;

  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? description;
  final String? address;
  final String? website;
  final String? logoUrl;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Backward compatibility fields
  final String? _providerName;
  final String? _country;
  final String? _emailAddress;
  final String? _providerCode;
  final DateTime? _createdDate;
  final String? _corporateTaxId;
  final String? _companyDescription;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        description,
        address,
        website,
        logoUrl,
        isActive,
        rating,
        totalReviews,
        createdAt,
        updatedAt,
        _providerName,
        _country,
        _emailAddress,
        _providerCode,
        _createdDate,
        _corporateTaxId,
        _companyDescription,
      ];

  /// Backward compatibility getters for tests
  String get providerName => _providerName ?? name;
  String get country => _country ?? address ?? '';
  String get emailAddress => _emailAddress ?? email;
  String get providerCode => _providerCode ?? id;
  DateTime? get createdDate => _createdDate ?? createdAt;
  String get corporateTaxId => _corporateTaxId ?? id; // placeholder
  String get companyDescription => _companyDescription ?? description ?? '';
  bool get isValid =>
      name.isNotEmpty && email.isNotEmpty && phoneNumber.isNotEmpty;

  Provider copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? description,
    String? address,
    String? website,
    String? logoUrl,
    bool? isActive,
    double? rating,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      address: address ?? this.address,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
