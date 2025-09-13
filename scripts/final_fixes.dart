#!/usr/bin/env dart

import 'dart:io';

void main() {
  stdout.writeln('🔧 Running final fixes for remaining issues...');

  // Fix constructor issues
  fixConstructorIssues();

  // Fix widget test issues
  fixWidgetTests();

  // Fix auth-related issues
  fixAuthIssues();

  // Fix provider issues
  fixProviderIssues();

  stdout.writeln('✅ Final fixes completed!');
}

void fixConstructorIssues() {
  stdout.writeln('📝 Fixing constructor issues...');

  final testDir = Directory('test');
  if (testDir.existsSync()) {
    testDir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dart')) {
        String content = entity.readAsStringSync();
        bool modified = false;

        // Fix BLoC constructor calls
        if (content.contains('DocumentBloc(')) {
          content = content.replaceAll('DocumentBloc(mockRepository)',
              'DocumentBloc(repository: mockRepository)');
          modified = true;
        }

        if (content.contains('MessageBloc(')) {
          content = content.replaceAll('MessageBloc(mockRepository)',
              'MessageBloc(repository: mockRepository)');
          modified = true;
        }

        if (content.contains('RegistrationBloc(')) {
          content = content.replaceAll('RegistrationBloc(mockRepository)',
              'RegistrationBloc(repository: mockRepository)');
          modified = true;
        }

        // Fix repository method calls
        if (content.contains('sendBroadcastMessage(any, any, any, any, any)')) {
          content = content.replaceAll(
              'sendBroadcastMessage(any, any, any, any, any)',
              'sendBroadcastMessage(any)');
          modified = true;
        }

        if (content.contains('markAsRead(any, any)')) {
          content =
              content.replaceAll('markAsRead(any, any)', 'markAsRead(any)');
          modified = true;
        }

        if (content.contains('updateRegistrationStatus(any, any)')) {
          content = content.replaceAll('updateRegistrationStatus(any, any)',
              'updateRegistrationStatus(any)');
          modified = true;
        }

        if (modified) {
          entity.writeAsStringSync(content);
          stdout.writeln('  ✓ Fixed ${entity.path}');
        }
      }
    });
  }
}

void fixWidgetTests() {
  stdout.writeln('📝 Fixing widget test issues...');

  // Fix document upload widget test
  final docUploadFile = File(
      'test/presentation/widgets/document/document_upload_widget_test.dart');
  if (docUploadFile.existsSync()) {
    String content = docUploadFile.readAsStringSync();

    // Fix constructor parameters
    content = content.replaceAll('onDocumentUploaded:', 'onUploaded:');
    content = content.replaceAll('onDocumentSelected:', 'onSelected:');
    content = content.replaceAll('maxFileSizeBytes:', 'maxFileSize:');
    content = content.replaceAll('errorMessage:', 'error:');
    content = content.replaceAll('isUploading:', 'uploading:');
    content = content.replaceAll('uploadProgress:', 'progress:');
    content = content.replaceAll('selectedDocument:', 'document:');

    docUploadFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed document upload widget test');
  }

  // Fix google sign in button test
  final googleSignInFile =
      File('test/presentation/widgets/auth/google_sign_in_button_test.dart');
  if (googleSignInFile.existsSync()) {
    String content = googleSignInFile.readAsStringSync();

    // Remove duplicate onPressed parameters
    content = content.replaceAllMapped(
        RegExp(
            r'GoogleSignInButton\([^)]*onPressed:[^,)]*,[^)]*onPressed:[^,)]*[^)]*\)'),
        (match) => 'GoogleSignInButton(onPressed: () {})');

    googleSignInFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed google sign in button test');
  }
}

void fixAuthIssues() {
  stdout.writeln('📝 Fixing auth-related issues...');

  // Fix login page test
  final loginPageFile =
      File('test/presentation/pages/auth/login_page_test.dart');
  if (loginPageFile.existsSync()) {
    String content = loginPageFile.readAsStringSync();

    // Fix auth state constructors
    content = content.replaceAll('AuthInitial()', 'AuthInitial()');
    content = content.replaceAll('AuthLoading()', 'AuthLoading()');
    content = content.replaceAll('AuthError(', 'AuthError(message: ');

    // Fix auth event parameter
    content = content.replaceAll('add(null)', 'add(CheckAuthStatus())');

    loginPageFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed login page test');
  }

  // Fix profile completion wrapper test
  final profileWrapperFile = File(
      'test/presentation/widgets/auth/profile_completion_wrapper_test.dart');
  if (profileWrapperFile.existsSync()) {
    String content = profileWrapperFile.readAsStringSync();

    // Add missing mock file import
    if (!content
        .contains("import 'profile_completion_wrapper_test.mocks.dart';")) {
      content = content.replaceFirst(
          "import 'package:mockito/annotations.dart';",
          "import 'package:mockito/annotations.dart';\nimport 'profile_completion_wrapper_test.mocks.dart';");
    }

    // Fix user type references
    content = content.replaceAll('UserType.', 'UserRole.');
    content = content.replaceAll('UserLoaded(',
        'UserAuthenticated(user: User(id: "1", email: "test@test.com", role: UserRole.tourist), ');
    content = content.replaceAll('UserLoading()', 'UserLoading()');
    content = content.replaceAll('UserError(', 'UserError(message: ');

    profileWrapperFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed profile completion wrapper test');
  }
}

void fixProviderIssues() {
  stdout.writeln('📝 Fixing provider-related issues...');

  // Fix provider list item test
  final providerListFile =
      File('test/presentation/widgets/provider/provider_list_item_test.dart');
  if (providerListFile.existsSync()) {
    String content = providerListFile.readAsStringSync();

    // Fix provider constructor parameters
    content = content.replaceAll('name:', 'companyName:');
    content = content.replaceAll('email:', 'contactEmail:');

    providerListFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed provider list item test');
  }
}
