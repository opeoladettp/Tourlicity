#!/usr/bin/env dart

import 'dart:io';

void main() {
  stdout.writeln('🎯 Running targeted fixes for specific issues...');
  
  // Fix specific test files
  fixDocumentBlocTest();
  fixMessageBlocTest();
  fixRegistrationBlocTest();
  
  stdout.writeln('✅ Targeted fixes completed!');
}

void fixDocumentBlocTest() {
  stdout.writeln('📝 Fixing Document BLoC test...');
  
  final file = File('test/presentation/blocs/document/document_bloc_test.dart');
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    
    // Fix remaining API result calls
    content = content.replaceAll('ApiResult.success(', 'ApiSuccess(data: ');
    content = content.replaceAll('ApiResult.failure(', 'ApiFailure(message: ');
    
    // Fix method calls
    content = content.replaceAll('mockRepository.reviewDocument(', 'mockRepository.approveDocument(documentId: anyNamed("documentId"), reviewedBy: anyNamed("reviewedBy")');
    content = content.replaceAll('mockRepository.downloadDocument(', 'mockRepository.getDownloadUrl(');
    
    // Fix event constructors
    content = content.replaceAll('ReviewDocument(', 'ApproveDocument(documentId: "doc1", reviewedBy: "admin"');
    content = content.replaceAll('DownloadDocument(', 'GetDownloadUrl(documentId: "doc1"');
    
    // Fix state constructors
    content = content.replaceAll('DocumentUploadSuccess(', 'DocumentUploaded(document: ');
    content = content.replaceAll('DocumentDownloading()', 'DocumentLoading()');
    content = content.replaceAll('DocumentDownloadSuccess(', 'DocumentDownloaded(url: ');
    
    file.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed Document BLoC test');
  }
}

void fixMessageBlocTest() {
  stdout.writeln('📝 Fixing Message BLoC test...');
  
  final file = File('test/presentation/blocs/message/message_bloc_test.dart');
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    
    // Fix API result calls
    content = content.replaceAll('ApiResult.success(', 'ApiSuccess(data: ');
    content = content.replaceAll('ApiResult.failure(', 'ApiFailure(message: ');
    
    // Fix method calls
    content = content.replaceAll('mockRepository.getMessages()', 'mockRepository.getMessagesForUser("user1")');
    content = content.replaceAll('mockRepository.sendMessage(', 'mockRepository.sendBroadcastMessage(tourId: "tour1", title: "Test", content: "Test message", type: MessageType.info, priority: MessagePriority.normal');
    content = content.replaceAll('mockRepository.markAsRead(', 'mockRepository.markMessageAsRead(');
    content = content.replaceAll('mockRepository.dismissMessage(', 'mockRepository.markMessageAsDismissed(');
    
    // Fix event constructors
    content = content.replaceAll('LoadMessages()', 'LoadMessagesForUser(userId: "user1")');
    content = content.replaceAll('SendMessage(', 'SendBroadcastMessage(tourId: "tour1", title: "Test", content: "Test message", type: MessageType.info, priority: MessagePriority.normal');
    content = content.replaceAll('MarkMessageAsRead(', 'MarkMessageAsRead(messageId: "msg1", userId: "user1"');
    content = content.replaceAll('DismissMessage(', 'MarkMessageAsDismissed(messageId: "msg1", userId: "user1"');
    content = content.replaceAll('DeleteMessage()', 'DeleteMessage(messageId: "msg1")');
    
    // Fix state constructors
    content = content.replaceAll('MessageLoaded(', 'MessagesLoaded(messages: ');
    content = content.replaceAll('MessageSent()', 'MessageSent(message: testMessage)');
    content = content.replaceAll('MessageUpdated()', 'MessageUpdated(message: testMessage)');
    content = content.replaceAll('MessageDeleted()', 'MessageDeleted(message: testMessage)');
    content = content.replaceAll('MessageUpdating()', 'MessageLoading()');
    content = content.replaceAll('MessageDeleting()', 'MessageLoading()');
    
    file.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed Message BLoC test');
  }
}

void fixRegistrationBlocTest() {
  stdout.writeln('📝 Fixing Registration BLoC test...');
  
  final file = File('test/presentation/blocs/registration/registration_bloc_test.dart');
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    
    // Fix API result calls
    content = content.replaceAll('ApiResult.success(', 'ApiSuccess(data: ');
    content = content.replaceAll('ApiResult.failure(', 'ApiFailure(message: ');
    
    // Fix method calls
    content = content.replaceAll('mockRepository.getRegistrations()', 'mockRepository.getRegistrationsByTourist("user1")');
    content = content.replaceAll('mockRepository.createRegistration(', 'mockRepository.registerForTour(joinCode: anyNamed("joinCode"), touristId: anyNamed("touristId")');
    content = content.replaceAll('mockRepository.updateRegistrationStatus(', 'mockRepository.approveRegistration(');
    content = content.replaceAll('mockRepository.findTourByJoinCode(', 'mockRepository.getRegistrationByConfirmationCode(');
    
    // Fix event constructors
    content = content.replaceAll('LoadRegistrations()', 'LoadRegistrationsByTourist(touristId: "user1")');
    content = content.replaceAll('CreateRegistration(', 'RegisterForTour(joinCode: "JOIN123", touristId: "user1"');
    content = content.replaceAll('CancelRegistration()', 'CancelRegistration(registrationId: "reg1")');
    content = content.replaceAll('SearchTourByJoinCode(', 'GetRegistrationByConfirmationCode(confirmationCode: ');
    
    // Fix state constructors
    content = content.replaceAll('RegistrationLoaded(', 'RegistrationsLoaded(registrations: ');
    content = content.replaceAll('RegistrationSubmitted()', 'RegistrationSubmitted(registration: testRegistration)');
    content = content.replaceAll('RegistrationSubmitting()', 'RegistrationLoading()');
    content = content.replaceAll('RegistrationUpdating()', 'RegistrationLoading()');
    content = content.replaceAll('TourSearching()', 'RegistrationLoading()');
    content = content.replaceAll('TourFound(', 'RegistrationFound(registration: ');
    
    file.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed Registration BLoC test');
  }
}