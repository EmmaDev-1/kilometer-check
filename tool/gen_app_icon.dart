// Herramienta de build (no forma parte de la app): convierte el WebP de
// origen `assets/icons/icon.png` a PNG reales que consumen
// flutter_launcher_icons y flutter_native_splash.
//
// Genera:
//  - app_icon.png            → 1024x1024, logo a sangre (ícono/iOS/web).
//  - app_icon_foreground.png → 1024x1024 transparente, logo centrado con
//    padding (zona segura del ícono adaptativo + splash).
//
// Uso: fvm dart run tool/gen_app_icon.dart
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final File source = File('assets/icons/icon.png');
  final bytes = source.readAsBytesSync();

  final img.Image? src = img.decodeImage(bytes);
  if (src == null) {
    stderr.writeln('No se pudo decodificar assets/icons/icon.png');
    exit(1);
  }
  stdout.writeln('Origen decodificado: ${src.width}x${src.height}');

  // 1) Ícono a sangre 1024x1024.
  final img.Image icon = img.copyResize(
    src,
    width: 1024,
    height: 1024,
    interpolation: img.Interpolation.cubic,
  );
  File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(icon));

  // 2) Foreground con padding: logo al ~62% centrado sobre lienzo transparente.
  const int canvas = 1024;
  const int logoSize = 640;
  const int offset = (canvas - logoSize) ~/ 2;

  final img.Image foreground = img.Image(
    width: canvas,
    height: canvas,
    numChannels: 4,
  );
  img.fill(foreground, color: img.ColorRgba8(0, 0, 0, 0));

  final img.Image logo = img.copyResize(
    src,
    width: logoSize,
    height: logoSize,
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(foreground, logo, dstX: offset, dstY: offset);
  File(
    'assets/icons/app_icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(foreground));

  // 3) Favicon web 32x32.
  final img.Image favicon = img.copyResize(
    src,
    width: 32,
    height: 32,
    interpolation: img.Interpolation.average,
  );
  File('web/favicon.png').writeAsBytesSync(img.encodePng(favicon));

  stdout.writeln(
    'OK → app_icon.png (1024) + app_icon_foreground.png (logo $logoSize) + favicon.png (32)',
  );
}
