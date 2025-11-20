import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/core/errors/exceptions.dart';
import 'package:restful_consumer/src/extensions/external/page_folder.dart';
import 'package:restful_consumer/src/models/paginated_response.dart';
import 'package:restful_consumer/src/protocol/modeling_protocol.dart';
import 'package:restful_consumer/src/utils/either.dart';

// Test model for pagination
class TestUser extends ModelingProtocol {
  final String name;
  final int age;

  const TestUser({required this.name, required this.age});

  @override
  TestUser fromJson(dynamic json) {
    return TestUser(name: json['name'] as String, age: json['age'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {'name': name, 'age': age};

  @override
  List<Object?> get props => [name, age];
}

void main() {
  group('PaginatedResponseFutureExtension', () {
    group('foldPaginated', () {
      test('should extract content from successful paginated response', () async {
        final paginatedResponse = PaginatedResponse<TestUser>(
          content: [
            const TestUser(name: 'John', age: 30),
            const TestUser(name: 'Jane', age: 25),
          ],
          currentPage: 0,
          pageSize: 10,
          totalElements: 2,
          totalPages: 1,
          isLast: true,
        );

        final Future<Either<Exception, PaginatedResponse<TestUser>>> future = Future.value(
          Right(paginatedResponse),
        );
        final result = await future.foldPaginated();

        expect(result.isRight(), true);
        final users = result.fold((l) => null, (r) => r);
        expect(users, isA<List<TestUser>>());
        expect(users!.length, 2);
        expect(users[0].name, 'John');
        expect(users[0].age, 30);
        expect(users[1].name, 'Jane');
        expect(users[1].age, 25);
      });

      test('should handle empty paginated response', () async {
        final paginatedResponse = PaginatedResponse<TestUser>(
          content: [],
          currentPage: 0,
          pageSize: 10,
          totalElements: 0,
          totalPages: 0,
          isLast: true,
        );

        final Future<Either<Exception, PaginatedResponse<TestUser>>> future = Future.value(
          Right(paginatedResponse),
        );
        final result = await future.foldPaginated();

        expect(result.isRight(), true);
        final users = result.fold((l) => null, (r) => r);
        expect(users, isA<List<TestUser>>());
        expect(users!.length, 0);
      });

      test('should propagate exception from failed paginated response', () async {
        final exception = NoDataToDecodeException(StackTrace.current);
        final Future<Either<Exception, PaginatedResponse<TestUser>>> future = Future.value(
          Left(exception),
        );
        final result = await future.foldPaginated();

        expect(result.isLeft(), true);
        final error = result.fold((l) => l, (r) => null);
        expect(error, isA<NoDataToDecodeException>());
      });

      test('should handle generic exception', () async {
        final exception = Exception('Generic error');
        final Future<Either<Exception, PaginatedResponse<TestUser>>> future = Future.value(
          Left(exception),
        );
        final result = await future.foldPaginated();

        expect(result.isLeft(), true);
        final error = result.fold((l) => l, (r) => null);
        expect(error, isA<Exception>());
        expect(error.toString(), 'Exception: Generic error');
      });

      test('should work with different model types', () async {
        final paginatedResponse = PaginatedResponse<TestUser>(
          content: [
            const TestUser(name: 'Product 1', age: 1),
            const TestUser(name: 'Product 2', age: 2),
          ],
          currentPage: 0,
          pageSize: 10,
          totalElements: 2,
          totalPages: 1,
          isLast: true,
        );

        final Future<Either<Exception, PaginatedResponse<TestUser>>> future = Future.value(
          Right(paginatedResponse),
        );
        final result = await future.foldPaginated();

        expect(result.isRight(), true);
        final products = result.fold((l) => null, (r) => r);
        expect(products, isA<List<TestUser>>());
        expect(products!.length, 2);
        expect(products[0].name, 'Product 1');
        expect(products[0].age, 1);
      });

      test('should handle async future completion', () async {
        final paginatedResponse = PaginatedResponse<TestUser>(
          content: [const TestUser(name: 'Async User', age: 35)],
          currentPage: 0,
          pageSize: 10,
          totalElements: 1,
          totalPages: 1,
          isLast: true,
        );

        final Future<Either<Exception, PaginatedResponse<TestUser>>> future = Future.delayed(
          const Duration(milliseconds: 10),
          () => Right(paginatedResponse),
        );

        final result = await future.foldPaginated();

        expect(result.isRight(), true);
        final users = result.fold((l) => null, (r) => r);
        expect(users, isA<List<TestUser>>());
        expect(users!.length, 1);
        expect(users[0].name, 'Async User');
      });
    });
  });
}
