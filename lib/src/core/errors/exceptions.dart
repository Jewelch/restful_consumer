import 'package:dio/dio.dart' show DioException, RequestOptions, DioExceptionType;

sealed class RestfulConsumerException extends DioException {
  RestfulConsumerException({
    super.error,
    super.stackTrace,
    required super.requestOptions,
    super.type,
    super.message,
  });
}

class NoDataToDecodeException extends RestfulConsumerException {
  NoDataToDecodeException(StackTrace stackTrace)
    : super(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        stackTrace: stackTrace,
        message: 'You should provide either some mocking data or a real response to be treated',
      );
}

class UnsupportedDataTypeException extends RestfulConsumerException {
  UnsupportedDataTypeException(dynamic data, StackTrace stackTrace)
    : super(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        stackTrace: stackTrace,
        message: 'Unsupported data $data type encountered during decoding.',
      );
}

class JsonParsingException extends RestfulConsumerException {
  JsonParsingException(dynamic e, StackTrace stackTrace)
    : super(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.unknown,
        error: e,
        stackTrace: stackTrace,
        message: 'An error has Occured during JSON parsing process',
      );
}

class DioRequestException extends RestfulConsumerException {
  DioRequestException(DioExceptionType? type, dynamic e, StackTrace stackTrace)
    : super(
        requestOptions: RequestOptions(path: ''),
        type: type ?? DioExceptionType.connectionError,
        error: e,
        stackTrace: stackTrace,
        message: 'An error has Occured during Dio request process',
      );
}
