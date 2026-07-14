import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/mileage_reading.dart';

/// Modelo de datos que sabe construirse desde la respuesta de
/// `core/search_item` de Wialon.
class MileageModel extends MileageReading {
  const MileageModel({
    required super.kilometers,
    required super.unitName,
    required super.timestamp,
  });

  /// Estructura esperada (flags `0x1 + 0x2000`):
  /// ```json
  /// { "item": { "nm": "...", "id": 734455, "cnm": 539343, ... } }
  /// ```
  /// `cnm` es el contador de kilometraje en km.
  factory MileageModel.fromWialonJson(Map<String, dynamic> json) {
    final Object? item = json['item'];
    if (item is! Map<String, dynamic>) {
      throw const ParsingException(
        'La respuesta de Wialon no contiene la unidad solicitada.',
      );
    }

    final Object? counter = item['cnm'];
    if (counter is! num) {
      throw const ParsingException(
        'La respuesta de Wialon no incluye el contador de kilometraje.',
      );
    }

    return MileageModel(
      kilometers: counter.toInt(),
      unitName: (item['nm'] as String?) ?? 'Unidad desconocida',
      timestamp: DateTime.now(),
    );
  }
}
