import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/core/errors/exceptions.dart';

void main() {
  group('RestfulConsumerException hierarchy', () {
    test('all exceptions should be DioException', () {
      final noDataException = NoDataToDecodeException(StackTrace.current);
      final unsupportedException = UnsupportedDataTypeException('data', StackTrace.current);
      final jsonException = JsonParsingException('error', StackTrace.current);
      final dioException = DioRequestException(
        DioExceptionType.connectionError,
        'error',
        StackTrace.current,
      );

      expect(noDataException, isA<DioException>());
      expect(unsupportedException, isA<DioException>());
      expect(jsonException, isA<DioException>());
      expect(dioException, isA<DioException>());
    });

    test('all exceptions should be RestfulConsumerException', () {
      final noDataException = NoDataToDecodeException(StackTrace.current);
      final unsupportedException = UnsupportedDataTypeException('data', StackTrace.current);
      final jsonException = JsonParsingException('error', StackTrace.current);
      final dioException = DioRequestException(
        DioExceptionType.connectionError,
        'error',
        StackTrace.current,
      );

      expect(noDataException, isA<RestfulConsumerException>());
      expect(unsupportedException, isA<RestfulConsumerException>());
      expect(jsonException, isA<RestfulConsumerException>());
      expect(dioException, isA<RestfulConsumerException>());
    });
  });

  group('NoDataToDecodeException', () {
    test('should be a RestfulConsumerException', () {
      final exception = NoDataToDecodeException(StackTrace.current);
      expect(exception, isA<RestfulConsumerException>());
    });

    test('should have correct properties', () {
      final stackTrace = StackTrace.current;
      final exception = NoDataToDecodeException(stackTrace);

      expect(exception.stackTrace, stackTrace);
      expect(exception.type, DioExceptionType.badResponse);
      expect(
        exception.message,
        'You should provide either some mocking data or a real response to be treated',
      );
      expect(exception.requestOptions.path, '');
    });

    test('should create instance without error', () {
      expect(() => NoDataToDecodeException(StackTrace.current), returnsNormally);
    });
  });

  group('UnsupportedDataTypeException', () {
    test('should be a RestfulConsumerException', () {
      final exception = UnsupportedDataTypeException('test data', StackTrace.current);
      expect(exception, isA<RestfulConsumerException>());
    });

    test('should have correct properties', () {
      final data = 'test data';
      final stackTrace = StackTrace.current;
      final exception = UnsupportedDataTypeException(data, stackTrace);

      expect(exception.stackTrace, stackTrace);
      expect(exception.type, DioExceptionType.badResponse);
      expect(exception.message, 'Unsupported data $data type encountered during decoding.');
      expect(exception.requestOptions.path, '');
    });

    test('should handle different data types', () {
      final stringData = 'string data';
      final intData = 42;
      final objectData = {'key': 'value'};

      final exception1 = UnsupportedDataTypeException(stringData, StackTrace.current);
      final exception2 = UnsupportedDataTypeException(intData, StackTrace.current);
      final exception3 = UnsupportedDataTypeException(objectData, StackTrace.current);

      expect(exception1.message, contains('string data'));
      expect(exception2.message, contains('42'));
      expect(exception3.message, contains('{key: value}'));
    });

    test('should create instance without error', () {
      expect(() => UnsupportedDataTypeException('test', StackTrace.current), returnsNormally);
    });
  });

  group('JsonParsingException', () {
    test('should be a RestfulConsumerException', () {
      final exception = JsonParsingException('error', StackTrace.current);
      expect(exception, isA<RestfulConsumerException>());
    });

    test('should have correct properties', () {
      final error = 'JSON parsing failed';
      final stackTrace = StackTrace.current;
      final exception = JsonParsingException(error, stackTrace);

      expect(exception.error, error);
      expect(exception.stackTrace, stackTrace);
      expect(exception.type, DioExceptionType.unknown);
      expect(exception.message, 'An error has Occured during JSON parsing process');
      expect(exception.requestOptions.path, '');
    });

    test('should handle different error types', () {
      final exception1 = JsonParsingException('String error', StackTrace.current);
      final exception2 = JsonParsingException(Exception('Exception error'), StackTrace.current);
      final exception3 = JsonParsingException(42, StackTrace.current);

      expect(exception1.error, 'String error');
      expect(exception2.error, isA<Exception>());
      expect(exception3.error, 42);
    });

    test('should create instance without error', () {
      expect(() => JsonParsingException('test', StackTrace.current), returnsNormally);
    });
  });

  group('DioRequestException', () {
    test('should be a RestfulConsumerException', () {
      final exception = DioRequestException(
        DioExceptionType.connectionError,
        'error',
        StackTrace.current,
      );
      expect(exception, isA<RestfulConsumerException>());
    });

    test('should have correct properties', () {
      final error = 'Request failed';
      final stackTrace = StackTrace.current;
      final type = DioExceptionType.connectionError;
      final exception = DioRequestException(type, error, stackTrace);

      expect(exception.error, error);
      expect(exception.stackTrace, stackTrace);
      expect(exception.type, type);
      expect(exception.message, 'An error has Occured during Dio request process');
      expect(exception.requestOptions.path, '');
    });

    test('should handle null type with default', () {
      final exception = DioRequestException(null, 'error', StackTrace.current);
      expect(exception.type, DioExceptionType.connectionError);
    });

    test('should handle different error types', () {
      final exception1 = DioRequestException(
        DioExceptionType.connectionError,
        'String error',
        StackTrace.current,
      );
      final exception2 = DioRequestException(
        DioExceptionType.connectionError,
        Exception('Network error'),
        StackTrace.current,
      );
      final exception3 = DioRequestException(
        DioExceptionType.connectionError,
        404,
        StackTrace.current,
      );

      expect(exception1.error, 'String error');
      expect(exception2.error, isA<Exception>());
      expect(exception3.error, 404);
    });

    test('should handle different DioExceptionType', () {
      final connectionError = DioRequestException(
        DioExceptionType.connectionError,
        'Connection failed',
        StackTrace.current,
      );
      final timeoutError = DioRequestException(
        DioExceptionType.connectionTimeout,
        'Timeout',
        StackTrace.current,
      );
      final responseError = DioRequestException(
        DioExceptionType.badResponse,
        'Bad response',
        StackTrace.current,
      );

      expect(connectionError.type, DioExceptionType.connectionError);
      expect(timeoutError.type, DioExceptionType.connectionTimeout);
      expect(responseError.type, DioExceptionType.badResponse);
    });

    test('should create instance without error', () {
      expect(
        () => DioRequestException(DioExceptionType.connectionError, 'test', StackTrace.current),
        returnsNormally,
      );
    });
  });
}
