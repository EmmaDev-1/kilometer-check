import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/mileage_reading.dart';
import '../../domain/repositories/mileage_repository.dart';
import '../datasources/wialon_remote_datasource.dart';

/// Implementación de [MileageRepository] respaldada por Wialon.
///
/// Garantiza el contrato de dominio: toda falla sale como [AppException].
class MileageRepositoryImpl implements MileageRepository {
  const MileageRepositoryImpl(this._datasource);

  final WialonRemoteDatasource _datasource;

  @override
  Future<MileageReading> getCurrentMileage() async {
    try {
      return await _datasource.fetchMileage();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const UnexpectedException();
    }
  }
}
