import 'package:dio/dio.dart' hide ResponseDecoder;
import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/core/errors/exceptions.dart';
import 'package:restful_consumer/src/core/response_decoder.dart';
import 'package:restful_consumer/src/models/no_data_model.dart';
import 'package:restful_consumer/src/models/paginated_response.dart';
import 'package:restful_consumer/src/protocol/modeling_protocol.dart';

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

// List model for testing
class UserList extends ModelingProtocol {
  final List<dynamic> users;

  const UserList(this.users);

  @override
  UserList fromJson(dynamic json) {
    return UserList(json as List<dynamic>);
  }

  @override
  List<Object?> get props => [users];
}

// Failing model for error testing
class FailingModel extends ModelingProtocol {
  @override
  FailingModel fromJson(dynamic json) {
    throw Exception('Parsing failed');
  }

  @override
  List<Object?> get props => [];
}

// Throwing model for error testing
class ThrowingModel extends ModelingProtocol {
  @override
  ThrowingModel fromJson(dynamic json) {
    throw 'String error';
  }

  @override
  List<Object?> get props => [];
}

// Empty list model
class EmptyListModel extends ModelingProtocol {
  final List<dynamic> items;

  const EmptyListModel(this.items);

  @override
  EmptyListModel fromJson(dynamic json) {
    return EmptyListModel(json as List);
  }

  @override
  List<Object?> get props => [items];
}

// Test mixin implementation
class TestDecoder with ResponseDecoder {}

void main() {
  group('GenericResponseDecoder', () {
    late TestDecoder decoder;

    setUp(() {
      decoder = TestDecoder();
    });

    group('decode with Map data', () {
      test('should decode Map response successfully', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {'name': 'John', 'age': 30},
          statusCode: 200,
        );

        final result = decoder.decode<TestUser, TestUser>(
          const TestUser(name: '', age: 0),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isRight(), true);
        final user = result.fold((l) => null, (r) => r);
        expect(user, isA<TestUser>());
        expect((user as TestUser).name, 'John');
        expect(user.age, 30);
      });

      test('should decode mocking data successfully', () {
        final result = decoder.decode<TestUser, TestUser>(
          const TestUser(name: '', age: 0),
          mockingData: {'name': 'Mock User', 'age': 25},
          mocking: true,
          paginated: false,
        );

        expect(result.isRight(), true);
        final user = result.fold((l) => null, (r) => r);
        expect(user, isA<TestUser>());
        expect((user as TestUser).name, 'Mock User');
        expect(user.age, 25);
      });
    });

    group('decode with List data', () {
      test('should decode List response successfully with custom model', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: [
            {'name': 'John', 'age': 30},
            {'name': 'Jane', 'age': 25},
          ],
          statusCode: 200,
        );

        final result = decoder.decode<UserList, UserList>(
          const UserList([]),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isRight(), true);
        final userList = result.fold((l) => null, (r) => r);
        expect(userList, isA<UserList>());
        expect((userList as UserList).users.length, 2);
      });
    });

    group('decode with pagination', () {
      test('should decode paginated response successfully', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {
            'content': [
              {'name': 'John', 'age': 30},
              {'name': 'Jane', 'age': 25},
            ],
            'currentPage': 0,
            'pageSize': 10,
            'totalElements': 2,
            'totalPages': 1,
            'isLast': true,
          },
          statusCode: 200,
        );

        final result = decoder.decode<PaginatedResponse<TestUser>, TestUser>(
          const TestUser(name: '', age: 0),
          response: response,
          mocking: false,
          paginated: true,
        );

        expect(result.isRight(), true);
        final paginatedResponse = result.fold((l) => null, (r) => r);
        expect(paginatedResponse, isA<PaginatedResponse<TestUser>>());
        expect((paginatedResponse as PaginatedResponse<TestUser>).content.length, 2);
        expect(paginatedResponse.currentPage, 0);
        expect(paginatedResponse.pageSize, 10);
        expect(paginatedResponse.totalElements, 2);
        expect(paginatedResponse.totalPages, 1);
        expect(paginatedResponse.isLast, true);
      });

      test('should decode paginated response with mocking data', () {
        final mockingData = {
          'content': [
            {'name': 'Mock User 1', 'age': 30},
            {'name': 'Mock User 2', 'age': 25},
          ],
          'currentPage': 1,
          'pageSize': 5,
          'totalElements': 10,
          'totalPages': 2,
          'isLast': false,
        };

        final result = decoder.decode<PaginatedResponse<TestUser>, TestUser>(
          const TestUser(name: '', age: 0),
          mockingData: mockingData,
          mocking: true,
          paginated: true,
        );

        expect(result.isRight(), true);
        final paginatedResponse = result.fold((l) => null, (r) => r);
        expect(paginatedResponse, isA<PaginatedResponse<TestUser>>());
        expect((paginatedResponse as PaginatedResponse<TestUser>).content.length, 2);
        expect(paginatedResponse.currentPage, 1);
        expect(paginatedResponse.pageSize, 5);
        expect(paginatedResponse.totalElements, 10);
        expect(paginatedResponse.totalPages, 2);
        expect(paginatedResponse.isLast, false);
      });

      test('should handle empty paginated response', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {
            'content': [],
            'currentPage': 0,
            'pageSize': 10,
            'totalElements': 0,
            'totalPages': 0,
            'isLast': true,
          },
          statusCode: 200,
        );

        final result = decoder.decode<PaginatedResponse<TestUser>, TestUser>(
          const TestUser(name: '', age: 0),
          response: response,
          mocking: false,
          paginated: true,
        );

        expect(result.isRight(), true);
        final paginatedResponse = result.fold((l) => null, (r) => r);
        expect(paginatedResponse, isA<PaginatedResponse<TestUser>>());
        expect((paginatedResponse as PaginatedResponse<TestUser>).content.length, 0);
        expect(paginatedResponse.totalElements, 0);
      });
    });

    group('decode with NoDataModel', () {
      test('should decode NoDataModel with success true for 200 response', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: <String, dynamic>{},
          statusCode: 200,
        );

        final result = decoder.decode<NoDataModel, NoDataModel>(
          NoDataModel.empty(),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isRight(), true);
        final model = result.fold((l) => null, (r) => r);
        expect(model, isA<NoDataModel>());
        expect((model as NoDataModel).success, true);
      });

      test('should decode NoDataModel with success false for 400 response', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: <String, dynamic>{},
          statusCode: 400,
        );

        final result = decoder.decode<NoDataModel, NoDataModel>(
          NoDataModel.empty(),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isRight(), true);
        final model = result.fold((l) => null, (r) => r);
        expect(model, isA<NoDataModel>());
        expect((model as NoDataModel).success, false);
      });

      test('should decode NoDataModel with success true when mocking', () {
        final result = decoder.decode<NoDataModel, NoDataModel>(
          NoDataModel.empty(),
          mockingData: <String, dynamic>{},
          mocking: true,
          paginated: false,
        );

        expect(result.isRight(), true);
        final model = result.fold((l) => null, (r) => r);
        expect(model, isA<NoDataModel>());
        expect((model as NoDataModel).success, true);
      });

      test('should decode NoDataModel with pagination enabled', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {
            'content': [],
            'currentPage': 0,
            'pageSize': 10,
            'totalElements': 0,
            'totalPages': 0,
            'isLast': true,
          },
          statusCode: 200,
        );

        final result = decoder.decode<PaginatedResponse<NoDataModel>, NoDataModel>(
          NoDataModel.empty(),
          response: response,
          mocking: false,
          paginated: true,
        );

        expect(result.isRight(), true);
        final paginatedResponse = result.fold((l) => null, (r) => r);
        expect(paginatedResponse, isA<PaginatedResponse<NoDataModel>>());
      });
    });

    group('decode error cases', () {
      test('should return NoDataToDecodeException when no data provided', () {
        final result = decoder.decode<TestUser, TestUser>(
          const TestUser(name: '', age: 0),
          mocking: false,
          paginated: false,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<NoDataToDecodeException>());
      });

      test('should return UnsupportedDataTypeException for unsupported data', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: 'plain string',
          statusCode: 200,
        );

        final result = decoder.decode<TestUser, TestUser>(
          const TestUser(name: '', age: 0),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<UnsupportedDataTypeException>());
      });

      test('should return UnsupportedDataTypeException for number data', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: 42,
          statusCode: 200,
        );

        final result = decoder.decode<TestUser, TestUser>(
          const TestUser(name: '', age: 0),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<UnsupportedDataTypeException>());
      });

      test('should return Exception when fromJson throws Exception', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {'name': 'John'},
          statusCode: 200,
        );

        final result = decoder.decode<FailingModel, FailingModel>(
          FailingModel(),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<Exception>());
      });

      test('should return JsonParsingException for generic error', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {'test': 'data'},
          statusCode: 200,
        );

        final result = decoder.decode<ThrowingModel, ThrowingModel>(
          ThrowingModel(),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<JsonParsingException>());
      });

      test('should handle pagination errors gracefully', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {
            'content': [
              {'name': 'John', 'age': 30},
            ],
            'currentPage': 0,
            'pageSize': 10,
            'totalElements': 1,
            'totalPages': 1,
            'isLast': true,
          },
          statusCode: 200,
        );

        final result = decoder.decode<PaginatedResponse<FailingModel>, FailingModel>(
          FailingModel(),
          response: response,
          mocking: false,
          paginated: true,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<Exception>());
      });
    });

    group('decode edge cases', () {
      test('should handle empty map', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: <String, dynamic>{},
          statusCode: 200,
        );

        final result = decoder.decode<NoDataModel, NoDataModel>(
          NoDataModel.empty(),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isRight(), true);
      });

      test('should handle empty list', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: [],
          statusCode: 200,
        );

        final result = decoder.decode<EmptyListModel, EmptyListModel>(
          const EmptyListModel([]),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isRight(), true);
      });

      test('should handle status codes in range 200-299', () {
        for (var code in [200, 201, 202, 204, 299]) {
          final response = Response(
            requestOptions: RequestOptions(path: '/test'),
            data: <String, dynamic>{},
            statusCode: code,
          );

          final result = decoder.decode<NoDataModel, NoDataModel>(
            NoDataModel.empty(),
            response: response,
            mocking: false,
            paginated: false,
          );

          expect(result.isRight(), true);
          final model = result.fold((l) => null, (r) => r);
          expect((model)?.success, true, reason: 'Status code $code should result in success=true');
        }
      });

      test('should handle status codes outside 200-299 range', () {
        for (var code in [100, 199, 300, 400, 404, 500]) {
          final response = Response(
            requestOptions: RequestOptions(path: '/test'),
            data: <String, dynamic>{},
            statusCode: code,
          );

          final result = decoder.decode<NoDataModel, NoDataModel>(
            NoDataModel.empty(),
            response: response,
            mocking: false,
            paginated: false,
          );

          expect(result.isRight(), true);
          final model = result.fold((l) => null, (r) => r);
          expect(
            (model)?.success,
            false,
            reason: 'Status code $code should result in success=false',
          );
        }
      });

      test('should handle null mockingData when mocking is true', () {
        final result = decoder.decode<TestUser, TestUser>(
          const TestUser(name: '', age: 0),
          mockingData: null,
          mocking: true,
          paginated: false,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<NoDataToDecodeException>());
      });

      test('should handle null response when mocking is false', () {
        final result = decoder.decode<TestUser, TestUser>(
          const TestUser(name: '', age: 0),
          response: null,
          mocking: false,
          paginated: false,
        );

        expect(result.isLeft(), true);
        final exception = result.fold((l) => l, (r) => null);
        expect(exception, isA<NoDataToDecodeException>());
      });
    });

    group('pattern matching coverage', () {
      test('should handle paginated=true with any model type', () {
        final response1 = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {
            'content': [
              {'name': 'Test', 'age': 25},
            ],
            'currentPage': 0,
            'pageSize': 10,
            'totalElements': 1,
            'totalPages': 1,
            'isLast': true,
          },
          statusCode: 200,
        );

        // Test with TestUser
        final result1 = decoder.decode<PaginatedResponse<TestUser>, TestUser>(
          const TestUser(name: '', age: 0),
          response: response1,
          mocking: false,
          paginated: true,
        );
        expect(result1.isRight(), true);

        // Test with NoDataModel
        final response2 = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {
            'content': [
              {'success': true},
            ],
            'currentPage': 0,
            'pageSize': 10,
            'totalElements': 1,
            'totalPages': 1,
            'isLast': true,
          },
          statusCode: 200,
        );

        final result2 = decoder.decode<PaginatedResponse<NoDataModel>, NoDataModel>(
          NoDataModel.empty(),
          response: response2,
          mocking: false,
          paginated: true,
        );
        expect(result2.isRight(), true);
      });

      test('should handle paginated=false with NoDataModel', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: <String, dynamic>{},
          statusCode: 200,
        );

        final result = decoder.decode<NoDataModel, NoDataModel>(
          NoDataModel.empty(),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isRight(), true);
        final model = result.fold((l) => null, (r) => r);
        expect(model, isA<NoDataModel>());
        expect((model as NoDataModel).success, true);
      });

      test('should handle paginated=false with non-NoDataModel', () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          data: {'name': 'John', 'age': 30},
          statusCode: 200,
        );

        final result = decoder.decode<TestUser, TestUser>(
          const TestUser(name: '', age: 0),
          response: response,
          mocking: false,
          paginated: false,
        );

        expect(result.isRight(), true);
        final user = result.fold((l) => null, (r) => r);
        expect(user, isA<TestUser>());
        expect((user as TestUser).name, 'John');
      });
    });
  });
}
