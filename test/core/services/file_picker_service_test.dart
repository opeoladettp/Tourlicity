import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/services/file_picker_service.dart';

void main() {
  group('FilePickerService', () {

    group('File Validation', () {
      test('should validate file size correctly', () {
        // Test file size validation logic
        expect(FilePickerService.maxFileSizeBytes, equals(10 * 1024 * 1024));
        expect(FilePickerService.maxImageSizeBytes, equals(5 * 1024 * 1024));
      });

      test('should check supported file types correctly', () {
        // Test document extensions
        expect(FilePickerService.isFileTypeSupported('pdf'), isTrue);
        expect(FilePickerService.isFileTypeSupported('doc'), isTrue);
        expect(FilePickerService.isFileTypeSupported('docx'), isTrue);
        expect(FilePickerService.isFileTypeSupported('txt'), isTrue);
        
        // Test image extensions
        expect(FilePickerService.isFileTypeSupported('jpg'), isTrue);
        expect(FilePickerService.isFileTypeSupported('jpeg'), isTrue);
        expect(FilePickerService.isFileTypeSupported('png'), isTrue);
        expect(FilePickerService.isFileTypeSupported('gif'), isTrue);
        
        // Test unsupported extensions
        expect(FilePickerService.isFileTypeSupported('exe'), isFalse);
        expect(FilePickerService.isFileTypeSupported('zip'), isFalse);
        expect(FilePickerService.isFileTypeSupported('mp4'), isFalse);
      });

      test('should identify image files correctly', () {
        expect(FilePickerService.isImageFile('jpg'), isTrue);
        expect(FilePickerService.isImageFile('jpeg'), isTrue);
        expect(FilePickerService.isImageFile('png'), isTrue);
        expect(FilePickerService.isImageFile('gif'), isTrue);
        expect(FilePickerService.isImageFile('bmp'), isTrue);
        expect(FilePickerService.isImageFile('webp'), isTrue);
        
        expect(FilePickerService.isImageFile('pdf'), isFalse);
        expect(FilePickerService.isImageFile('doc'), isFalse);
        expect(FilePickerService.isImageFile('txt'), isFalse);
      });
    });

    group('File Size Formatting', () {
      test('should format file sizes correctly', () {
        expect(FilePickerService.formatFileSize(500), equals('500 B'));
        expect(FilePickerService.formatFileSize(1024), equals('1.0 KB'));
        expect(FilePickerService.formatFileSize(1536), equals('1.5 KB'));
        expect(FilePickerService.formatFileSize(1024 * 1024), equals('1.0 MB'));
        expect(FilePickerService.formatFileSize(1536 * 1024), equals('1.5 MB'));
        expect(FilePickerService.formatFileSize(10 * 1024 * 1024), equals('10.0 MB'));
      });
    });

    group('FilePickerException', () {
      test('should create exception with message and type', () {
        const exception = FilePickerException(
          'Test error message',
          FilePickerErrorType.fileSizeExceeded,
        );
        
        expect(exception.message, equals('Test error message'));
        expect(exception.type, equals(FilePickerErrorType.fileSizeExceeded));
        expect(exception.toString(), equals('Test error message'));
      });
    });

    group('FileValidationResult', () {
      test('should create valid result', () {
        const result = FileValidationResult(
          isValid: true,
          fileSize: 1024,
          fileName: 'test.pdf',
          extension: 'pdf',
          isImage: false,
        );
        
        expect(result.isValid, isTrue);
        expect(result.fileSize, equals(1024));
        expect(result.fileName, equals('test.pdf'));
        expect(result.extension, equals('pdf'));
        expect(result.isImage, isFalse);
        expect(result.error, isNull);
        expect(result.errorType, isNull);
      });

      test('should create invalid result', () {
        const result = FileValidationResult(
          isValid: false,
          error: 'File too large',
          errorType: FilePickerErrorType.fileSizeExceeded,
        );
        
        expect(result.isValid, isFalse);
        expect(result.error, equals('File too large'));
        expect(result.errorType, equals(FilePickerErrorType.fileSizeExceeded));
        expect(result.fileSize, isNull);
        expect(result.fileName, isNull);
        expect(result.extension, isNull);
        expect(result.isImage, isNull);
      });
    });

    group('FileInfo', () {
      test('should create file info correctly', () {
        const fileInfo = FileInfo(
          path: '/path/to/file.pdf',
          name: 'file.pdf',
          size: 2048,
          extension: 'pdf',
          isImage: false,
        );
        
        expect(fileInfo.path, equals('/path/to/file.pdf'));
        expect(fileInfo.name, equals('file.pdf'));
        expect(fileInfo.size, equals(2048));
        expect(fileInfo.extension, equals('pdf'));
        expect(fileInfo.isImage, isFalse);
      });
    });

    group('Constants', () {
      test('should have correct allowed extensions', () {
        expect(FilePickerService.allowedDocumentExtensions, contains('pdf'));
        expect(FilePickerService.allowedDocumentExtensions, contains('doc'));
        expect(FilePickerService.allowedDocumentExtensions, contains('docx'));
        expect(FilePickerService.allowedDocumentExtensions, contains('txt'));
        expect(FilePickerService.allowedDocumentExtensions, contains('rtf'));
        
        expect(FilePickerService.allowedImageExtensions, contains('jpg'));
        expect(FilePickerService.allowedImageExtensions, contains('jpeg'));
        expect(FilePickerService.allowedImageExtensions, contains('png'));
        expect(FilePickerService.allowedImageExtensions, contains('gif'));
        expect(FilePickerService.allowedImageExtensions, contains('bmp'));
        expect(FilePickerService.allowedImageExtensions, contains('webp'));
      });

      test('should have correct MIME types', () {
        expect(FilePickerService.allowedMimeTypes, contains('application/pdf'));
        expect(FilePickerService.allowedMimeTypes, contains('application/msword'));
        expect(FilePickerService.allowedMimeTypes, contains('application/vnd.openxmlformats-officedocument.wordprocessingml.document'));
        expect(FilePickerService.allowedMimeTypes, contains('text/plain'));
        expect(FilePickerService.allowedMimeTypes, contains('text/rtf'));
        expect(FilePickerService.allowedMimeTypes, contains('image/jpeg'));
        expect(FilePickerService.allowedMimeTypes, contains('image/png'));
        expect(FilePickerService.allowedMimeTypes, contains('image/gif'));
        expect(FilePickerService.allowedMimeTypes, contains('image/bmp'));
        expect(FilePickerService.allowedMimeTypes, contains('image/webp'));
      });
    });
  });
}