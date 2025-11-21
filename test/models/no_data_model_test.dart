import 'package:flutter_test/flutter_test.dart';
import 'package:restful_consumer/src/data/models/no_data_model.dart';

void main() {
  group('NoDataModel', () {
    test('fromJson should create an instance from JSON with success true', () {
      final model = NoDataModel.empty().fromJson({'success': true});
      expect(model, isA<NoDataModel>());
      expect(model.success, true);
    });

    test('fromJson should create an instance from JSON with success false', () {
      final model = NoDataModel.empty().fromJson({'success': false});
      expect(model, isA<NoDataModel>());
      expect(model.success, false);
    });

    test('should have success property', () {
      final model = NoDataModel(success: true);
      expect(model.success, true);
    });

    test('empty factory should create instance with success true', () {
      final model = NoDataModel.empty();
      expect(model.success, true);
    });

    test('props should return list with success', () {
      final model = NoDataModel(success: true);
      expect(model.props, [true]);
    });

    test('equality should work based on success value', () {
      final model1 = NoDataModel(success: true);
      final model2 = NoDataModel(success: true);
      final model3 = NoDataModel(success: false);

      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });
  });
}

