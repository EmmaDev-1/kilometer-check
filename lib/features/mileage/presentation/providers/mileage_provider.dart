import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/mileage_reading.dart';
import '../../domain/usecases/get_current_mileage.dart';

/// Estado de la consulta de kilometraje.
enum MileageStatus { initial, loading, success, failure }

/// Comparación contra la lectura anterior (petición EXTRA del ejercicio).
enum MileageTrend {
  /// Aún no hay lecturas.
  none,

  /// Primera lectura registrada: no hay contra qué comparar.
  firstReading,

  /// El kilometraje aumentó respecto a la lectura anterior.
  increased,

  /// El kilometraje se mantuvo constante.
  constant,

  /// Caso defensivo: el contador disminuyó (p. ej. reinicio del contador).
  decreased,
}

/// Fuente de verdad de la pantalla de kilometraje.
///
/// Los widgets leen y reaccionan a este [ChangeNotifier] vía `provider`
/// (`context.watch` / `context.select`), como pide el ejercicio.
class MileageProvider extends ChangeNotifier {
  MileageProvider({required GetCurrentMileage getCurrentMileage})
    : _getCurrentMileage = getCurrentMileage;

  final GetCurrentMileage _getCurrentMileage;

  MileageStatus _status = MileageStatus.initial;
  MileageReading? _reading;
  MileageReading? _previousReading;
  MileageTrend _trend = MileageTrend.none;
  String? _errorMessage;
  bool _disposed = false;

  MileageStatus get status => _status;

  /// Última lectura exitosa (se conserva aunque una consulta posterior falle).
  MileageReading? get reading => _reading;
  MileageReading? get previousReading => _previousReading;
  MileageTrend get trend => _trend;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == MileageStatus.loading;
  bool get hasData => _reading != null;

  /// Diferencia en km contra la lectura anterior (0 si no aplica).
  int get deltaKm {
    if (_reading == null || _previousReading == null) return 0;
    return _reading!.kilometers - _previousReading!.kilometers;
  }

  /// Consulta el kilometraje actual en Wialon.
  ///
  /// Ignora llamadas mientras hay una consulta en curso (evita doble tap).
  Future<void> fetchMileage() async {
    if (isLoading) return;

    _status = MileageStatus.loading;
    _errorMessage = null;
    _safeNotify();

    try {
      final MileageReading newReading = await _getCurrentMileage();
      _previousReading = _reading;
      _reading = newReading;
      _trend = _compareReadings(
        previous: _previousReading,
        current: newReading,
      );
      _status = MileageStatus.success;
    } on AppException catch (exception) {
      _status = MileageStatus.failure;
      _errorMessage = exception.message;
    } catch (_) {
      _status = MileageStatus.failure;
      _errorMessage = const UnexpectedException().message;
    }

    _safeNotify();
  }

  MileageTrend _compareReadings({
    required MileageReading? previous,
    required MileageReading current,
  }) {
    if (previous == null) return MileageTrend.firstReading;
    if (current.kilometers > previous.kilometers) {
      return MileageTrend.increased;
    }
    if (current.kilometers < previous.kilometers) {
      return MileageTrend.decreased;
    }
    return MileageTrend.constant;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
