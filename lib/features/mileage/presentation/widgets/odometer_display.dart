import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';

/// Métrica hero de la pantalla: el kilometraje actual.
///
/// - Sin datos: guiones tenues (pulsantes durante la carga inicial).
/// - Con datos: contador que "rueda" desde el valor mostrado hasta el
///   nuevo ([AppMotion.odometer]) y un halo azul que pulsa al actualizar.
class OdometerDisplay extends StatefulWidget {
  const OdometerDisplay({
    super.key,
    required this.kilometers,
    required this.isLoading,
  });

  /// Kilometraje a mostrar; `null` si aún no hay lecturas.
  final int? kilometers;
  final bool isLoading;

  @override
  State<OdometerDisplay> createState() => _OdometerDisplayState();
}

class _OdometerDisplayState extends State<OdometerDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didUpdateWidget(OdometerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool valueArrived =
        widget.kilometers != null && widget.kilometers != oldWidget.kilometers;
    if (valueArrived) _glowController.forward(from: 0);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          'KILOMETRAJE ACTUAL',
          style: AppTextStyles.caption(context).copyWith(
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: AppColors.text500,
          ),
        ),
        Gap.vMd(),
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            // Intensidad del halo: sube y baja (0 → 1 → 0).
            final double intensity = math.sin(math.pi * _glowController.value);
            return Stack(
              alignment: Alignment.center,
              // Permite que los círculos sobresalgan por las orillas.
              clipBehavior: Clip.none,
              children: [
                // Círculos con glow ORBITANDO DETRÁS de la tarjeta: la
                // tarjeta sólida tapa el centro y solo asoman por las orillas.
                const Positioned.fill(
                  child: CirclesAnimationBackground(
                    circle1OffsetXRange: 150,
                    circle1OffsetYRange: 14,
                    circle2OffsetXRange: 150,
                    circle2OffsetYRange: 14,
                    circleDiameter: 40,
                    blurRadius: 40,
                    spreadRadius: 18,
                    duration: Duration(seconds: 12),
                    child: SizedBox.expand(),
                  ),
                ),
                // Tarjeta sólida por encima del glow.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.xl,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bg900,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Color.lerp(
                        AppColors.bg800,
                        AppColors.blueLight,
                        intensity * 0.8,
                      )!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue.withValues(
                          alpha: 0.35 * intensity,
                        ),
                        blurRadius: 48 * intensity,
                        spreadRadius: 2 * intensity,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ],
            );
          },
          child: AnimatedSwitcher(
            duration: AppMotion.base,
            switchInCurve: AppMotion.easeOut,
            child: widget.kilometers == null
                ? _PlaceholderDashes(
                    key: const ValueKey('placeholder'),
                    pulsing: widget.isLoading,
                  )
                : _RollingCounter(
                    key: const ValueKey('counter'),
                    value: widget.kilometers!,
                  ),
          ),
        ),
      ],
    );
  }
}

/// Contador que anima el valor mostrado hacia el nuevo valor.
class _RollingCounter extends StatelessWidget {
  const _RollingCounter({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // Al cambiar `end`, anima desde el valor actualmente mostrado.
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: AppMotion.odometer,
      curve: AppMotion.easeOut,
      builder: (context, animatedValue, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                NumberFormatter.thousands(animatedValue.round()),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text100,
                  letterSpacing: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              'km',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.text500,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Guiones de espera; pulsan suavemente durante la carga inicial.
class _PlaceholderDashes extends StatefulWidget {
  const _PlaceholderDashes({super.key, required this.pulsing});

  final bool pulsing;

  @override
  State<_PlaceholderDashes> createState() => _PlaceholderDashesState();
}

class _PlaceholderDashesState extends State<_PlaceholderDashes>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(_PlaceholderDashes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulsing != widget.pulsing) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.pulsing) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.9, end: 0.35).animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.easeInOut),
      ),
      child: Text(
        '– – – – – –',
        textAlign: TextAlign.center,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.bg700,
        ),
      ),
    );
  }
}
