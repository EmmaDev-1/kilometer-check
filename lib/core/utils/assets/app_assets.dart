/// Rutas base de assets. No instanciar: solo constantes.
///
/// Regla al agregar archivos nuevos:
///  1. Coloca el archivo en la carpeta correcta
///     (`assets/images`, `assets/icons`, `assets/animations`).
///  2. Agrega la constante en la clase correspondiente.
///  3. Consúmela desde UI (idealmente con `AppImage`).
final class AppAssets {
  const AppAssets._();

  static const String images = 'assets/images';
  static const String icons = 'assets/icons';
  static const String animations = 'assets/animations';
}

/// Assets raster (png / jpg / webp) en `assets/images`.
final class AppImages {
  const AppImages._();

  // Aún no hay assets raster; agrega aquí las constantes cuando existan.
  // static const String logo = '${AppAssets.images}/logo.png';
}

/// Assets SVG en `assets/icons`.
final class AppIcons {
  const AppIcons._();

  /// Ícono de neumático usado en la tarjeta del vehículo y el splash.
  static const String tire = '${AppAssets.icons}/tire.svg';
}

/// Animaciones (json/Lottie) en `assets/animations`.
final class AppAnimations {
  const AppAnimations._();

  // Las animaciones de esta app son programáticas (CustomPainter /
  // AnimationController). Agrega aquí constantes si se suman archivos Lottie.
}
