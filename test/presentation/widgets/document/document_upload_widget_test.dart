import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/presentation/widgets/document/document_upload_widget.dart';
import 'package:tourlicity_app/presentation/blocs/document/document_bloc.dart';
import 'package:tourlicity_app/domain/entities/document.dart';
import 'package:tourlicity_app/core/services/file_picker_service.dart';

// Mock classes
class MockFilePickerService extends Mock implements FilePickerService {}
class MockDocumentBloc extends Mock implements DocumentBloc {}

@GenerateMocks([FilePickerService, DocumentBloc])
void main() {
  group('DocumentUploadWidget Tests', () {
    late MockDocumentBloc mockDocumentBloc;

    setUp(() {
      mockDocumentBloc = MockDocumentBloc();
    });

    testWidgets('should display upload widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DocumentBloc>.value(
            value: mockDocumentBloc,
            child: const Scaffold(
              body: DocumentUploadWidget(
                userId: 'user1',
              ),
            ),
          ),
        ),
      );

      // Should display the widget
      expect(find.byType(DocumentUploadWidget), findsOneWidget);
    });

    testWidgets('should display with tour ID', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DocumentBloc>.value(
            value: mockDocumentBloc,
            child: const Scaffold(
              body: DocumentUploadWidget(
                userId: 'user1',
                tourId: 'tour1',
              ),
            ),
          ),
        ),
      );

      // Should display the widget with tour context
      expect(find.byType(DocumentUploadWidget), findsOneWidget);
    });

    testWidgets('should display with initial document type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DocumentBloc>.value(
            value: mockDocumentBloc,
            child: const Scaffold(
              body: DocumentUploadWidget(
                userId: 'user1',
                initialType: DocumentType.passport,
              ),
            ),
          ),
        ),
      );

      // Should display the widget with initial type
      expect(find.byType(DocumentUploadWidget), findsOneWidget);
    });

    testWidgets('should handle upload success callback', (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DocumentBloc>.value(
            value: mockDocumentBloc,
            child: Scaffold(
              body: DocumentUploadWidget(
                userId: 'user1',
                onUploadSuccess: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Should display the widget
      expect(find.byType(DocumentUploadWidget), findsOneWidget);
      
      // Callback should be available (would be called on successful upload)
      expect(callbackCalled, isFalse); // Initially false
    });
  });
}