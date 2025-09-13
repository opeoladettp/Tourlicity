import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'provider_model.g.dart';

@JsonSerializable()
class ProviderModel {
  final String id;
  @JsonKey(name: 'provider_name')
  final String providerName;
  final String country;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  final String address;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'email_address')
  final String emailAddress;
  @JsonKey(name: 'corporate_tax_id')
  final String? corporateTaxId;
  @JsonKey(name: 'company_description')
  final String? companyDescription;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'provider_code')
  final String providerCode;
  @JsonKey(name: 'created_date')
  final String createdDate;

  const ProviderModel({
    required this.id,
    required this.providerName,
    required this.country,
    this.logoUrl,
    required this.address,
    required this.phoneNumber,
    required this.emailAddress,
    this.corporateTaxId,
    this.companyDescription,
    required this.isActive,
    required this.providerCode,
    required this.createdDate,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderModelToJson(this);

  factory ProviderModel.fromEntity(Provider provider) {
    return ProviderModel(
      id: provider.id,
      providerName: provider.providerName,
      country: provider.country,
      logoUrl: provider.logoUrl,
      address: provider.address ?? '',
      phoneNumber: provider.phoneNumber,
      emailAddress: provider.emailAddress,
      corporateTaxId: provider.corporateTaxId,
      companyDescription: provider.companyDescription,
      isActive: provider.isActive,
      providerCode: provider.providerCode,
      createdDate: provider.createdDate?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    );
  }

  Provider toEntity() {
    return Provider(
      id: id,
      name: providerName,
      email: emailAddress,
      phoneNumber: phoneNumber,
      description: companyDescription,
      address: address,
      logoUrl: logoUrl,
      isActive: isActive,
      providerName: providerName,
      country: country,
      emailAddress: emailAddress,
      corporateTaxId: corporateTaxId,
      companyDescription: companyDescription,
      providerCode: providerCode,
      createdDate: DateTime.parse(createdDate),
    );
  }
}
