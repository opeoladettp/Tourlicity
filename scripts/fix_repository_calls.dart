#!/usr/bin/env dart

import 'dart:io';

void main() {
  stdout.writeln('🔧 Fixing repository method call issues...');
  
  // Fix message repository test calls
  fixMessageRepositoryTest();
  
  // Fix registration repository test calls
  fixRegistrationRepositoryTest();
  
  // Fix document repository test calls
  fixDocumentRepositoryTest();
  
  stdout.writeln('✅ Repository method call fixes completed!');
}

void fixMessageRepositoryTest() {
  stdout.writeln('📝 Fixing message repository test...');
  
  final testFile = File('test/data/repositories/message_repository_impl_test.dart');
  if (testFile.existsSync()) {
    String content = testFile.readAsStringSync();
    
    // Fix method calls with missing parameters
    content = content.replaceAll('deleteMessage()', 'deleteMessage("messageId")');
    
    testFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed message repository test');
  }
}

void fixRegistrationRepositoryTest() {
  stdout.writeln('📝 Fixing registration repository test...');
  
  final testFile = File('test/data/repositories/registration_repository_impl_test.dart');
  if (testFile.existsSync()) {
    String content = testFile.readAsStringSync();
    
    // Fix method calls with missing parameters
    final fixes = {
      'approveRegistration()': 'approveRegistration("registrationId")',
      'rejectRegistration()': 'rejectRegistration("registrationId")',
      'cancelRegistration()': 'cancelRegistration("registrationId")',
      'updateRegistration()': 'updateRegistration("registrationId")',
      'completeRegistration()': 'completeRegistration("registrationId")',
    };
    
    fixes.forEach((oldCall, newCall) {
      content = content.replaceAll(oldCall, newCall);
    });
    
    testFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed registration repository test');
  }
}

void fixDocumentRepositoryTest() {
  stdout.writeln('📝 Fixing document repository test...');
  
  final testFile = File('test/data/repositories/document_repository_impl_test.dart');
  if (testFile.existsSync()) {
    String content = testFile.readAsStringSync();
    
    // Fix method calls with missing parameters
    final fixes = {
      'deleteDocument()': 'deleteDocument("documentId")',
      'approveDocument()': 'approveDocument("documentId")',
      'rejectDocument()': 'rejectDocument("documentId")',
    };
    
    fixes.forEach((oldCall, newCall) {
      content = content.replaceAll(oldCall, newCall);
    });
    
    testFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed document repository test');
  }
}