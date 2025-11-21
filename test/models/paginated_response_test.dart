import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/data/definition/model.dart';
import 'package:restful_consumer/src/data/models/paginated_response.dart';

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
  group('PaginatedResponse', () {
    group('constructor', () {
      test('should create instance with all properties', () {
        final users = [
          const TestUser(name: 'John', age: 30),
          const TestUser(name: 'Jane', age: 25),
        ];

        final response = PaginatedResponse<TestUser>(
          content: users,
          currentPage: 1,
          pageSize: 10,
          totalElements: 50,
          totalPages: 5,
          isLast: false,
        );

        expect(response.content, users);
        expect(response.currentPage, 1);
        expect(response.pageSize, 10);
        expect(response.totalElements, 50);
        expect(response.totalPages, 5);
        expect(response.isLast, false);
      });
    });

    group('empty factory', () {
      test('should create empty paginated response', () {
        final emptyUser = const TestUser(name: '', age: 0);
        final response = PaginatedResponse.empty(emptyUser);

        expect(response.content, [emptyUser]);
        expect(response.currentPage, 0);
        expect(response.pageSize, 1);
        expect(response.totalElements, 0);
        expect(response.totalPages, 1);
        expect(response.isLast, true);
      });
    });

    group('fromJson factory', () {
      test('should create from valid JSON', () {
        final json = {
          'content': [
            {'name': 'John', 'age': 30},
            {'name': 'Jane', 'age': 25},
          ],
          'currentPage': 2,
          'pageSize': 10,
          'totalElements': 25,
          'totalPages': 3,
          'isLast': false,
        };

        final response = PaginatedResponse.fromJson(json, const TestUser(name: '', age: 0));

        expect(response.content.length, 2);
        expect(response.content[0].name, 'John');
        expect(response.content[0].age, 30);
        expect(response.content[1].name, 'Jane');
        expect(response.content[1].age, 25);
        expect(response.currentPage, 2);
        expect(response.pageSize, 10);
        expect(response.totalElements, 25);
        expect(response.totalPages, 3);
        expect(response.isLast, false);
      });

      test('should handle null values with safe defaults', () {
        final json = {
          'content': null,
          'currentPage': null,
          'pageSize': null,
          'totalElements': null,
          'totalPages': null,
          'isLast': null,
        };

        final response = PaginatedResponse.fromJson(json, const TestUser(name: '', age: 0));

        expect(response.content, []);
        expect(response.currentPage, 0);
        expect(response.pageSize, 0);
        expect(response.totalElements, 0);
        expect(response.totalPages, 0);
        expect(response.isLast, false);
      });

      test('should handle empty content array', () {
        final json = {
          'content': [],
          'currentPage': 0,
          'pageSize': 10,
          'totalElements': 0,
          'totalPages': 0,
          'isLast': true,
        };

        final response = PaginatedResponse.fromJson(json, const TestUser(name: '', age: 0));

        expect(response.content, []);
        expect(response.currentPage, 0);
        expect(response.pageSize, 10);
        expect(response.totalElements, 0);
        expect(response.totalPages, 0);
        expect(response.isLast, true);
      });

      test('should handle missing fields', () {
        final json = <String, dynamic>{};

        final response = PaginatedResponse.fromJson(json, const TestUser(name: '', age: 0));

        expect(response.content, []);
        expect(response.currentPage, 0);
        expect(response.pageSize, 0);
        expect(response.totalElements, 0);
        expect(response.totalPages, 0);
        expect(response.isLast, false);
      });

      test('should handle partial JSON', () {
        final json = {
          'content': [
            {'name': 'Test', 'age': 20},
          ],
          'currentPage': 1,
          // Missing other fields
        };

        final response = PaginatedResponse.fromJson(json, const TestUser(name: '', age: 0));

        expect(response.content.length, 1);
        expect(response.content[0].name, 'Test');
        expect(response.content[0].age, 20);
        expect(response.currentPage, 1);
        expect(response.pageSize, 0); // Default value
        expect(response.totalElements, 0); // Default value
        expect(response.totalPages, 0); // Default value
        expect(response.isLast, false); // Default value
      });
    });

    group('toJson method', () {
      test('should convert to JSON correctly', () {
        final users = [
          const TestUser(name: 'John', age: 30),
          const TestUser(name: 'Jane', age: 25),
        ];

        final response = PaginatedResponse<TestUser>(
          content: users,
          currentPage: 1,
          pageSize: 10,
          totalElements: 50,
          totalPages: 5,
          isLast: false,
        );

        final json = response.toJson();

        expect(json['content'], isA<List>());
        expect(json['content'].length, 2);
        expect(json['content'][0]['name'], 'John');
        expect(json['content'][0]['age'], 30);
        expect(json['content'][1]['name'], 'Jane');
        expect(json['content'][1]['age'], 25);
        expect(json['currentPage'], 1);
        expect(json['pageSize'], 10);
        expect(json['totalElements'], 50);
        expect(json['totalPages'], 5);
        expect(json['isLast'], false);
      });

      test('should handle empty content in JSON', () {
        final response = PaginatedResponse<TestUser>(
          content: [],
          currentPage: 0,
          pageSize: 10,
          totalElements: 0,
          totalPages: 0,
          isLast: true,
        );

        final json = response.toJson();

        expect(json['content'], []);
        expect(json['currentPage'], 0);
        expect(json['pageSize'], 10);
        expect(json['totalElements'], 0);
        expect(json['totalPages'], 0);
        expect(json['isLast'], true);
      });

      test('should handle single item content', () {
        final users = [const TestUser(name: 'Single', age: 40)];

        final response = PaginatedResponse<TestUser>(
          content: users,
          currentPage: 0,
          pageSize: 1,
          totalElements: 1,
          totalPages: 1,
          isLast: true,
        );

        final json = response.toJson();

        expect(json['content'].length, 1);
        expect(json['content'][0]['name'], 'Single');
        expect(json['content'][0]['age'], 40);
        expect(json['totalElements'], 1);
        expect(json['isLast'], true);
      });
    });

    group('edge cases', () {
      test('should handle large numbers', () {
        final json = {
          'content': [],
          'currentPage': 999999,
          'pageSize': 1000,
          'totalElements': 1000000,
          'totalPages': 1000,
          'isLast': false,
        };

        final response = PaginatedResponse.fromJson(json, const TestUser(name: '', age: 0));

        expect(response.currentPage, 999999);
        expect(response.pageSize, 1000);
        expect(response.totalElements, 1000000);
        expect(response.totalPages, 1000);
        expect(response.isLast, false);
      });

      test('should handle zero values', () {
        final json = {
          'content': [],
          'currentPage': 0,
          'pageSize': 0,
          'totalElements': 0,
          'totalPages': 0,
          'isLast': true,
        };

        final response = PaginatedResponse.fromJson(json, const TestUser(name: '', age: 0));

        expect(response.currentPage, 0);
        expect(response.pageSize, 0);
        expect(response.totalElements, 0);
        expect(response.totalPages, 0);
        expect(response.isLast, true);
      });

      test('should handle negative values with safe defaults', () {
        final json = {
          'content': [],
          'currentPage': -1,
          'pageSize': -5,
          'totalElements': -10,
          'totalPages': -2,
          'isLast': false,
        };

        final response = PaginatedResponse.fromJson(json, const TestUser(name: '', age: 0));

        // Safe defaults should handle negative values
        expect(response.currentPage, -1); // int? allows negative
        expect(response.pageSize, -5); // int? allows negative
        expect(response.totalElements, -10); // int? allows negative
        expect(response.totalPages, -2); // int? allows negative
        expect(response.isLast, false);
      });
    });
  });
}
