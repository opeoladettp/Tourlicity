import 'package:equatable/equatable.dart';

enum DocumentType {
  passport,
  visa,
  insurance,
  medicalCertificate,
  emergencyContact,
  other,
}

enum DocumentStatus {
  pending,
  approved,
  rejected,
  expired,
}

class Document extends Equatable {
  final String id;
  final String userId;
  final String? tourId; // null for general documents, specific for tour documents
  final String fileName;
  final String originalFileName;
  final DocumentType type;
  final DocumentStatus status;
  final int fileSizeBytes;
  final String mimeType;
  final String? description;
  final DateTime uploadedAt;
  final DateTime? expiryDate;
  final String? reviewNotes;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? downloadUrl;
  final DateTime? urlExpiresAt;

  const Document({
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

  bool get isValid {
    return fileName.isNotEmpty &&
        originalFileName.isNotEmpty &&
        fileSizeBytes > 0 &&
        mimeType.isNotEmpty &&
        userId.isNotEmpty;
  }

  bool get isPending => status == DocumentStatus.pending;
  bool get isApproved => status == DocumentStatus.approved;
  bool get isRejected => status == DocumentStatus.rejected;
  bool get isExpired => status == DocumentStatus.expired;

  bool get requiresReview => status == DocumentStatus.pending;

  bool get hasExpiry => expiryDate != null;

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  bool get isExpiredByDate {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get canDownload {
    return downloadUrl != null && 
           urlExpiresAt != null && 
           DateTime.now().isBefore(urlExpiresAt!);
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.visa:
        return 'Visa';
      case DocumentType.insurance:
        return 'Travel Insurance';
      case DocumentType.medicalCertificate:
        return 'Medical Certificate';
      case DocumentType.emergencyContact:
        return 'Emergency Contact';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  bool get isImageFile {
    return mimeType.startsWith('image/');
  }

  bool get isPdfFile {
    return mimeType == 'application/pdf';
  }

  Document approve({String? notes, String? reviewedBy}) {
    return copyWith(
      status: DocumentStatus.approved,
      reviewNotes: notes,
      reviewedBy: reviewedBy,
      reviewedAt: DateTime.now(),
    );
  }

  Document reject({required String reason, String? reviewedBy}) {
    return copyWith(
      status: DocumentStatus.rejected,
      reviewNotes: reason,
      reviewedBy: reviewedBy,
      reviewedAt: DateTime.now(),
    );
  }

  Document markExpired() {
    return copyWith(status: DocumentStatus.expired);
  }

  Document updateDownloadUrl({
    required String url,
    required DateTime expiresAt,
  }) {
    return copyWith(
      downloadUrl: url,
      urlExpiresAt: expiresAt,
    );
  }

  Document copyWith({
    String? id,
    String? userId,
    String? tourId,
    String? fileName,
    String? originalFileName,
    DocumentType? type,
    DocumentStatus? status,
    int? fileSizeBytes,
    String? mimeType,
    String? description,
    DateTime? uploadedAt,
    DateTime? expiryDate,
    String? reviewNotes,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? downloadUrl,
    DateTime? urlExpiresAt,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tourId: tourId ?? this.tourId,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      type: type ?? this.type,
      status: status ?? this.status,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      description: description ?? this.description,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      urlExpiresAt: urlExpiresAt ?? this.urlExpiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tourId,
        fileName,
        originalFileName,
        type,
        status,
        fileSizeBytes,
        mimeType,
        description,
        uploadedAt,
        expiryDate,
        reviewNotes,
        reviewedBy,
        reviewedAt,
        downloadUrl,
        urlExpiresAt,
      ];
}