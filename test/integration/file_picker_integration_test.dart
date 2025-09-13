import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/services/file_picker_service.dart';

void main() {
  group('File Picker Service Tests', () {
    late FilePickerService filePickerService;

    setUp(() {
      filePickerService = FilePickerService();
    });

    test('FilePickerService should be instantiable', () {
      expect(filePickerService, isNotNull);
      expect(filePickerService, isA<FilePickerService>());
    });

    test('FilePickerService should have required methods', () {
      // Test that the service has the expected interface
      expect(filePickerService.pickDocument, isA<Function>());
      expect(filePickerService.pickImage, isA<Function>());
      expect(filePickerService.pickImageFromCamera, isA<Function>());
      expect(filePickerService.pickImageFromGallery, isA<Function>());
    });

    test('FilePickerService should have validation methods', () {
      // Test validation and utility methods
      expect(filePickerService.validateFile, isA<Function>());
      expect(filePickerService.getFileInfo, isA<Function>());
      expect(FilePickerService.formatFileSize, isA<Function>());
      expect(FilePickerService.isFileTypeSupported, isA<Function>());
      expect(FilePickerService.isImageFile, isA<Function>());
    });

    test('FilePickerService should have correct file size limits', () {
      expect(FilePickerService.maxFileSizeBytes, equals(10 * 1024 * 1024)); // 10MB
      expect(FilePickerService.maxImageSizeBytes, equals(5 * 1024 * 1024)); // 5MB
    });

    test('FilePickerService should have correct allowed extensions', () {
      expect(FilePickerService.allowedDocumentExtensions, contains('pdf'));
      expect(FilePickerService.allowedDocumentExtensions, contains('doc'));
      expect(FilePickerService.allowedDocumentExtensions, contains('docx'));
      expect(FilePickerService.allowedImageExtensions, contains('jpg'));
      expect(FilePickerService.allowedImageExtensions, contains('png'));
    });

    test('formatFileSize should format bytes correctly', () {
      expect(FilePickerService.formatFileSize(500), equals('500 B'));
      expect(FilePickerService.formatFileSize(1536), equals('1.5 KB'));
      expect(FilePickerService.formatFileSize(2097152), equals('2.0 MB'));
    });

    test('isFileTypeSupported should validate extensions correctly', () {
      expect(FilePickerService.isFileTypeSupported('pdf'), isTrue);
      expect(FilePickerService.isFileTypeSupported('jpg'), isTrue);
      expect(FilePickerService.isFileTypeSupported('exe'), isFalse);
    });

    test('isImageFile should identify image extensions correctly', () {
      expect(FilePickerService.isImageFile('jpg'), isTrue);
      expect(FilePickerService.isImageFile('png'), isTrue);
      expect(FilePickerService.isImageFile('pdf'), isFalse);
    });
  });
}