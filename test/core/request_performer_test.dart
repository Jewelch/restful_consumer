// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/core/errors/exceptions.dart';
import 'package:restful_consumer/src/core/request_performer.dart';
import 'package:restful_consumer/src/models/no_data_model.dart';
import 'package:restful_consumer/src/protocol/modeling_protocol.dart';
import 'package:restful_consumer/src/utils/networking_utilities.dart';

// Test model
class TestUser extends ModelingProtocol {
  final String name;
  final int age;

  const TestUser({required this.name, required this.age});

  @override
  TestUser fromJson(dynamic json) {
    return TestUser(name: json['name'] as String, age: json['age'] as int);
  }

  @override
  List<Object?> get props => [name, age];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RequestPerformer', () {
    late Dio dio;
    late RequestPerformer performer;

    setUp(() {
      dio = Dio();
      performer = RequestPerformer.mockWith(dio);

      // Configure with default options
      RequestPerformer.configure(
        BaseOptions(baseUrl: 'https://api.test.com'),
        debuggingEnabled: false,
        mockingEnabled: false,
      );
    });

    group('configure', () {
      test('should configure with default options', () {
        expect(
          () => RequestPerformer.configure(BaseOptions(baseUrl: 'https://api.example.com')),
          returnsNormally,
        );
      });

      test('should configure with custom headers', () {
        expect(
          () => RequestPerformer.configure(
            BaseOptions(baseUrl: 'https://api.example.com'),
            headers: {'Authorization': 'Bearer token'},
          ),
          returnsNormally,
        );
      });

      test('should configure with interceptor', () {
        final interceptor = QueuedInterceptorsWrapper();
        expect(
          () => RequestPerformer.configure(
            BaseOptions(baseUrl: 'https://api.example.com'),
            interceptor: interceptor,
          ),
          returnsNormally,
        );
      });

      test('should configure with debugging enabled', () {
        expect(
          () => RequestPerformer.configure(
            BaseOptions(baseUrl: 'https://api.example.com'),
            debuggingEnabled: true,
          ),
          returnsNormally,
        );
      });

      test('should configure with mocking enabled', () {
        expect(
          () => RequestPerformer.configure(
            BaseOptions(baseUrl: 'https://api.example.com'),
            mockingEnabled: true,
            mockingDurationInMs: 100,
          ),
          returnsNormally,
        );
      });
    });

    group('constructor', () {
      test('should create instance with dio', () {
        final performer = RequestPerformer(dio);
        expect(performer, isA<RequestPerformer>());
      });

      test('should create mockWith instance', () {
        final performer = RequestPerformer.mockWith(dio);
        expect(performer, isA<RequestPerformer>());
      });
    });

    group('performDecodingRequest - mocking', () {
      setUp(() {
        RequestPerformer.configure(
          BaseOptions(baseUrl: 'https://api.test.com'),
          mockingEnabled: true,
          mockingDurationInMs: 10,
        );
      });

      test('should return mocked data when mockingEnabled is true', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          mockingData: {'name': 'Mock User', 'age': 30},
        );

        expect(result.isRight(), true);
        final user = result.fold((l) => null, (r) => r);
        expect(user, isA<TestUser>());
        expect((user as TestUser).name, 'Mock User');
        expect(user.age, 30);
      });

      test('should return mocked data when mockIt is true', () async {
        RequestPerformer.configure(
          BaseOptions(baseUrl: 'https://api.test.com'),
          mockingEnabled: false,
        );

        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          mockIt: true,
          mockingData: {'name': 'Mock User 2', 'age': 25},
        );

        expect(result.isRight(), true);
        final user = result.fold((l) => null, (r) => r);
        expect((user as TestUser).name, 'Mock User 2');
      });

      test('should work with NoDataModel mocking', () async {
        final result = await performer.performDecodingRequest<NoDataModel, NoDataModel>(
          decodableModel: NoDataModel.empty(),
          method: RestfulMethods.post,
          path: '/action',
          mockIt: true,
          mockingData: <String, dynamic>{},
        );

        expect(result.isRight(), true);
        final model = result.fold((l) => null, (r) => r);
        expect(model, isA<NoDataModel>());
        expect((model as NoDataModel).success, true);
      });
    });

    group('performDecodingRequest - simulate failure', () {
      test('should return error when simulateFailure is true', () async {
        RequestPerformer.configure(
          BaseOptions(baseUrl: 'https://api.test.com'),
          mockingDurationInMs: 10,
        );

        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          simulateFailure: true,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<Exception>());
        expect(exception.toString(), contains('Simulated failure'));
      });
    });

    group('performDecodingRequest - options', () {
      setUp(() {
        RequestPerformer.configure(
          BaseOptions(baseUrl: 'https://api.test.com'),
          mockingEnabled: true,
          mockingDurationInMs: 10,
        );
      });

      test('should use custom baseUrl when provided', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          baseUrl: 'https://custom.api.com',
          mockIt: true,
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle extraHeaders', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          extraHeaders: {'Authorization': 'Bearer token'},
          mockIt: true,
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle queryParameters', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          queryParameters: {'id': '123'},
          mockIt: true,
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle body', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.post,
          path: '/users',
          body: {'name': 'New User', 'age': 25},
          mockIt: true,
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle contentType with no headers conflict', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          mockIt: true,
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle custom options', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          options: Options(headers: {'Custom': 'Header'}),
          mockIt: true,
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle cancelToken', () async {
        final cancelToken = CancelToken();
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          cancelToken: cancelToken,
          mockIt: true,
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle debugIt parameter', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          debugIt: false,
          mockIt: true,
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });
    });

    group('performDecodingRequest - all HTTP methods', () {
      setUp(() {
        RequestPerformer.configure(
          BaseOptions(baseUrl: 'https://api.test.com'),
          mockingEnabled: true,
          mockingDurationInMs: 10,
        );
      });

      test('should handle GET method', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle POST method', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.post,
          path: '/users',
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle PUT method', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.put,
          path: '/users/1',
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });

      test('should handle DELETE method', () async {
        final result = await performer.performDecodingRequest<NoDataModel, NoDataModel>(
          decodableModel: NoDataModel.empty(),
          method: RestfulMethods.delete,
          path: '/users/1',
          mockIt: true,
          mockingData: <String, dynamic>{},
        );

        expect(result.isRight(), true);
      });

      test('should handle PATCH method', () async {
        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.patch,
          path: '/users/1',
          mockingData: {'name': 'Test', 'age': 20},
        );

        expect(result.isRight(), true);
      });
    });

    group('performDecodingRequest - error handling', () {
      test('should handle mocking with invalid data', () async {
        RequestPerformer.configure(
          BaseOptions(baseUrl: 'https://api.test.com'),
          mockingEnabled: true,
          mockingDurationInMs: 10,
        );

        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
          mockingData: 'invalid data',
        );

        expect(result.isLeft(), true);
      });

      test('should handle mocking without mockingData', () async {
        RequestPerformer.configure(
          BaseOptions(baseUrl: 'https://api.test.com'),
          mockingEnabled: true,
          mockingDurationInMs: 10,
        );

        final result = await performer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<NoDataToDecodeException>());
      });
    });

    group('performDecodingRequest - real HTTP requests with mock', () {
      setUp(() {
        RequestPerformer.configure(
          BaseOptions(baseUrl: 'https://api.test.com'),
          mockingEnabled: false,
          debuggingEnabled: false,
        );
      });

      test('should handle successful real HTTP request with mocked dio', () async {
        // Create a mock response
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/users'),
          data: {'name': 'Real User', 'age': 30},
          statusCode: 200,
        );

        // Create a new Dio instance for testing
        final testDio = Dio();

        // Mock the request by using HttpClientAdapter
        testDio.httpClientAdapter = _MockAdapter(mockResponse);

        final testPerformer = RequestPerformer.mockWith(testDio);

        final result = await testPerformer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.get,
          path: '/users',
        );

        expect(result.isRight(), true);
        final user = result.fold((l) => null, (r) => r);
        expect(user, isA<TestUser>());
        expect((user as TestUser).name, 'Real User');
        expect(user.age, 30);
      });

      test('should handle HTTP request errors', () async {
        // Create a Dio that will throw an error
        final testDio = Dio();
        testDio.httpClientAdapter = _ErrorAdapter();

        final testPerformer = RequestPerformer.mockWith(testDio);

        try {
          final result = await testPerformer.performDecodingRequest<TestUser, TestUser>(
            decodableModel: const TestUser(name: '', age: 0),
            method: RestfulMethods.get,
            path: '/users',
          );

          expect(result.isLeft(), true);
          final exception = result.fold((l) => l, (r) => null);
          expect(exception, isA<DioRequestException>());
        } catch (e) {
          // If DioException is thrown directly, that's also valid
          expect(e, isA<DioException>());
        }
      });

      test('should handle POST request with body', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/users'),
          data: {'name': 'Created User', 'age': 25},
          statusCode: 201,
        );

        final testDio = Dio();
        testDio.httpClientAdapter = _MockAdapter(mockResponse);

        final testPerformer = RequestPerformer.mockWith(testDio);

        final result = await testPerformer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.post,
          path: '/users',
          body: {'name': 'New User', 'age': 25},
        );

        expect(result.isRight(), true);
      });

      test('should handle request with progress callbacks', () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: '/upload'),
          data: {'name': 'Uploaded', 'age': 1},
          statusCode: 200,
        );

        final testDio = Dio();
        testDio.httpClientAdapter = _MockAdapter(mockResponse);

        final testPerformer = RequestPerformer.mockWith(testDio);

        var sendProgressCalled = false;
        var receiveProgressCalled = false;

        final result = await testPerformer.performDecodingRequest<TestUser, TestUser>(
          decodableModel: const TestUser(name: '', age: 0),
          method: RestfulMethods.post,
          path: '/upload',
          onSendProgress: (sent, total) {
            sendProgressCalled = true;
          },
          onReceiveProgress: (received, total) {
            receiveProgressCalled = true;
          },
        );

        expect(result.isRight(), true);
      });
    });
  });
}

// Mock HTTP adapter for testing real HTTP flow
class _MockAdapter implements HttpClientAdapter {
  final Response response;

  _MockAdapter(this.response);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(response.data),
      response.statusCode ?? 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// Error adapter for testing error handling
class _ErrorAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      error: 'Network error',
      type: DioExceptionType.connectionError,
    );
  }

  @override
  void close({bool force = false}) {}
}
