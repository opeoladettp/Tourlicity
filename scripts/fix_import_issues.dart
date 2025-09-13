import 'dart:io';

void main() async {
  stdout.writeln('Starting import fixes...');
  
  // Fix mockito any matcher issues
  await fixMockitoAnyMatchers();
  
  // Remove unused imports
  await removeUnusedImports();
  
  stdout.writeln('Import fixes completed!');
}

Future<void> fixMockitoAnyMatchers() async {
  stdout.writeln('Fixing mockito any matcher issues...');
  
  final testFiles = [
    'test/core/security/biometric_auth_service_test.dart',
    'test/core/security/secure_session_manager_test.dart',
    'test/presentation/blocs/auth/auth_bloc_test.dart',
    'test/presentation/widgets/forms/profile_completion_form_test.dart',
    'test/core/services/sync_service_test.dart',
    'test/data/repositories/offline_custom_tour_repository_test.dart',
    'test/presentation/pages/tour_template/tour_template_list_page_test.dart',
  ];
  
  for (final filePath in testFiles) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();
      
      // Fix specific any usage patterns
      content = content.replaceAll('any(named: \'key\')', 'anyNamed(\'key\')');
      content = content.replaceAll('any(named: \'value\')', 'anyNamed(\'value\')');
      content = content.replaceAll('any(named: \'localizedReason\')', 'anyNamed(\'localizedReason\')');
      content = content.replaceAll('any(named: \'options\')', 'anyNamed(\'options\')');
      content = content.replaceAll('any(named: \'idToken\')', 'anyNamed(\'idToken\')');
      content = content.replaceAll('any(named: \'accessToken\')', 'anyNamed(\'accessToken\')');
      
      // Fix generic any usage in verify calls
      content = content.replaceAll('verify(mockStorage.delete(key: any))', 'verify(mockStorage.delete(key: anyNamed(\'key\')))');
      content = content.replaceAll('when(mockStorage.write(key: any, value: any))', 'when(mockStorage.write(key: anyNamed(\'key\'), value: anyNamed(\'value\')))');
      content = content.replaceAll('verify(mockStorage.write(key: \'last_activity_time\', value: any))', 'verify(mockStorage.write(key: \'last_activity_time\', value: anyNamed(\'value\')))');
      
      await file.writeAsString(content);
      stdout.writeln('Fixed mockito matchers in: $filePath');
    }
  }
}

Future<void> removeUnusedImports() async {
  stdout.writeln('Removing unused imports...');
  
  final filesToFix = [
    'test/presentation/widgets/forms/profile_completion_form_test.dart',
    'test/integration/security_integration_test.dart',
    'test/presentation/widgets/common/accessibility_widgets_test.dart',
  ];
  
  for (final filePath in filesToFix) {
    final file = File(filePath);
    if (await file.exists()) {
      String content = await file.readAsString();
      
      // Remove unused imports
      if (filePath.contains('profile_completion_form_test.dart')) {
        content = content.replaceAll("import 'package:tourlicity_app/domain/entities/user.dart';\n", '');
      }
      
      if (filePath.contains('security_integration_test.dart')) {
        content = content.replaceAll("import 'package:flutter/material.dart';\n", '');
        content = content.replaceAll("import 'package:tourlicity_app/main.dart';\n", '');
      }
      
      if (filePath.contains('accessibility_widgets_test.dart')) {
        content = content.replaceAll("import 'package:flutter/services.dart';\n", '');
      }
      
      await file.writeAsString(content);
      stdout.writeln('Removed unused imports from: $filePath');
    }
  }
}