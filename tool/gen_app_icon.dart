// Herramienta de build (no forma parte de la app): convierte el WebP de
// origen `assets/icons/icon.png` a PNG reales que consumen
// flutter_launcher_icons y flutter_native_splash.
//
// Genera:
//  - app_icon.png            → 1024x1024, logo a sangre (ícono/iOS/web).
//  - app_icon_foreground.png → 1024x1024 transparente, logo centrado con
//    padding (zona segura del ícono adaptativo Android).
//  - splash_icon.png         → 1024x1024 transparente, logo más pequeño que
//    el foreground del ícono (splash nativo: se ve mejor más compacto que
//    el ícono adaptativo, que sí necesita llenar más el círculo del launcher).
//
// Uso: fvm dart run tool/gen_app_icon.dart
import 'dart:io';

import 'package:image/image.dart' as img;

/// Compone [src] centrado en un lienzo transparente de [canvas]x[canvas],
/// ocupando [logoSize] px, y lo guarda en [path].
void _writePaddedLogo(
  img.Image src, {
  required String path,
  required int canvas,
  required int logoSize,
}) {
  final int offset = (canvas - logoSize) ~/ 2;
  final img.Image out = img.Image(width: canvas, height: canvas, numChannels: 4);
  img.fill(out, color: img.ColorRgba8(0, 0, 0, 0));

  final img.Image logo = img.copyResize(
    src,
    width: logoSize,
    height: logoSize,
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(out, logo, dstX: offset, dstY: offset);
  File(path).writeAsBytesSync(img.encodePng(out));
}

void main() {
  final File source = File('assets/icons/icon.png');
  final bytes = source.readAsBytesSync();

  final img.Image? src = img.decodeImage(bytes);
  if (src == null) {
    stderr.writeln('No se pudo decodificar assets/icons/icon.png');
    exit(1);
  }
  stdout.writeln('Origen decodificado: ${src.width}x${src.height}');

  const int canvas = 1024;

  // 1) Ícono a sangre 1024x1024 (launcher legacy / iOS / web).
  final img.Image icon = img.copyResize(
    src,
    width: canvas,
    height: canvas,
    interpolation: img.Interpolation.cubic,
  );
  File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(icon));

  // 2) Foreground del ícono adaptativo Android: logo al ~62%.
  const int foregroundLogoSize = 640;
  _writePaddedLogo(
    src,
    path: 'assets/icons/app_icon_foreground.png',
    canvas: canvas,
    logoSize: foregroundLogoSize,
  );

  // 3) Imagen del splash nativo: logo más chico (~46%) que el del ícono.
  const int splashLogoSize = 470;
  _writePaddedLogo(
    src,
    path: 'assets/icons/splash_icon.png',
    canvas: canvas,
    logoSize: splashLogoSize,
  );

  // 4) Favicon web 32x32.
  final img.Image favicon = img.copyResize(
    src,
    width: 32,
    height: 32,
    interpolation: img.Interpolation.average,
  );
  File('web/favicon.png').writeAsBytesSync(img.encodePng(favicon));

  stdout.writeln(
    'OK → app_icon.png (1024) + app_icon_foreground.png (logo $foregroundLogoSize) '
    '+ splash_icon.png (logo $splashLogoSize) + favicon.png (32)',
  );
}
