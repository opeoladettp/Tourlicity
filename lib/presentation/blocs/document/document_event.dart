import 'package:equatable/equatable.dart';
import '../../../domain/entities/document.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class UploadDocument extends DocumentEvent {
  final String filePath;
  final String userId;
  final String? tourId;
  final DocumentType type;
  final String? description;
  final DateTime? expiryDate;

  const UploadDocument({
    required this.filePath,
    required this.userId,
    this.tourId,
    required this.type,
    this.description,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [filePath, userId, tourId, type, description, expiryDate];
}

class LoadDocumentById extends DocumentEvent {
  final String documentId;

  const LoadDocumentById(this.documentId);

  @override
  List<Object> get props => [documentId];
}

class LoadDocumentsByUser extends DocumentEvent {
  final String userId;
  final DocumentType? type;
  final DocumentStatus? status;
  final String? tourId;
  final int? limit;
  final int? offset;

  const LoadDocumentsByUser({
    required this.userId,
    this.type,
    this.status,
    this.tourId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, type, status, tourId, limit, offset];
}

class LoadDocumentsByTour extends DocumentEvent {
  final String tourId;
  final DocumentType? type;
  final DocumentStatus? status;
  final int? limit;
  final int? offset;

  const LoadDocumentsByTour({
    required this.tourId,
    this.type,
    this.status,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [tourId, type, status, limit, offset];
}

class LoadDocumentsForReview extends DocumentEvent {
  final String? providerId;
  final String? tourId;
  final DocumentType? type;
  final int? limit;
  final int? offset;

  const LoadDocumentsForReview({
    this.providerId,
    this.tourId,
    this.type,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [providerId, tourId, type, limit, offset];
}

class GetDownloadUrl extends DocumentEvent {
  final String documentId;

  const GetDownloadUrl(this.documentId);

  @override
  List<Object> get props => [documentId];
}

class ApproveDocument extends DocumentEvent {
  final String documentId;
  final String? notes;
  final String reviewedBy;

  const ApproveDocument({
    required this.documentId,
    this.notes,
    required this.reviewedBy,
  });

  @override
  List<Object?> get props => [documentId, notes, reviewedBy];
}

class RejectDocument extends DocumentEvent {
  final String documentId;
  final String reason;
  final String reviewedBy;

  const RejectDocument({
    required this.documentId,
    required this.reason,
    required this.reviewedBy,
  });

  @override
  List<Object> get props => [documentId, reason, reviewedBy];
}

class DeleteDocument extends DocumentEvent {
  final String documentId;

  const DeleteDocument(this.documentId);

  @override
  List<Object> get props => [documentId];
}

class UpdateDocument extends DocumentEvent {
  final String documentId;
  final String? description;
  final DateTime? expiryDate;

  const UpdateDocument({
    required this.documentId,
    this.description,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [documentId, description, expiryDate];
}

class LoadDocumentStats extends DocumentEvent {
  final String? userId;
  final String? tourId;

  const LoadDocumentStats({
    this.userId,
    this.tourId,
  });

  @override
  List<Object?> get props => [userId, tourId];
}

class SearchDocuments extends DocumentEvent {
  final String? query;
  final String? userId;
  final String? tourId;
  final DocumentType? type;
  final DocumentStatus? status;
  final DateTime? uploadedAfter;
  final DateTime? uploadedBefore;
  final int? limit;
  final int? offset;

  const SearchDocuments({
    this.query,
    this.userId,
    this.tourId,
    this.type,
    this.status,
    this.uploadedAfter,
    this.uploadedBefore,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [
        query,
        userId,
        tourId,
        type,
        status,
        uploadedAfter,
        uploadedBefore,
        limit,
        offset,
      ];
}

class LoadExpiringDocuments extends DocumentEvent {
  final String? userId;
  final String? tourId;
  final int daysAhead;
  final int? limit;
  final int? offset;

  const LoadExpiringDocuments({
    this.userId,
    this.tourId,
    this.daysAhead = 30,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, tourId, daysAhead, limit, offset];
}

class BulkApproveDocuments extends DocumentEvent {
  final List<String> documentIds;
  final String? notes;
  final String reviewedBy;

  const BulkApproveDocuments({
    required this.documentIds,
    this.notes,
    required this.reviewedBy,
  });

  @override
  List<Object?> get props => [documentIds, notes, reviewedBy];
}

class BulkRejectDocuments extends DocumentEvent {
  final List<String> documentIds;
  final String reason;
  final String reviewedBy;

  const BulkRejectDocuments({
    required this.documentIds,
    required this.reason,
    required this.reviewedBy,
  });

  @override
  List<Object> get props => [documentIds, reason, reviewedBy];
}

class RefreshDocuments extends DocumentEvent {
  const RefreshDocuments();
}

class ClearDocumentError extends DocumentEvent {
  const ClearDocumentError();
}

class FilterDocumentsByStatus extends DocumentEvent {
  final DocumentStatus? status;

  const FilterDocumentsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class FilterDocumentsByType extends DocumentEvent {
  final DocumentType? type;

  const FilterDocumentsByType(this.type);

  @override
  List<Object?> get props => [type];
}