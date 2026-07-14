/// Constantes de integración con la API remota de Wialon.
///
/// Flujo mínimo para obtener el kilometraje (2 llamadas):
///  1. `svc=token/login`   → intercambia el token por una sesión (`eid`).
///  2. `svc=core/search_item` con [flagsBaseAndCounters] → devuelve el item
///     con el contador de kilometraje (`cnm` / `cnm_km`, en km).
final class WialonConstants {
  const WialonConstants._();

  /// Endpoint único de la API remota (el servicio se define vía `svc`).
  ///
  /// Configurable por entorno (útil para pruebas o proxies locales):
  /// `flutter run --dart-define=WIALON_BASE_URL=<url>`.
  static const String baseUrl = String.fromEnvironment(
    'WIALON_BASE_URL',
    defaultValue: 'https://hst-api.wialon.com/wialon/ajax.html',
  );

  /// Token de acceso.
  ///
  /// En un entorno productivo este valor NUNCA debe vivir en el código:
  /// se inyectaría vía `--dart-define` o un secret manager. Para este
  /// ejercicio se usa como default el token de prueba provisto en el PDF.
  static const String token = String.fromEnvironment(
    'WIALON_TOKEN',
    defaultValue:
        '5dce19710a5e26ab8b7b8986cb3c49e58C291791B7F0A7AEB8AFBFCEED7DC03BC48FF5F8',
  );

  /// Unidad registrada en Wialon para el ejercicio.
  static const int unitId = 734455;
  static const String unitName = 'Buick Skylark Convertible';

  /// Flags de `core/search_item`:
  /// `0x1` (información base) + `0x2000` (contadores → `cnm`).
  static const int flagsBaseAndCounters = 0x1 + 0x2000; // 8193

  /// Códigos de error relevantes de la API.
  static const int errorInvalidSession = 1;

  /// Tiempo máximo de espera por llamada.
  static const Duration requestTimeout = Duration(seconds: 15);
}
