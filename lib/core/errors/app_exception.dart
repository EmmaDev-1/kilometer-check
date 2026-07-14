/// Jerarquía de errores de la aplicación.
///
/// Toda falla que cruza la frontera de la capa de datos se traduce a una
/// [AppException] con un mensaje amigable para el usuario, de modo que la
/// capa de presentación nunca tenga que interpretar errores crudos.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Mensaje listo para mostrarse en UI.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Sin conexión, timeout o fallo de transporte HTTP.
final class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'No fue posible conectar con el servidor. '
        'Revisa tu conexión e inténtalo de nuevo.',
  ]);
}

/// La API de Wialon respondió con un código de error.
final class WialonApiException extends AppException {
  WialonApiException(this.code) : super(_messageForCode(code));

  /// Código de error devuelto por Wialon (`{"error": code}`).
  final int code;

  static String _messageForCode(int code) => switch (code) {
    1 => 'La sesión con Wialon expiró. Inténtalo de nuevo.',
    4 || 5 => 'La solicitud enviada a Wialon no es válida.',
    7 => 'El token no tiene permisos para consultar esta unidad.',
    8 => 'Token de acceso inválido o expirado.',
    1001 =>
      'Wialon está recibiendo demasiadas solicitudes. '
          'Espera un momento e inténtalo de nuevo.',
    _ => 'Wialon devolvió un error inesperado (código $code).',
  };
}

/// La respuesta llegó bien pero no tiene la forma esperada.
final class ParsingException extends AppException {
  const ParsingException([
    super.message = 'La respuesta del servidor no tiene el formato esperado.',
  ]);
}

/// Cualquier falla no contemplada.
final class UnexpectedException extends AppException {
  const UnexpectedException([
    super.message = 'Ocurrió un error inesperado. Inténtalo de nuevo.',
  ]);
}
