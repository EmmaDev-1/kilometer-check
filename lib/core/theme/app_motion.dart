import 'package:flutter/animation.dart';

/// Curvas y duraciones estándar de animación de la app.
///
/// Las curvas replican los easings del sitio de iTire.
final class AppMotion {
  const AppMotion._();

  /// `cubic-bezier(0.16, 1, 0.3, 1)` — salida suave y elástica.
  static const Curve easeOut = Cubic(0.16, 1, 0.3, 1);

  /// `cubic-bezier(0.4, 0, 0.2, 1)` — estándar material.
  static const Curve easeInOut = Cubic(0.4, 0, 0.2, 1);

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 550);

  /// Duración del conteo del odómetro al actualizar kilometraje.
  static const Duration odometer = Duration(milliseconds: 1200);
}
