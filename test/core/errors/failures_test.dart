import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('should be a subclass of Failure', () {
      const failure = ServerFailure(message: 'Server error');
      expect(failure, isA<Failure>());
    });

    test('should contain message', () {
      const failure = ServerFailure(message: 'Server error');
      expect(failure.message, 'Server error');
    });

    test('should be equal when messages are the same', () {
      const failure1 = ServerFailure(message: 'Server error');
      const failure2 = ServerFailure(message: 'Server error');

      expect(failure1, equals(failure2));
    });

    test('should not be equal when messages are different', () {
      const failure1 = ServerFailure(message: 'Server error 1');
      const failure2 = ServerFailure(message: 'Server error 2');

      expect(failure1, isNot(equals(failure2)));
    });

    test('props should contain message', () {
      const failure = ServerFailure(message: 'Server error');
      expect(failure.props, ['Server error']);
    });
  });

  group('CacheFailure', () {
    test('should be a subclass of Failure', () {
      const failure = CacheFailure(message: 'Cache error');
      expect(failure, isA<Failure>());
    });

    test('should contain message', () {
      const failure = CacheFailure(message: 'Cache error');
      expect(failure.message, 'Cache error');
    });

    test('should be equal when messages are the same', () {
      const failure1 = CacheFailure(message: 'Cache error');
      const failure2 = CacheFailure(message: 'Cache error');

      expect(failure1, equals(failure2));
    });

    test('should not be equal when messages are different', () {
      const failure1 = CacheFailure(message: 'Cache error 1');
      const failure2 = CacheFailure(message: 'Cache error 2');

      expect(failure1, isNot(equals(failure2)));
    });

    test('props should contain message', () {
      const failure = CacheFailure(message: 'Cache error');
      expect(failure.props, ['Cache error']);
    });
  });

  group('Failure equality', () {
    test('ServerFailure and CacheFailure should not be equal even with same message', () {
      const serverFailure = ServerFailure(message: 'Error');
      const cacheFailure = CacheFailure(message: 'Error');

      expect(serverFailure, isNot(equals(cacheFailure)));
    });
  });
}
