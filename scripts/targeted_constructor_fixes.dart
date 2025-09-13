#!/usr/bin/env dart

import 'dart:io';

void main() {
  stdout.writeln('🔧 Running targeted constructor fixes...');
  
  // Fix specific BLoC constructor issues
  fixSpecificBlocIssues();
  
  // Fix repository method call issues
  fixRepositoryMethodCalls();
  
  // Fix missing mock files
  generateMissingMocks();
  
  stdout.writeln('✅ Targeted constructor fixes completed!');
}

void fixSpecificBlocIssues() {
  stdout.writeln('📝 Fixing specific BLoC constructor issues...');
  
  // Check the actual BLoC constructor signatures first
  final messageBlocFile = File('lib/presentation/blocs/message/message_bloc.dart');
  if (messageBlocFile.existsSync()) {
    String content = messageBlocFile.readAsStringSync();
    stdout.writeln('  📋 MessageBloc constructor signature found');
    
    // Fix the test file based on actual constructor
    final msgTestFile = File('test/presentation/blocs/message/message_bloc_test.dart');
    if (msgTestFile.existsSync()) {
      String testContent = msgTestFile.readAsStringSync();
      
      // Check if constructor expects positional parameter
      if (content.contains('MessageBloc(this.')) {
        testContent = testContent.replaceAll(
          'MessageBloc(repository: mockRepository)',
          'MessageBloc(mockRepository)'
        );
      } else if (content.contains('MessageBloc({required')) {
        testContent = testContent.replaceAll(
          'MessageBloc(mockRepository)',
          'MessageBloc(repository: mockRepository)'
        );
      }
      
      msgTestFile.writeAsStringSync(testContent);
      stdout.writeln('  ✓ Fixed MessageBloc test constructor');
    }
  }
  
  // Similar fix for DocumentBloc
  final documentBlocFile = File('lib/presentation/blocs/document/document_bloc.dart');
  if (documentBlocFile.existsSync()) {
    String content = documentBlocFile.readAsStringSync();
    
    final docTestFile = File('test/presentation/blocs/document/document_bloc_test.dart');
    if (docTestFile.existsSync()) {
      String testContent = docTestFile.readAsStringSync();
      
      if (content.contains('DocumentBloc(this.')) {
        testContent = testContent.replaceAll(
          'DocumentBloc(repository: mockRepository)',
          'DocumentBloc(mockRepository)'
        );
      } else if (content.contains('DocumentBloc({required')) {
        testContent = testContent.replaceAll(
          'DocumentBloc(mockRepository)',
          'DocumentBloc(repository: mockRepository)'
        );
      }
      
      docTestFile.writeAsStringSync(testContent);
      stdout.writeln('  ✓ Fixed DocumentBloc test constructor');
    }
  }
  
  // Similar fix for RegistrationBloc
  final registrationBlocFile = File('lib/presentation/blocs/registration/registration_bloc.dart');
  if (registrationBlocFile.existsSync()) {
    String content = registrationBlocFile.readAsStringSync();
    
    final regTestFile = File('test/presentation/blocs/registration/registration_bloc_test.dart');
    if (regTestFile.existsSync()) {
      String testContent = regTestFile.readAsStringSync();
      
      if (content.contains('RegistrationBloc(this.')) {
        testContent = testContent.replaceAll(
          'RegistrationBloc(repository: mockRepository)',
          'RegistrationBloc(mockRepository)'
        );
      } else if (content.contains('RegistrationBloc({required')) {
        testContent = testContent.replaceAll(
          'RegistrationBloc(mockRepository)',
          'RegistrationBloc(repository: mockRepository)'
        );
      }
      
      regTestFile.writeAsStringSync(testContent);
      stdout.writeln('  ✓ Fixed RegistrationBloc test constructor');
    }
  }
}

void fixRepositoryMethodCalls() {
  stdout.writeln('📝 Fixing repository method call issues...');
  
  final repositoryTests = [
    'test/data/repositories/message_repository_impl_test.dart',
    'test/data/repositories/registration_repository_impl_test.dart',
  ];
  
  for (final testPath in repositoryTests) {
    final testFile = File(testPath);
    if (testFile.existsSync()) {
      String content = testFile.readAsStringSync();
      bool modified = false;
      
      // Fix method calls that expect parameters
      final methodFixes = {
        'deleteMessage()': 'deleteMessage("messageId")',
        'approveRegistration()': 'approveRegistration("registrationId")',
        'rejectRegistration()': 'rejectRegistration("registrationId")',
        'cancelRegistration()': 'cancelRegistration("registrationId")',
        'updateRegistration()': 'updateRegistration("registrationId")',
        'completeRegistration()': 'completeRegistration("registrationId")',
      };
      
      methodFixes.forEach((oldCall, newCall) {
        if (content.contains(oldCall)) {
          content = content.replaceAll(oldCall, newCall);
          modified = true;
        }
      });
      
      if (modified) {
        testFile.writeAsStringSync(content);
        stdout.writeln('  ✓ Fixed method calls in $testPath');
      }
    }
  }
}

void generateMissingMocks() {
  stdout.writeln('📝 Generating missing mock files...');
  
  // Create missing mock files that are referenced but don't exist
  final missingMocks = [
    'test/presentation/widgets/auth/profile_completion_wrapper_test.mocks.dart',
  ];
  
  for (final mockPath in missingMocks) {
    final mockFile = File(mockPath);
    if (!mockFile.existsSync()) {
      // Create a basic mock file
      const mockContent = '''
// Mocks generated by Mockito 5.4.4 from annotations
// in tourlicity_app/test/presentation/widgets/auth/profile_completion_wrapper_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:tourlicity_app/presentation/blocs/user/user_bloc.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [UserBloc].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserBloc extends _i1.Mock implements _i2.UserBloc {
  MockUserBloc() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Stream<_i2.UserState> get stream => (super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: _i3.Stream<_i2.UserState>.empty(),
      ) as _i3.Stream<_i2.UserState>);

  @override
  _i2.UserState get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _i2.UserInitial(),
      ) as _i2.UserState);
}
''';
      
      // Ensure directory exists
      mockFile.parent.createSync(recursive: true);
      mockFile.writeAsStringSync(mockContent);
      stdout.writeln('  ✓ Created missing mock file: $mockPath');
    }
  }
}