#!/usr/bin/env dart

import 'dart:io';

void main() {
  stdout.writeln('🔧 Fixing mock-related issues...');

  // Regenerate problematic mocks
  regenerateMocks();

  // Fix mock overrides
  fixMockOverrides();

  // Fix integration test issues
  fixIntegrationTests();

  stdout.writeln('✅ Mock fixes completed!');
}

void regenerateMocks() {
  stdout.writeln('📝 Regenerating problematic mocks...');

  // Delete problematic mock files to force regeneration
  final mockFiles = [
    'test/core/services/offline_manager_test.mocks.dart',
    'test/core/services/sync_service_test.mocks.dart',
    'test/data/repositories/offline_custom_tour_repository_test.mocks.dart',
    'test/presentation/blocs/custom_tour/custom_tour_bloc_test.mocks.dart',
    'test/presentation/blocs/document/document_bloc_test.mocks.dart',
    'test/presentation/blocs/registration/registration_bloc_test.mocks.dart',
  ];

  for (final mockFile in mockFiles) {
    final file = File(mockFile);
    if (file.existsSync()) {
      file.deleteSync();
      stdout.writeln('  ✓ Deleted $mockFile');
    }
  }
}

void fixMockOverrides() {
  stdout.writeln('📝 Fixing mock override issues...');

  // Fix biometric auth service test mock
  final bioTestFile =
      File('test/core/security/biometric_auth_service_test.mocks.dart');
  if (bioTestFile.existsSync()) {
    String content = bioTestFile.readAsStringSync();

    // Fix authenticate method signature
    content = content.replaceAll(
        'Future<bool> authenticate({required String? localizedReason, AuthenticationOptions? options})',
        'Future<bool> authenticate({Iterable<AuthMessages> authMessages = const <AuthMessages>[], required String localizedReason, AuthenticationOptions options = const AuthenticationOptions()})');

    bioTestFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed biometric auth mock');
  }
}

void fixIntegrationTests() {
  stdout.writeln('📝 Fixing integration test issues...');

  // Fix monitoring integration test
  final monitoringTestFile =
      File('test/integration/monitoring_integration_test.dart');
  if (monitoringTestFile.existsSync()) {
    String content = monitoringTestFile.readAsStringSync();

    // Add missing import
    if (!content
        .contains("import 'package:integration_test/integration_test.dart'")) {
      content = content.replaceFirst(
          "import 'package:flutter_test/flutter_test.dart';",
          "import 'package:flutter_test/flutter_test.dart';\nimport 'package:integration_test/integration_test.dart';");
    }

    // Fix IntegrationTestWidgetsBinding
    content = content.replaceAll('IntegrationTestWidgetsBinding',
        'IntegrationTestWidgetsFlutterBinding');

    monitoringTestFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed monitoring integration test');
  }

  // Fix security integration test
  final securityTestFile =
      File('test/integration/security_integration_test.dart');
  if (securityTestFile.existsSync()) {
    String content = securityTestFile.readAsStringSync();

    // Remove unused imports
    content =
        content.replaceAll("import 'package:flutter/material.dart';\n", "");
    content = content.replaceAll(
        "import 'package:tourlicity_app/main.dart' as app;\n", "");

    securityTestFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed security integration test');
  }
}
