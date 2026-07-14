import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Componente único para renderizar imágenes:
///
/// - Raster local (`png/jpg/jpeg/webp`) → `Image.asset`.
/// - Raster network → `CachedNetworkImage` (con cache).
/// - SVG local → `SvgPicture.asset`.
/// - SVG network → `SvgPicture.network`.
///
/// El tipo se decide a partir de [source]: es network si inicia con
/// `http(s)://` y es SVG si termina en `.svg` (case-insensitive).
class AppImage extends StatelessWidget {
  const AppImage(
    this.source, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeOutDuration = const Duration(milliseconds: 200),
  });

  /// Ruta local (usar constantes de `AppImages`/`AppIcons`) o URL.
  final String source;

  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  /// Aplica a SVG (via `ColorFilter`), no a raster.
  final Color? color;

  final Widget? placeholder;
  final Widget? errorWidget;

  /// Solo aplican para raster network.
  final Duration fadeInDuration;
  final Duration fadeOutDuration;

  bool get _isNetwork =>
      source.startsWith('http://') || source.startsWith('https://');

  bool get _isSvg => source.toLowerCase().endsWith('.svg');

  Widget get _defaultPlaceholder => const Center(
    child: SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  Widget get _defaultError => const Icon(Icons.broken_image_outlined);

  @override
  Widget build(BuildContext context) {
    final ColorFilter? colorFilter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null;

    if (_isSvg) {
      return _isNetwork
          ? SvgPicture.network(
              source,
              width: width,
              height: height,
              fit: fit,
              alignment: alignment,
              colorFilter: colorFilter,
              placeholderBuilder: (_) => placeholder ?? _defaultPlaceholder,
            )
          : SvgPicture.asset(
              source,
              width: width,
              height: height,
              fit: fit,
              alignment: alignment,
              colorFilter: colorFilter,
            );
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        fadeInDuration: fadeInDuration,
        fadeOutDuration: fadeOutDuration,
        placeholder: (_, _) => placeholder ?? _defaultPlaceholder,
        errorWidget: (_, _, _) => errorWidget ?? _defaultError,
      );
    }

    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, _, _) => errorWidget ?? _defaultError,
    );
  }
}
