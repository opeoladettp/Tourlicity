// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    DocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tourId: json['tour_id'] as String?,
      fileName: json['file_name'] as String,
      originalFileName: json['original_file_name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      fileSizeBytes: (json['file_size_bytes'] as num).toInt(),
      mimeType: json['mime_type'] as String,
      description: json['description'] as String?,
      uploadedAt: json['uploaded_at'] as String,
      expiryDate: json['expiry_date'] as String?,
      reviewNotes: json['review_notes'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      downloadUrl: json['download_url'] as String?,
      urlExpiresAt: json['url_expires_at'] as String?,
    );

Map<String, dynamic> _$DocumentModelToJson(DocumentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'tour_id': instance.tourId,
      'file_name': instance.fileName,
      'original_file_name': instance.originalFileName,
      'type': instance.type,
      'status': instance.status,
      'file_size_bytes': instance.fileSizeBytes,
      'mime_type': instance.mimeType,
      'description': instance.description,
      'uploaded_at': instance.uploadedAt,
      'expiry_date': instance.expiryDate,
      'review_notes': instance.reviewNotes,
      'reviewed_by': instance.reviewedBy,
      'reviewed_at': instance.reviewedAt,
      'download_url': instance.downloadUrl,
      'url_expires_at': instance.urlExpiresAt,
    };
