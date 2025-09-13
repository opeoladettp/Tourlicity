import 'package:equatable/equatable.dart';
import '../../../domain/entities/document.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {
  const DocumentInitial();
}

class DocumentLoading extends DocumentState {
  const DocumentLoading();
}

class DocumentUploading extends DocumentState {
  final double? progress;

  const DocumentUploading({this.progress});

  @override
  List<Object?> get props => [progress];
}

class DocumentLoaded extends DocumentState {
  final Document document;

  const DocumentLoaded(this.document);

  @override
  List<Object> get props => [document];
}

class DocumentsLoaded extends DocumentState {
  final List<Document> documents;
  final bool hasReachedMax;
  final int totalCount;
  final DocumentStatus? currentStatusFilter;
  final DocumentType? currentTypeFilter;

  const DocumentsLoaded({
    required this.documents,
    this.hasReachedMax = false,
    this.totalCount = 0,
    this.currentStatusFilter,
    this.currentTypeFilter,
  });

  @override
  List<Object?> get props => [
        documents,
        hasReachedMax,
        totalCount,
        currentStatusFilter,
        currentTypeFilter,
      ];

  DocumentsLoaded copyWith({
    List<Document>? documents,
    bool? hasReachedMax,
    int? totalCount,
    DocumentStatus? currentStatusFilter,
    DocumentType? currentTypeFilter,
  }) {
    return DocumentsLoaded(
      documents: documents ?? this.documents,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      currentStatusFilter: currentStatusFilter ?? this.currentStatusFilter,
      currentTypeFilter: currentTypeFilter ?? this.currentTypeFilter,
    );
  }
}

class DocumentStatsLoaded extends DocumentState {
  final Map<String, int> stats;

  const DocumentStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class DocumentDownloadUrlLoaded extends DocumentState {
  final String downloadUrl;
  final String documentId;

  const DocumentDownloadUrlLoaded({
    required this.downloadUrl,
    required this.documentId,
  });

  @override
  List<Object> get props => [downloadUrl, documentId];
}

class DocumentError extends DocumentState {
  final String message;
  final String? errorCode;

  const DocumentError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class DocumentOperationSuccess extends DocumentState {
  final Document document;
  final String message;

  const DocumentOperationSuccess({
    required this.document,
    required this.message,
  });

  @override
  List<Object> get props => [document, message];
}

class DocumentBulkOperationSuccess extends DocumentState {
  final List<Document> documents;
  final String message;

  const DocumentBulkOperationSuccess({
    required this.documents,
    required this.message,
  });

  @override
  List<Object> get props => [documents, message];
}

// Specific success states for different operations
class DocumentUploaded extends DocumentOperationSuccess {
  const DocumentUploaded({
    required super.document,
  }) : super(
          message: 'Document uploaded successfully',
        );
}

class DocumentApproved extends DocumentOperationSuccess {
  const DocumentApproved({
    required super.document,
  }) : super(
          message: 'Document approved successfully',
        );
}

class DocumentRejected extends DocumentOperationSuccess {
  const DocumentRejected({
    required super.document,
  }) : super(
          message: 'Document rejected',
        );
}

class DocumentUpdated extends DocumentOperationSuccess {
  const DocumentUpdated({
    required super.document,
  }) : super(
          message: 'Document updated successfully',
        );
}

class DocumentDeleted extends DocumentState {
  final String message;

  const DocumentDeleted({
    this.message = 'Document deleted successfully',
  });

  @override
  List<Object> get props => [message];
}

class DocumentsBulkApproved extends DocumentBulkOperationSuccess {
  const DocumentsBulkApproved({
    required super.documents,
  }) : super(
          message: '${documents.length} documents approved successfully',
        );
}

class DocumentsBulkRejected extends DocumentBulkOperationSuccess {
  const DocumentsBulkRejected({
    required super.documents,
  }) : super(
          message: '${documents.length} documents rejected',
        );
}