import '../entities/mileage_reading.dart';
import '../repositories/mileage_repository.dart';

/// Caso de uso: consultar el kilometraje actual de la unidad.
class GetCurrentMileage {
  const GetCurrentMileage(this._repository);

  final MileageRepository _repository;

  Future<MileageReading> call() => _repository.getCurrentMileage();
}
