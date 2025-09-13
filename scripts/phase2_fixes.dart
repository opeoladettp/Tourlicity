#!/usr/bin/env dart

import 'dart:io';

void main() {
  stdout.writeln('🔧 Running Phase 2 fixes for critical remaining issues...');

  // Fix performance module critical errors
  fixPerformanceCriticalIssues();

  // Fix BLoC constructor issues
  fixBlocConstructorIssues();

  // Fix splash screen auth issues
  fixSplashScreenIssues();

  // Fix entity constructor issues
  fixEntityConstructorIssues();

  // Fix widget parameter issues
  fixWidgetParameterIssues();

  stdout.writeln('✅ Phase 2 fixes completed!');
}

void fixPerformanceCriticalIssues() {
  stdout.writeln('📝 Fixing performance module critical issues...');

  // Fix animation optimizer mixin issue
  final animFile = File('lib/core/performance/animation_optimizer.dart');
  if (animFile.existsSync()) {
    String content = animFile.readAsStringSync();

    // Remove the problematic with clause completely
    content = content.replaceAll(
        'mixin AnimationOptimizationMixin<T extends StatefulWidget> with TickerProviderStateMixin<T>',
        'mixin AnimationOptimizationMixin<T extends StatefulWidget>');

    // Fix the TickerProvider usage by making it abstract
    content = content.replaceAll(
        'AnimationController(vsync: this', 'AnimationController(vsync: vsync');

    // Add vsync parameter to methods that need it
    content = content.replaceAllMapped(
        RegExp(r'AnimationController\(vsync: vsync([^)]*)\)'),
        (match) =>
            'AnimationController(vsync: vsync, duration: const Duration(milliseconds: 300)${match.group(1) ?? ""})');

    animFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed animation optimizer mixin');
  }

  // Fix code splitting issues
  final codeSplitFile = File('lib/core/performance/code_splitting.dart');
  if (codeSplitFile.existsSync()) {
    String content = codeSplitFile.readAsStringSync();

    // Fix widget declaration issue
    content = content.replaceAll('widget.', 'widget?.');

    // Fix RenderAbstractViewport offset issue
    content = content.replaceAll('.offset', '.paintOffset');

    // Fix constraints issue
    content = content.replaceAll(
        'constraints.maxHeight', '(constraints as BoxConstraints).maxHeight');

    // Remove null-aware operators where not needed
    content = content.replaceAll('widget?.', 'widget.');

    codeSplitFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed code splitting issues');
  }

  // Fix optimized image service
  final imageFile = File('lib/core/performance/optimized_image_service.dart');
  if (imageFile.existsSync()) {
    String content = imageFile.readAsStringSync();

    // Fix cache manager type
    content = content.replaceAll(
        'CustomCacheManager()', 'DefaultCacheManager() as BaseCacheManager');

    imageFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed optimized image service');
  }
}

void fixBlocConstructorIssues() {
  stdout.writeln('📝 Fixing BLoC constructor issues...');

  // Fix message bloc test
  final msgTestFile =
      File('test/presentation/blocs/message/message_bloc_test.dart');
  if (msgTestFile.existsSync()) {
    String content = msgTestFile.readAsStringSync();

    // Fix constructor call
    content = content.replaceAll('MessageBloc(mockRepository)',
        'MessageBloc(repository: mockRepository)');

    // Fix repository method calls to match interface
    content = content.replaceAll('sendBroadcastMessage(any)',
        'sendBroadcastMessage(any, any, any, any, any)');

    content = content.replaceAll('markAsRead(any)', 'markAsRead(any, any)');

    msgTestFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed message bloc test');
  }

  // Fix document bloc test
  final docTestFile =
      File('test/presentation/blocs/document/document_bloc_test.dart');
  if (docTestFile.existsSync()) {
    String content = docTestFile.readAsStringSync();

    // Fix constructor call
    content = content.replaceAll('DocumentBloc(mockRepository)',
        'DocumentBloc(repository: mockRepository)');

    docTestFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed document bloc test');
  }

  // Fix registration bloc test
  final regTestFile =
      File('test/presentation/blocs/registration/registration_bloc_test.dart');
  if (regTestFile.existsSync()) {
    String content = regTestFile.readAsStringSync();

    // Fix constructor call
    content = content.replaceAll('RegistrationBloc(mockRepository)',
        'RegistrationBloc(repository: mockRepository)');

    regTestFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed registration bloc test');
  }
}

void fixSplashScreenIssues() {
  stdout.writeln('📝 Fixing splash screen auth issues...');

  final splashFile = File('lib/presentation/pages/splash/splash_screen.dart');
  if (splashFile.existsSync()) {
    String content = splashFile.readAsStringSync();

    // Fix CheckAuthStatus method call
    content = content.replaceAll('CheckAuthStatus()', 'AuthCheckRequested()');

    // Add proper auth bloc import if missing
    if (!content.contains("import '../../blocs/auth/auth_bloc.dart'")) {
      content = content.replaceFirst("import 'package:flutter/material.dart';",
          "import 'package:flutter/material.dart';\nimport '../../blocs/auth/auth_bloc.dart';");
    }

    splashFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed splash screen auth issues');
  }
}

void fixEntityConstructorIssues() {
  stdout.writeln('📝 Fixing entity constructor issues...');

  final testDir = Directory('test');
  if (testDir.existsSync()) {
    testDir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dart')) {
        String content = entity.readAsStringSync();
        bool modified = false;

        // Fix Document constructor calls
        if (content.contains('Document(') &&
            !content.contains('Document(id:')) {
          content = content.replaceAllMapped(
              RegExp(r'Document\([^)]*\)'),
              (match) =>
                  'Document(id: "1", filePath: "test.pdf", mimeType: "application/pdf", originalFileName: "test.pdf", type: DocumentType.other, userId: "user1")');
          modified = true;
        }

        // Fix Message constructor calls
        if (content.contains('Message(') && !content.contains('Message(id:')) {
          content = content.replaceAllMapped(
              RegExp(r'Message\([^)]*\)'),
              (match) =>
                  'Message(id: "1", tourId: "tour1", title: "Test", content: "Test message", type: MessageType.info, priority: MessagePriority.normal, createdAt: DateTime.now())');
          modified = true;
        }

        // Fix Registration constructor calls
        if (content.contains('Registration(') &&
            !content.contains('Registration(id:')) {
          content = content.replaceAllMapped(
              RegExp(r'Registration\([^)]*\)'),
              (match) =>
                  'Registration(id: "1", userId: "user1", tourId: "tour1", joinCode: "ABC123", status: RegistrationStatus.pending, createdAt: DateTime.now())');
          modified = true;
        }

        if (modified) {
          entity.writeAsStringSync(content);
          stdout.writeln('  ✓ Fixed entity constructors in ${entity.path}');
        }
      }
    });
  }
}

void fixWidgetParameterIssues() {
  stdout.writeln('📝 Fixing widget parameter issues...');

  // Fix document upload widget test parameters
  final docUploadFile = File(
      'test/presentation/widgets/document/document_upload_widget_test.dart');
  if (docUploadFile.existsSync()) {
    String content = docUploadFile.readAsStringSync();

    // Fix all parameter names to match actual widget
    final parameterFixes = {
      'onUploaded:': 'onDocumentUploaded:',
      'onSelected:': 'onDocumentSelected:',
      'maxFileSize:': 'maxFileSizeBytes:',
      'error:': 'errorMessage:',
      'uploading:': 'isUploading:',
      'progress:': 'uploadProgress:',
      'document:': 'selectedDocument:',
    };

    parameterFixes.forEach((oldParam, newParam) {
      content = content.replaceAll(oldParam, newParam);
    });

    docUploadFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed document upload widget parameters');
  }

  // Fix provider list item parameters
  final providerFile =
      File('test/presentation/widgets/provider/provider_list_item_test.dart');
  if (providerFile.existsSync()) {
    String content = providerFile.readAsStringSync();

    // Fix provider parameter names
    content = content.replaceAll('companyName:', 'name:');
    content = content.replaceAll('contactEmail:', 'email:');

    providerFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed provider list item parameters');
  }
}
