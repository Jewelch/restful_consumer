import 'package:dio/dio.dart' show DioException, RequestOptions, DioExceptionType;

sealed class RestfulConsumerException extends DioException {
  RestfulConsumerException({super.error, super.stackTrace, super.type, super.message})
    : super(requestOptions: RequestOptions(path: ''));
}

class NoDataToDecodeException extends RestfulConsumerException {
  NoDataToDecodeException(StackTrace stackTrace)
    : super(
        type: DioExceptionType.badResponse,
        stackTrace: stackTrace,
        message: 'You should provide either some mocking data or a real response to be treated',
      );
}

class UnsupportedDataTypeException extends RestfulConsumerException {
  UnsupportedDataTypeException(dynamic data, StackTrace stackTrace)
    : super(
        type: DioExceptionType.badResponse,
        stackTrace: stackTrace,
        message: 'Unsupported data $data type encountered during decoding.',
      );
}

class JsonParsingException extends RestfulConsumerException {
  JsonParsingException(dynamic e, StackTrace stackTrace)
    : super(
        type: DioExceptionType.unknown,
        error: e,
        stackTrace: stackTrace,
        message: 'An error has Occured during JSON parsing process',
      );
}

class DioRequestException extends RestfulConsumerException {
  DioRequestException(DioExceptionType? type, dynamic e, StackTrace stackTrace)
    : super(
        type: type ?? DioExceptionType.connectionError,
        error: e,
        stackTrace: stackTrace,
        message: 'An error has Occured during Dio request process',
      );
}

class CacheException implements Exception {}
