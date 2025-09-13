import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/services/connectivity_service.dart';

void main() {
  late ConnectivityService connectivityService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    connectivityService = ConnectivityService();
  });

  tearDown(() {
    connectivityService.dispose();
  });

  group('ConnectivityService', () {
    test('should initialize with default online state', () {
      // Assert
      expect(connectivityService.isOnline, isTrue);
    });

    test('should provide connectivity stream', () {
      // Act
      final stream = connectivityService.connectivityStream;

      // Assert
      expect(stream, isNotNull);
    });

    test('should check internet connection', () async {
      // Act
      final hasConnection = await connectivityService.hasInternetConnection();

      // Assert
      expect(hasConnection, isA<bool>());
    });

    test('should handle connectivity initialization', () async {
      // Act & Assert - should not throw
      expect(
        () async => await connectivityService.initialize(),
        returnsNormally,
      );
    });

    test('should dispose properly', () {
      // Act & Assert - should not throw
      expect(
        () => connectivityService.dispose(),
        returnsNormally,
      );
    });
  });
}