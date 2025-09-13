import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/domain/entities/tour_template.dart';
import 'package:tourlicity_app/domain/entities/web_link.dart';
import 'package:tourlicity_app/presentation/blocs/tour_template/tour_template_state.dart';

void main() {
  group('TourTemplateBloc', () {
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

    test('TourTemplateInitial state should be equal', () {
      const state1 = TourTemplateInitial();
      const state2 = TourTemplateInitial();
      expect(state1, equals(state2));
    });

    test('TourTemplatesLoaded state should contain templates', () {
      final state = TourTemplatesLoaded(templates: [testTemplate]);
      expect(state.templates, contains(testTemplate));
      expect(state.templates.length, equals(1));
    });

    test('TourTemplateLoaded state should contain template', () {
      final state = TourTemplateLoaded(testTemplate);
      expect(state.template, equals(testTemplate));
    });

    test('TourTemplateError state should contain error message', () {
      const state = TourTemplateError(message: 'Test error');
      expect(state.message, equals('Test error'));
    });

    test('TourTemplateOperationSuccess state should contain success message',
        () {
      const state = TourTemplateOperationSuccess(message: 'Success');
      expect(state.message, equals('Success'));
    });

    test('TourTemplatesLoaded copyWith should work correctly', () {
      final originalState = TourTemplatesLoaded(templates: [testTemplate]);
      final newTemplate = testTemplate.copyWith(title: 'Updated Template');
      final updatedState = originalState.copyWith(templates: [newTemplate]);

      expect(updatedState.templates.first.templateName,
          equals('Updated Template'));
      expect(
          originalState.templates.first.templateName, equals('Test Template'));
    });
  });
}
