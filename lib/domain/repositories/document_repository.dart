import '../entities/document.dart';
import '../../core/network/api_result.dart';

/// Repository interface for document operations
abstract class DocumentRepository {
  /// Upload a new document
  Future<ApiResult<Document>> uploadDocument({
    required String filePath,
    required String userId,
    String? tourId,
    required DocumentType type,
    String? description,
    DateTime? expiryDate,
  });

  /// Get document by ID
  Future<ApiResult<Document>> getDocumentById(String documentId);

  /// Get documents for a user
  Future<ApiResult<List<Document>>> getDocumentsByUser({
    required String userId,
    DocumentType? type,
    DocumentStatus? status,
    String? tourId,
    int? limit,
    int? offset,
  });

  /// Get documents for a tour (provider view)
  Future<ApiResult<List<Document>>> getDocumentsByTour({
    required String tourId,
    DocumentType? type,
    DocumentStatus? status,
    int? limit,
    int? offset,
  });

  /// Get documents requiring review (provider/admin view)
  Future<ApiResult<List<Document>>> getDocumentsForReview({
    String? providerId,
    String? tourId,
    DocumentType? type,
    int? limit,
    int? offset,
  });

  /// Download document (get secure URL)
  Future<ApiResult<String>> getDownloadUrl(String documentId);

  /// Approve document (provider/admin only)
  Future<ApiResult<Document>> approveDocument({
    required String documentId,
    String? notes,
    required String reviewedBy,
  });

  /// Reject document (provider/admin only)
  Future<ApiResult<Document>> rejectDocument({
    required String documentId,
    required String reason,
    required String reviewedBy,
  });

  /// Delete document
  Future<ApiResult<void>> deleteDocument(String documentId);

  /// Update document metadata
  Future<ApiResult<Document>> updateDocument({
    required String documentId,
    String? description,
    DateTime? expiryDate,
  });

  /// Get document statistics
  Future<ApiResult<Map<String, int>>> getDocumentStats({
    String? userId,
    String? tourId,
  });

  /// Search documents
  Future<ApiResult<List<Document>>> searchDocuments({
    String? query,
    String? userId,
    String? tourId,
    DocumentType? type,
    DocumentStatus? status,
    DateTime? uploadedAfter,
    DateTime? uploadedBefore,
    int? limit,
    int? offset,
  });

  /// Check for expiring documents
  Future<ApiResult<List<Document>>> getExpiringDocuments({
    String? userId,
    String? tourId,
    int daysAhead = 30,
    int? limit,
    int? offset,
  });

  /// Bulk approve documents
  Future<ApiResult<List<Document>>> bulkApproveDocuments({
    required List<String> documentIds,
    String? notes,
    required String reviewedBy,
  });

  /// Bulk reject documents
  Future<ApiResult<List<Document>>> bulkRejectDocuments({
    required List<String> documentIds,
    required String reason,
    required String reviewedBy,
  });
}