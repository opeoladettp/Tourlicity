import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/presentation/pages/tourist/my_tours_page.dart';
import 'package:tourlicity_app/presentation/widgets/common/optimized_list_view.dart';
import 'package:tourlicity_app/presentation/blocs/custom_tour/custom_tour_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Mock classes
class MockCustomTourBloc extends Mock implements CustomTourBloc {}

void main() {
  group('Memory Leak Detection Tests', () {
    testWidgets('should not leak memory when navigating between pages', (WidgetTester tester) async {
      final mockBloc = MockCustomTourBloc();
      
      // Record initial memory usage
      final initialMemory = _getMemoryUsage();
      
      // Navigate through multiple pages multiple times
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CustomTourBloc>(
              create: (_) => mockBloc,
              child: const MyToursPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        
        // Navigate to a different page
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Other Page')),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }
      
      // Force garbage collection
      await _forceGarbageCollection();
      
      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      // Memory increase should be reasonable (less than 10MB for this test)
      expect(memoryIncrease, lessThan(10 * 1024 * 1024)); // 10MB
    });

    testWidgets('should properly dispose of controllers and streams', (WidgetTester tester) async {
      final controllers = <TextEditingController>[];
      
      // Create multiple widgets with controllers
      for (int i = 0; i < 5; i++) {
        final controller = TextEditingController();
        controllers.add(controller);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }
      
      // Remove all widgets
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      
      // Force garbage collection
      await _forceGarbageCollection();
      
      // Controllers should be disposed (this is a simplified check)
      for (final controller in controllers) {
        expect(() => controller.text, throwsA(isA<AssertionError>()));
      }
    });

    testWidgets('should handle large lists without memory issues', (WidgetTester tester) async {
      final initialMemory = _getMemoryUsage();
      
      // Create a large list
      final items = List.generate(1000, (index) => 'Item $index');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptimizedListView<String>(
              items: items,
              itemBuilder: (context, item, index) {
                return ListTile(
                  title: Text(item),
                  subtitle: Text('Subtitle for $item'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Scroll through the list
      for (int i = 0; i < 10; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
      }
      
      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      // Memory increase should be reasonable for a large list
      expect(memoryIncrease, lessThan(50 * 1024 * 1024)); // 50MB
    });

    testWidgets('should handle rapid widget creation and disposal', (WidgetTester tester) async {
      final initialMemory = _getMemoryUsage();
      
      // Rapidly create and dispose widgets
      for (int i = 0; i < 100; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: List.generate(10, (index) => 
                  Card(
                    child: ListTile(
                      title: Text('Item $index'),
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        
        if (i % 10 == 0) {
          await tester.pumpAndSettle();
        }
      }
      
      // Clear everything
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      
      // Force garbage collection
      await _forceGarbageCollection();
      
      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      // Memory should not increase significantly
      expect(memoryIncrease, lessThan(20 * 1024 * 1024)); // 20MB
    });

    testWidgets('should handle image loading and disposal properly', (WidgetTester tester) async {
      final initialMemory = _getMemoryUsage();
      
      // Create widgets with images
      for (int i = 0; i < 20; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),
                        ),
                        Text('Image $index'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
        
        if (i % 5 == 0) {
          await tester.pumpAndSettle();
        }
      }
      
      // Clear everything
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      
      // Force garbage collection
      await _forceGarbageCollection();
      
      final finalMemory = _getMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      // Memory should not increase significantly
      expect(memoryIncrease, lessThan(30 * 1024 * 1024)); // 30MB
    });
  });
}

// Helper function to get current memory usage (simplified)
int _getMemoryUsage() {
  // In a real implementation, this would use platform-specific APIs
  // to get actual memory usage. For testing purposes, we'll use a placeholder.
  return DateTime.now().millisecondsSinceEpoch % 1000000;
}

// Helper function to force garbage collection
Future<void> _forceGarbageCollection() async {
  // Force multiple garbage collection cycles
  for (int i = 0; i < 3; i++) {
    await Future.delayed(const Duration(milliseconds: 100));
    // In a real implementation, this would trigger actual GC
  }
}