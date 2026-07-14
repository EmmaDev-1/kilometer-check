import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../motion/circles_animation_background.dart';
import '../spacing/spacing_tokens.dart';

/// Botón "hero" con fondo animado de círculos con glow
/// ([CirclesAnimationBackground]).
///
/// Es un botón oscuro tipo píldora sobre un halo azul + amarillo (familia
/// iTire) que se mueve suavemente. Conserva las buenas prácticas del resto
/// de botones de la app:
/// - [isLoading] muestra un spinner y **bloquea el doble tap**.
/// - Micro-animación de escala al presionar.
///
/// El componente **no recorta** los círculos: reserva alto suficiente
/// ([height]) para que el glow se muestre completo en cualquier punto de la
/// animación sin invadir el contenido vecino.
///
/// Pensado para el CTA principal (p. ej. "Consultar kilometraje").
class AnimatedBackgroundButton extends StatefulWidget {
  const AnimatedBackgroundButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.isLoading = false,
    this.animated = true,
    this.height = 160,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isLoading;

  /// Si es `false`, muestra la píldora sin el fondo animado de círculos
  /// (mismo estilo, sin la animación). Útil para mover el efecto a otro
  /// componente sin perder el aspecto del botón.
  final bool animated;

  /// Alto total reservado cuando [animated] es `true`. Debe ser mayor que el
  /// botón para que el halo quepa completo (sin recorte) por arriba y abajo.
  final double height;

  /// Alto del botón visible (más grueso que un botón estándar).
  static const double _buttonHeight = 64;

  @override
  State<AnimatedBackgroundButton> createState() =>
      _AnimatedBackgroundButtonState();
}

class _AnimatedBackgroundButtonState extends State<AnimatedBackgroundButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  Widget _content() {
    if (widget.isLoading) {
      return const SizedBox(
        key: ValueKey('loader'),
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.6,
          color: AppColors.text100,
        ),
      );
    }

    return Row(
      key: const ValueKey('content'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: Spacing.xs),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text100,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  /// La píldora en sí (borde/relleno tipo badge + estados de carga y
  /// presión), independiente del fondo animado.
  Widget _pill() {
    return AnimatedScale(
      scale: _pressed && _enabled ? 0.97 : 1,
      duration: AppMotion.fast,
      curve: AppMotion.easeOut,
      child: Listener(
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: SizedBox(
          width: double.infinity,
          height: AnimatedBackgroundButton._buttonHeight,
          child: FilledButton(
            onPressed: _enabled ? widget.onPressed : null,
            style:
                FilledButton.styleFrom(
                  // Mismo diseño que el badge "Primera lectura registrada":
                  // relleno azul translúcido + borde azul.
                  backgroundColor: AppColors.blue.withValues(alpha: 0.15),
                  disabledBackgroundColor: AppColors.blue.withValues(
                    alpha: 0.15,
                  ),
                  foregroundColor: AppColors.text100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  side: BorderSide(
                    color: AppColors.blueLight.withValues(alpha: 0.45),
                  ),
                ).copyWith(
                  // Sin sombra propia: el glow del fondo hace ese trabajo.
                  elevation: const WidgetStatePropertyAll(0),
                ),
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: AppMotion.easeInOut,
              switchOutCurve: AppMotion.easeInOut,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: _content(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sin animación: solo la píldora, a lo ancho, con su alto normal.
    if (!widget.animated) return _pill();

    // Con animación: se reserva alto suficiente para que el halo quepa
    // completo (sin recorte) sin desbordar hacia los vecinos.
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: CirclesAnimationBackground(
        color1: AppColors.blueLight,
        color2: AppColors.yellow,
        // Recorrido en elipse: los círculos orbitan y asoman completos por
        // arriba, abajo y los costados del botón (nunca se recortan).
        circle1OffsetXRange: 80,
        circle1OffsetYRange: 20,
        circle2OffsetXRange: 80,
        circle2OffsetYRange: 20,
        circleDiameter: 34,
        blurRadius: 34,
        spreadRadius: 16,
        duration: const Duration(seconds: 10),
        child: Padding(
          // Margen horizontal para que el glow asome por los lados.
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
          child: _pill(),
        ),
      ),
    );
  }
}
