import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kilometer_check/core/errors/app_exception.dart';
import 'package:kilometer_check/features/mileage/domain/entities/mileage_reading.dart';
import 'package:kilometer_check/features/mileage/domain/usecases/get_current_mileage.dart';
import 'package:kilometer_check/features/mileage/presentation/providers/mileage_provider.dart';

MileageReading _reading(int km) => MileageReading(
  kilometers: km,
  unitName: 'Buick Skylark Convertible',
  timestamp: DateTime(2026, 7, 13, 12),
);

/// Fake del caso de uso: devuelve resultados en orden
/// ([MileageReading] o lanza [AppException]).
class _FakeGetCurrentMileage implements GetCurrentMileage {
  _FakeGetCurrentMileage(this._results);

  final List<Object> _results;
  int calls = 0;

  @override
  Future<MileageReading> call() async {
    final Object result = _results[calls++];
    if (result is AppException) throw result;
    return result as MileageReading;
  }
}

void main() {
  group('MileageProvider', () {
    test('estado inicial: sin datos ni tendencia', () {
      final provider = MileageProvider(
        getCurrentMileage: _FakeGetCurrentMileage([_reading(100)]),
      );

      expect(provider.status, MileageStatus.initial);
      expect(provider.reading, isNull);
      expect(provider.trend, MileageTrend.none);
      expect(provider.hasData, isFalse);
    });

    test('primera consulta exitosa → success + firstReading', () async {
      final provider = MileageProvider(
        getCurrentMileage: _FakeGetCurrentMileage([_reading(539343)]),
      );

      final Future<void> request = provider.fetchMileage();
      expect(
        provider.status,
        MileageStatus.loading,
        reason: 'Debe notificar el estado de carga de inmediato',
      );
      await request;

      expect(provider.status, MileageStatus.success);
      expect(provider.reading?.kilometers, 539343);
      expect(provider.trend, MileageTrend.firstReading);
      expect(provider.deltaKm, 0);
    });

    test('kilometraje igual en la segunda consulta → constant', () async {
      final provider = MileageProvider(
        getCurrentMileage: _FakeGetCurrentMileage([
          _reading(539343),
          _reading(539343),
        ]),
      );

      await provider.fetchMileage();
      await provider.fetchMileage();

      expect(provider.trend, MileageTrend.constant);
      expect(provider.deltaKm, 0);
    });

    test(
      'kilometraje mayor en la segunda consulta → increased + delta',
      () async {
        final provider = MileageProvider(
          getCurrentMileage: _FakeGetCurrentMileage([
            _reading(539343),
            _reading(539420),
          ]),
        );

        await provider.fetchMileage();
        await provider.fetchMileage();

        expect(provider.trend, MileageTrend.increased);
        expect(provider.deltaKm, 77);
        expect(provider.previousReading?.kilometers, 539343);
      },
    );

    test(
      'falla → failure con mensaje amigable y conserva la lectura previa',
      () async {
        final provider = MileageProvider(
          getCurrentMileage: _FakeGetCurrentMileage([
            _reading(539343),
            const NetworkException(),
          ]),
        );

        await provider.fetchMileage();
        await provider.fetchMileage();

        expect(provider.status, MileageStatus.failure);
        expect(provider.errorMessage, const NetworkException().message);
        expect(
          provider.reading?.kilometers,
          539343,
          reason: 'El último dato válido debe seguir visible',
        );
      },
    );

    test(
      'ignora consultas mientras hay una en curso (anti doble-tap)',
      () async {
        final completer = Completer<MileageReading>();
        final usecase = _BlockingGetCurrentMileage(completer);
        final provider = MileageProvider(getCurrentMileage: usecase);

        final Future<void> first = provider.fetchMileage();
        final Future<void> second = provider.fetchMileage();

        completer.complete(_reading(539343));
        await Future.wait([first, second]);

        expect(usecase.calls, 1);
        expect(provider.status, MileageStatus.success);
      },
    );
  });
}

class _BlockingGetCurrentMileage implements GetCurrentMileage {
  _BlockingGetCurrentMileage(this._completer);

  final Completer<MileageReading> _completer;
  int calls = 0;

  @override
  Future<MileageReading> call() {
    calls++;
    return _completer.future;
  }
}
