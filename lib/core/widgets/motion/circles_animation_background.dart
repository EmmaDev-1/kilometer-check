import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Fondo animado de dos círculos con "glow" que se desplazan suavemente
/// detrás del [child], creando un halo vivo.
///
/// Adaptado de un componente que dependía del paquete `sizer` (`.w`/`.h`):
/// aquí los tamaños y rangos se expresan en píxeles lógicos —autocontenido,
/// sin acoplarse al tamaño de la pantalla— y los colores usan la familia de
/// la app (por defecto azul + amarillo de iTire).
///
/// Mejora respecto al original: usa [AnimatedBuilder] en lugar de `setState`
/// dentro de un listener, evitando reconstruir todo el árbol en cada frame.
class CirclesAnimationBackground extends StatefulWidget {
  const CirclesAnimationBackground({
    super.key,
    required this.child,
    this.color1 = AppColors.blueLight,
    this.color2 = AppColors.yellow,
    this.circle1OffsetXRange = 70,
    this.circle1OffsetYRange = 6,
    this.circle2OffsetXRange = 70,
    this.circle2OffsetYRange = 6,
    this.circleDiameter = 22,
    this.blurRadius = 34,
    this.spreadRadius = 18,
    this.duration = const Duration(seconds: 8),
  });

  /// Contenido que se dibuja por encima de los círculos.
  final Widget child;

  /// Colores de cada círculo (glow).
  final Color color1;
  final Color color2;

  /// Rango de desplazamiento en píxeles de cada círculo (ejes X e Y).
  final double circle1OffsetXRange;
  final double circle1OffsetYRange;
  final double circle2OffsetXRange;
  final double circle2OffsetYRange;

  /// Diámetro base de los círculos (el glow real crece con blur/spread).
  final double circleDiameter;
  final double blurRadius;
  final double spreadRadius;

  /// Duración de un ciclo completo del movimiento.
  final Duration duration;

  @override
  State<CirclesAnimationBackground> createState() =>
      _CirclesAnimationBackgroundState();
}

class _CirclesAnimationBackgroundState extends State<CirclesAnimationBackground>
    with SingleTickerProviderStateMixin {
  // Órbita continua (sin `reverse`): como el movimiento usa sin/cos, el
  // ciclo empalma perfecto en cada vuelta y no hay rebote → animación fluida.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _glow(Color color, double dx, double dy) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Container(
        width: widget.circleDiameter,
        height: widget.circleDiameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: widget.blurRadius,
              spreadRadius: widget.spreadRadius,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // El child (contenido en primer plano) no depende de la animación,
      // así que se construye una sola vez y se reutiliza en cada frame.
      child: widget.child,
      builder: (context, child) {
        final double angle = 2 * math.pi * _controller.value;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            _glow(
              widget.color1,
              widget.circle1OffsetXRange * math.sin(angle),
              widget.circle1OffsetYRange * math.cos(angle),
            ),
            _glow(
              widget.color2,
              // Desfase de 1 rad → los círculos no se mueven al unísono.
              widget.circle2OffsetXRange * math.sin(angle + 1),
              widget.circle2OffsetYRange * math.cos(angle + 1),
            ),
            child!,
          ],
        );
      },
    );
  }
}
