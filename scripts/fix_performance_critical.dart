#!/usr/bin/env dart

import 'dart:io';

void main() {
  stdout.writeln('🔧 Fixing critical performance module issues...');
  
  // Fix animation optimizer critical issues
  fixAnimationOptimizer();
  
  // Fix code splitting critical issues
  fixCodeSplitting();
  
  // Fix optimized image service
  fixOptimizedImageService();
  
  stdout.writeln('✅ Performance module critical fixes completed!');
}

void fixAnimationOptimizer() {
  stdout.writeln('📝 Fixing animation optimizer...');
  
  final animFile = File('lib/core/performance/animation_optimizer.dart');
  if (animFile.existsSync()) {
    String content = animFile.readAsStringSync();
    
    // Completely rewrite the problematic mixin to be simpler
    content = content.replaceAll(
      'mixin AnimationOptimizationMixin<T extends StatefulWidget>',
      'mixin AnimationOptimizationMixin<T extends StatefulWidget> on TickerProviderStateMixin<T>'
    );
    
    // Fix TickerProvider usage
    content = content.replaceAll(
      'AnimationController(vsync: vsync',
      'AnimationController(vsync: this'
    );
    
    // Remove any problematic with clauses
    content = content.replaceAllMapped(
      RegExp(r'mixin [^{]* with [^{]*{'),
      (match) => '${match.group(0)!.replaceAll(RegExp(r' with [^{]*'), '')}{'
    );
    
    animFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed animation optimizer mixin');
  }
}

void fixCodeSplitting() {
  stdout.writeln('📝 Fixing code splitting...');
  
  final codeSplitFile = File('lib/core/performance/code_splitting.dart');
  if (codeSplitFile.existsSync()) {
    String content = codeSplitFile.readAsStringSync();
    
    // Fix widget declaration issue
    content = content.replaceAll(
      'widget.',
      'widget?.'
    );
    
    // Fix paintOffset issues - use a simpler approach
    content = content.replaceAll(
      '.paintOffset',
      '.offset ?? Offset.zero'
    );
    
    // Fix RenderAbstractViewport issues
    content = content.replaceAll(
      'RenderAbstractViewport',
      'RenderViewport'
    );
    
    // Remove unnecessary casts
    content = content.replaceAllMapped(
      RegExp(r' as BoxConstraints'),
      (match) => ''
    );
    
    // Fix constraints access
    content = content.replaceAll(
      '(constraints as BoxConstraints).maxHeight',
      'constraints.maxHeight'
    );
    
    codeSplitFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed code splitting issues');
  }
}

void fixOptimizedImageService() {
  stdout.writeln('📝 Fixing optimized image service...');
  
  final imageFile = File('lib/core/performance/optimized_image_service.dart');
  if (imageFile.existsSync()) {
    String content = imageFile.readAsStringSync();
    
    // Fix cache manager type issue
    content = content.replaceAll(
      'DefaultCacheManager() as BaseCacheManager',
      'DefaultCacheManager()'
    );
    
    // Fix CustomCacheManager usage
    content = content.replaceAll(
      'CustomCacheManager()',
      'DefaultCacheManager()'
    );
    
    imageFile.writeAsStringSync(content);
    stdout.writeln('  ✓ Fixed optimized image service');
  }
}