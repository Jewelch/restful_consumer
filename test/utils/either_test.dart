import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/utils/either.dart';

void main() {
  group('Either', () {
    test('Left should hold a value', () {
      final left = Either.left('Error');
      expect(left.isLeft(), true);
      expect(left.isRight(), false);
      expect(left.fold((l) => l, (r) => r), 'Error');
    });

    test('Right should hold a value', () {
      final right = Either.right(42);
      expect(right.isRight(), true);
      expect(right.isLeft(), false);
      expect(right.fold((l) => l, (r) => r), 42);
    });

    test('Left should return value using value getter', () {
      final left = Left<String, int>('Error');
      expect(left.value, 'Error');
    });

    test('Right should return value using value getter', () {
      final right = Right<String, int>(42);
      expect(right.value, 42);
    });

    test('getOrElse should return right value when Right', () {
      final right = Either<String, int>.right(42);
      expect(right.getOrNull(), 42);
    });

    test('getOrElse should return default value when Left', () {
      final left = Either<String, int>.left('Error');
      expect(left.getOrNull(), null);
    });

    test('fold should handle Left with left function', () {
      final left = Either<String, int>.left('Error');
      final result = left.fold((l) => 'Left: $l', (r) => 'Right: $r');
      expect(result, 'Left: Error');
    });

    test('fold should handle Right with right function', () {
      final right = Either<String, int>.right(42);
      final result = right.fold((l) => 'Left: $l', (r) => 'Right: $r');
      expect(result, 'Right: 42');
    });

    test('EitherFutureExt getOrNull should return value for Right', () async {
      final future = Future.value(Either<String, int>.right(42));
      final result = await future.getOrNull;
      expect(result, 42);
    });

    test('EitherFutureExt getOrNull should return null for Left', () async {
      final future = Future.value(Either<String, int>.left('Error'));
      final result = await future.getOrNull;
      expect(result, null);
    });
  });
}
