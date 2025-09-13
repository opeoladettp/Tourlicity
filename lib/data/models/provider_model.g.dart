// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderModel _$ProviderModelFromJson(Map<String, dynamic> json) =>
    ProviderModel(
      id: json['id'] as String,
      providerName: json['provider_name'] as String,
      country: json['country'] as String,
      logoUrl: json['logo_url'] as String?,
      address: json['address'] as String,
      phoneNumber: json['phone_number'] as String,
      emailAddress: json['email_address'] as String,
      corporateTaxId: json['corporate_tax_id'] as String?,
      companyDescription: json['company_description'] as String?,
      isActive: json['is_active'] as bool,
      providerCode: json['provider_code'] as String,
      createdDate: json['created_date'] as String,
    );

Map<String, dynamic> _$ProviderModelToJson(ProviderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider_name': instance.providerName,
      'country': instance.country,
      'logo_url': instance.logoUrl,
      'address': instance.address,
      'phone_number': instance.phoneNumber,
      'email_address': instance.emailAddress,
      'corporate_tax_id': instance.corporateTaxId,
      'company_description': instance.companyDescription,
      'is_active': instance.isActive,
      'provider_code': instance.providerCode,
      'created_date': instance.createdDate,
    };
