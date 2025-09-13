#!/usr/bin/env dart

import 'dart:io';

void main() {
  stdout.writeln('🔧 Restoring repository test files to proper state...');
  
  // Restore message repository test
  restoreMessageRepositoryTest();
  
  // Restore registration repository test
  restoreRegistrationRepositoryTest();
  
  // Restore document repository test
  restoreDocumentRepositoryTest();
  
  stdout.writeln('✅ Repository test restoration completed!');
}

void restoreMessageRepositoryTest() {
  stdout.writeln('📝 Restoring message repository test...');
  
  final testFile = File('test/data/repositories/message_repository_impl_test.dart');
  if (testFile.existsSync()) {
    String content = testFile.readAsStringSync();
    
    // Fix corrupted deleteMessage call
    content = content.replaceAllMapped(
      RegExp(r'deleteMessage\(id: "[^"]*", tourId: "[^"]*", title: "[^"]*", content: "[^"]*", type: [^,]*, priority: [^,]*, createdAt: [^)]*\)'),
      (match) => 'deleteMessage("message-1")'
    );
    
    testFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Restored message repository test');
  }
}

void restoreRegistrationRepositoryTest() {
  stdout.writeln('📝 Restoring registration repository test...');
  
  final testFile = File('test/data/repositories/registration_repository_impl_test.dart');
  if (testFile.existsSync()) {
    String content = testFile.readAsStringSync();
    
    // Fix corrupted method calls
    final fixes = {
      RegExp(r'approveRegistration\(id: "[^"]*", userId: "[^"]*", tourId: "[^"]*", joinCode: "[^"]*", status: [^,]*, createdAt: [^)]*\)'): 'approveRegistration("registration-1")',
      RegExp(r'rejectRegistration\(id: "[^"]*", userId: "[^"]*", tourId: "[^"]*", joinCode: "[^"]*", status: [^,]*, createdAt: [^)]*\)'): 'rejectRegistration("registration-1")',
      RegExp(r'cancelRegistration\(id: "[^"]*", userId: "[^"]*", tourId: "[^"]*", joinCode: "[^"]*", status: [^,]*, createdAt: [^)]*\)'): 'cancelRegistration("registration-1")',
      RegExp(r'updateRegistration\(id: "[^"]*", userId: "[^"]*", tourId: "[^"]*", joinCode: "[^"]*", status: [^,]*, createdAt: [^)]*\)'): 'updateRegistration("registration-1")',
      RegExp(r'completeRegistration\(id: "[^"]*", userId: "[^"]*", tourId: "[^"]*", joinCode: "[^"]*", status: [^,]*, createdAt: [^)]*\)'): 'completeRegistration("registration-1")',
    };
    
    fixes.forEach((pattern, replacement) {
      content = content.replaceAllMapped(pattern, (match) => replacement);
    });
    
    testFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Restored registration repository test');
  }
}

void restoreDocumentRepositoryTest() {
  stdout.writeln('📝 Restoring document repository test...');
  
  final testFile = File('test/data/repositories/document_repository_impl_test.dart');
  if (testFile.existsSync()) {
    String content = testFile.readAsStringSync();
    
    // Fix corrupted method calls
    final fixes = {
      RegExp(r'deleteDocument\(id: "[^"]*", filePath: "[^"]*", mimeType: "[^"]*", originalFileName: "[^"]*", type: [^,]*, userId: "[^"]*"\)'): 'deleteDocument("document-1")',
      RegExp(r'approveDocument\(id: "[^"]*", filePath: "[^"]*", mimeType: "[^"]*", originalFileName: "[^"]*", type: [^,]*, userId: "[^"]*"\)'): 'approveDocument("document-1")',
      RegExp(r'rejectDocument\(id: "[^"]*", filePath: "[^"]*", mimeType: "[^"]*", originalFileName: "[^"]*", type: [^,]*, userId: "[^"]*"\)'): 'rejectDocument("document-1")',
    };
    
    fixes.forEach((pattern, replacement) {
      content = content.replaceAllMapped(pattern, (match) => replacement);
    });
    
    testFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Restored document repository test');
  }
}