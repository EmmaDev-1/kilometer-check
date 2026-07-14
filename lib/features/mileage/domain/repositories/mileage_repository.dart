import '../entities/mileage_reading.dart';

/// Contrato de acceso al kilometraje de la unidad.
///
/// La capa de dominio no conoce Wialon ni HTTP: cualquier proveedor de
/// GPS podría implementarlo sin tocar presentación ni casos de uso.
abstract interface class MileageRepository {
  /// Obtiene la lectura actual de kilometraje.
  ///
  /// Lanza una `AppException` con mensaje amigable si algo falla.
  Future<MileageReading> getCurrentMileage();
}
