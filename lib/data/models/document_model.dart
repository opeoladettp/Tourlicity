import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entities.dart';

part 'document_model.g.dart';

@JsonSerializable()
class DocumentModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'tour_id')
  final String? tourId;
  @JsonKey(name: 'file_name')
  final String fileName;
  @JsonKey(name: 'original_file_name')
  final String originalFileName;
  final String type;
  final String status;
  @JsonKey(name: 'file_size_bytes')
  final int fileSizeBytes;
  @JsonKey(name: 'mime_type')
  final String mimeType;
  final String? description;
  @JsonKey(name: 'uploaded_at')
  final String uploadedAt;
  @JsonKey(name: 'expiry_date')
  final String? expiryDate;
  @JsonKey(name: 'review_notes')
  final String? reviewNotes;
  @JsonKey(name: 'reviewed_by')
  final String? reviewedBy;
  @JsonKey(name: 'reviewed_at')
  final String? reviewedAt;
  @JsonKey(name: 'download_url')
  final String? downloadUrl;
  @JsonKey(name: 'url_expires_at')
  final String? urlExpiresAt;

  const DocumentModel({
    required this.id,
    required this.userId,
    this.tourId,
    required this.fileName,
    required this.originalFileName,
    required this.type,
    required this.status,
    required this.fileSizeBytes,
    required this.mimeType,
    this.description,
    required this.uploadedAt,
    this.expiryDate,
    this.reviewNotes,
    this.reviewedBy,
    this.reviewedAt,
    this.downloadUrl,
    this.urlExpiresAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);

  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      userId: document.userId,
      tourId: document.tourId,
      fileName: document.fileName,
      originalFileName: document.originalFileName,
      type: document.type.name,
      status: document.status.name,
      fileSizeBytes: document.fileSizeBytes,
      mimeType: document.mimeType,
      description: document.description,
      uploadedAt: document.uploadedAt.toIso8601String(),
      expiryDate: document.expiryDate?.toIso8601String(),
      reviewNotes: document.reviewNotes,
      reviewedBy: document.reviewedBy,
      reviewedAt: document.reviewedAt?.toIso8601String(),
      downloadUrl: document.downloadUrl,
      urlExpiresAt: document.urlExpiresAt?.toIso8601String(),
    );
  }

  Document toEntity() {
    return Document(
      id: id,
      userId: userId,
      tourId: tourId,
      fileName: fileName,
      originalFileName: originalFileName,
      type: _parseDocumentType(type),
      status: _parseDocumentStatus(status),
      fileSizeBytes: fileSizeBytes,
      mimeType: mimeType,
      description: description,
      uploadedAt: DateTime.parse(uploadedAt),
      expiryDate: expiryDate != null ? DateTime.parse(expiryDate!) : null,
      reviewNotes: reviewNotes,
      reviewedBy: reviewedBy,
      reviewedAt: reviewedAt != null ? DateTime.parse(reviewedAt!) : null,
      downloadUrl: downloadUrl,
      urlExpiresAt: urlExpiresAt != null ? DateTime.parse(urlExpiresAt!) : null,
    );
  }

  DocumentType _parseDocumentType(String type) {
    switch (type.toLowerCase()) {
      case 'passport':
        return DocumentType.passport;
      case 'visa':
        return DocumentType.visa;
      case 'insurance':
        return DocumentType.insurance;
      case 'medicalcertificate':
      case 'medical_certificate':
        return DocumentType.medicalCertificate;
      case 'emergencycontact':
      case 'emergency_contact':
        return DocumentType.emergencyContact;
      case 'other':
        return DocumentType.other;
      default:
        return DocumentType.other;
    }
  }

  DocumentStatus _parseDocumentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DocumentStatus.pending;
      case 'approved':
        return DocumentStatus.approved;
      case 'rejected':
        return DocumentStatus.rejected;
      case 'expired':
        return DocumentStatus.expired;
      default:
        return DocumentStatus.pending;
    }
  }
}