import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/wialon_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/mileage_model.dart';

/// Cliente de la API remota de Wialon.
///
/// Flujo completo (2 llamadas):
///  1. `token/login` — intercambia el token por una sesión (`eid`).
///  2. `core/search_item` — con flags `0x1 + 0x2000` devuelve la unidad
///     con su contador de kilometraje (`cnm`, en km).
///
/// La sesión se cachea entre consultas; si Wialon reporta sesión
/// inválida (error 1), se re-autentica una única vez y reintenta.
class WialonRemoteDatasource {
  WialonRemoteDatasource({required http.Client client}) : _client = client;

  final http.Client _client;

  /// Sesión activa (`eid` de `token/login`). `null` si aún no hay login.
  String? _sessionId;

  /// Obtiene la lectura de kilometraje de la unidad del ejercicio.
  Future<MileageModel> fetchMileage() async {
    _sessionId ??= await _login();

    Map<String, dynamic> response = await _searchItem(_sessionId!);

    // Sesión expirada: re-login (una vez) y reintento.
    if (_errorCode(response) == WialonConstants.errorInvalidSession) {
      _sessionId = await _login();
      response = await _searchItem(_sessionId!);
    }

    _throwIfError(response);
    return MileageModel.fromWialonJson(response);
  }

  /// Llamada 1: `token/login`.
  Future<String> _login() async {
    final Map<String, dynamic> response = await _get(
      svc: 'token/login',
      params: {'token': WialonConstants.token},
    );
    _throwIfError(response);

    final Object? eid = response['eid'];
    if (eid is! String || eid.isEmpty) {
      throw const ParsingException(
        'Wialon no devolvió una sesión válida al iniciar sesión.',
      );
    }
    return eid;
  }

  /// Llamada 2: `core/search_item` con contadores.
  Future<Map<String, dynamic>> _searchItem(String sessionId) => _get(
    svc: 'core/search_item',
    params: {
      'id': WialonConstants.unitId,
      'flags': WialonConstants.flagsBaseAndCounters,
    },
    sessionId: sessionId,
  );

  /// GET genérico contra el endpoint único de Wialon.
  Future<Map<String, dynamic>> _get({
    required String svc,
    required Map<String, dynamic> params,
    String? sessionId,
  }) async {
    final Uri uri = Uri.parse(WialonConstants.baseUrl).replace(
      queryParameters: {
        'svc': svc,
        'params': jsonEncode(params),
        if (sessionId != null) 'sid': sessionId,
      },
    );

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(WialonConstants.requestTimeout);
    } on TimeoutException {
      throw const NetworkException(
        'Wialon tardó demasiado en responder. Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const NetworkException();
    } on AppException {
      rethrow;
    } catch (_) {
      // p. ej. SocketException en plataformas nativas.
      throw const NetworkException();
    }

    if (response.statusCode != 200) {
      throw NetworkException(
        'El servidor de Wialon respondió con estado ${response.statusCode}.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const ParsingException();
    }

    if (decoded is! Map<String, dynamic>) {
      throw const ParsingException();
    }
    return decoded;
  }

  /// Código de error de Wialon, o `null` si la respuesta fue exitosa.
  int? _errorCode(Map<String, dynamic> response) {
    final Object? code = response['error'];
    return code is int && code != 0 ? code : null;
  }

  void _throwIfError(Map<String, dynamic> response) {
    final int? code = _errorCode(response);
    if (code != null) throw WialonApiException(code);
  }
}
