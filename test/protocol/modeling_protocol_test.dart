import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/protocol/modeling_protocol.dart';

// Test implementation of ModelingProtocol
class TestModel extends ModelingProtocol {
  final String name;
  final int age;

  const TestModel({required this.name, required this.age});

  @override
  TestModel fromJson(dynamic json) {
    return TestModel(name: json['name'] as String, age: json['age'] as int);
  }

  @override
  List<Object?> get props => [name, age];
}

// Another test implementation
class EmptyModel extends ModelingProtocol {
  const EmptyModel();

  @override
  EmptyModel fromJson(dynamic json) {
    return const EmptyModel();
  }

  @override
  List<Object?> get props => [];
}

// Model with default props
class DefaultPropsModel extends ModelingProtocol {
  @override
  DefaultPropsModel fromJson(dynamic json) {
    return DefaultPropsModel();
  }
}

void main() {
  group('ModelingProtocol', () {
    test('should implement fromJson method', () {
      const model = TestModel(name: 'John', age: 30);
      final json = {'name': 'Jane', 'age': 25};
      final decoded = model.fromJson(json);

      expect(decoded, isA<TestModel>());
      expect(decoded.name, 'Jane');
      expect(decoded.age, 25);
    });

    test('should have props for equality comparison', () {
      const model1 = TestModel(name: 'John', age: 30);
      const model2 = TestModel(name: 'John', age: 30);
      const model3 = TestModel(name: 'Jane', age: 25);

      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });

    test('should work with empty props', () {
      const model1 = EmptyModel();
      const model2 = EmptyModel();

      expect(model1, equals(model2));
      expect(model1.props, isEmpty);
    });

    test('should be able to decode from json with fromJson', () {
      const model = TestModel(name: '', age: 0);
      final json = {'name': 'Test', 'age': 42};
      final result = model.fromJson(json);

      expect(result.name, 'Test');
      expect(result.age, 42);
    });

    test('models with different values should not be equal', () {
      const model1 = TestModel(name: 'Alice', age: 20);
      const model2 = TestModel(name: 'Alice', age: 30);
      const model3 = TestModel(name: 'Bob', age: 20);

      expect(model1, isNot(equals(model2)));
      expect(model1, isNot(equals(model3)));
      expect(model2, isNot(equals(model3)));
    });

    test('should handle complex json objects', () {
      const model = TestModel(name: '', age: 0);
      final json = {'name': 'Complex Name', 'age': 99, 'extra': 'ignored'};
      final result = model.fromJson(json);

      expect(result.name, 'Complex Name');
      expect(result.age, 99);
    });

    test('should use default props when not overridden', () {
      final model = DefaultPropsModel();
      expect(model.props, isEmpty);
    });

    test('should call props getter correctly', () {
      const model1 = TestModel(name: 'Test', age: 25);
      const model2 = EmptyModel();

      // Trigger props getter
      expect(model1.props.length, 2);
      expect(model2.props.length, 0);
    });

    test('should have default toJson implementation', () {
      const model = TestModel(name: 'Test', age: 25);
      final json = model.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json, isEmpty);
    });

    test('should have default toJson implementation for empty model', () {
      const model = EmptyModel();
      final json = model.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json, isEmpty);
    });
  });
}
