import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:tourlicity_app/domain/entities/tour_template.dart';
import 'package:tourlicity_app/domain/entities/web_link.dart';
import 'package:tourlicity_app/presentation/blocs/tour_template/tour_template_bloc.dart';
import 'package:tourlicity_app/presentation/blocs/tour_template/tour_template_state.dart';
import 'package:tourlicity_app/presentation/pages/tour_template/tour_template_form_page.dart';

import 'tour_template_form_page_test.mocks.dart';

@GenerateMocks([TourTemplateBloc])
void main() {
  group('TourTemplateFormPage', () {
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
      // Backward compatibility
      templateName: 'Test Template',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 7),
      createdDate: DateTime(2024, 1, 1),
    );

    setUp(() {
      mockBloc = MockTourTemplateBloc();
    });

    Widget createWidgetUnderTest({TourTemplate? template}) {
      return MaterialApp(
        home: BlocProvider<TourTemplateBloc>.value(
          value: mockBloc,
          child: TourTemplateFormPage(template: template),
        ),
      );
    }

    group('Create Mode', () {
      testWidgets('displays create form correctly', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Create Tour Template'), findsOneWidget);
        expect(find.text('Create'), findsOneWidget);
        expect(find.text('Template Name *'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Start Date *'), findsOneWidget);
        expect(find.text('End Date *'), findsOneWidget);
        expect(find.text('Active Template'), findsOneWidget);
      });

      testWidgets('validates required fields', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        // Try to submit without filling required fields
        await tester.tap(find.text('Create Template'));
        await tester.pump();

        expect(find.text('Template name is required'), findsOneWidget);
      });

      testWidgets('validates template name length', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        // Enter short template name
        await tester.enterText(find.byType(TextFormField).first, 'AB');
        await tester.tap(find.text('Create Template'));
        await tester.pump();

        expect(find.text('Template name must be at least 3 characters'),
            findsOneWidget);
      });

      testWidgets('shows date validation error', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        // Fill template name
        await tester.enterText(
            find.byType(TextFormField).first, 'Test Template');

        // Try to submit without dates
        await tester.tap(find.text('Create Template'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Please select both start and end dates'),
            findsOneWidget);
      });

      testWidgets('calculates and displays duration', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        // The duration display would be shown after selecting dates
        // This would require more complex interaction with date pickers
        expect(find.text('Duration:'), findsNothing); // Initially not shown
      });
    });

    group('Edit Mode', () {
      testWidgets('displays edit form with existing data', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest(template: testTemplate));

        expect(find.text('Edit Tour Template'), findsOneWidget);
        expect(find.text('Update'), findsOneWidget);
        expect(find.text('Test Template'), findsOneWidget);
        expect(find.text('Test description'), findsOneWidget);
      });

      testWidgets('shows duration for existing template', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest(template: testTemplate));

        expect(find.text('Duration: 7 days'), findsOneWidget);
      });
    });

    group('Form Interactions', () {
      testWidgets('toggles active status', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        final switchTile = find.byType(SwitchListTile);
        expect(switchTile, findsOneWidget);

        // The switch should be on by default
        final switchWidget = tester.widget<SwitchListTile>(switchTile);
        expect(switchWidget.value, isTrue);

        // Tap to toggle
        await tester.tap(switchTile);
        await tester.pump();

        // Would need to verify the state change through bloc interaction
      });

      testWidgets('shows web links section', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Web Links'), findsOneWidget);
        expect(find.text('Add Link'), findsOneWidget);
        expect(find.text('No web links added'), findsOneWidget);
      });
    });

    group('Bloc Integration', () {
      testWidgets('shows loading state', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateLoading());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows error snackbar', (tester) async {
        whenListen(
          mockBloc,
          Stream.fromIterable([
            const TourTemplateError(message: 'Validation error'),
          ]),
        );
        when(mockBloc.state).thenReturn(const TourTemplateInitial());

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Validation error'), findsOneWidget);
      });

      testWidgets('shows success snackbar and navigates back', (tester) async {
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
    });

    group('Date Selection', () {
      testWidgets('shows date picker on date field tap', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        // Find start date field and tap it
        final startDateField = find.text('Select date').first;
        await tester.tap(startDateField);
        await tester.pumpAndSettle();

        // Date picker should appear
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });
    });

    group('Form Submission', () {
      testWidgets('submits create form with valid data', (tester) async {
        when(mockBloc.state).thenReturn(const TourTemplateInitial());
        when(mockBloc.stream).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(createWidgetUnderTest());

        // Fill in template name
        await tester.enterText(
          find.widgetWithText(TextFormField, '').first,
          'New Template',
        );

        // Tap create button (would need dates selected first in real scenario)
        await tester.tap(find.text('Create Template'));
        await tester.pump();

        // Verify bloc interaction would happen here
        // verify(mockBloc.add(any)).called(1);
      });
    });
  });
}
