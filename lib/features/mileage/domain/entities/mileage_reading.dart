import 'package:flutter/foundation.dart';

/// Lectura de kilometraje de una unidad en un instante dado.
@immutable
class MileageReading {
  const MileageReading({
    required this.kilometers,
    required this.unitName,
    required this.timestamp,
  });

  /// Kilometraje del contador de la unidad (km).
  final int kilometers;

  /// Nombre de la unidad en Wialon.
  final String unitName;

  /// Momento local en que se obtuvo la lectura.
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MileageReading &&
          other.kilometers == kilometers &&
          other.unitName == unitName &&
          other.timestamp == timestamp;

  @override
  int get hashCode => Object.hash(kilometers, unitName, timestamp);

  @override
  String toString() =>
      'MileageReading(kilometers: $kilometers, unitName: $unitName, '
      'timestamp: $timestamp)';
}
