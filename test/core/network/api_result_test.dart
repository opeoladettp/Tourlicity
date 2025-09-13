import 'package:flutter_test/flutter_test.dart';
import 'package:tourlicity_app/core/network/api_result.dart';

void main() {
  group('ApiResult', () {
    group('ApiSuccess', () {
      test('should create success result with data', () {
        // Arrange
        const testData = 'test data';

        // Act
        const result = ApiSuccess<String>(data: testData);

        // Assert
        expect(result.data, equals(testData));
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.error, isNull);
      });

      test('should be equal when data is the same', () {
        // Arrange
        const result1 = ApiSuccess<String>(data: 'test');
        const result2 = ApiSuccess<String>(data: 'test');

        // Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal when data is different', () {
        // Arrange
        const result1 = ApiSuccess<String>(data: 'test1');
        const result2 = ApiSuccess<String>(data: 'test2');

        // Assert
        expect(result1, isNot(equals(result2)));
      });
    });

    group('ApiFailure', () {
      test('should create failure result with error details', () {
        // Arrange
        const message = 'Error occurred';
        const statusCode = 400;
        const errorCode = 'BAD_REQUEST';

        // Act
        const result = ApiFailure<String>(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );

        // Assert
        expect(result.message, equals(message));
        expect(result.statusCode, equals(statusCode));
        expect(result.errorCode, equals(errorCode));
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.data, isNull);
        expect(result.error, equals(message));
      });

      test('should create failure result with minimal data', () {
        // Arrange
        const message = 'Simple error';

        // Act
        const result = ApiFailure<String>(message: message);

        // Assert
        expect(result.message, equals(message));
        expect(result.statusCode, isNull);
        expect(result.errorCode, isNull);
      });

      test('should be equal when properties are the same', () {
        // Arrange
        const result1 = ApiFailure<String>(
          message: 'Error',
          statusCode: 400,
          errorCode: 'BAD_REQUEST',
        );
        const result2 = ApiFailure<String>(
          message: 'Error',
          statusCode: 400,
          errorCode: 'BAD_REQUEST',
        );

        // Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal when properties are different', () {
        // Arrange
        const result1 = ApiFailure<String>(message: 'Error1');
        const result2 = ApiFailure<String>(message: 'Error2');

        // Assert
        expect(result1, isNot(equals(result2)));
      });
    });

    group('fold method', () {
      test('should call onSuccess for ApiSuccess', () {
        // Arrange
        const testData = 'test data';
        const result = ApiSuccess<String>(data: testData);
        var successCalled = false;
        var failureCalled = false;

        // Act
        final foldResult = result.fold<String>(
          onSuccess: (data) {
            successCalled = true;
            return 'Success: $data';
          },
          onFailure: (error) {
            failureCalled = true;
            return 'Failure: $error';
          },
        );

        // Assert
        expect(successCalled, isTrue);
        expect(failureCalled, isFalse);
        expect(foldResult, equals('Success: $testData'));
      });

      test('should call onFailure for ApiFailure', () {
        // Arrange
        const errorMessage = 'Error occurred';
        const result = ApiFailure<String>(message: errorMessage);
        var successCalled = false;
        var failureCalled = false;

        // Act
        final foldResult = result.fold<String>(
          onSuccess: (data) {
            successCalled = true;
            return 'Success: $data';
          },
          onFailure: (error) {
            failureCalled = true;
            return 'Failure: $error';
          },
        );

        // Assert
        expect(successCalled, isFalse);
        expect(failureCalled, isTrue);
        expect(foldResult, equals('Failure: $errorMessage'));
      });
    });

    group('toString', () {
      test('should return correct string for ApiSuccess', () {
        // Arrange
        const result = ApiSuccess<String>(data: 'test');

        // Act & Assert
        expect(result.toString(), equals('ApiSuccess(data: test)'));
      });

      test('should return correct string for ApiFailure', () {
        // Arrange
        const result = ApiFailure<String>(
          message: 'Error',
          statusCode: 400,
          errorCode: 'BAD_REQUEST',
        );

        // Act & Assert
        expect(
            result.toString(),
            equals(
                'ApiFailure(message: Error, statusCode: 400, errorCode: BAD_REQUEST)'));
      });
    });
  });
}
