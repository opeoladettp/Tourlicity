import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../../core/network/api_result.dart';
import '../../core/network/api_client.dart';
import '../models/document_model.dart';

/// Implementation of DocumentRepository
class DocumentRepositoryImpl implements DocumentRepository {
  const DocumentRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<ApiResult<Document>> uploadDocument({
    required String filePath,
    required String userId,
    String? tourId,
    required DocumentType type,
    String? description,
    DateTime? expiryDate,
  }) async {
    try {
      final fields = <String, String>{
        'user_id': userId,
        'type': type.name,
        if (tourId != null) 'tour_id': tourId,
        if (description != null) 'description': description,
        if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
      };

      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        '/documents',
        filePath,
        fieldName: 'document',
        fields: fields,
      );

      return response.fold(
        onSuccess: (data) {
          final documentModel = DocumentModel.fromJson(data);
          return ApiSuccess(data: documentModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to upload document: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Document>> getDocumentById(String documentId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/documents/$documentId',
      );

      return response.fold(
        onSuccess: (data) {
          final documentModel = DocumentModel.fromJson(data);
          return ApiSuccess(data: documentModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get document: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<List<Document>>> getDocumentsByUser({
    required String userId,
    DocumentType? type,
    DocumentStatus? status,
    String? tourId,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'user_id': userId,
        if (type != null) 'type': type.name,
        if (status != null) 'status': status.name,
        if (tourId != null) 'tour_id': tourId,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/documents',
        queryParameters: queryParameters,
      );

      return response.fold(
        onSuccess: (data) {
          final documentsData = data['documents'] as List<dynamic>;
          final documents = documentsData
              .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: documents);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get user documents: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<List<Document>>> getDocumentsByTour({
    required String tourId,
    DocumentType? type,
    DocumentStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'tour_id': tourId,
        if (type != null) 'type': type.name,
        if (status != null) 'status': status.name,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/documents',
        queryParameters: queryParameters,
      );

      return response.fold(
        onSuccess: (data) {
          final documentsData = data['documents'] as List<dynamic>;
          final documents = documentsData
              .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: documents);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get tour documents: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<List<Document>>> getDocumentsForReview({
    String? providerId,
    String? tourId,
    DocumentType? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'status': 'pending',
        if (providerId != null) 'provider_id': providerId,
        if (tourId != null) 'tour_id': tourId,
        if (type != null) 'type': type.name,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/documents/review',
        queryParameters: queryParameters,
      );

      return response.fold(
        onSuccess: (data) {
          final documentsData = data['documents'] as List<dynamic>;
          final documents = documentsData
              .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: documents);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get documents for review: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<String>> getDownloadUrl(String documentId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/documents/$documentId/download',
      );

      return response.fold(
        onSuccess: (data) {
          final downloadUrl = data['download_url'] as String;
          return ApiSuccess(data: downloadUrl);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get download URL: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Document>> approveDocument({
    required String documentId,
    String? notes,
    required String reviewedBy,
  }) async {
    try {
      final requestData = {
        'status': 'approved',
        'reviewed_by': reviewedBy,
        if (notes != null) 'review_notes': notes,
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/documents/$documentId/review',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final documentModel = DocumentModel.fromJson(data);
          return ApiSuccess(data: documentModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to approve document: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Document>> rejectDocument({
    required String documentId,
    required String reason,
    required String reviewedBy,
  }) async {
    try {
      final requestData = {
        'status': 'rejected',
        'reviewed_by': reviewedBy,
        'review_notes': reason,
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/documents/$documentId/review',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final documentModel = DocumentModel.fromJson(data);
          return ApiSuccess(data: documentModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to reject document: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<void>> deleteDocument(String documentId) async {
    try {
      final response = await _apiClient.delete<void>(
        '/documents/$documentId',
      );

      return response.fold(
        onSuccess: (_) => const ApiSuccess(data: null),
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to delete document: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Document>> updateDocument({
    required String documentId,
    String? description,
    DateTime? expiryDate,
  }) async {
    try {
      final requestData = <String, dynamic>{
        if (description != null) 'description': description,
        if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String(),
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/documents/$documentId',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final documentModel = DocumentModel.fromJson(data);
          return ApiSuccess(data: documentModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to update document: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Map<String, int>>> getDocumentStats({
    String? userId,
    String? tourId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (userId != null) 'user_id': userId,
        if (tourId != null) 'tour_id': tourId,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/documents/stats',
        queryParameters: queryParameters,
      );

      return response.fold(
        onSuccess: (data) {
          final stats = Map<String, int>.from(data);
          return ApiSuccess(data: stats);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get document stats: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
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
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (query != null) 'query': query,
        if (userId != null) 'user_id': userId,
        if (tourId != null) 'tour_id': tourId,
        if (type != null) 'type': type.name,
        if (status != null) 'status': status.name,
        if (uploadedAfter != null) 'uploaded_after': uploadedAfter.toIso8601String(),
        if (uploadedBefore != null) 'uploaded_before': uploadedBefore.toIso8601String(),
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/documents/search',
        queryParameters: queryParameters,
      );

      return response.fold(
        onSuccess: (data) {
          final documentsData = data['documents'] as List<dynamic>;
          final documents = documentsData
              .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: documents);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to search documents: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<List<Document>>> getExpiringDocuments({
    String? userId,
    String? tourId,
    int daysAhead = 30,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'days_ahead': daysAhead,
        if (userId != null) 'user_id': userId,
        if (tourId != null) 'tour_id': tourId,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/documents/expiring',
        queryParameters: queryParameters,
      );

      return response.fold(
        onSuccess: (data) {
          final documentsData = data['documents'] as List<dynamic>;
          final documents = documentsData
              .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: documents);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get expiring documents: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<List<Document>>> bulkApproveDocuments({
    required List<String> documentIds,
    String? notes,
    required String reviewedBy,
  }) async {
    try {
      final requestData = {
        'document_ids': documentIds,
        'status': 'approved',
        'reviewed_by': reviewedBy,
        if (notes != null) 'review_notes': notes,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/documents/bulk-review',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final documentsData = data['documents'] as List<dynamic>;
          final documents = documentsData
              .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: documents);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to bulk approve documents: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<List<Document>>> bulkRejectDocuments({
    required List<String> documentIds,
    required String reason,
    required String reviewedBy,
  }) async {
    try {
      final requestData = {
        'document_ids': documentIds,
        'status': 'rejected',
        'reviewed_by': reviewedBy,
        'review_notes': reason,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/documents/bulk-review',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final documentsData = data['documents'] as List<dynamic>;
          final documents = documentsData
              .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: documents);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to bulk reject documents: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}