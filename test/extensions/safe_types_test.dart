import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/restful_consumer.dart';

void main() {
  group('SafeInt', () {
    test('should return the value when not null', () {
      const int value = 42;
      expect(value.safe, 42);
    });

    test('should return 0 when null', () {
      const int? value = null;
      expect(value.safe, 0);
    });
  });

  group('SafeString', () {
    test('should return the value when not null', () {
      const String value = 'Hello';
      expect(value.safe, 'Hello');
    });

    test('should return empty string when null', () {
      const String? value = null;
      expect(value.safe, '');
    });
  });

  group('SafeBool', () {
    test('should return the value when not null and true', () {
      const bool value = true;
      expect(value.safe, true);
    });

    test('should return the value when not null and false', () {
      const bool value = false;
      expect(value.safe, false);
    });

    test('should return false when null', () {
      const bool? value = null;
      expect(value.safe, false);
    });
  });

  group('SafeDouble', () {
    test('should return the value when not null', () {
      const double value = 3.14;
      expect(value.safe, 3.14);
    });

    test('should return 0 when null', () {
      const double? value = null;
      expect(value.safe, 0);
    });
  });

  group('SafeDateTime', () {
    test('should return the value when not null', () {
      final DateTime now = DateTime(2025, 10, 6);
      final DateTime value = now;
      expect(value.safe, now);
    });

    test('should return current DateTime when null', () {
      const DateTime? value = null;
      final result = value.safe;
      expect(result, isA<DateTime>());
      // We can't test exact equality since DateTime.now() changes,
      // but we can verify it's a valid DateTime
      expect(result.year, greaterThanOrEqualTo(2025));
    });
  });

  group('SafeNum', () {
    test('should return the int value when not null', () {
      const num value = 42;
      expect(value.safe, 42);
    });

    test('should return the double value when not null', () {
      const num value = 3.14;
      expect(value.safe, 3.14);
    });

    test('should return 0 when null', () {
      const num? value = null;
      expect(value.safe, 0);
    });
  });

  group('SafeList', () {
    test('should return the list when not null', () {
      final List<int> value = [1, 2, 3];
      expect(value.safe, [1, 2, 3]);
    });

    test('should return empty list when null', () {
      const List<int>? value = null;
      expect(value.safe, <int>[]);
    });

    test('should work with different types', () {
      final List<String> stringList = ['a', 'b', 'c'];
      expect(stringList.safe, ['a', 'b', 'c']);

      const List<String>? nullStringList = null;
      expect(nullStringList.safe, <String>[]);
    });

    test('should preserve list type when null', () {
      const List<double>? value = null;
      final result = value.safe;
      expect(result, isA<List<double>>());
      expect(result, isEmpty);
    });
  });

  group('SafeMap', () {
    test('should return the map when not null', () {
      final Map<String, int> value = {'a': 1, 'b': 2, 'c': 3};
      expect(value.safe, {'a': 1, 'b': 2, 'c': 3});
    });

    test('should return empty map when null', () {
      const Map<String, int>? value = null;
      expect(value.safe, <String, int>{});
    });

    test('should work with different key-value types', () {
      final Map<int, String> intStringMap = {1: 'one', 2: 'two'};
      expect(intStringMap.safe, {1: 'one', 2: 'two'});

      const Map<int, String>? nullIntStringMap = null;
      expect(nullIntStringMap.safe, <int, String>{});
    });

    test('should preserve map type when null', () {
      const Map<String, double>? value = null;
      final result = value.safe;
      expect(result, isA<Map<String, double>>());
      expect(result, isEmpty);
    });

    test('should work with complex types', () {
      final Map<String, List<int>> complexMap = {
        'numbers': [1, 2, 3],
        'more': [4, 5],
      };
      expect(complexMap.safe, {
        'numbers': [1, 2, 3],
        'more': [4, 5],
      });

      const Map<String, List<int>>? nullComplexMap = null;
      expect(nullComplexMap.safe, <String, List<int>>{});
    });
  });
}
