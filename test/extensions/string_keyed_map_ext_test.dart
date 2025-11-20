import 'dart:io' show HttpHeaders;

import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/extensions/internal/string_keyed_map_ext.dart';

void main() {
  group('HeadersInjections', () {
    test('setupContentType should add content-type header', () {
      final map = <String, dynamic>{};
      final result = map.setupContentType('application/json');

      expect(result[HttpHeaders.contentTypeHeader], 'application/json');
    });

    test('setupContentType should overwrite existing content-type', () {
      final map = <String, dynamic>{HttpHeaders.contentTypeHeader: 'text/plain'};
      final result = map.setupContentType('application/json');

      expect(result[HttpHeaders.contentTypeHeader], 'application/json');
    });

    test('setupContentType should preserve other headers', () {
      final map = <String, dynamic>{'Authorization': 'Bearer token'};
      final result = map.setupContentType('application/json');

      expect(result[HttpHeaders.contentTypeHeader], 'application/json');
      expect(result['Authorization'], 'Bearer token');
    });

    test('setupAcceptedResponseTypeTo should add accept header', () {
      final map = <String, dynamic>{};
      final result = map.setupAcceptedResponseTypeTo('json');

      expect(result[HttpHeaders.acceptHeader], 'application/json');
    });

    test('setupAcceptedResponseTypeTo should add accept header with xml', () {
      final map = <String, dynamic>{};
      final result = map.setupAcceptedResponseTypeTo('xml');

      expect(result[HttpHeaders.acceptHeader], 'application/xml');
    });

    test('setupAcceptedResponseTypeTo should overwrite existing accept header', () {
      final map = <String, dynamic>{HttpHeaders.acceptHeader: 'application/xml'};
      final result = map.setupAcceptedResponseTypeTo('json');

      expect(result[HttpHeaders.acceptHeader], 'application/json');
    });

    test('setupAcceptedResponseTypeTo should preserve other headers', () {
      final map = <String, dynamic>{'Authorization': 'Bearer token'};
      final result = map.setupAcceptedResponseTypeTo('json');

      expect(result[HttpHeaders.acceptHeader], 'application/json');
      expect(result['Authorization'], 'Bearer token');
    });

    test('chaining both extensions should work', () {
      final map = <String, dynamic>{};
      final result = map.setupContentType('application/json').setupAcceptedResponseTypeTo('json');

      expect(result[HttpHeaders.contentTypeHeader], 'application/json');
      expect(result[HttpHeaders.acceptHeader], 'application/json');
    });
  });
}
