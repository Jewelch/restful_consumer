import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/extensions/internal/iterable_ext.dart';

void main() {
  group('ListExt', () {
    test('addBasedOnCondition should add element when condition is true', () {
      final list = <int>[];
      list.addBasedOnCondition(1, condition: true);
      expect(list, [1]);
    });

    test('addBasedOnCondition should not add element when condition is false', () {
      final list = <int>[];
      list.addBasedOnCondition(2, condition: false);
      expect(list, isEmpty);
    });

    test('addBasedOnCondition should not add element when element is null', () {
      final list = <int?>[];
      list.addBasedOnCondition(null, condition: true);
      expect(list, isEmpty);
    });

    test('addBasedOnCondition should not add when both condition false and element null', () {
      final list = <String?>[];
      list.addBasedOnCondition(null, condition: false);
      expect(list, isEmpty);
    });

    test('addBasedOnCondition should work with strings', () {
      final list = <String>[];
      list.addBasedOnCondition('test', condition: true);
      expect(list, ['test']);
      list.addBasedOnCondition('ignored', condition: false);
      expect(list, ['test']);
    });

    test('addBasedOnCondition should work with complex objects', () {
      final list = <Map<String, int>>[];
      list.addBasedOnCondition({'key': 1}, condition: true);
      expect(list, [
        {'key': 1},
      ]);
    });
  });
}
