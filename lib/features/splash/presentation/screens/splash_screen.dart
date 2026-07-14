import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/widgets.dart';
import '../widgets/tire_ring_painter.dart';

/// Splash de entrada: dibuja la llanta iTire por fases y revela el
/// wordmark antes de navegar a la pantalla principal.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _totalDuration = Duration(milliseconds: 1700);
  static const Duration _exitDelay = Duration(milliseconds: 450);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _totalDuration,
  );

  Timer? _exitTimer;

  late final Animation<double> _ring = _interval(0.00, 0.55);
  late final Animation<double> _treads = _interval(0.30, 0.72);
  late final Animation<double> _hub = _interval(0.42, 0.78);
  late final Animation<double> _accent = _interval(0.58, 0.92);
  late final Animation<double> _wordmark = _interval(0.62, 1.00);
  late final Animation<double> _caption = _interval(0.78, 1.00);

  Animation<double> _interval(double begin, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(begin, end, curve: AppMotion.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller
      ..addStatusListener(_onAnimationStatus)
      ..forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _exitTimer = Timer(_exitDelay, () {
      if (mounted) context.go(AppRoutes.homePath);
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg950,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size.square(150),
                  painter: TireRingPainter(
                    ringProgress: _ring.value,
                    treadProgress: _treads.value,
                    hubProgress: _hub.value,
                    accentProgress: _accent.value,
                  ),
                ),
                Gap.vXl(),
                _fadeSlide(
                  progress: _wordmark.value,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.redHatDisplay(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text100,
                      ),
                      children: const [
                        TextSpan(
                          text: 'i',
                          style: TextStyle(color: AppColors.yellow),
                        ),
                        TextSpan(text: 'Tire'),
                      ],
                    ),
                  ),
                ),
                Gap.vXs(),
                _fadeSlide(
                  progress: _caption.value,
                  child: AppText(
                    'KILOMETER CHECK',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      letterSpacing: 4,
                      color: AppColors.text500,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _fadeSlide({required double progress, required Widget child}) {
    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, 14 * (1 - progress)),
        child: child,
      ),
    );
  }
}
