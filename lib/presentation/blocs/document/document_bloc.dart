import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/document.dart';
import '../../../domain/repositories/document_repository.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository _documentRepository;

  DocumentBloc({
    required DocumentRepository documentRepository,
  })  : _documentRepository = documentRepository,
        super(const DocumentInitial()) {
    on<UploadDocument>(_onUploadDocument);
    on<LoadDocumentById>(_onLoadDocumentById);
    on<LoadDocumentsByUser>(_onLoadDocumentsByUser);
    on<LoadDocumentsByTour>(_onLoadDocumentsByTour);
    on<LoadDocumentsForReview>(_onLoadDocumentsForReview);
    on<GetDownloadUrl>(_onGetDownloadUrl);
    on<ApproveDocument>(_onApproveDocument);
    on<RejectDocument>(_onRejectDocument);
    on<DeleteDocument>(_onDeleteDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<LoadDocumentStats>(_onLoadDocumentStats);
    on<SearchDocuments>(_onSearchDocuments);
    on<LoadExpiringDocuments>(_onLoadExpiringDocuments);
    on<BulkApproveDocuments>(_onBulkApproveDocuments);
    on<BulkRejectDocuments>(_onBulkRejectDocuments);
    on<RefreshDocuments>(_onRefreshDocuments);
    on<ClearDocumentError>(_onClearDocumentError);
    on<FilterDocumentsByStatus>(_onFilterDocumentsByStatus);
    on<FilterDocumentsByType>(_onFilterDocumentsByType);
  }

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentUploading());

    final result = await _documentRepository.uploadDocument(
      filePath: event.filePath,
      userId: event.userId,
      tourId: event.tourId,
      type: event.type,
      description: event.description,
      expiryDate: event.expiryDate,
    );

    result.fold(
      onSuccess: (document) => emit(DocumentUploaded(document: document)),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onLoadDocumentById(
    LoadDocumentById event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.getDocumentById(event.documentId);

    result.fold(
      onSuccess: (document) => emit(DocumentLoaded(document)),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onLoadDocumentsByUser(
    LoadDocumentsByUser event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentsLoaded) {
      emit(const DocumentLoading());
    }

    final result = await _documentRepository.getDocumentsByUser(
      userId: event.userId,
      type: event.type,
      status: event.status,
      tourId: event.tourId,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      onSuccess: (documents) {
        final currentState = state;
        if (currentState is DocumentsLoaded && event.offset != null && event.offset! > 0) {
          // Append to existing list for pagination
          final updatedDocuments = List.of(currentState.documents)
            ..addAll(documents);
          emit(DocumentsLoaded(
            documents: updatedDocuments,
            hasReachedMax: documents.isEmpty,
            totalCount: currentState.totalCount + documents.length,
            currentStatusFilter: event.status,
            currentTypeFilter: event.type,
          ));
        } else {
          // Replace list for initial load or refresh
          emit(DocumentsLoaded(
            documents: documents,
            hasReachedMax: documents.isEmpty || (event.limit != null && documents.length < event.limit!),
            totalCount: documents.length,
            currentStatusFilter: event.status,
            currentTypeFilter: event.type,
          ));
        }
      },
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onLoadDocumentsByTour(
    LoadDocumentsByTour event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentsLoaded) {
      emit(const DocumentLoading());
    }

    final result = await _documentRepository.getDocumentsByTour(
      tourId: event.tourId,
      type: event.type,
      status: event.status,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      onSuccess: (documents) {
        final currentState = state;
        if (currentState is DocumentsLoaded && event.offset != null && event.offset! > 0) {
          // Append to existing list for pagination
          final updatedDocuments = List.of(currentState.documents)
            ..addAll(documents);
          emit(DocumentsLoaded(
            documents: updatedDocuments,
            hasReachedMax: documents.isEmpty,
            totalCount: currentState.totalCount + documents.length,
            currentStatusFilter: event.status,
            currentTypeFilter: event.type,
          ));
        } else {
          // Replace list for initial load or refresh
          emit(DocumentsLoaded(
            documents: documents,
            hasReachedMax: documents.isEmpty || (event.limit != null && documents.length < event.limit!),
            totalCount: documents.length,
            currentStatusFilter: event.status,
            currentTypeFilter: event.type,
          ));
        }
      },
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onLoadDocumentsForReview(
    LoadDocumentsForReview event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentsLoaded) {
      emit(const DocumentLoading());
    }

    final result = await _documentRepository.getDocumentsForReview(
      providerId: event.providerId,
      tourId: event.tourId,
      type: event.type,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      onSuccess: (documents) {
        emit(DocumentsLoaded(
          documents: documents,
          hasReachedMax: documents.isEmpty || (event.limit != null && documents.length < event.limit!),
          totalCount: documents.length,
          currentStatusFilter: DocumentStatus.pending,
          currentTypeFilter: event.type,
        ));
      },
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onGetDownloadUrl(
    GetDownloadUrl event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.getDownloadUrl(event.documentId);

    result.fold(
      onSuccess: (downloadUrl) => emit(DocumentDownloadUrlLoaded(
        downloadUrl: downloadUrl,
        documentId: event.documentId,
      )),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onApproveDocument(
    ApproveDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.approveDocument(
      documentId: event.documentId,
      notes: event.notes,
      reviewedBy: event.reviewedBy,
    );

    result.fold(
      onSuccess: (document) => emit(DocumentApproved(document: document)),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onRejectDocument(
    RejectDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.rejectDocument(
      documentId: event.documentId,
      reason: event.reason,
      reviewedBy: event.reviewedBy,
    );

    result.fold(
      onSuccess: (document) => emit(DocumentRejected(document: document)),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onDeleteDocument(
    DeleteDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.deleteDocument(event.documentId);

    result.fold(
      onSuccess: (_) => emit(const DocumentDeleted()),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onUpdateDocument(
    UpdateDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.updateDocument(
      documentId: event.documentId,
      description: event.description,
      expiryDate: event.expiryDate,
    );

    result.fold(
      onSuccess: (document) => emit(DocumentUpdated(document: document)),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onLoadDocumentStats(
    LoadDocumentStats event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.getDocumentStats(
      userId: event.userId,
      tourId: event.tourId,
    );

    result.fold(
      onSuccess: (stats) => emit(DocumentStatsLoaded(stats)),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onSearchDocuments(
    SearchDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentsLoaded) {
      emit(const DocumentLoading());
    }

    final result = await _documentRepository.searchDocuments(
      query: event.query,
      userId: event.userId,
      tourId: event.tourId,
      type: event.type,
      status: event.status,
      uploadedAfter: event.uploadedAfter,
      uploadedBefore: event.uploadedBefore,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      onSuccess: (documents) {
        emit(DocumentsLoaded(
          documents: documents,
          hasReachedMax: documents.isEmpty || (event.limit != null && documents.length < event.limit!),
          totalCount: documents.length,
          currentStatusFilter: event.status,
          currentTypeFilter: event.type,
        ));
      },
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onLoadExpiringDocuments(
    LoadExpiringDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    if (state is! DocumentsLoaded) {
      emit(const DocumentLoading());
    }

    final result = await _documentRepository.getExpiringDocuments(
      userId: event.userId,
      tourId: event.tourId,
      daysAhead: event.daysAhead,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      onSuccess: (documents) {
        emit(DocumentsLoaded(
          documents: documents,
          hasReachedMax: documents.isEmpty || (event.limit != null && documents.length < event.limit!),
          totalCount: documents.length,
        ));
      },
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onBulkApproveDocuments(
    BulkApproveDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.bulkApproveDocuments(
      documentIds: event.documentIds,
      notes: event.notes,
      reviewedBy: event.reviewedBy,
    );

    result.fold(
      onSuccess: (documents) => emit(DocumentsBulkApproved(documents: documents)),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onBulkRejectDocuments(
    BulkRejectDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await _documentRepository.bulkRejectDocuments(
      documentIds: event.documentIds,
      reason: event.reason,
      reviewedBy: event.reviewedBy,
    );

    result.fold(
      onSuccess: (documents) => emit(DocumentsBulkRejected(documents: documents)),
      onFailure: (error) => emit(DocumentError(message: error)),
    );
  }

  Future<void> _onRefreshDocuments(
    RefreshDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    // Reset to initial state and trigger a refresh
    emit(const DocumentInitial());
  }

  void _onClearDocumentError(
    ClearDocumentError event,
    Emitter<DocumentState> emit,
  ) {
    if (state is DocumentError) {
      emit(const DocumentInitial());
    }
  }

  Future<void> _onFilterDocumentsByStatus(
    FilterDocumentsByStatus event,
    Emitter<DocumentState> emit,
  ) async {
    final currentState = state;
    if (currentState is DocumentsLoaded) {
      // Re-load documents with new status filter
      // This would typically trigger a new LoadDocumentsByUser or LoadDocumentsByTour event
      // For now, we'll just update the filter in the state
      emit(currentState.copyWith(currentStatusFilter: event.status));
    }
  }

  Future<void> _onFilterDocumentsByType(
    FilterDocumentsByType event,
    Emitter<DocumentState> emit,
  ) async {
    final currentState = state;
    if (currentState is DocumentsLoaded) {
      // Re-load documents with new type filter
      // This would typically trigger a new LoadDocumentsByUser or LoadDocumentsByTour event
      // For now, we'll just update the filter in the state
      emit(currentState.copyWith(currentTypeFilter: event.type));
    }
  }
}