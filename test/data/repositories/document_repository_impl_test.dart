import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:tourlicity_app/core/network/api_client.dart';
import 'package:tourlicity_app/core/network/api_result.dart';
import 'package:tourlicity_app/data/repositories/document_repository_impl.dart';
import 'package:tourlicity_app/domain/entities/document.dart';

class MockApiClient extends Mock implements ApiClient {
  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#get, [path], {
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#post, [path], {
          #data: data,
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#patch, [path], {
          #data: data,
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#delete, [path], {
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#uploadFile, [path, filePath], {
          #fieldName: fieldName,
          #fields: fields,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );

  @override
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#put, [path], {
          #data: data,
          #queryParameters: queryParameters,
          #headers: headers,
        }),
        returnValue: Future<ApiResult<T>>.value(
          ApiFailure<T>(message: 'Mock not configured'),
        ),
      );
}

void main() {
  group('DocumentRepositoryImpl', () {
    late DocumentRepositoryImpl repository;
    late MockApiClient mockApiClient;

    // Test document data for API responses (used in test setup)

    final testDocumentJson = {
      'id': '1',
      'user_id': 'user-1',
      'tour_id': 'tour-1',
      'file_name': 'test_document.pdf',
      'original_file_name': 'passport.pdf',
      'type': 'passport',
      'status': 'pending',
      'file_size_bytes': 1024000,
      'mime_type': 'application/pdf',
      'description': 'Test passport document',
      'uploaded_at': '2024-01-01T00:00:00.000Z',
      'expiry_date': '2025-01-01T00:00:00.000Z',
      'review_notes': null,
      'reviewed_by': null,
      'reviewed_at': null,
      'download_url': null,
      'url_expires_at': null,
    };

    setUp(() {
      mockApiClient = MockApiClient();
      repository = DocumentRepositoryImpl(apiClient: mockApiClient);
    });

    group('uploadDocument', () {
      test('should return document when upload is successful', () async {
        // Arrange
        when(mockApiClient.uploadFile<Map<String, dynamic>>(
          '/documents',
          '/path/to/file.pdf',
          fieldName: 'document',
          fields: anyNamed('fields'),
        )).thenAnswer((_) async => ApiSuccess(data: testDocumentJson));

        // Act
        final result = await repository.uploadDocument(
          filePath: "test.pdf",
          userId: "user1",
          type: DocumentType.other,
          description: "Test document",
        );

        // Assert
        expect(result, isA<ApiSuccess<Document>>());
        final document = result.data!;
        expect(document.id, '1');
        expect(document.userId, 'user-1');
        expect(document.type, DocumentType.passport);
        expect(document.status, DocumentStatus.pending);
      });

      test('should return failure when upload fails', () async {
        // Arrange
        when(mockApiClient.uploadFile<Map<String, dynamic>>(
          '/documents',
          '/path/to/file.pdf',
          fieldName: 'document',
          fields: anyNamed('fields'),
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Upload failed',
              statusCode: 400,
            ));

        // Act
        final result = await repository.uploadDocument(
          filePath: "test.pdf",
          userId: "user1",
          type: DocumentType.other,
          description: "Test document",
        );

        // Assert
        expect(result, isA<ApiFailure<Document>>());
        expect(result.error, 'Upload failed');
      });
    });

    group('getDocumentById', () {
      test('should return document when API call is successful', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents/1',
        )).thenAnswer((_) async => ApiSuccess(data: testDocumentJson));

        // Act
        final result = await repository.getDocumentById('1');

        // Assert
        expect(result, isA<ApiSuccess<Document>>());
        final document = result.data!;
        expect(document.id, '1');
        expect(document.originalFileName, 'passport.pdf');
      });

      test('should return failure when document not found', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents/999',
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Document not found',
              statusCode: 404,
            ));

        // Act
        final result = await repository.getDocumentById('999');

        // Assert
        expect(result, isA<ApiFailure<Document>>());
        expect(result.error, 'Document not found');
      });
    });

    group('getDocumentsByUser', () {
      test('should return list of documents when API call is successful', () async {
        // Arrange
        final documentsResponse = {
          'documents': [testDocumentJson],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: documentsResponse));

        // Act
        final result = await repository.getDocumentsByUser(
          userId: 'user-1',
          type: DocumentType.passport,
          status: DocumentStatus.pending,
          limit: 10,
          offset: 0,
        );

        // Assert
        expect(result, isA<ApiSuccess<List<Document>>>());
        final documents = result.data!;
        expect(documents.length, 1);
        expect(documents.first.id, '1');

        // Verify API call with query parameters
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/documents',
          queryParameters: {
            'user_id': 'user-1',
            'type': 'passport',
            'status': 'pending',
            'limit': 10,
            'offset': 0,
          },
        )).called(1);
      });

      test('should return empty list when no documents found', () async {
        // Arrange
        final documentsResponse = {
          'documents': <Map<String, dynamic>>[],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: documentsResponse));

        // Act
        final result = await repository.getDocumentsByUser(userId: 'user-1');

        // Assert
        expect(result, isA<ApiSuccess<List<Document>>>());
        final documents = result.data!;
        expect(documents.isEmpty, true);
      });
    });

    group('getDocumentsByTour', () {
      test('should return list of documents for tour', () async {
        // Arrange
        final documentsResponse = {
          'documents': [testDocumentJson],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: documentsResponse));

        // Act
        final result = await repository.getDocumentsByTour(tourId: 'tour-1');

        // Assert
        expect(result, isA<ApiSuccess<List<Document>>>());
        final documents = result.data!;
        expect(documents.length, 1);
        expect(documents.first.tourId, 'tour-1');

        // Verify API call
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/documents',
          queryParameters: {
            'tour_id': 'tour-1',
          },
        )).called(1);
      });
    });

    group('getDocumentsForReview', () {
      test('should return pending documents for review', () async {
        // Arrange
        final documentsResponse = {
          'documents': [testDocumentJson],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents/review',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: documentsResponse));

        // Act
        final result = await repository.getDocumentsForReview(
          providerId: 'provider-1',
          tourId: 'tour-1',
        );

        // Assert
        expect(result, isA<ApiSuccess<List<Document>>>());
        final documents = result.data!;
        expect(documents.length, 1);
        expect(documents.first.status, DocumentStatus.pending);

        // Verify API call
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/documents/review',
          queryParameters: {
            'status': 'pending',
            'provider_id': 'provider-1',
            'tour_id': 'tour-1',
          },
        )).called(1);
      });
    });

    group('getDownloadUrl', () {
      test('should return download URL when API call is successful', () async {
        // Arrange
        final downloadResponse = {
          'download_url': 'https://example.com/download/document.pdf',
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents/1/download',
        )).thenAnswer((_) async => ApiSuccess(data: downloadResponse));

        // Act
        final result = await repository.getDownloadUrl('1');

        // Assert
        expect(result, isA<ApiSuccess<String>>());
        expect(result.data, 'https://example.com/download/document.pdf');
      });
    });

    group('approveDocument', () {
      test('should return approved document when API call is successful', () async {
        // Arrange
        final approvedDocumentJson = {
          ...testDocumentJson,
          'status': 'approved',
          'review_notes': 'Document looks good',
          'reviewed_by': 'provider-1',
          'reviewed_at': '2024-01-02T00:00:00.000Z',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/documents/1/review',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: approvedDocumentJson));

        // Act
        final result = await repository.approveDocument(
          documentId: "1",
          notes: "Document looks good",
          reviewedBy: "provider-1",
        );

        // Assert
        expect(result, isA<ApiSuccess<Document>>());
        final document = result.data!;
        expect(document.status, DocumentStatus.approved);
        expect(document.reviewNotes, 'Document looks good');
        expect(document.reviewedBy, 'provider-1');

        // Verify API call
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/documents/1/review',
          data: {
            'status': 'approved',
            'reviewed_by': 'provider-1',
            'review_notes': 'Document looks good',
          },
        )).called(1);
      });
    });

    group('rejectDocument', () {
      test('should return rejected document when API call is successful', () async {
        // Arrange
        final rejectedDocumentJson = {
          ...testDocumentJson,
          'status': 'rejected',
          'review_notes': 'Document is blurry',
          'reviewed_by': 'provider-1',
          'reviewed_at': '2024-01-02T00:00:00.000Z',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/documents/1/review',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: rejectedDocumentJson));

        // Act
        final result = await repository.rejectDocument(
          documentId: "1",
          reason: "Document is blurry",
          reviewedBy: "provider-1",
        );

        // Assert
        expect(result, isA<ApiSuccess<Document>>());
        final document = result.data!;
        expect(document.status, DocumentStatus.rejected);
        expect(document.reviewNotes, 'Document is blurry');

        // Verify API call
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/documents/1/review',
          data: {
            'status': 'rejected',
            'reviewed_by': 'provider-1',
            'review_notes': 'Document is blurry',
          },
        )).called(1);
      });
    });

    group('deleteDocument', () {
      test('should return success when document is deleted', () async {
        // Arrange
        when(mockApiClient.delete<void>(
          '/documents/1',
        )).thenAnswer((_) async => const ApiSuccess(data: null));

        // Act
        final result = await repository.deleteDocument("document-1");

        // Assert
        expect(result, isA<ApiSuccess<void>>());
      });

      test('should return failure when delete fails', () async {
        // Arrange
        when(mockApiClient.delete<void>(
          '/documents/1',
        )).thenAnswer((_) async => const ApiFailure(
              message: 'Delete failed',
              statusCode: 400,
            ));

        // Act
        final result = await repository.deleteDocument("document-1");

        // Assert
        expect(result, isA<ApiFailure<void>>());
        expect(result.error, 'Delete failed');
      });
    });

    group('updateDocument', () {
      test('should return updated document when API call is successful', () async {
        // Arrange
        final updatedDocumentJson = {
          ...testDocumentJson,
          'description': 'Updated description',
          'expiry_date': '2026-01-01T00:00:00.000Z',
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          '/documents/1',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: updatedDocumentJson));

        // Act
        final result = await repository.updateDocument(
          documentId: "1",
          description: "Updated description",
          expiryDate: DateTime.parse('2026-01-01T00:00:00.000Z'),
        );

        // Assert
        expect(result, isA<ApiSuccess<Document>>());
        final document = result.data!;
        expect(document.description, 'Updated description');

        // Verify API call
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/documents/1',
          data: {
            'description': 'Updated description',
            'expiry_date': '2026-01-01T00:00:00.000Z',
          },
        )).called(1);
      });
    });

    group('getDocumentStats', () {
      test('should return document statistics when API call is successful', () async {
        // Arrange
        final statsResponse = {
          'pending': 5,
          'approved': 10,
          'rejected': 2,
          'expired': 1,
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents/stats',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: statsResponse));

        // Act
        final result = await repository.getDocumentStats(
          userId: 'user-1',
          tourId: 'tour-1',
        );

        // Assert
        expect(result, isA<ApiSuccess<Map<String, int>>>());
        final stats = result.data!;
        expect(stats['pending'], 5);
        expect(stats['approved'], 10);
        expect(stats['rejected'], 2);
        expect(stats['expired'], 1);
      });
    });

    group('searchDocuments', () {
      test('should return search results when API call is successful', () async {
        // Arrange
        final searchResponse = {
          'documents': [testDocumentJson],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents/search',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: searchResponse));

        // Act
        final result = await repository.searchDocuments(
          query: 'passport',
          userId: 'user-1',
          type: DocumentType.passport,
        );

        // Assert
        expect(result, isA<ApiSuccess<List<Document>>>());
        final documents = result.data!;
        expect(documents.length, 1);

        // Verify API call
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/documents/search',
          queryParameters: {
            'query': 'passport',
            'user_id': 'user-1',
            'type': 'passport',
          },
        )).called(1);
      });
    });

    group('getExpiringDocuments', () {
      test('should return expiring documents when API call is successful', () async {
        // Arrange
        final expiringResponse = {
          'documents': [testDocumentJson],
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          '/documents/expiring',
          queryParameters: any,
        )).thenAnswer((_) async => ApiSuccess(data: expiringResponse));

        // Act
        final result = await repository.getExpiringDocuments(
          userId: 'user-1',
          daysAhead: 30,
        );

        // Assert
        expect(result, isA<ApiSuccess<List<Document>>>());
        final documents = result.data!;
        expect(documents.length, 1);

        // Verify API call
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/documents/expiring',
          queryParameters: {
            'days_ahead': 30,
            'user_id': 'user-1',
          },
        )).called(1);
      });
    });

    group('bulkApproveDocuments', () {
      test('should return approved documents when API call is successful', () async {
        // Arrange
        final bulkResponse = {
          'documents': [testDocumentJson],
        };

        when(mockApiClient.post<Map<String, dynamic>>(
          '/documents/bulk-review',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: bulkResponse));

        // Act
        final result = await repository.bulkApproveDocuments(
          documentIds: ['1', '2'],
          notes: 'All documents approved',
          reviewedBy: 'provider-1',
        );

        // Assert
        expect(result, isA<ApiSuccess<List<Document>>>());
        final documents = result.data!;
        expect(documents.length, 1);

        // Verify API call
        verify(mockApiClient.post<Map<String, dynamic>>(
          '/documents/bulk-review',
          data: {
            'document_ids': ['1', '2'],
            'status': 'approved',
            'reviewed_by': 'provider-1',
            'review_notes': 'All documents approved',
          },
        )).called(1);
      });
    });

    group('bulkRejectDocuments', () {
      test('should return rejected documents when API call is successful', () async {
        // Arrange
        final bulkResponse = {
          'documents': [testDocumentJson],
        };

        when(mockApiClient.post<Map<String, dynamic>>(
          '/documents/bulk-review',
          data: any,
        )).thenAnswer((_) async => ApiSuccess(data: bulkResponse));

        // Act
        final result = await repository.bulkRejectDocuments(
          documentIds: ['1', '2'],
          reason: 'Documents are unclear',
          reviewedBy: 'provider-1',
        );

        // Assert
        expect(result, isA<ApiSuccess<List<Document>>>());
        final documents = result.data!;
        expect(documents.length, 1);

        // Verify API call
        verify(mockApiClient.post<Map<String, dynamic>>(
          '/documents/bulk-review',
          data: {
            'document_ids': ['1', '2'],
            'status': 'rejected',
            'reviewed_by': 'provider-1',
            'review_notes': 'Documents are unclear',
          },
        )).called(1);
      });
    });

    group('error handling', () {
      test('should handle exceptions and return failure', () async {
        // Arrange
        when(mockApiClient.uploadFile<Map<String, dynamic>>(
          '/documents',
          '/path/to/file.pdf',
          fieldName: 'document',
          fields: anyNamed('fields'),
        )).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.uploadDocument(
          filePath: "test.pdf",
          userId: "user1",
          type: DocumentType.other,
          description: "Test document",
        );

        // Assert
        expect(result, isA<ApiFailure<Document>>());
        expect(result.error, contains('Failed to upload document'));
      });
    });
  });
}