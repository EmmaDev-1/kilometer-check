import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kilometer_check/core/constants/wialon_constants.dart';
import 'package:kilometer_check/core/errors/app_exception.dart';
import 'package:kilometer_check/features/mileage/data/datasources/wialon_remote_datasource.dart';

http.Response _json(Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), 200);

const Map<String, dynamic> _unitItem = {
  'item': {'nm': 'Buick Skylark Convertible', 'id': 734455, 'cnm': 539343},
};

void main() {
  group('WialonRemoteDatasource', () {
    test('hace login, consulta el contador y reutiliza la sesión', () async {
      int loginCalls = 0;
      String? lastSid;

      final client = MockClient((request) async {
        final String? svc = request.url.queryParameters['svc'];
        switch (svc) {
          case 'token/login':
            loginCalls++;
            final params =
                jsonDecode(request.url.queryParameters['params']!)
                    as Map<String, dynamic>;
            expect(params['token'], WialonConstants.token);
            return _json({
              'eid': 'session-1',
              'user': {'nm': 'SdkDemo'},
            });
          case 'core/search_item':
            lastSid = request.url.queryParameters['sid'];
            final params =
                jsonDecode(request.url.queryParameters['params']!)
                    as Map<String, dynamic>;
            expect(params['id'], WialonConstants.unitId);
            expect(params['flags'], WialonConstants.flagsBaseAndCounters);
            return _json(_unitItem);
        }
        fail('Servicio inesperado: $svc');
      });

      final datasource = WialonRemoteDatasource(client: client);

      final first = await datasource.fetchMileage();
      expect(first.kilometers, 539343);
      expect(first.unitName, 'Buick Skylark Convertible');
      expect(lastSid, 'session-1');

      await datasource.fetchMileage();
      expect(loginCalls, 1, reason: 'La sesión debe reutilizarse');
    });

    test(
      're-autentica y reintenta cuando la sesión expira (error 1)',
      () async {
        int loginCalls = 0;
        int searchCalls = 0;

        final client = MockClient((request) async {
          final String? svc = request.url.queryParameters['svc'];
          if (svc == 'token/login') {
            loginCalls++;
            return _json({'eid': 'session-$loginCalls'});
          }
          searchCalls++;
          // La segunda consulta simula una sesión expirada.
          if (searchCalls == 2) return _json({'error': 1});
          return _json(_unitItem);
        });

        final datasource = WialonRemoteDatasource(client: client);

        await datasource.fetchMileage(); // login 1 + search 1
        final reading = await datasource.fetchMileage(); // search 2 (error) →
        // login 2 + search 3

        expect(reading.kilometers, 539343);
        expect(loginCalls, 2);
        expect(searchCalls, 3);
      },
    );

    test('propaga errores de la API como WialonApiException', () async {
      final client = MockClient((request) async {
        final String? svc = request.url.queryParameters['svc'];
        if (svc == 'token/login') return _json({'eid': 'session-1'});
        return _json({'error': 7});
      });

      final datasource = WialonRemoteDatasource(client: client);

      await expectLater(
        datasource.fetchMileage(),
        throwsA(isA<WialonApiException>().having((e) => e.code, 'code', 7)),
      );
    });

    test('convierte estados HTTP != 200 en NetworkException', () async {
      final client = MockClient(
        (request) async => http.Response('Server error', 500),
      );

      final datasource = WialonRemoteDatasource(client: client);

      await expectLater(
        datasource.fetchMileage(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('convierte respuestas no-JSON en ParsingException', () async {
      final client = MockClient(
        (request) async => http.Response('<html>mantenimiento</html>', 200),
      );

      final datasource = WialonRemoteDatasource(client: client);

      await expectLater(
        datasource.fetchMileage(),
        throwsA(isA<ParsingException>()),
      );
    });
  });
}
