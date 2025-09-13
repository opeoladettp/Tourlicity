import 'dart:io';

void main() async {
  stdout.writeln('Fixing remaining anyNamed issues...');
  
  // Get all test files
  final testDir = Directory('test');
  final testFiles = await testDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();
  
  for (final file in testFiles) {
    String content = await file.readAsString();
    bool modified = false;
    
    // Replace anyNamed with any for specific patterns
    if (content.contains('anyNamed(')) {
      content = content.replaceAll('anyNamed(\'key\')', 'any');
      content = content.replaceAll('anyNamed(\'value\')', 'any');
      content = content.replaceAll('anyNamed(\'localizedReason\')', 'any');
      content = content.replaceAll('anyNamed(\'options\')', 'any');
      content = content.replaceAll('anyNamed(\'idToken\')', 'any');
      content = content.replaceAll('anyNamed(\'accessToken\')', 'any');
      content = content.replaceAll('anyNamed(\'joinCode\')', 'any');
      content = content.replaceAll('anyNamed(\'touristId\')', 'any');
      content = content.replaceAll('anyNamed(\'specialRequirements\')', 'any');
      content = content.replaceAll('anyNamed(\'emergencyContactName\')', 'any');
      content = content.replaceAll('anyNamed(\'emergencyContactPhone\')', 'any');
      content = content.replaceAll('anyNamed(\'status\')', 'any');
      content = content.replaceAll('anyNamed(\'limit\')', 'any');
      content = content.replaceAll('anyNamed(\'offset\')', 'any');
      content = content.replaceAll('anyNamed(\'notes\')', 'any');
      content = content.replaceAll('anyNamed(\'queryParameters\')', 'any');
      content = content.replaceAll('anyNamed(\'data\')', 'any');
      modified = true;
    }
    
    if (modified) {
      await file.writeAsString(content);
      stdout.writeln('Fixed anyNamed issues in: ${file.path}');
    }
  }
  
  stdout.writeln('Completed fixing anyNamed issues!');
}