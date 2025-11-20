import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/utils/networking_utilities.dart';

void main() {
  group('RestfulMethods', () {
    test('GET should have correct name', () {
      expect(RestfulMethods.get.name, 'GET');
    });

    test('POST should have correct name', () {
      expect(RestfulMethods.post.name, 'POST');
    });

    test('PUT should have correct name', () {
      expect(RestfulMethods.put.name, 'PUT');
    });

    test('DELETE should have correct name', () {
      expect(RestfulMethods.delete.name, 'DELETE');
    });

    test('PATCH should have correct name', () {
      expect(RestfulMethods.patch.name, 'PATCH');
    });

    test('all enum values should exist', () {
      expect(RestfulMethods.values.length, 8);
      expect(RestfulMethods.values, contains(RestfulMethods.get));
      expect(RestfulMethods.values, contains(RestfulMethods.post));
      expect(RestfulMethods.values, contains(RestfulMethods.put));
      expect(RestfulMethods.values, contains(RestfulMethods.delete));
      expect(RestfulMethods.values, contains(RestfulMethods.patch));
      expect(RestfulMethods.values, contains(RestfulMethods.connect));
      expect(RestfulMethods.values, contains(RestfulMethods.options));
      expect(RestfulMethods.values, contains(RestfulMethods.trace));
    });
  });
}
