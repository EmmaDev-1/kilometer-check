import 'package:flutter_test/flutter_test.dart';
import 'package:kilometer_check/core/errors/app_exception.dart';
import 'package:kilometer_check/features/mileage/data/models/mileage_model.dart';

void main() {
  group('MileageModel.fromWialonJson', () {
    test('parsea la respuesta real de core/search_item', () {
      final model = MileageModel.fromWialonJson({
        'searchSpec': {'itemsType': 'avl_unit'},
        'item': {
          'nm': 'Buick Skylark Convertible',
          'cls': 2,
          'id': 734455,
          'cnm': 539343,
          'cneh': 9529,
        },
      });

      expect(model.kilometers, 539343);
      expect(model.unitName, 'Buick Skylark Convertible');
    });

    test('acepta contadores con decimales (num → int)', () {
      final model = MileageModel.fromWialonJson({
        'item': {'nm': 'Unidad', 'cnm': 539343.7},
      });

      expect(model.kilometers, 539343);
    });

    test('lanza ParsingException si falta el item', () {
      expect(
        () => MileageModel.fromWialonJson({'error': 0}),
        throwsA(isA<ParsingException>()),
      );
    });

    test('lanza ParsingException si falta el contador cnm', () {
      expect(
        () => MileageModel.fromWialonJson({
          'item': {'nm': 'Unidad sin contador'},
        }),
        throwsA(isA<ParsingException>()),
      );
    });
  });
}
