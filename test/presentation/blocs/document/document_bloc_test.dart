import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tourlicity_app/presentation/blocs/document/document_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/document/document_event.dart';
import 'package:tourlicity_app/presentation/blocs/document/document_state.dart';
import 'package:tourlicity_app/domain/repositories/document_repository.dart';
import 'package:tourlicity_app/domain/entities/document.dart';
import 'package:tourlicity_app/core/network/api_result.dart';

import 'document_bloc_test.mocks.dart';

@GenerateMocks([DocumentRepository])
void main() {
  late DocumentBloc documentBloc;
  late MockDocumentRepository mockRepository;

  setUp(() {
    mockRepository = MockDocumentRepository();
    documentBloc = DocumentBloc(documentRepository: mockRepository);
  });

  tearDown(() {
    documentBloc.close();
  });

  group('DocumentBloc', () {
    test('initial state is DocumentInitial', () {
      expect(documentBloc.state, isA<DocumentInitial>());
    });

    group('LoadDocumentsByUser', () {
      blocTest<DocumentBloc, DocumentState>(
        'emits [DocumentLoading, DocumentLoaded] when successful',
        build: () {
          when(mockRepository.getDocumentsByUser(
            userId: 'user1',
          )).thenAnswer((_) async => const ApiSuccess(data: <Document>[]));
          return documentBloc;
        },
        act: (bloc) => bloc.add(const LoadDocumentsByUser(userId: 'user1')),
        expect: () => [
          isA<DocumentLoading>(),
          isA<DocumentsLoaded>(),
        ],
      );

      blocTest<DocumentBloc, DocumentState>(
        'emits [DocumentLoading, DocumentError] when fails',
        build: () {
          when(mockRepository.getDocumentsByUser(
            userId: 'user1',
          )).thenAnswer((_) async => const ApiFailure(message: 'Error'));
          return documentBloc;
        },
        act: (bloc) => bloc.add(const LoadDocumentsByUser(userId: 'user1')),
        expect: () => [
          isA<DocumentLoading>(),
          isA<DocumentError>(),
        ],
      );
    });

    group('UploadDocument', () {
      blocTest<DocumentBloc, DocumentState>(
        'emits [DocumentUploading, DocumentUploaded] when successful',
        build: () {
          final document = Document(
            id: "1",
            userId: "user1",
            fileName: "test.pdf",
            originalFileName: "test.pdf",
            type: DocumentType.other,
            status: DocumentStatus.pending,
            fileSizeBytes: 1024,
            mimeType: "application/pdf",
            uploadedAt: DateTime.now(),
          );
          when(mockRepository.uploadDocument(
            filePath: 'test.pdf',
            userId: 'user123',
            type: DocumentType.other,
            description: 'Test document',
          )).thenAnswer((_) async => ApiSuccess(data: document));
          return documentBloc;
        },
        act: (bloc) => bloc.add(const UploadDocument(
          filePath: "test.pdf",
          userId: "user1",
          type: DocumentType.other,
          description: "Test document",
        )),
        expect: () => [
          isA<DocumentUploading>(),
          isA<DocumentUploaded>(),
        ],
      );
    });

    group('GetDownloadUrl', () {
      blocTest<DocumentBloc, DocumentState>(
        'emits [DocumentLoading, DocumentDownloadReady] when successful',
        build: () {
          when(mockRepository.getDownloadUrl('doc1'))
              .thenAnswer((_) async => const ApiSuccess(data: 'https://example.com/download'));
          return documentBloc;
        },
        act: (bloc) => bloc.add(const GetDownloadUrl('doc1')),
        expect: () => [
          isA<DocumentLoading>(),
          isA<DocumentLoaded>(),
        ],
      );
    });
  });
}