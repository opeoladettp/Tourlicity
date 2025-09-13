import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling file and image selection across platforms
class FilePickerService {
  static const FilePickerService _instance = FilePickerService._internal();
  factory FilePickerService() => _instance;
  const FilePickerService._internal();

  ImagePicker get _imagePicker => ImagePicker();

  // File size limits (in bytes)
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // Allowed file types
  static const List<String> allowedDocumentExtensions = [
    'pdf', 'doc', 'docx', 'txt', 'rtf'
  ];
  
  static const List<String> allowedImageExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'
  ];

  static const List<String> allowedMimeTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
    'text/rtf',
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/bmp',
    'image/webp',
  ];

  /// Pick a document file (PDF, DOC, etc.)
  Future<FilePickerResult?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedDocumentExtensions,
        allowMultiple: false,
        withData: false, // Don't load file data into memory
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file size
        if (file.size > maxFileSizeBytes) {
          throw const FilePickerException(
            'File size exceeds 10MB limit',
            FilePickerErrorType.fileSizeExceeded,
          );
        }

        // Validate file extension
        final extension = file.extension?.toLowerCase();
        if (extension == null || !allowedDocumentExtensions.contains(extension)) {
          throw const FilePickerException(
            'Unsupported file type. Allowed: pdf, doc, docx, txt, rtf',
            FilePickerErrorType.unsupportedFileType,
          );
        }

        return result;
      }
      return null;
    } catch (e) {
      if (e is FilePickerException) {
        rethrow;
      }
      throw const FilePickerException(
        'Failed to pick document',
        FilePickerErrorType.unknown,
      );
    }
  }

  /// Pick an image file
  Future<FilePickerResult?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file size
        if (file.size > maxImageSizeBytes) {
          throw const FilePickerException(
            'Image size exceeds 5MB limit',
            FilePickerErrorType.fileSizeExceeded,
          );
        }

        // Validate file extension
        final extension = file.extension?.toLowerCase();
        if (extension == null || !allowedImageExtensions.contains(extension)) {
          throw const FilePickerException(
            'Unsupported image type. Allowed: jpg, jpeg, png, gif, bmp, webp',
            FilePickerErrorType.unsupportedFileType,
          );
        }

        return result;
      }
      return null;
    } catch (e) {
      if (e is FilePickerException) {
        rethrow;
      }
      throw const FilePickerException(
        'Failed to pick image',
        FilePickerErrorType.unknown,
      );
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Validate file size
        final file = File(image.path);
        final fileSize = await file.length();
        
        if (fileSize > maxImageSizeBytes) {
          throw const FilePickerException(
            'Image size exceeds ${maxImageSizeBytes ~/ (1024 * 1024)}MB limit',
            FilePickerErrorType.fileSizeExceeded,
          );
        }
      }

      return image;
    } catch (e) {
      if (e is FilePickerException) {
        rethrow;
      }
      throw FilePickerException(
        'Failed to capture image: ${e.toString()}',
        FilePickerErrorType.unknown,
      );
    }
  }

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Validate file size
        final file = File(image.path);
        final fileSize = await file.length();
        
        if (fileSize > maxImageSizeBytes) {
          throw const FilePickerException(
            'Image size exceeds ${maxImageSizeBytes ~/ (1024 * 1024)}MB limit',
            FilePickerErrorType.fileSizeExceeded,
          );
        }
      }

      return image;
    } catch (e) {
      if (e is FilePickerException) {
        rethrow;
      }
      throw FilePickerException(
        'Failed to pick image from gallery: ${e.toString()}',
        FilePickerErrorType.unknown,
      );
    }
  }

  /// Pick any supported file type
  Future<FilePickerResult?> pickAnyFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          ...allowedDocumentExtensions,
          ...allowedImageExtensions,
        ],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file size based on type
        final extension = file.extension?.toLowerCase();
        final isImage = allowedImageExtensions.contains(extension);
        final maxSize = isImage ? maxImageSizeBytes : maxFileSizeBytes;
        
        if (file.size > maxSize) {
          throw FilePickerException(
            'File size exceeds ${maxSize ~/ (1024 * 1024)}MB limit',
            FilePickerErrorType.fileSizeExceeded,
          );
        }

        // Validate file extension
        if (extension == null || 
            (!allowedDocumentExtensions.contains(extension) && 
             !allowedImageExtensions.contains(extension))) {
          throw FilePickerException(
            'Unsupported file type. Allowed: ${[...allowedDocumentExtensions, ...allowedImageExtensions].join(', ')}',
            FilePickerErrorType.unsupportedFileType,
          );
        }

        return result;
      }
      return null;
    } catch (e) {
      if (e is FilePickerException) {
        rethrow;
      }
      throw FilePickerException(
        'Failed to pick file: ${e.toString()}',
        FilePickerErrorType.unknown,
      );
    }
  }

  /// Validate file by path
  Future<FileValidationResult> validateFile(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        return const FileValidationResult(
          isValid: false,
          error: 'File does not exist',
          errorType: FilePickerErrorType.fileNotFound,
        );
      }

      final fileSize = await file.length();
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      // Check file extension
      if (!allowedDocumentExtensions.contains(extension) && 
          !allowedImageExtensions.contains(extension)) {
        return FileValidationResult(
          isValid: false,
          error: 'Unsupported file type: $extension',
          errorType: FilePickerErrorType.unsupportedFileType,
        );
      }

      // Check file size
      final isImage = allowedImageExtensions.contains(extension);
      final maxSize = isImage ? maxImageSizeBytes : maxFileSizeBytes;
      
      if (fileSize > maxSize) {
        return FileValidationResult(
          isValid: false,
          error: 'File size exceeds ${maxSize ~/ (1024 * 1024)}MB limit',
          errorType: FilePickerErrorType.fileSizeExceeded,
        );
      }

      return FileValidationResult(
        isValid: true,
        fileSize: fileSize,
        fileName: fileName,
        extension: extension,
        isImage: isImage,
      );
    } catch (e) {
      return FileValidationResult(
        isValid: false,
        error: 'Failed to validate file: ${e.toString()}',
        errorType: FilePickerErrorType.unknown,
      );
    }
  }

  /// Get file info without validation
  Future<FileInfo?> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        return null;
      }

      final fileSize = await file.length();
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      final isImage = allowedImageExtensions.contains(extension);

      return FileInfo(
        path: filePath,
        name: fileName,
        size: fileSize,
        extension: extension,
        isImage: isImage,
      );
    } catch (e) {
      return null;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if file type is supported
  static bool isFileTypeSupported(String extension) {
    final ext = extension.toLowerCase();
    return allowedDocumentExtensions.contains(ext) || 
           allowedImageExtensions.contains(ext);
  }

  /// Check if file is an image
  static bool isImageFile(String extension) {
    return allowedImageExtensions.contains(extension.toLowerCase());
  }
}

/// Custom exception for file picker errors
class FilePickerException implements Exception {
  const FilePickerException(this.message, this.type);
  
  final String message;
  final FilePickerErrorType type;

  @override
  String toString() => message;
}

/// Types of file picker errors
enum FilePickerErrorType {
  fileSizeExceeded,
  unsupportedFileType,
  fileNotFound,
  permissionDenied,
  unknown,
}

/// Result of file validation
class FileValidationResult {
  const FileValidationResult({
    required this.isValid,
    this.error,
    this.errorType,
    this.fileSize,
    this.fileName,
    this.extension,
    this.isImage,
  });

  final bool isValid;
  final String? error;
  final FilePickerErrorType? errorType;
  final int? fileSize;
  final String? fileName;
  final String? extension;
  final bool? isImage;
}

/// File information
class FileInfo {
  const FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.extension,
    required this.isImage,
  });

  final String path;
  final String name;
  final int size;
  final String extension;
  final bool isImage;
}