import 'package:dio/dio.dart' hide ResponseDecoder;
import 'package:dio_logger_plus/dio_logger_plus.dart';
import 'package:flutter/foundation.dart';

import '../extensions/internal/iterable_ext.dart';
import '../protocol/modeling_protocol.dart';
import '../utils/index.dart';
import 'errors/exceptions.dart';
import 'response_decoder.dart';

class RequestPerformer with ResponseDecoder {
  final Dio dio;

  RequestPerformer(this.dio);

  @visibleForTesting
  RequestPerformer.mockWith(this.dio);

  static final Map<String, dynamic> _headers = {};

  static final _backgroundTransformer = BackgroundTransformer();

  static DioLogger? _coloredLogger;

  static void configure(
    BaseOptions baseOptions, {
    Map<String, dynamic> headers = const {},
    QueuedInterceptorsWrapper? interceptor,
    bool debuggingEnabled = false,
    bool debugRequestHeaders = false,
    bool debugRequestBody = false,
    bool debugResponseBody = false,
    bool debugError = false,
    bool debugCompact = false,
    bool mockingEnabled = false,
    final int mockingDurationInMs = 500,
  }) {
    _coloredLogger = DioLogger(
      request: debugRequestHeaders,
      requestHeader: debugRequestHeaders,
      requestBody: debugRequestBody,
      responseBody: debugResponseBody,
      error: debugError,
      compact: debugCompact,
      maxWidth: 90,
      isOnlyDebug: true,
    );

    _baseOptions = baseOptions;
    _interceptor = interceptor;
    _debuggingEnabled = debuggingEnabled;
    _mockingEnabled = mockingEnabled;
    _mockingDuration = mockingDurationInMs;
    _headers.addAll(headers);
  }

  static late BaseOptions _baseOptions;
  static late QueuedInterceptorsWrapper? _interceptor;
  static bool _debuggingEnabled = false;
  static bool _mockingEnabled = false;
  static int _mockingDuration = 500;

  Future<Either<Exception, R>> performDecodingRequest<R, MP extends ModelingProtocol>({
    final bool disableInterception = false,
    required MP decodableModel,
    final bool paginated = false,
    final bool mockIt = false,
    final bool debugIt = false,
    final bool simulateFailure = false,
    required RestfulMethods method,
    String? baseUrl,
    required String path,
    final dynamic body,
    final Options? options,
    final String contentType = Headers.jsonContentType,
    final StringKeyedMap? extraHeaders,
    final StringKeyedMap? queryParameters,
    final CancelToken? cancelToken,
    final ProgressCallback? onSendProgress,
    final ProgressCallback? onReceiveProgress,
    final dynamic mockingData,
  }) async {
    if (simulateFailure) {
      return Future.delayed(
        Duration(milliseconds: _mockingDuration),
      ).then((_) => Left(Exception('Simulated failure')));
    }

    //! Dio definition
    dio.options = _baseOptions.copyWith(
      baseUrl: baseUrl ?? _baseOptions.baseUrl,
      contentType: contentType,
      headers: _headers..addAll(extraHeaders ?? {}),
    );

    //! Interceptor setup
    dio.interceptors
      ..clear()
      ..addBasedOnCondition(condition: !disableInterception, _interceptor)
      ..addBasedOnCondition(condition: _debuggingEnabled || debugIt, _coloredLogger);

    //! Background transformer setup
    dio.transformer = _backgroundTransformer;

    //! Mocking setup
    if (_mockingEnabled || mockIt) {
      return Future.delayed(Duration(milliseconds: _mockingDuration)).then(
        (_) => (decode<R, MP>(
          decodableModel,
          mockingData: mockingData,
          mocking: true,
          paginated: paginated,
        )).fold((e) => Left(e), (r) => Right(r)),
      );
    }

    //! Request execution
    final Response response;
    try {
      response = await dio.request(
        path,
        data: body,
        queryParameters: queryParameters,
        options: DioMixin.checkOptions(method.name, options),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e, s) {
      // Only catches Dio request errors
      return Left(DioRequestException((e as DioException?)?.type, e, s));
    }

    // Decode the response (already returns Either with its own error handling)
    return decode<R, MP>(
      decodableModel,
      response: response,
      mocking: false,
      paginated: paginated,
    ).fold((e) => Left(e), (r) => Right(r));
  }
}
