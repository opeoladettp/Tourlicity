import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:tourlicity_app/domain/entities/tour_template.dart';
import 'package:tourlicity_app/domain/entities/web_link.dart';
import 'package:tourlicity_app/presentation/blocs/tour_template/tour_template_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/tour_template/tour_template_event.dart';
import 'package:tourlicity_app/presentation/blocs/tour_template/tour_template_state.dart';
import 'package:tourlicity_app/presentation/pages/tour_template/tour_template_list_page.dart';

class MockTourTemplateBloc extends MockBloc<TourTemplateEvent, TourTemplateState> implements TourTemplateBloc {}

void main() {
  group('TourTemplateListPage', () {
    late MockTourTemplateBloc mockBloc;

    final testTemplate = TourTemplate(
      id: '1',
      title: 'Test Template',
      description: 'Test description',
      duration: 168, // 7 days in hours
      price: 299.99,
      maxParticipants: 10,
      providerId: 'provider-1',
      isActive: true,
      webLinks: const [
        WebLink(id: '1', title: 'Test Link', url: 'https://example.com'),
      ],
      createdAt: DateTime(2024, 1, 1),
      // Backward compatibility
      templateName: 'Test Template',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 7),
      createdDate: DateTime(2024, 1, 1),
    );

    setUp(() {
      mockBloc = MockTourTemplateBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<TourTemplateBloc>.value(
          value: mockBloc,
          child: const TourTemplateListPage(),
        ),
      );
    }

    testWidgets('displays loading indicator when state is loading',
        (tester) async {
      when(mockBloc.state).thenReturn(const TourTemplateLoading());
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when state is error', (tester) async {
      when(mockBloc.state).thenReturn(
        const TourTemplateError(message: 'Network error'),
      );
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays empty state when no templates', (tester) async {
      when(mockBloc.state).thenReturn(
        const TourTemplatesLoaded(templates: []),
      );
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No tour templates found'), findsOneWidget);
      expect(find.text('Create a new tour template to get started'),
          findsOneWidget);
      expect(find.text('Add Template'), findsOneWidget);
    });

    testWidgets('displays templates when loaded', (tester) async {
      when(mockBloc.state).thenReturn(
        TourTemplatesLoaded(templates: [testTemplate]),
      );
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Template'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('shows search bar', (tester) async {
      when(mockBloc.state).thenReturn(const TourTemplateInitial());
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search tour templates...'), findsOneWidget);
    });

    testWidgets('shows filter button in app bar', (tester) async {
      when(mockBloc.state).thenReturn(const TourTemplateInitial());
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('shows floating action button', (tester) async {
      when(mockBloc.state).thenReturn(const TourTemplateInitial());
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('triggers search when text is entered', (tester) async {
      when(mockBloc.state).thenReturn(const TourTemplateInitial());
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test query');
      await tester.pump();

      verify(mockBloc.add(const SearchTourTemplates('test query'))).called(1);
    });

    testWidgets('shows snackbar on error', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const TourTemplateError(message: 'Network error'),
        ]),
      );
      when(mockBloc.state).thenReturn(const TourTemplateInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('shows snackbar on success', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const TourTemplateOperationSuccess(
            message: 'Template created successfully',
          ),
        ]),
      );
      when(mockBloc.state).thenReturn(const TourTemplateInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Template created successfully'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      when(mockBloc.state).thenReturn(
        TourTemplatesLoaded(templates: [testTemplate]),
      );
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap the popup menu button
      final popupButton = find.byType(PopupMenuButton<String>);
      await tester.tap(popupButton);
      await tester.pumpAndSettle();

      // Tap delete option
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Delete Tour Template'), findsOneWidget);
      expect(
          find.text(
              'Are you sure you want to delete "Test Template"? This action cannot be undone.'),
          findsOneWidget);
    });

    testWidgets('handles pull to refresh', (tester) async {
      when(mockBloc.state).thenReturn(
        TourTemplatesLoaded(templates: [testTemplate]),
      );
      when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());

      // Find the RefreshIndicator and trigger refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();

      verify(mockBloc.add(const RefreshTourTemplates())).called(1);
    });
  });
}
